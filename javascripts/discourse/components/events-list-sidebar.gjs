import Component from "@glimmer/component";
import { service } from "@ember/service";
import { findListPage, showsSidebar } from "../lib/list-page";
import EventsUpcomingList from "./events-upcoming-list";

export default class EventsListSidebar extends Component {
  @service router;
  @service site;

  get active() {
    const url = this.router.currentURL || "";
    return !this.site.mobileView && showsSidebar(findListPage(url));
  }

  <template>
    {{#if this.active}}
      <aside class="events-list-sidebar">
        <EventsUpcomingList />
      </aside>
    {{/if}}
  </template>
}
