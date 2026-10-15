import Component from "@glimmer/component";
import { service } from "@ember/service";
import { findListPage, showsCalendar } from "../lib/list-page";
import EventsCalendarGrid from "./events-calendar-grid";

export default class EventsListCalendar extends Component {
  @service router;

  get active() {
    const url = this.router.currentURL || "";
    return showsCalendar(findListPage(url));
  }

  <template>
    {{#if this.active}}
      <EventsCalendarGrid />
    {{/if}}
  </template>
}
