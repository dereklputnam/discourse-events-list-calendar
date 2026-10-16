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

// Removes events in the row's excluded categories and their subcategories.
// `categories` is the site's category list.
export function excludeEvents(events, page, categories) {
  const excluded = new Set(
    (page?.exclude_categories || []).map(Number).filter(Boolean)
  );
  if (!excluded.size) {
    return events;
  }

  const parentOf = new Map(categories.map((c) => [c.id, c.parent_category_id]));
  const isExcluded = (id) => {
    for (let c = id; c; c = parentOf.get(c)) {
      if (excluded.has(c)) {
        return true;
      }
    }
    return false;
  };

  return events.filter(
    (e) => !isExcluded(Number(e.categoryId ?? e.category_id))
  );
}
