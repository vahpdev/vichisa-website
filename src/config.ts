/**
 * Single source of truth for wedding constants and the route map.
 * Placeholders (phones, IBAN) stay as in the prototype until the couple
 * supplies final values.
 */

/** Wedding date/time, Europe/Madrid. Ceremony starts at 17:00. */
export const WEDDING = "2027-07-09T17:00:00+02:00";

/** RSVPs close at the end of this day, Europe/Madrid. */
export const RSVP_DEADLINE = "2027-05-15T23:59:59+02:00";

/** Couple WhatsApp, country code, no "+" (used for wa.me links). */
export const WHATSAPP = "34654961767";

export const CONTACT_EMAIL = "boda@vichisa.com";
export const PHONE_ISABEL = "+34 654 96 17 67";
export const PHONE_VICENTE = "+34 654 20 41 80";
export const HASHTAG = "#LaVichisa";

/** Placeholder until the couple supplies the real account number. */
export const IBAN = "ES00 0000 0000 0000 0000 0000";

/** Returns a `tel:` URI for a phone number, stripping spaces and non-digits. */
export function telUri(phone: string): string {
  return `tel:${phone.replace(/\D/g, "")}`;
}

/** Palette keys; each maps to a `:root[data-page="…"]` block in tokens.css. */
export type PageId = "inicio" | "boda" | "rsvp" | "viaje" | "belleza" | "vigo" | "regalo";

export interface RouteInfo {
  id: PageId;
  path: string;
  /** Short label used in the menu. */
  label: string;
  /** Full title used in the pager and headings. */
  title: string;
}

export const ROUTES: readonly RouteInfo[] = [
  { id: "inicio", path: "/", label: "Inicio", title: "Inicio" },
  { id: "boda", path: "/boda", label: "La boda", title: "La boda" },
  { id: "rsvp", path: "/rsvp", label: "Confirmar", title: "Confirmar asistencia" },
  { id: "viaje", path: "/viaje", label: "Viaje y alojamiento", title: "Viaje y alojamiento" },
  {
    id: "belleza",
    path: "/belleza",
    label: "Peluquería y maquillaje",
    title: "Peluquería y maquillaje",
  },
  { id: "vigo", path: "/vigo", label: "Descubre Vigo", title: "Descubre Vigo" },
  { id: "regalo", path: "/regalo", label: "Regalo", title: "Regalo" },
];

/** Normalizes a URL path so "/" and "/boda/" compare equal to their route. */
export function normalizePath(pathname: string): string {
  if (pathname.length > 1 && pathname.endsWith("/")) return pathname.slice(0, -1);
  return pathname;
}

export function routeForPath(pathname: string): RouteInfo | undefined {
  const clean = normalizePath(pathname);
  return ROUTES.find((r) => r.path === clean);
}
