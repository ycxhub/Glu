-- Glu AI: server-side quota ledger, RevenueCat entitlement mirror, meal envelope, onboarding profile.
-- RPCs are SECURITY DEFINER; callers must be authenticated (JWT). Edge uses user JWT forwarded to Postgres.

-- ---------------------------------------------------------------------------
-- RevenueCat server mirror (webhook + optional REST refresh writes here)
-- ---------------------------------------------------------------------------
create table if not exists public.revenuecat_entitlements (
  user_id uuid primary key references auth.users (id) on delete cascade,
  rc_app_user_id text,
  entitlement_id text not null default 'Glu Gold',
  is_active boolean not null default false,
  expires_at timestamptz,
  last_event_id text,
  payload jsonb,
  updated_at timestamptz not null default now()
);

create index if not exists revenuecat_entitlements_active_idx
  on public.revenuecat_entitlements (user_id)
  where is_active = true;

alter table public.revenuecat_entitlements enable row level security;

-- Authenticated users may read their own row (client refresh / diagnostics).
create policy "revenuecat_entitlements_select_own"
  on public.revenuecat_entitlements for select
  to authenticated
  using (auth.uid() = user_id);

-- No client writes; service role / Edge webhook bypasses RLS.

-- ---------------------------------------------------------------------------
-- Two-phase meal analysis attempts (reserve → finalize | release)
-- ---------------------------------------------------------------------------
create table if not exists public.analysis_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  install_id text not null default '',
  idempotency_key text not null,
  status text not null check (status in ('reserved', 'completed', 'failed', 'released')),
  charged boolean not null default false,
  meal_id uuid,
  analysis_state text,
  envelope_snapshot jsonb,
  error_message text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, idempotency_key)
);

create index if not exists analysis_attempts_user_status_idx
  on public.analysis_attempts (user_id, status);

create index if not exists analysis_attempts_user_charged_idx
  on public.analysis_attempts (user_id)
  where charged = true and status = 'completed';

-- Per-install abuse-resistance: count charged completions across all
-- accounts that share an install_id. Empty install_id is excluded so
-- legacy / unidentified clients fall back to per-user quota only.
create index if not exists analysis_attempts_install_charged_idx
  on public.analysis_attempts (install_id)
  where charged = true and status = 'completed' and install_id <> '';

alter table public.analysis_attempts enable row level security;
-- No policies: deny direct client access; use RPCs only.

-- ---------------------------------------------------------------------------
-- Meal logs: optional envelope (immutable AI + user estimate); legacy `output` stays
-- ---------------------------------------------------------------------------
alter table public.meal_logs
  add column if not exists envelope jsonb;

-- ---------------------------------------------------------------------------
-- Onboarding profile (saved answers + schema version)
-- ---------------------------------------------------------------------------
alter table public.profiles
  add column if not exists onboarding_profile jsonb;

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
create or replace function public.is_staff_or_developer(p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.user_staff_roles r
    where r.user_id = p_user_id
      and r.role in ('admin', 'developer')
  );
$$;

create or replace function public.has_glu_gold_server(p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (
      select e.is_active
         and (e.expires_at is null or e.expires_at > now())
      from public.revenuecat_entitlements e
      where e.user_id = p_user_id
        and e.entitlement_id = 'Glu Gold'
      limit 1
    ),
    false
  );
$$;

create or replace function public.count_charged_meal_analyses(p_user_id uuid)
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select count(*)::int
  from public.analysis_attempts a
  where a.user_id = p_user_id
    and a.charged = true
    and a.status = 'completed';
$$;

-- Per-install count across users — defends the 5-free quota against
-- sign-out-and-create-new-account abuse on the same device.
create or replace function public.count_charged_meal_analyses_by_install(p_install_id text)
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select case
    when p_install_id is null or length(trim(p_install_id)) = 0 then 0
    else (
      select count(*)::int
      from public.analysis_attempts a
      where a.install_id = p_install_id
        and a.charged = true
        and a.status = 'completed'
    )
  end;
$$;

