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
