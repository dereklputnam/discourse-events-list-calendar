import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";
import { findListPage, newIcon } from "../lib/list-page";

export default class EventsNewTopicButton extends Component {
  @service composer;
  @service currentUser;
  @service router;

  get active() {
    return !!this.page?.new_button && !!this.currentUser?.can_create_topic;
  }

  get label() {
    return this.page.new_label?.trim() || i18n("topic.create");
  }

  get icon() {
    return newIcon(this.page);
  }

  get page() {
    return findListPage(this.router.currentURL);
  }

  @action
  create() {
    this.composer.openNewTopic();
  }

  <template>
    {{#if this.active}}
      <DButton
        @action={{this.create}}
        @icon={{this.icon}}
        @translatedLabel={{this.label}}
        @translatedTitle={{this.label}}
        class="btn-primary events-list-new__button"
      />
    {{/if}}
  </template>
}
