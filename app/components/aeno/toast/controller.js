import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    duration: { type: Number, default: 5000 },
  };

  connect() {
    // Auto-dismiss after duration
    if (this.durationValue > 0) {
      this.timeout = setTimeout(() => this.dismiss(), this.durationValue);
    }

    // Listen for animation end to remove from DOM
    this.element.addEventListener(
      "animationend",
      this.handleAnimationEnd.bind(this),
    );
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }

  dismiss() {
    // Trigger fade-out animation
    this.element.classList.remove("animate-toast-enter");
    this.element.classList.add("animate-toast-exit");
  }

  handleAnimationEnd(event) {
    // Only remove on exit animation
    if (event.animationName === "toast-exit") {
      this.element.remove();
    }
  }
}
