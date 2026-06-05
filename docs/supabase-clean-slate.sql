-- Sembl destructive Supabase clean slate script.
--
-- Run this in the Supabase SQL editor only when you are ready to remove the
-- current Sembl application schema and Supabase CLI migration history.
--
-- What this does:
-- - drops every object in the public schema, including Sembl tables, views,
--   functions, triggers, policies, and custom types
-- - recreates the public schema with standard Supabase grants
-- - clears Supabase CLI migration tracking
--
-- What this does not do:
-- - delete auth users
-- - delete storage buckets/files
-- - delete project settings, API keys, auth providers, or Edge Functions

begin;

drop schema if exists public cascade;
create schema public;

grant usage on schema public to postgres, anon, authenticated, service_role;
grant all on schema public to postgres;
grant all on schema public to service_role;

alter default privileges in schema public grant all on tables to postgres;
alter default privileges in schema public grant all on sequences to postgres;
alter default privileges in schema public grant all on functions to postgres;

alter default privileges in schema public grant select, insert, update, delete on tables to anon;
alter default privileges in schema public grant usage, select on sequences to anon;
alter default privileges in schema public grant execute on functions to anon;

alter default privileges in schema public grant select, insert, update, delete on tables to authenticated;
alter default privileges in schema public grant usage, select on sequences to authenticated;
alter default privileges in schema public grant execute on functions to authenticated;

alter default privileges in schema public grant all on tables to service_role;
alter default privileges in schema public grant all on sequences to service_role;
alter default privileges in schema public grant all on functions to service_role;

do $$
begin
  if to_regclass('supabase_migrations.schema_migrations') is not null then
    truncate table supabase_migrations.schema_migrations;
  end if;
end $$;

commit;

-- Optional auth cleanup:
-- If you created disposable test users and want to remove them, delete them
-- manually from Authentication > Users in the Supabase dashboard.
