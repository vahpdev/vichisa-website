# vichisa.com

Private wedding website for **Isabel y Vicente** — 9 July 2027, Vigo.

The site is invite-only: only email addresses registered in the guest list can
sign in. Guests confirm attendance, dietary needs, drinks and song requests
through the site, and the couple manages every response from a private admin
panel. The site is in Spanish.

## Pages

| Route      | Content                                       |
| ---------- | --------------------------------------------- |
| `/`        | Home — save-the-date, countdown, hashtag      |
| `/boda`    | Ceremony, celebration, timeline and maps      |
| `/rsvp`    | Attendance confirmation                       |
| `/viaje`   | Airports, trains, hotels and the special rate |
| `/belleza` | Hair and makeup                               |
| `/vigo`    | Plans, beaches and restaurants                |
| `/regalo`  | Gift details                                  |
| `/login`   | Email + 6-digit code                          |
| `/admin`   | Private panel for the couple                  |

## Stack

Astro 5 on Cloudflare Workers (SSR), D1 for data, Resend for email, Turnstile
on login. Spanish only, no analytics.

## Repository

- `reference/` — original design prototype
- `assets/` — logos and save-the-date
- `src/` — Astro application
