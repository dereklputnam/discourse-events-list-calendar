import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";
import {
  calendarCollapsed,
  findListPage,
  showsCalendar,
} from "../lib/list-page";
import EventsCalendarGrid from "./events-calendar-grid";

const STORAGE_PREFIX = "events-list-calendar-collapsed:";

export default class EventsListCalendar extends Component {
  @service router;
  @service capabilities;

  // Per list slug, so each list page remembers its own state
  @tracked choices = {};

  get page() {
    return findListPage(this.router.currentURL || "");
  }

  get active() {
    return showsCalendar(this.page);
  }

  get collapsed() {
    const slug = this.page?.slug;
    if (slug in this.choices) {
      return this.choices[slug];
    }

    let stored;
    try {
      stored = localStorage.getItem(STORAGE_PREFIX + slug);
    } catch {
      // storage can be unavailable; fall back to the default
    }
    return calendarCollapsed(stored, !this.capabilities.viewport.sm);
  }

  @action
  toggle() {
    const slug = this.page.slug;
    const collapsed = !this.collapsed;

    this.choices = { ...this.choices, [slug]: collapsed };
    try {
      localStorage.setItem(STORAGE_PREFIX + slug, collapsed ? "1" : "0");
    } catch {
      // the choice still applies for this visit
    }
  }

  <template>
    {{#if this.active}}
      <div class="events-list-calendar-toggle">
        <DButton
          @action={{this.toggle}}
          @icon={{if this.collapsed "chevron-down" "chevron-up"}}
          @translatedLabel={{if
            this.collapsed
            (i18n (themePrefix "calendar.show"))
            (i18n (themePrefix "calendar.hide"))
          }}
          aria-expanded={{if this.collapsed "false" "true"}}
          class="btn-flat events-list-calendar-toggle__button"
        />
      </div>
      {{#unless this.collapsed}}
        <EventsCalendarGrid />
      {{/unless}}
    {{/if}}
  </template>
}
