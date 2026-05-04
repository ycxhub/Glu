alter table public.revenuecat_entitlements
  add column if not exists will_renew boolean not null default true;

create unique index if not exists revenuecat_entitlements_last_event_id_uidx
  on public.revenuecat_entitlements (last_event_id)
  where last_event_id is not null;
