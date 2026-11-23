-- Synthetic edge-case fixtures for local development only. Not real guests.

INSERT INTO invitations (id, label, max_seats, active) VALUES
  (1, 'Ana Sola',              1, 1),
  (2, 'Pareja Ejemplo',        2, 1),
  (3, 'Familia Núñez "Los 4"', 4, 1),
  (4, 'Invitación Retirada',   2, 0),   -- removed from the sheet, RSVP must survive
  (5, 'Sin Correo',            2, 1),
  (6, 'Fila Incompleta',       1, 1),
  (7, 'Cancelación',           2, 1);

INSERT INTO invitation_emails (email, invitation_id) VALUES
  ('ana@example.com',    1),
  ('pareja1@example.com', 2),
  ('pareja2@example.com', 2),
  ('nunez@example.com',  3);

INSERT INTO guests (invitation_id, name, is_primary) VALUES
  (1, 'Ana Sola', 1),
  (2, 'Pareja Uno', 1), (2, 'Pareja Dos', 0),
  (3, 'María "Mar" Núñez 🎉', 1), (3, 'Luis Núñez', 0),
  (3, 'Elena Núñez', 0), (3, 'Pablo Núñez', 0),
  (4, 'Retirado Ejemplo', 1),
  (7, 'Cancela Ejemplo', 1);

INSERT INTO rsvps (invitation_id, attending, drinks, song, message) VALUES
  (1, 1, 'Vino tinto', 'Dancing Queen', '¡Con ganas!'),
  (2, 1, 'Agua', NULL, NULL),
  (3, 1, 'Cerveza, vino', 'La bamba', 'Sin prisa'),
  (4, 1, NULL, NULL, NULL),
  (7, 0, NULL, NULL, 'Nos lo perdemos, lo sentimos');

INSERT INTO attendees (invitation_id, name, allergies, intolerances, diet) VALUES
  (1, 'Ana Sola', NULL, NULL, NULL),
  (2, 'Pareja Uno', NULL, NULL, NULL),
  (3, 'María "Mar" Núñez 🎉', 'Frutos secos', 'Lactosa', 'Vegetariana'),
  (3, 'Luis Núñez',            NULL,            NULL,      'Vegana'),
  (3, 'Elena Núñez',           'Marisco',       NULL,      'Sin gluten'),
  (3, 'Pablo Núñez',           NULL,            'Fructosa',NULL),
  (4, 'Retirado Ejemplo', NULL, NULL, NULL);

-- One fresh code and one already expired (PP-13 replaces the row on resend).
INSERT INTO auth_codes (email, code_hmac, expires_at, attempts) VALUES
  ('ana@example.com',    'hmac-fresh-code', strftime('%Y-%m-%dT%H:%M:%fZ','now','+10 minutes'), 0),
  ('pareja1@example.com','hmac-expired',    strftime('%Y-%m-%dT%H:%M:%fZ','now','-1 hour'),      5);

-- Both throttle dimensions: per email and per IP.
INSERT INTO login_throttle (key, window_start, count) VALUES
  ('email:ana@example.com', strftime('%Y-%m-%dT%H:%M:%fZ','now','-30 minutes'), 5),
  ('ip:203.0.113.7',        strftime('%Y-%m-%dT%H:%M:%fZ','now','-30 minutes'), 12);

-- One clean sync and one partial run (errors as JSON).
INSERT INTO sync_log (run_at, rows, invitations, errors) VALUES
  ('2026-11-14T08:00:00.000Z', 198, 124, NULL),
  ('2026-11-15T08:00:00.000Z', 199, 124, '[{"row":42,"error":"email inválido"}]');
