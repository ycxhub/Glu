-- Glu AI core schema (prd-glu-ai/architecture.md)
-- RLS: users only touch their own rows.

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- Profiles (1:1 with auth.users)
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles_insert_own"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- ---------------------------------------------------------------------------
-- Meal logs (JSON matches MealAIOutput from Edge / app)
-- ---------------------------------------------------------------------------
create table if not exists public.meal_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  output jsonb not null,
  image_storage_path text
);

create index if not exists meal_logs_user_created_idx
  on public.meal_logs (user_id, created_at desc);

alter table public.meal_logs enable row level security;

create policy "meal_logs_select_own"
  on public.meal_logs for select
  using (auth.uid() = user_id);

create policy "meal_logs_insert_own"
  on public.meal_logs for insert
  with check (auth.uid() = user_id);

create policy "meal_logs_delete_own"
  on public.meal_logs for delete
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- New user → profile row
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.email))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
