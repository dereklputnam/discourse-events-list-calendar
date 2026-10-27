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

const CATEGORY_PATH_SEPARATOR = ":";

// Finds a category from a filter path such as `products:auditor:news`, a plain
// slug, or an ID. `categories` is the site's category list.
function findCategoryByPath(path, categories) {
  if (/^\d+$/.test(path)) {
    return categories.find((c) => c.id === Number(path));
  }

  const byId = new Map(categories.map((c) => [c.id, c]));
  const pathOf = (category) => {
    const slugs = [];
    for (let c = category; c; c = byId.get(c.parent_category_id)) {
      slugs.unshift(c.slug);
    }
    return slugs.join(CATEGORY_PATH_SEPARATOR);
  };

  return categories.find((c) => pathOf(c) === path);
}

// What a new topic should start with, taken from the list's own filter query.
// Only values that are unambiguous are used: a single positive category, and
// tags the topic must all have. Negated terms and OR lists are ignored, so the
// author still chooses whenever the list allows more than one answer.
export function prefillFromQuery(query, categories = []) {
  const tags = [];
  const categoryPaths = [];

  for (const token of (query || "").split(/\s+/)) {
    const match = /^=?(tag|category):(.+)$/.exec(token);
    if (!match) {
      continue;
    }

    const [, key, value] = match;
    if (key === "category") {
      categoryPaths.push(...value.split(",").filter(Boolean));
    } else if (!value.includes(",")) {
      tags.push(...value.split("+").filter(Boolean));
    }
  }

  const category =
    categoryPaths.length === 1
      ? findCategoryByPath(categoryPaths[0], categories)
      : undefined;

  return { category, tags };
}
