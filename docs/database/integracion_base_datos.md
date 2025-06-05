# Database Integration

The project uses PostgreSQL. The `database` service defined in `docker-compose.yml` builds from `docker/database/Dockerfile`.

## Initialization scripts
SQL files inside `database/init/` are executed when the container starts:
- `01-init.sql` – general schemas and extensions
- `02-accounting.sql` – accounting tables
- `03-finance.sql` – finance tables
- `04-sales.sql` – sales tables
- `05-purchases.sql` – purchase tables
- `06-inventory.sql` – inventory tables
- `07-payroll.sql` – payroll tables

## Folder structure
- `database/` – database setup and initialization files
- `docker/database/Dockerfile` – custom Postgres image that copies the scripts
