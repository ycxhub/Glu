-- Staff roles (admin / developer). Writable only via service role / SQL editor — no client writes.

create table if not exists public.user_staff_roles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  role text not null check (role in ('admin', 'developer')),
  created_at timestamptz not null default now()
);

alter table public.user_staff_roles enable row level security;

-- Authenticated users can read their own row only.
create policy "user_staff_roles_select_own"
  on public.user_staff_roles for select
  to authenticated
  using (auth.uid() = user_id);

-- No insert/update/delete for authenticated clients (assign roles in dashboard SQL only).

grant select on public.user_staff_roles to authenticated;
