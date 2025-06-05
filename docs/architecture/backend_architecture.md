# Backend Architecture

The backend is built with [NestJS](https://nestjs.com/) and TypeScript. It follows a modular design so each business area can live in its own module.

## Main folders
- `src/` – application source code
  - `config/` – environment and database configuration
  - `database/` – TypeORM setup and utilities
  - `modules/` – feature modules (e.g. `core`)
  - `auth/` – authentication helpers
  - `common/` – shared DTOs and utilities
- `test/` – unit and e2e tests

Run `npm run test` inside `backend/` to execute the Jest unit tests.

The entry point is `main.ts` and `app.module.ts` brings the modules together. `docker-compose.yml` runs the service as `backend` and connects to the PostgreSQL container.
