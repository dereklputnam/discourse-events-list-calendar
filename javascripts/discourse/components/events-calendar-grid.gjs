import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { popupAjaxError } from "discourse/lib/ajax-error";
// Reuse the calendar plugin's own FullCalendar wrapper and event formatter so
// the list page matches the official category calendar (views, styling, colors).
// The imports are optional so the theme still loads where the plugin is absent.
import FullCalendar from "discourse/plugins/discourse-events/discourse/components/full-calendar" with {
  discourseImport: "optional",
};
import formatEventForCalendar from "discourse/plugins/discourse-events/discourse/lib/format-event-for-calendar" with {
  discourseImport: "optional",
};

import openEventComposer from "discourse/plugins/discourse-events/discourse/lib/open-event-composer" with {
  discourseImport: "optional",
};
import {
  eventsDefaultCategory,
  findListPage,
  newTopicTags,
} from "../lib/list-page";

export default class EventsCalendarGrid extends Component {
  @service composer;
  @service currentUser;
  @service router;
  @service site;
  @service siteSettings;
  @service discoursePostEventService;

  // Same rule as the plugin's own calendars
  get canCreateEvent() {
    return (
      !!openEventComposer &&
      this.currentUser?.can_create_discourse_post_event &&
      this.currentUser?.can_create_topic
    );
  }

  get refreshKey() {
    return String(this.currentUser?.id);
  }

  // Clicking a day or dragging a range opens a new event starting there.
  @action
  async createEvent(info) {
    const category = eventsDefaultCategory(
      this.siteSettings.calendar_upcoming_events_default_category,
      this.site.categories
    );

    await openEventComposer({
      composer: this.composer,
      currentUser: this.currentUser,
      siteSettings: this.siteSettings,
      info,
      category: category ?? null,
    });

    const tags = newTopicTags(findListPage(this.router.currentURL));
    if (tags.length) {
      this.composer.model?.set("tags", tags);
    }
  }

  @action
  async loadEvents(info) {
    try {
      const events = await this.discoursePostEventService.fetchEvents({
        after: info.startStr,
        before: info.endStr,
        include_ongoing: true,
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
      {{#if FullCalendar}}
        <FullCalendar
          @height="650px"
          @initialView={{this.siteSettings.calendar_upcoming_events_default_view}}
          @placeholder={{true}}
          @onDateClick={{if this.canCreateEvent this.createEvent}}
          @onLoadEvents={{this.loadEvents}}
          @refreshKey={{this.refreshKey}}
        />
      {{/if}}
    </div>
  </template>
}
