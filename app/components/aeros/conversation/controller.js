import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["messagesContainer", "scrollAnchor"];

  connect() {
    console.log("conversation connected");

    // Auto-scroll to bottom on initial load
    this.scrollToBottom();
  }

  scrollToBottom() {
    if (this.hasScrollAnchorTarget) {
      this.scrollAnchorTarget.scrollIntoView({ behavior: "smooth" });
    }
  }
}
