import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { popupAjaxError } from "discourse/lib/ajax-error";
// Reuse the calendar plugin's own FullCalendar wrapper and event formatter so
// the list page matches the official category calendar (views, styling, colors).
import FullCalendar from "discourse/plugins/discourse-events/discourse/components/full-calendar";
import formatEventForCalendar from "discourse/plugins/discourse-events/discourse/lib/format-event-for-calendar";
import { findListPage, pageTags } from "../lib/list-page";

export default class EventsCalendarGrid extends Component {
  @service currentUser;
  @service router;
  @service siteSettings;
  @service discoursePostEventService;

  get refreshKey() {
    return [this.currentUser?.id, ...this.#tags].join("-");
  }

  get #tags() {
    return pageTags(findListPage(this.router.currentURL));
  }

  @action
  async loadEvents(info) {
    try {
      const events = await this.discoursePostEventService.fetchEvents({
        after: info.startStr,
        before: info.endStr,
        include_ongoing: true,
        ...(this.#tags.length ? { tags: this.#tags } : {}),
      });
      const timezone = this.currentUser?.user_option?.timezone;
      return events.map((e) =>
        formatEventForCalendar(
          e,
          this.siteSettings.map_events_to_color,
          timezone
        )
      );
    } catch (err) {
      popupAjaxError(err);
    }
  }

  <template>
    <div class="events-list-calendar">
      <FullCalendar
        @height="650px"
        @placeholder={{true}}
        @onLoadEvents={{this.loadEvents}}
        @refreshKey={{this.refreshKey}}
      />
    </div>
  </template>
}
