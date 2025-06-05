# Frontend Architecture

The frontend lives in `frontend/edi-frontend` and uses the Quasar framework on top of Vue 3.

## Key folders
- `src/` – Vue components, pages and layouts
- `public/` – static assets and `index.html`
- `quasar.config.ts` – Quasar configuration
- `package.json` – scripts and dependencies

The `frontend` service in `docker-compose.yml` serves the production build. During development the Quasar CLI watches the `src/` directory for changes.
