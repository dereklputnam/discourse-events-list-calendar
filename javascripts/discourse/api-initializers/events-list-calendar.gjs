import { apiInitializer } from "discourse/lib/api";
import EventsListCalendar from "../components/events-list-calendar";
import EventsListSidebar from "../components/events-list-sidebar";
import { findListPage, showsSidebar } from "../lib/list-page";

export default apiInitializer((api) => {
  api.renderInOutlet("discovery-list-container-top", EventsListCalendar);
  api.renderInOutlet("discovery-list-container-top", EventsListSidebar);

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
