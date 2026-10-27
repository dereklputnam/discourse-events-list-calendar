import { apiInitializer } from "discourse/lib/api";
import I18n from "discourse-i18n";
import EventsListCalendar from "../components/events-list-calendar";
import EventsListSidebar from "../components/events-list-sidebar";
import EventsNewTopicButton from "../components/events-new-topic-button";
import eventTopicIds from "../lib/event-topic-ids";
import { composerLabel, findListPage, showsSidebar } from "../lib/list-page";

export default apiInitializer((api) => {
  api.renderInOutlet("discovery-list-container-top", EventsListCalendar);
  api.renderInOutlet("discovery-list-container-top", EventsListSidebar);
  // Inside the navigation bar, where the New Topic button sits on /latest
  api.renderInOutlet("after-create-topic-button", EventsNewTopicButton);

  const router = api.container.lookup("service:router");

  api.registerValueTransformer(
    "topic-list-item-class",
    ({ value, context }) => {
      const page = findListPage(router.currentURL);
      const ids = eventTopicIds.ids;

      if (page?.events_only && ids && !ids.has(context.topic?.id)) {
        value.push("--no-event");
      }

      return value;
    }
  );

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

    if (page?.events_only) {
      eventTopicIds.load();
    }

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
