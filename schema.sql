-- MySub isolated schema. Run in Supabase SQL Editor.
create schema if not exists mysub;
create table if not exists mysub.admins (user_id uuid primary key references auth.users(id) on delete cascade);
create table if not exists mysub.services (id uuid primary key default gen_random_uuid(), name text not null, created_at timestamptz default now());
create table if not exists mysub.subscriptions (
 id uuid primary key default gen_random_uuid(), customer_id uuid not null references auth.users(id) on delete cascade,
 customer_name text not null, service_id uuid references mysub.services(id), starts_on date not null,
 ends_on date not null, price_iqd numeric(12,0) not null default 0 check(price_iqd>=0),
 status text not null default 'active' check(status in ('active','paused','cancelled')),
 notes text, created_at timestamptz default now(), check(ends_on>=starts_on)
);
create table if not exists mysub.payments (
 id uuid primary key default gen_random_uuid(), subscription_id uuid not null references mysub.subscriptions(id) on delete cascade,
 amount_iqd numeric(12,0) not null check(amount_iqd>=0), paid_at timestamptz not null default now(), note text
);
create or replace function mysub.is_admin() returns boolean language sql stable security definer set search_path = '' as $$
 select exists(select 1 from mysub.admins where user_id=(select auth.uid()));
$$;
revoke all on function mysub.is_admin() from public;
grant usage on schema mysub to authenticated;
grant execute on function mysub.is_admin() to authenticated;
grant select,insert,update,delete on mysub.services,mysub.subscriptions,mysub.payments to authenticated;
grant select on mysub.admins to authenticated;
alter table mysub.admins enable row level security;
alter table mysub.services enable row level security;
alter table mysub.subscriptions enable row level security;
alter table mysub.payments enable row level security;
create policy "admins read self" on mysub.admins for select to authenticated using (user_id=(select auth.uid()));
create policy "services read" on mysub.services for select to authenticated using (true);
create policy "services admin insert" on mysub.services for insert to authenticated with check (mysub.is_admin());
create policy "services admin update" on mysub.services for update to authenticated using (mysub.is_admin()) with check (mysub.is_admin());
create policy "services admin delete" on mysub.services for delete to authenticated using (mysub.is_admin());
create policy "subscriptions read" on mysub.subscriptions for select to authenticated using (customer_id=(select auth.uid()) or mysub.is_admin());
create policy "subscriptions admin insert" on mysub.subscriptions for insert to authenticated with check (mysub.is_admin());
create policy "subscriptions admin update" on mysub.subscriptions for update to authenticated using (mysub.is_admin()) with check (mysub.is_admin());
create policy "subscriptions admin delete" on mysub.subscriptions for delete to authenticated using (mysub.is_admin());
create policy "payments admin read" on mysub.payments for select to authenticated using (mysub.is_admin());
create policy "payments admin insert" on mysub.payments for insert to authenticated with check (mysub.is_admin());
create policy "payments admin update" on mysub.payments for update to authenticated using (mysub.is_admin()) with check (mysub.is_admin());
create policy "payments admin delete" on mysub.payments for delete to authenticated using (mysub.is_admin());
-- IMPORTANT: In Supabase Dashboard > API settings > Exposed schemas, add mysub.
-- Bootstrap first admin MANUALLY in SQL editor, after logging in to create auth user:
-- insert into mysub.admins(user_id) values ('YOUR_AUTH_USER_UUID');
-- Customers must have an existing Supabase Auth user; use the dashboard's Invite user feature.
