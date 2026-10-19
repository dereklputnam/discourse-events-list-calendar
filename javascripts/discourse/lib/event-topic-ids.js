import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";

// IDs of every topic that has an event object, loaded once per page view.
class EventTopicIds {
  @tracked ids = null;

  #loading = false;

  async load() {
    if (this.ids || this.#loading) {
      return;
    }

    this.#loading = true;
    try {
      const { events } = await ajax("/discourse-post-event/events.json");
      this.ids = new Set((events || []).map((e) => e.post?.topic?.id));
    } finally {
      this.#loading = false;
    }
  }
}

export default new EventTopicIds();
