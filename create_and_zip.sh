#!/usr/bin/env bash
set -e

ROOT_DIR="carx-operator"
rm -rf "$ROOT_DIR"
mkdir -p "$ROOT_DIR"

# helper to write files
write() {
  local path="$ROOT_DIR/$1"
  mkdir -p "$(dirname "$path")"
  cat > "$path"
}

# README.md
write "README.md" <<'EOF'
## carx-operator (Next.js) - Railway deploy guide

Overview
- Next.js app with API routes and a worker for periodic health checks.
- Uses PostgreSQL via `DATABASE_URL`.
- Operator auth via JWT.

Required environment variables on Railway:
- DATABASE_URL — provided by Railway Postgres plugin
- JWT_SECRET — random long secret for signing tokens
- NEXT_PUBLIC_HEALTH_CHECK_INTERVAL — seconds (default `60`)
- WEBHOOK_ACTION_URL — (optional) webhook invoked for start/stop/restart actions
- PORT — (optional) default 3000

Quick local setup
1. Copy files into a directory.
2. Install:
   npm install
3. Create DB and run migrations:
   psql $DATABASE_URL -f migrations/init.sql
4. Create admin:
   npm run init-admin -- --username=admin --password=StrongPass123
5. Run dev:
   npm run dev
6. Start worker locally:
   npm run worker

Railway deploy (copy-paste)
1. Create new Railway project.
2. Add PostgreSQL plugin (Railway will create DATABASE_URL).
3. Connect GitHub repo (or upload ZIP) and deploy.
4. In Railway project settings, add environment variables:
   - JWT_SECRET (generate random)
   - NEXT_PUBLIC_HEALTH_CHECK_INTERVAL (optional, default 60)
   - WEBHOOK_ACTION_URL (optional)
5. Add a new service for worker (type: background) with start command:
   npm run worker
6. Run a one-off migration using Railway's SQL tab or run `psql $DATABASE_URL -f migrations/init.sql`.
7. Initialize admin via Railway Console (one-off):
   npm run init-admin -- --username=admin --password=StrongPass123

API examples
- Login:
  POST /api/auth/login { "username":"admin", "password":"..." } -> { token }
- List services:
  GET /api/services  (Authorization: Bearer <token>)
- Create service:
  POST /api/services { "name","endpoint","description" }

Notes
- Operator actions (start/stop/restart) call WEBHOOK_ACTION_URL with JSON { serviceId, action, user } — implement target action handler on your side.
- To integrate SSH/Docker/K8s actions, replace webhook call with direct orchestrator logic (do not put keys in chat).

Zip helper
Run this to create a zip of current directory: