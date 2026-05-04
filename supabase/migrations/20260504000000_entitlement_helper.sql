create or replace function public.glu_gold_entitlement_id()
returns text
language sql
immutable
as $$
  select 'Glu Gold'
$$;

create table if not exists public.entitlements_catalog (
  id text primary key,
  description text not null
);

insert into public.entitlements_catalog (id, description)
values ('Glu Gold', 'Premium tier - unlimited meal analysis')
on conflict (id) do nothing;

insert into public.entitlements_catalog (id, description)
select distinct entitlement_id, 'Legacy RevenueCat entitlement'
from public.revenuecat_entitlements
where entitlement_id is not null
on conflict (id) do nothing;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'revenuecat_entitlements_entitlement_id_fk'
  ) then
    alter table public.revenuecat_entitlements
      add constraint revenuecat_entitlements_entitlement_id_fk
      foreign key (entitlement_id) references public.entitlements_catalog (id);
  end if;
end $$;

create or replace function public.has_glu_gold_server(p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.revenuecat_entitlements e
    where e.user_id = p_user_id
      and e.entitlement_id = public.glu_gold_entitlement_id()
      and e.is_active
      and (e.expires_at is null or e.expires_at > now())
  )
$$;
