CREATE USER lab_user WITH ENCRYPTED PASSWORD 'lab_pass';

-- PostgreSQL 15+ does not grant CREATE on schema public via database-level GRANT.
-- Owning the database makes lab_user a member of pg_database_owner.
CREATE DATABASE lab_netmicro_payments OWNER lab_user;
CREATE DATABASE lab_netmicro_jobs OWNER lab_user;
CREATE DATABASE lab_netmicro_policy OWNER lab_user;
CREATE DATABASE lab_netmicro_pricing OWNER lab_user;

GRANT ALL PRIVILEGES ON DATABASE lab_netmicro_payments TO lab_user;
GRANT ALL PRIVILEGES ON DATABASE lab_netmicro_jobs TO lab_user;
GRANT ALL PRIVILEGES ON DATABASE lab_netmicro_policy TO lab_user;
GRANT ALL PRIVILEGES ON DATABASE lab_netmicro_pricing TO lab_user;
