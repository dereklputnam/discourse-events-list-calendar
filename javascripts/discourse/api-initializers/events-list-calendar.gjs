import { apiInitializer } from "discourse/lib/api";
import EventsListCalendar from "../components/events-list-calendar";
import EventsListSidebar from "../components/events-list-sidebar";
import EventsNewTopicButton from "../components/events-new-topic-button";
import eventTopicIds from "../lib/event-topic-ids";
import { findListPage, showsSidebar } from "../lib/list-page";

export default apiInitializer((api) => {
  api.renderInOutlet("discovery-list-container-top", EventsListCalendar);
  api.renderInOutlet("discovery-list-container-top", EventsListSidebar);
  api.renderInOutlet("discovery-list-container-top", EventsNewTopicButton);

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
