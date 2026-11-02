import { apiInitializer } from "discourse/lib/api";
import I18n from "discourse-i18n";
import EventsListCalendar from "../components/events-list-calendar";
import EventsListSidebar from "../components/events-list-sidebar";
import EventsNewTopicButton from "../components/events-new-topic-button";
import {
  composerLabel,
  findListPage,
  newTopicCategory,
  showsSidebar,
} from "../lib/list-page";

export default apiInitializer((api) => {
  api.renderInOutlet("discovery-list-container-top", EventsListCalendar);
  api.renderInOutlet("discovery-list-container-top", EventsListSidebar);
  // Inside the navigation bar, where the New Topic button sits on /latest
  api.renderInOutlet("after-create-topic-button", EventsNewTopicButton);

  const router = api.container.lookup("service:router");

  // A new topic started on a list page defaults to the row's category. Hooking
  // the composer opening covers every way of starting one there: our button,
  // Horizon's sidebar button and the keyboard shortcut. A category the author
  // or a draft already has is left alone.
  api.onAppEvent("composer:open", ({ model }) => {
    if (model?.action !== "createTopic" || model.categoryId) {
      return;
    }

    const category = newTopicCategory(
      findListPage(router.currentURL),
      api.container.lookup("service:site").categories
    );

    if (category) {
      model.set("categoryId", category.id);
    }
  });

  // The composer reads the save label as a translation key, so the text is
  // registered under one before it is returned. The action title is literal.
  const SAVE_LABEL_KEY = "events_list_calendar.composer.save";
  const newTopicLabel = (model) =>
    model.action === "createTopic"
      ? composerLabel(findListPage(router.currentURL))
      : undefined;

  api.customizeComposerText({
    actionTitle: newTopicLabel,

    saveLabel(model) {
      const label = newTopicLabel(model);
      if (!label) {
        return;
      }

      I18n.translations[I18n.locale].js.events_list_calendar = {
        composer: { save: label },
      };
      return SAVE_LABEL_KEY;
    },
  });

  api.onPageChange((url) => {
    const page = findListPage(url);

    document.body.classList.toggle(
      "has-events-list-hidden-topics",
      !!page?.hide_topic_list
    );
    document.body.classList.toggle(
      "has-events-list-sidebar",
      showsSidebar(page)
    );
  });
});
