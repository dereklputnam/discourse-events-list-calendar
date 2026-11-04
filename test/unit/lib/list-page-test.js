import { module, test } from "qunit";
import {
  composerLabel,
  eventBody,
  findListPage,
  newIcon,
  newTopicCategory,
  newTopicTags,
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

  test("composerLabel turns the button label into the composer text", function (assert) {
    const page = (label) => ({ new_button: true, new_label: label });

    assert.strictEqual(composerLabel(page("New Event")), "Create Event");
    assert.strictEqual(composerLabel(page("new webinar")), "Create webinar");
    assert.strictEqual(
      composerLabel(page("  New   Learning Lab ")),
      "Create Learning Lab"
    );
    assert.strictEqual(composerLabel(page("Event")), "Create Event");
  });

  test("composerLabel stays empty without a button or a label", function (assert) {
    assert.strictEqual(composerLabel(undefined), undefined);
    assert.strictEqual(composerLabel({ new_label: "New Event" }), undefined);
    assert.strictEqual(composerLabel({ new_button: true }), undefined);
    assert.strictEqual(
      composerLabel({ new_button: true, new_label: "New" }),
      undefined
    );
  });

  test("newTopicCategory finds the row's category", function (assert) {
    const categories = [{ id: 1 }, { id: 2 }];

    assert.strictEqual(
      newTopicCategory({ new_category: [2] }, categories),
      categories[1]
    );
    assert.strictEqual(
      newTopicCategory({ new_category: 1 }, categories),
      categories[0]
    );
    assert.strictEqual(
      newTopicCategory({ new_category: ["2"] }, categories),
      categories[1]
    );
  });

  test("newTopicCategory is empty without a usable category", function (assert) {
    const categories = [{ id: 1 }];

    assert.strictEqual(newTopicCategory({}, categories), undefined);
    assert.strictEqual(
      newTopicCategory({ new_category: [] }, categories),
      undefined
    );
    assert.strictEqual(
      newTopicCategory({ new_category: [9] }, categories),
      undefined
    );
    assert.strictEqual(newTopicCategory(undefined, categories), undefined);
    assert.strictEqual(newTopicCategory({ new_category: [1] }), undefined);
  });

  test("eventBody starts at the next full hour and lasts an hour", function (assert) {
    assert.strictEqual(
      eventBody("America/New_York", new Date(2026, 10, 5, 13, 20)),
      '[event start="2026-11-05 14:00" end="2026-11-05 15:00" status="public" timezone="America/New_York"]\n[/event]'
    );
  });

  test("eventBody rolls over midnight and month ends", function (assert) {
    assert.strictEqual(
      eventBody("UTC", new Date(2026, 9, 31, 23, 40)),
      '[event start="2026-11-01 00:00" end="2026-11-01 01:00" status="public" timezone="UTC"]\n[/event]'
    );
  });

  test("newIcon uses the row's icon, tolerating a fa- prefix", function (assert) {
    assert.strictEqual(
      newIcon({ new_icon: "far-calendar-plus" }),
      "far-calendar-plus"
    );
    assert.strictEqual(newIcon({ new_icon: " fa-plus " }), "plus");
    assert.strictEqual(newIcon({}), "far-pen-to-square");
    assert.strictEqual(newIcon(undefined), "far-pen-to-square");
  });

  test("newTopicTags returns the row's tags", function (assert) {
    assert.deepEqual(newTopicTags({ new_tags: ["events", "news"] }), [
      "events",
      "news",
    ]);
    assert.deepEqual(newTopicTags({ new_tags: "events" }), ["events"]);
    assert.deepEqual(newTopicTags({}), []);
    assert.deepEqual(newTopicTags(undefined), []);
  });
});
