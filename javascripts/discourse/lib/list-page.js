// Custom Topic Lists pages live at /lists/<slug>. Returns the `list_pages` row
// whose slug matches the current URL.
export function findListPage(url, pages = settings.list_pages) {
  const match = /\/lists\/([^/?#]+)/.exec(url || "");
  const slug = match && decodeURIComponent(match[1]).toLowerCase();

  return (pages || []).find(
    (page) => page.slug && page.slug.trim().toLowerCase() === slug
  );
}

export function showsCalendar(page) {
  return page?.layout === "calendar";
}

export function showsSidebar(page) {
  return page?.layout === "sidebar";
}

// The text for the composer's buttons when a new topic is started from a list
// whose button has a label: "New Event" becomes "Create Event".
export function composerLabel(page) {
  if (!page?.new_button) {
    return;
  }

  const noun = (page.new_label || "").trim().replace(/^new\b\s*/i, "");
  return noun ? `Create ${noun}` : undefined;
}

// The category a new topic should default to on this list page, if the row sets
// one. `categories` is the site's category list.
export function newTopicCategory(page, categories = []) {
  const id = Number([].concat(page?.new_category ?? [])[0]);
  return id ? categories.find((c) => c.id === id) : undefined;
}

// Starting text for a new event topic: an event block that begins at the next
// full hour and lasts an hour.
export function eventBody(timezone, now = new Date()) {
  const start = new Date(now);
  start.setHours(start.getHours() + 1, 0, 0, 0);
  const end = new Date(start.getTime() + 60 * 60 * 1000);
  const pad = (n) => String(n).padStart(2, "0");
  const format = (d) =>
    `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;

  return `[event start="${format(start)}" end="${format(end)}" status="public" timezone="${timezone}"]\n[/event]`;
}

// Icon for the new-topic buttons on a list page. Falls back to the pen icon the
// Horizon sidebar button uses. A leading "fa-" prefix is tolerated.
export function newIcon(page) {
  return (
    (page?.new_icon || "").trim().replace(/^fa-/, "") || "far-pen-to-square"
  );
}
