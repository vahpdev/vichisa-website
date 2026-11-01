# vichisa.com

Private wedding site for **Isabel y Vicente** — 9 July 2027, Vigo.

Only emails registered in the guest sheet can enter. RSVPs are stored in D1 and
managed from `/admin`. Spanish only.

Full plan: [`../vichisa-website-plan.md`](../vichisa-website-plan.md).

## Stack

- Astro 5 + `@astrojs/cloudflare` (SSR) on Cloudflare Workers
- D1 for invitations, guests, RSVPs and auth
- Resend for transactional email
- Turnstile on login
- Vitest + Playwright
- Design ported 1:1 from the prototype in `reference/`

## Routes

| Route      | Access   | Content                                      |
| ---------- | -------- | -------------------------------------------- |
| `/login`   | Public   | Email + 6-digit code, Turnstile              |
| `/`        | Gated    | Inicio — hero, save-the-date, countdown, CTA |
| `/boda`    | Gated    | Ceremonia, pazo, timeline, maps              |
| `/rsvp`    | Gated    | RSVP form                                    |
| `/viaje`   | Gated    | Airports, trains, hotels, special rate       |
| `/belleza` | Gated    | Hair and makeup                              |
| `/vigo`    | Gated    | Plans, beaches, restaurants                  |
| `/regalo`  | Gated    | Gift / IBAN                                  |
| `/admin`   | Couple   | Dashboard, responses, diets, CSV export      |

`/api/auth/*`, `/api/rsvp` and the cron sync live under the Worker.

## Repository layout

```
reference/   Original HTML + Markdown prototype (source of truth for copy/design)
assets/      Logo variants and save-the-date image
src/         Astro app (created in ticket 2)
```

## Decisions

| Decision               | Choice                                                        |
| ---------------------- | ------------------------------------------------------------- |
| Email provider         | **Resend** (free tier, 3k/month)                              |
| Sheet access           | **Published CSV for now**; move to service account later      |
| Invitation grouping    | **TBD** — `Grupo` column is the working default               |
| Guests without email   | Per-invitation link + manual admin entry                      |
| Existing 404 hostname  | Inspect, then replace with the Worker                         |
| Domain                 | **vichisa.com** (the prototype's `lavichisa.com` is wrong)    |
| Admins                 | `vhoyospoyato@gmail.com`, `isabelpazo@gmail.com`              |

## Manual setup checklist (ticket 1)

These require account access and are not automated in the repo.

### Cloudflare

- [ ] Confirm the Workers plan and which product currently serves the 404 on `vichisa.com`
- [ ] Export the current DNS records before any cutover
- [ ] Confirm Email Routing is enabled and MX records point to Cloudflare
- [ ] Create a Turnstile widget for `vichisa.com` (site key + secret)

### Resend

- [ ] Create the Resend account and add `vichisa.com` as a domain
- [ ] Publish the DKIM and SPF records Resend provides
- [ ] Add a DMARC record (`p=none` initially, then tighten)
- [ ] Create an API key and store it as a Worker secret (`RESEND_API_KEY`)

### Email identity

- [ ] Create `boda@vichisa.com` in Email Routing and forward it to both admin inboxes
- [ ] Send a test from `boda@vichisa.com` to Gmail
- [ ] Verify the received headers show **SPF pass, DKIM pass, DMARC pass**

### GitHub / Workers Builds

- [ ] Repo: <https://github.com/vahpdev/vichisa-website>
- [ ] Connect the repo to Cloudflare Workers Builds
- [ ] Confirm a preview deploy runs on push

## Local development

Not scaffolded yet — see ticket 2 (Astro + Cloudflare adapter).
