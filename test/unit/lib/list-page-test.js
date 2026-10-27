import { module, test } from "qunit";
import {
  findListPage,
  prefillFromQuery,
  showsCalendar,
  showsSidebar,
} from "../../../discourse/lib/list-page";

module("Unit | Lib | list-page", function () {
  const pages = [
    { slug: "events", layout: "sidebar" },
    { slug: "Endpoint-Protector", layout: "calendar" },
  ];

  test("findListPage matches the slug after /lists/", function (assert) {
    assert.strictEqual(findListPage("/lists/events", pages), pages[0]);
    assert.strictEqual(
      findListPage("/lists/events?order=views", pages),
      pages[0]
    );
    assert.strictEqual(findListPage("/lists/events/", pages), pages[0]);
  });

  test("findListPage ignores case and rows without a slug", function (assert) {
    assert.strictEqual(
      findListPage("/lists/endpoint-protector", pages),
      pages[1]
    );
    assert.strictEqual(
      findListPage("/lists/events", [{ layout: "calendar" }]),
      undefined
    );
  });

  test("findListPage does not match partial slugs or other routes", function (assert) {
    assert.strictEqual(findListPage("/lists/events-archive", pages), undefined);
    assert.strictEqual(findListPage("/latest", pages), undefined);
    assert.strictEqual(findListPage("/c/events/12", pages), undefined);
    assert.strictEqual(findListPage(undefined, pages), undefined);
    assert.strictEqual(findListPage("/lists/events", []), undefined);
  });

  test("layout helpers", function (assert) {
    assert.true(showsCalendar({ layout: "calendar" }));
    assert.false(showsSidebar({ layout: "calendar" }));
    assert.true(showsSidebar({ layout: "sidebar" }));
    assert.false(showsCalendar({ layout: "sidebar" }));
    assert.false(showsCalendar(undefined));
    assert.false(showsSidebar(undefined));
  });

  test("prefillFromQuery uses one positive category and AND tags", function (assert) {
    const categories = [
      { id: 1, slug: "products" },
      { id: 2, slug: "auditor", parent_category_id: 1 },
      { id: 3, slug: "news", parent_category_id: 2 },
    ];

    assert.deepEqual(prefillFromQuery("tag:events", categories), {
      category: undefined,
      tags: ["events"],
    });
    assert.strictEqual(
      prefillFromQuery("category:products:auditor:news", categories).category,
      categories[2]
    );
    assert.strictEqual(
      prefillFromQuery("category:3 tag:a+b", categories).category,
      categories[2]
    );
    assert.deepEqual(prefillFromQuery("tag:a+b", categories).tags, ["a", "b"]);
  });

  test("prefillFromQuery leaves ambiguous or negated terms to the author", function (assert) {
    const categories = [
      { id: 1, slug: "a" },
      { id: 2, slug: "b" },
    ];

    assert.strictEqual(
      prefillFromQuery("category:a,b", categories).category,
      undefined
    );
    assert.deepEqual(prefillFromQuery("tag:a,b", categories).tags, []);
    assert.deepEqual(prefillFromQuery("-tag:x -category:a", categories), {
      category: undefined,
      tags: [],
    });
    assert.deepEqual(prefillFromQuery(undefined), {
      category: undefined,
      tags: [],
    });
  });
});
