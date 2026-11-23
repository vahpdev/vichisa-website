# Database (D1)

The site stores invitations, RSVPs and login state in a single Cloudflare D1
(SQLite) database. The database name is `vichisa-db` and the Worker sees it
through the `DB` binding (`env.DB`).

- Database id: `f5cb10c7-a29c-4fa9-9347-135834911c4e` (in `wrangler.jsonc`)
- Bindings are not secrets: nothing about D1 belongs in `.dev.vars`.
- `--local` and `--remote` are two separate databases. Local data lives in
  `.wrangler/state/v3/d1/` and is disposable; remote is the real database.

## Schema

| Table               | Columns                                                                      | Notes                                                          |
| ------------------- | ---------------------------------------------------------------------------- | -------------------------------------------------------------- |
| `invitations`       | `id`, `label`, `max_seats`, `active`, `updated_at`                           | One row per group. `active = 0` means removed from the sheet.  |
| `invitation_emails` | `email` (PK), `invitation_id`                                                | One email belongs to exactly one invitation.                   |
| `guests`            | `id`, `invitation_id`, `name`, `is_primary`                                  | Guest names derived from the sheet.                            |
| `rsvps`             | `invitation_id` (PK), `attending`, `drinks`, `song`, `message`, `updated_at` | The PK enforces **one RSVP per invitation**. No row = pending. |
| `attendees`         | `id`, `invitation_id`, `name`, `allergies`, `intolerances`, `diet`           | Who actually comes; replaced on every RSVP edit.               |
| `auth_codes`        | `email` (PK), `code_hmac`, `expires_at`, `attempts`                          | One active code per email; single use by deleting the row.     |
| `login_throttle`    | `key` (PK), `window_start`, `count`                                          | `key` is `email:…` or `ip:…`.                                  |
| `sync_log`          | `run_at` (PK), `rows`, `invitations`, `errors`                               | `errors` is `NULL` or a JSON array.                            |

Conventions:

- Timestamps are `TEXT` ISO-8601 in UTC (`2027-02-01T10:00:00.000Z`). Format for
  display, compare as strings, never rely on the server timezone.
- Booleans are `INTEGER` `0`/`1` with `CHECK` constraints.
- Emails are stored trimmed and lowercase; email columns use `COLLATE NOCASE`.
- Foreign keys are always enforced by D1 (no `PRAGMA` needed, and `PRAGMA` is
  not allowed in migrations). Deleting an invitation cascades to its emails,
  guests, RSVP and attendees.
- Every writer sets `updated_at` explicitly.
- Indexes exist for reverse lookups by `invitation_id` and for expiring auth
  codes.

## Migrations

Files live in `migrations/` and are applied in filename order. Never edit or
rename a migration that has run anywhere: D1 records applied filenames in
`d1_migrations` and will not re-run them. Add a new numbered file instead.

```bash
npm run db:list                     # applied/pending, local
npm run db:migrate:local            # apply pending migrations locally
npm run db:migrate:remote           # apply pending migrations to production
npm run db:seed:local               # load fixtures/edge-cases.sql
npm run db:reset:local              # wipe local state, migrate and seed
npm run db:query:local -- "SELECT * FROM invitations"
```

Creating a migration:

```bash
npx wrangler d1 migrations create vichisa-db <name>
```

## Fixtures

`fixtures/edge-cases.sql` is **synthetic data only** — real guests never enter
the repository or the fixtures. It is loaded with `npm run db:seed:local` and
covers:

- 1-seat, 2-seat and 4-seat invitations, including two emails for one group.
- An invitation with no email and no guests (incomplete sheet row).
- An inactive invitation that still has an RSVP (sync deactivation must not
  delete answers).
- An "attending" RSVP with fewer attendees than seats and a "not attending"
  RSVP with zero attendees.
- Accented, quoted and emoji names plus every diet field.
- Fresh and expired auth codes, both throttle keys, a clean and a partial sync.

Expected counts after seeding locally:

| Table               | Rows |
| ------------------- | ---- |
| `invitations`       | 7    |
| `invitation_emails` | 4    |
| `guests`            | 9    |
| `rsvps`             | 5    |
| `attendees`         | 7    |
| `auth_codes`        | 2    |
| `login_throttle`    | 2    |
| `sync_log`          | 2    |

The remote database must stay empty until the sheet sync (PP-12) runs. Do not
seed it.

## Constraints to check by hand

Each of these must fail after seeding locally:

```bash
# One RSVP per invitation -> UNIQUE constraint failed: rsvps.invitation_id
npm run db:query:local -- "INSERT INTO rsvps (invitation_id, attending) VALUES (1, 0)"

# No orphans -> FOREIGN KEY constraint failed
npm run db:query:local -- "INSERT INTO attendees (invitation_id, name) VALUES (999, 'Fantasma')"

# One invitation per email -> UNIQUE constraint failed: invitation_emails.email
npm run db:query:local -- "INSERT INTO invitation_emails (email, invitation_id) VALUES ('ana@example.com', 2)"

# Boolean guard -> CHECK constraint failed
npm run db:query:local -- "INSERT INTO invitations (label, active) VALUES ('Mala', 5)"
```

`npm run db:reset:local` after the checks, so the fixtures are clean again.

## Backups

Export before risky changes and before the wedding:

```bash
npx wrangler d1 export vichisa-db --remote --output backup-vichisa.sql
```

Restore into a scratch database first; restoring over production means running
the exported SQL against the remote DB explicitly. The full backup/restore
runbook belongs to PP-19.

## Next steps (PP-12)

The sync task will add a stable `source_key` column to match sheet rows
idempotently, and it will use this schema as-is. When the app starts reading
`env.DB`, type the binding (for example with `npx wrangler types` or a small
`Env` declaration in `src/env.d.ts`).
