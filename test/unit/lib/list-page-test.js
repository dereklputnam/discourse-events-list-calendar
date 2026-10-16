import { module, test } from "qunit";
import {
  excludeEvents,
  findListPage,
  showsCalendar,
  showsSidebar,
} from "../../../javascripts/discourse/lib/list-page";

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

  test("excludeEvents drops excluded categories and their subcategories", function (assert) {
    const categories = [
      { id: 1 },
      { id: 2, parent_category_id: 1 },
      { id: 3, parent_category_id: 2 },
      { id: 4 },
    ];
    const events = [
      { id: "a", categoryId: 1 },
      { id: "b", category_id: 3 },
      { id: "c", categoryId: 4 },
    ];

    assert.deepEqual(
      excludeEvents(events, { exclude_categories: [2] }, categories).map(
        (e) => e.id
      ),
      ["a", "c"]
    );
    assert.deepEqual(
      excludeEvents(events, { exclude_categories: ["1"] }, categories).map(
        (e) => e.id
      ),
      ["c"]
    );
    assert.strictEqual(excludeEvents(events, {}, categories), events);
  });
});
