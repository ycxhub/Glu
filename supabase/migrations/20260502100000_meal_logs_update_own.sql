-- Allow authenticated users to UPDATE their own meal_logs rows (e.g. edited Meal Estimate output).
-- Mirrors select/insert/delete: same ownership check.

create policy "meal_logs_update_own"
  on public.meal_logs for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
