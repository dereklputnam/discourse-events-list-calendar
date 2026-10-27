import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";
import { findListPage, prefillFromQuery } from "../lib/list-page";

export default class EventsNewTopicButton extends Component {
  @service composer;
  @service currentUser;
  @service router;
  @service site;

  get active() {
    return !!this.page?.new_button && !!this.currentUser?.can_create_topic;
  }

  get label() {
    return this.page.new_label?.trim() || i18n("topic.create");
  }

  get page() {
    return findListPage(this.router.currentURL);
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

    this.composer.openNewTopic({ category, tags });
  }

  <template>
    {{#if this.active}}
      <DButton
        @action={{this.create}}
        @icon="far-pen-to-square"
        @translatedLabel={{this.label}}
        class="btn-default events-list-new__button"
      />
    {{/if}}
  </template>
}
