import Component from "@glimmer/component";
import { service } from "@ember/service";
import calendarState from "../lib/calendar-state";
import { findListPage, showsCalendar } from "../lib/list-page";
import EventsCalendarGrid from "./events-calendar-grid";

export default class EventsListCalendar extends Component {
  @service capabilities;
  @service router;

  get page() {
    return findListPage(this.router.currentURL || "");
  }

  get active() {
    return (
      showsCalendar(this.page) &&
      !calendarState.isCollapsed(this.page.slug, !this.capabilities.viewport.sm)
    );
  }

  <template>
    {{#if this.active}}
      <EventsCalendarGrid />
    {{/if}}
  </template>
}
