import { tracked } from "@glimmer/tracking";
import { calendarCollapsed } from "./list-page";

const STORAGE_PREFIX = "events-list-calendar-collapsed:";

// Shared by the Show/Hide button (in the navigation bar) and the calendar, so
// the choice is remembered per list slug in the browser.
class CalendarState {
  @tracked choices = {};

  isCollapsed(slug, mobile) {
    if (slug in this.choices) {
      return this.choices[slug];
    }

    let stored;
    try {
      stored = localStorage.getItem(STORAGE_PREFIX + slug);
    } catch {
      // storage can be unavailable; fall back to the default
    }
    return calendarCollapsed(stored, mobile);
  }

  toggle(slug, mobile) {
    const collapsed = !this.isCollapsed(slug, mobile);

    this.choices = { ...this.choices, [slug]: collapsed };
    try {
      localStorage.setItem(STORAGE_PREFIX + slug, collapsed ? "1" : "0");
    } catch {
      // the choice still applies for this visit
    }
  }
}

export default new CalendarState();
