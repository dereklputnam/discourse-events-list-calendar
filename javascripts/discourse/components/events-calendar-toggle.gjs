import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";
import calendarState from "../lib/calendar-state";
import { findListPage, showsCalendar } from "../lib/list-page";

// Show/Hide calendar button, rendered in the navigation bar next to the new button
export default class EventsCalendarToggle extends Component {
  @service capabilities;
  @service router;

  get page() {
    return findListPage(this.router.currentURL || "");
  }

  get active() {
    return showsCalendar(this.page);
  }

  get mobile() {
    return !this.capabilities.viewport.sm;
  }

  get collapsed() {
    return calendarState.isCollapsed(this.page?.slug, this.mobile);
  }

  @action
  toggle() {
    calendarState.toggle(this.page.slug, this.mobile);
  }

  <template>
    {{#if this.active}}
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
    {{/if}}
  </template>
}
