-- Migration number: 0001 	 2026-11-15T21:42:12.127Z
-- PP-11 · Initial schema for vichisa.com
-- D1 is SQLite: foreign keys are always enforced, no PRAGMA statements.
-- Timestamps are TEXT ISO-8601 UTC, e.g. 2027-02-01T10:00:00.000Z.
-- Emails are stored trimmed + lowercase; COLLATE NOCASE guards case drift.

CREATE TABLE invitations (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  label      TEXT    NOT NULL,
  max_seats  INTEGER NOT NULL DEFAULT 1 CHECK (max_seats >= 1),
  active     INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1)),
  updated_at TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE invitation_emails (
  email         TEXT    PRIMARY KEY COLLATE NOCASE,
  invitation_id INTEGER NOT NULL REFERENCES invitations(id) ON DELETE CASCADE
);

CREATE TABLE guests (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  invitation_id INTEGER NOT NULL REFERENCES invitations(id) ON DELETE CASCADE,
  name          TEXT    NOT NULL,
  is_primary    INTEGER NOT NULL DEFAULT 0 CHECK (is_primary IN (0, 1))
);

CREATE TABLE rsvps (
  invitation_id INTEGER PRIMARY KEY REFERENCES invitations(id) ON DELETE CASCADE,
  attending     INTEGER NOT NULL CHECK (attending IN (0, 1)),
  drinks        TEXT,
  song          TEXT,
  message       TEXT,
  updated_at    TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE attendees (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  invitation_id INTEGER NOT NULL REFERENCES invitations(id) ON DELETE CASCADE,
  name          TEXT    NOT NULL,
  allergies     TEXT,
  intolerances  TEXT,
  diet          TEXT
);

CREATE TABLE auth_codes (
  email      TEXT    PRIMARY KEY COLLATE NOCASE,
  code_hmac  TEXT    NOT NULL,
  expires_at TEXT    NOT NULL,
  attempts   INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE login_throttle (
  key          TEXT    PRIMARY KEY,
  window_start TEXT    NOT NULL,
  count        INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE sync_log (
  run_at      TEXT    PRIMARY KEY,
  rows        INTEGER NOT NULL DEFAULT 0,
  invitations INTEGER NOT NULL DEFAULT 0,
  errors      TEXT
);

-- Indexes for the lookups the app actually does.
CREATE INDEX idx_invitation_emails_invitation ON invitation_emails(invitation_id);
CREATE INDEX idx_guests_invitation            ON guests(invitation_id);
CREATE INDEX idx_attendees_invitation         ON attendees(invitation_id);
CREATE INDEX idx_auth_codes_expires           ON auth_codes(expires_at);
