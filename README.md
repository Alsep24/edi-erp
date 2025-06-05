# edi-ERP

edi-ERP is a modular ERP (Enterprise Resource Planning) system.  The
repository contains a NestJS backend, a Quasar/Vue frontend and a set of
PostgreSQL initialization scripts.  It is intended as a starting point for a
small business ERP solution.

## Using Docker

The easiest way to run the entire stack is via `docker-compose` which will
start PostgreSQL, the backend API and the frontend application.

```bash
docker-compose up --build
```

This command builds the containers and starts them on their default ports
(`5432` for PostgreSQL, `3000` for the API and `8080` for the frontend).

## Manual development

### Backend

1. `cd backend`
2. Copy `.env.example` to `.env` and adjust values if required
3. Install dependencies with `yarn` or `npm install`
4. Run the development server:

   ```bash
   yarn start:dev
   # or
   npm run start:dev
   ```

### Frontend

The frontend has its own README with detailed commands.  In short:

1. `cd frontend/edi-frontend`
2. Install dependencies with `yarn` or `npm install`
3. Start the dev server using `quasar dev`

For more information see
[`frontend/edi-frontend/README.md`](frontend/edi-frontend/README.md).

## Documentation

The `docs/` directory contains placeholder files for architecture, database and
implementation topics.  They are currently stubs and will be expanded as the
project evolves.
