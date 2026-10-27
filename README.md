# Events List Calendar

A Discourse theme component that shows an events calendar, or an upcoming events sidebar, on pages created with [Discourse Custom Topic Lists](https://meta.discourse.org/t/discourse-custom-topic-lists/311186).

The Discourse Calendar category calendar needs a category ID. Custom list pages (`/lists/<slug>`) have none, so this component mounts the calendar itself and fetches events through the calendar plugin's events API.

## Requirements

- The calendar plugin with post events enabled (`discourse_post_event_enabled`).
- Custom Topic Lists, which creates the `/lists/<slug>` pages.
- The component imports the plugin's `full-calendar` component, event formatter and events service. It expects the plugin's module path to be `discourse/plugins/discourse-events/...`. If your install registers the plugin under another name, such as `discourse-calendar`, update the three imports in `javascripts/discourse/components/`.

## Settings

`list_pages` has one row per list page:

| Field                   | Description                                                                                                                                                |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| List slug               | The slug as set in Custom Topic Lists, for example `events` for `/lists/events`. Matched exactly, ignoring case.                                           |
| Layout                  | `calendar` shows the full calendar above the topic list. `sidebar` shows an upcoming events list to the right of the topic list (desktop only).            |
| Show new button         | Optional. Adds a New Topic button to the list's navigation bar that opens a blank composer, so the author chooses the category and tags.                   |
| New button label        | Optional text for that button, for example `New Event`. The composer's buttons follow it, so `New Event` becomes `Create Event`. Empty means New Topic.    |
| New button type         | `topic` opens a plain composer. `event` also inserts an event block starting at the next full hour.                                                        |
| Only topics with events | Optional. Hides topics in the list that have no event object, such as archive posts. They are hidden in the browser, so the list still pages through them. |
| Hide topic list         | Optional. Hides the standard topic list on that page.                                                                                                      |

Lists themselves, including which topics they show, are managed in Custom Topic Lists. This component does not change a list's query, and the calendar and sidebar always show all events.

## How it works

- The calendar reuses the plugin's own FullCalendar wrapper, so the views (day, week, month, year), styling and event colors match the category calendar.
- The sidebar is a small list that reuses the plugin's `upcoming-events-list` CSS classes. It is built here instead of importing the plugin's block.
- Both render in the `discovery-list-container-top` outlet and only appear when the current URL matches a `list_pages` row.

## Tests

`test/unit/lib/list-page-test.js` covers slug matching and the layout helpers. It runs as part of the theme's QUnit suite on a development Discourse. QUnit cannot run on production-mode sites.

## License

MIT. See [LICENSE](LICENSE).