-- ---------------------------------------------------------------------------
-- reserve_meal_analysis(idempotency_key, install_id)
-- ---------------------------------------------------------------------------
create or replace function public.reserve_meal_analysis(
  p_idempotency_key text,
  p_install_id text default ''
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_row public.analysis_attempts%rowtype;
  v_charged int;
  v_charged_install int;
  v_quota_count int;
  v_staff boolean;
  v_gold boolean;
  v_attempt_id uuid;
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  if p_idempotency_key is null or length(trim(p_idempotency_key)) < 8 then
    return jsonb_build_object('ok', false, 'error', 'invalid_idempotency_key');
  end if;

  v_staff := public.is_staff_or_developer(uid);
  v_gold := public.has_glu_gold_server(uid);

  select * into v_row
  from public.analysis_attempts a
  where a.user_id = uid and a.idempotency_key = p_idempotency_key
  limit 1;

  if found then
    if v_row.status = 'completed' and v_row.meal_id is not null then
      return jsonb_build_object(
        'ok', true,
        'duplicate', true,
        'attempt_id', v_row.id,
        'meal_id', v_row.meal_id,
        'analysis_state', v_row.analysis_state,
        'charged', v_row.charged
      );
    elsif v_row.status = 'reserved' then
      return jsonb_build_object(
        'ok', true,
        'duplicate', false,
        'attempt_id', v_row.id,
        'status', 'reserved'
      );
    elsif v_row.status in ('released', 'failed')
       or (v_row.status = 'completed' and v_row.meal_id is null) then
      update public.analysis_attempts a
      set
        status = 'reserved',
        meal_id = null,
        charged = false,
        analysis_state = null,
        envelope_snapshot = null,
        error_message = null,
        install_id = coalesce(p_install_id, ''),
        updated_at = now()
      where a.id = v_row.id;
      return jsonb_build_object(
        'ok', true,
        'duplicate', false,
        'attempt_id', v_row.id,
        'status', 're_reserved'
      );
    end if;
  end if;

  v_charged := public.count_charged_meal_analyses(uid);
  v_charged_install := public.count_charged_meal_analyses_by_install(p_install_id);
  -- Quota is the higher of per-account and per-install: blocks both
  -- single-account exhaustion and same-device account-recycling abuse.
  v_quota_count := greatest(v_charged, v_charged_install);

  if not v_staff and not v_gold and v_quota_count >= 5 then
    return jsonb_build_object(
      'ok', false,
      'error', 'quota_exhausted',
      'charged', v_charged,
      'charged_install', v_charged_install
    );
  end if;

  begin
    insert into public.analysis_attempts (user_id, install_id, idempotency_key, status)
    values (uid, coalesce(p_install_id, ''), p_idempotency_key, 'reserved')
    returning id into v_attempt_id;
  exception
    when unique_violation then
      select * into v_row
      from public.analysis_attempts a
      where a.user_id = uid and a.idempotency_key = p_idempotency_key
      limit 1;
      if v_row.status = 'completed' and v_row.meal_id is not null then
        return jsonb_build_object(
          'ok', true,
          'duplicate', true,
          'attempt_id', v_row.id,
          'meal_id', v_row.meal_id,
          'analysis_state', v_row.analysis_state,
          'charged', v_row.charged
        );
      elsif v_row.status = 'reserved' then
        return jsonb_build_object(
          'ok', true,
          'duplicate', false,
          'attempt_id', v_row.id,
          'status', 'reserved'
        );
      end if;
      return jsonb_build_object('ok', false, 'error', 'reserve_race_retry');
  end;

  return jsonb_build_object(
    'ok', true,
    'attempt_id', v_attempt_id,
    'charged_so_far', v_charged,
    'staff', v_staff,
    'gold', v_gold
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- release_meal_analysis(attempt_id, error_message, analysis_state)
-- ---------------------------------------------------------------------------
drop function if exists public.release_meal_analysis(uuid, text);

create or replace function public.release_meal_analysis(
  p_attempt_id uuid,
  p_error_message text default null,
  p_analysis_state text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  n int;
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  update public.analysis_attempts a
  set
    status = 'released',
    error_message = p_error_message,
    analysis_state = coalesce(p_analysis_state, a.analysis_state),
    updated_at = now()
  where a.id = p_attempt_id
    and a.user_id = uid
    and a.status = 'reserved';

  get diagnostics n = row_count;
  if n = 0 then
    return jsonb_build_object('ok', false, 'error', 'not_found_or_not_reserved');
  end if;

  return jsonb_build_object('ok', true);
end;
$$;

-- ---------------------------------------------------------------------------
-- finalize_meal_analysis(attempt_id, envelope, analysis_state, charged_flag)
-- Inserts meal_logs; sets attempt completed; charged only for free non-staff when flag true
-- ---------------------------------------------------------------------------
create or replace function public.finalize_meal_analysis(
  p_attempt_id uuid,
  p_envelope jsonb,
  p_analysis_state text,
  p_should_charge boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_row public.analysis_attempts%rowtype;
  v_staff boolean;
  v_gold boolean;
  v_charged bool;
  v_meal_id uuid;
  v_user_estimate jsonb;
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  select * into v_row
  from public.analysis_attempts a
  where a.id = p_attempt_id and a.user_id = uid
  for update;

  if not found then
    return jsonb_build_object('ok', false, 'error', 'attempt_not_found');
  end if;

  if v_row.status <> 'reserved' then
    return jsonb_build_object('ok', false, 'error', 'invalid_attempt_state', 'status', v_row.status);
  end if;

  v_staff := public.is_staff_or_developer(uid);
  v_gold := public.has_glu_gold_server(uid);

  v_charged := p_should_charge and not v_staff and not v_gold;

  v_user_estimate := p_envelope -> 'user_estimate';
  if v_user_estimate is null then
    -- Hard fail rather than silently storing the entire envelope as
    -- meal_logs.output — downstream readers expect output to be the
    -- estimate shape (items/totals/spike_risk), not the whole envelope.
    return jsonb_build_object(
      'ok', false,
      'error', 'envelope_missing_user_estimate'
    );
  end if;

  insert into public.meal_logs (user_id, output, envelope)
  values (uid, v_user_estimate, p_envelope)
  returning id into v_meal_id;

  update public.analysis_attempts a
  set
    status = 'completed',
    charged = v_charged,
    meal_id = v_meal_id,
    analysis_state = p_analysis_state,
    envelope_snapshot = p_envelope,
    updated_at = now()
  where a.id = p_attempt_id;

  return jsonb_build_object(
    'ok', true,
    'meal_id', v_meal_id,
    'charged', v_charged,
    'analysis_state', p_analysis_state
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- meal_analysis_quota_status(install_id) — remaining charged slots for UI.
-- install_id is optional; when supplied, the per-install ceiling is also
-- considered so the UI reflects device-level exhaustion (matches reserve).
-- ---------------------------------------------------------------------------
create or replace function public.meal_analysis_quota_status(
  p_install_id text default ''
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_charged int;
  v_charged_install int;
  v_quota_count int;
  v_staff boolean;
  v_gold boolean;
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  v_staff := public.is_staff_or_developer(uid);
  v_gold := public.has_glu_gold_server(uid);
  v_charged := public.count_charged_meal_analyses(uid);
  v_charged_install := public.count_charged_meal_analyses_by_install(p_install_id);
  v_quota_count := greatest(v_charged, v_charged_install);

  return jsonb_build_object(
    'ok', true,
    'charged_completed', v_charged,
    'charged_install', v_charged_install,
    'staff', v_staff,
    'gold', v_gold,
    'remaining_free', case
      when v_staff or v_gold then null
      else greatest(0, 5 - v_quota_count)
    end
  );
end;
$$;

grant execute on function public.reserve_meal_analysis(text, text) to authenticated;
grant execute on function public.release_meal_analysis(uuid, text, text) to authenticated;
grant execute on function public.finalize_meal_analysis(uuid, jsonb, text, boolean) to authenticated;
grant execute on function public.meal_analysis_quota_status(text) to authenticated;
