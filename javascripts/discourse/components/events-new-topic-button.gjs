import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";
import { eventBody, findListPage, prefillFromQuery } from "../lib/list-page";

export default class EventsNewTopicButton extends Component {
  @service composer;
  @service currentUser;
  @service router;
  @service site;

  get page() {
    return findListPage(this.router.currentURL);
  }

  get active() {
    if (!this.page?.new_button || !this.currentUser?.can_create_topic) {
      return false;
    }

    return (
      this.page.new_type !== "event" ||
      !!this.currentUser.can_create_discourse_post_event
    );
  }

  get label() {
    return this.page.new_label?.trim() || i18n("topic.create");
  }

  @action
  create() {
    const slug = this.page.slug.trim().toLowerCase();
    const list = (this.site.custom_topic_lists || []).find(
      (l) => l.slug?.trim().toLowerCase() === slug
    );
    const { category, tags } = prefillFromQuery(
      list?.query,
      this.site.categories
    );
    const body =
      this.page.new_type === "event"
        ? eventBody(
            this.currentUser.user_option?.timezone ||
              Intl.DateTimeFormat().resolvedOptions().timeZone
          )
        : undefined;

    this.composer.openNewTopic({ category, tags, body });
  }

  <template>
    {{#if this.active}}
      <div class="events-list-new">
        <DButton
          @action={{this.create}}
          @icon="far-pen-to-square"
          @translatedLabel={{this.label}}
          class="btn-default events-list-new__button"
        />
      </div>
    {{/if}}
  </template>
}
