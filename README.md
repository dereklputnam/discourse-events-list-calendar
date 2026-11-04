# Events List Calendar

A Discourse theme component that shows an events calendar, or an upcoming events sidebar, on pages created with [Discourse Custom Topic Lists](https://meta.discourse.org/t/discourse-custom-topic-lists/311186).

The Discourse Calendar category calendar needs a category ID. Custom list pages (`/lists/<slug>`) have none, so this component mounts the calendar itself and fetches events through the calendar plugin's events API.

## Requirements

- The calendar plugin with post events enabled (`discourse_post_event_enabled`).
- Custom Topic Lists, which creates the `/lists/<slug>` pages.
- The component imports the plugin's `full-calendar` component, event formatter and events service. It expects the plugin's module path to be `discourse/plugins/discourse-events/...`. If your install registers the plugin under another name, such as `discourse-calendar`, update the three imports in `javascripts/discourse/components/`.

## Settings

`list_pages` has one row per list page:

| Field               | Description                                                                                                                                                                                                                                                                                                                                                                                      |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| List slug           | The slug as set in Custom Topic Lists, for example `events` for `/lists/events`. Matched exactly, ignoring case.                                                                                                                                                                                                                                                                                 |
| Layout              | `calendar` shows the full calendar above the topic list. `sidebar` shows an upcoming events list to the right of the topic list (desktop only).                                                                                                                                                                                                                                                  |
| Show new button     | Optional. Adds a New Topic button to the list's navigation bar that opens a blank composer, so the author chooses the category and tags.                                                                                                                                                                                                                                                         |
| New button label    | Optional text for that button, for example `New Event`. The composer's buttons follow it, so `New Event` becomes `Create Event`. Empty means New Topic.                                                                                                                                                                                                                                          |
| New button icon | Optional icon, chosen from a picker with previews. Empty means the pen icon. The button is shown as an icon only on phones. |
| Hide Horizon sidebar button | Horizon only. Hides the sidebar New Topic button on this page. When left visible it shows the same label and icon as the button above the list. |
| New button category | Optional. New topics started on this list page default to this category. It also applies to Horizon's sidebar New Topic button and the `c` shortcut while that page is open.                                                                                                                                                                                                                     |
| Start with an event | Optional. New topics started on this list page open with an event block that starts at the next full hour and lasts an hour. It shows as the event input box in the rich editor and stays if the author changes the category. It works together with **New button category**: in an Events category there is still one event block, though the events plugin uses its own composer labels there. |
| New button type     | `topic` opens a plain composer. `event` also inserts an event block starting at the next full hour.                                                                                                                                                                                                                                                                                              |
| Hide topic list     | Optional. Hides the standard topic list on that page.                                                                                                                                                                                                                                                                                                                                            |

Lists themselves, including which topics they show, are managed in Custom Topic Lists. This component does not change a list's query, and the calendar and sidebar always show all events.

## Showing only topics with events

What a list shows is decided by its query in Custom Topic Lists, and Discourse can now filter by events there (added in [discourse/discourse#45158](https://github.com/discourse/discourse/pull/45158)). Add these to the list's query, for example `tag:events event:any`:

| Query term                                      | Meaning                                                                            |
| ----------------------------------------------- | ---------------------------------------------------------------------------------- |
| `event:any`                                     | Only topics that have an event. Archive posts without one are left out.            |
| `-event:any`                                    | Only topics without an event.                                                      |
| `event:upcoming`, `event:ongoing`, `event:past` | Filter by the event's state. A comma means any of, as in `event:upcoming,ongoing`. |
| `order:event-start-asc`                         | Sort by event start, soonest first. `order:event-start` sorts latest first.        |

For an upcoming events list, use `event:upcoming,ongoing order:event-start-asc`. This filters on the server, so paging and counts stay correct. The calendar and sidebar always show all events and are not affected by it.

## How it works

- The calendar reuses the plugin's own FullCalendar wrapper, so the views (day, week, month, year), styling and event colors match the category calendar.
- The sidebar is a small list that reuses the plugin's `upcoming-events-list` CSS classes. It is built here instead of importing the plugin's block.
- Both render in the `discovery-list-container-top` outlet and only appear when the current URL matches a `list_pages` row.

## Tests

`test/unit/lib/list-page-test.js` covers slug matching and the layout helpers. It runs as part of the theme's QUnit suite on a development Discourse. QUnit cannot run on production-mode sites.

## License

MIT. See [LICENSE](LICENSE).
