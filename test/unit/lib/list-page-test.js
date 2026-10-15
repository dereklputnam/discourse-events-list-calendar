import { module, test } from "qunit";
import {
  findListPage,
  pageTags,
  showsCalendar,
  showsSidebar,
} from "../../../javascripts/discourse/lib/list-page";

module("Unit | Lib | list-page", function () {
  const pages = [
    { slug: "events", layout: "sidebar" },
    { slug: "Endpoint-Protector", layout: "calendar", tags: ["ep"] },
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

  test("pageTags returns an array of tag names", function (assert) {
    assert.deepEqual(pageTags({ tags: ["a", "b"] }), ["a", "b"]);
    assert.deepEqual(pageTags({ tags: "a|b" }), ["a", "b"]);
    assert.deepEqual(pageTags({}), []);
    assert.deepEqual(pageTags(undefined), []);
  });
});
