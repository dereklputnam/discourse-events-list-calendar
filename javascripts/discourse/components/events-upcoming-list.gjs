import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import { findListPage, pageTags } from "../lib/list-page";

const MAX_EVENTS = 10;
const WINDOW_DAYS = 180;

// Upcoming events list for the sidebar layout. Mirrors the markup of the calendar
// plugin's `upcoming-events-list` block (so its CSS applies) but can be scoped to
// the tags set on the matching `list_pages` row, which the plugin block cannot.
export default class EventsUpcomingList extends Component {
  @service router;
  @service discoursePostEventService;

  @tracked events = [];
  @tracked loading = true;

  @action
  async load() {
    const tags = pageTags(findListPage(this.router.currentURL));
    const now = new Date();
    const until = new Date(now.getTime() + WINDOW_DAYS * 24 * 60 * 60 * 1000);

    try {
      const events = await this.discoursePostEventService.fetchEvents({
        after: now.toISOString(),
        before: until.toISOString(),
        include_ongoing: true,
        ...(tags.length ? { tags } : {}),
      });

      this.events = events
        .map((e) => ({
          title: e.name || e.post?.topic?.title,
          url: e.post?.url,
          // the service returns event models, which expose camelCase fields
          start: new Date(e.startsAt ?? e.starts_at),
        }))
        .filter((e) => !Number.isNaN(e.start.getTime()))
        .sort((a, b) => a.start - b.start)
        .slice(0, MAX_EVENTS)
        .map((e) => ({
          ...e,
          month: e.start.toLocaleDateString(undefined, { month: "short" }),
          day: e.start.getDate(),
        }));
    } catch (err) {
      popupAjaxError(err);
    } finally {
      this.loading = false;
    }
  }

  <template>
    <div class="upcoming-events-list" {{didInsert this.load}}>
      <h3 class="upcoming-events-list__heading events-list-sidebar__heading">
        {{i18n (themePrefix "upcoming_events.heading")}}
      </h3>
      <div class="upcoming-events-list__container">
        {{#each this.events as |event|}}
          <a class="upcoming-events-list__event" href={{event.url}}>
            <div class="upcoming-events-list__event-date">
              <div class="month">{{event.month}}</div>
              <div class="day">{{event.day}}</div>
            </div>
            <div class="upcoming-events-list__event-content">
              <span
                class="upcoming-events-list__event-name"
                title={{event.title}}
              >{{event.title}}</span>
            </div>
          </a>
        {{else}}
          {{#unless this.loading}}
            <div class="upcoming-events-list__no-events">
              {{i18n (themePrefix "upcoming_events.empty")}}
            </div>
          {{/unless}}
        {{/each}}
      </div>
      <div class="upcoming-events-list__footer">
        <a class="upcoming-events-list__view-all" href="/upcoming-events">
          {{i18n (themePrefix "upcoming_events.view_all")}}
        </a>
      </div>
    </div>
  </template>
}
