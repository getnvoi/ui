import { Controller } from "@hotwired/stimulus";

const BASE_Z_INDEX = 40;

export default class extends Controller {
  static targets = ["background", "wrapper"];

  connect() {
    this.#stackAboveExisting();

    // Auto-open on connect (for lazy shell creation pattern)
    requestAnimationFrame(() => {
      this.backgroundTarget.classList.add("opacity-100", "pointer-events-auto");
      this.backgroundTarget.classList.remove("opacity-0", "pointer-events-none");
      this.wrapperTarget.classList.remove("translate-x-full");
      document.body.classList.add("overflow-hidden");
    });

    document.addEventListener("keydown", this.handleKeydown);
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown);
    this.#restoreBodyScroll();
  }

  handleKeydown = (event) => {
    if (event.key === "Escape") this.#closeTopmost();
  };

  open() {
    this.#stackAboveExisting();
    requestAnimationFrame(() => {
      this.backgroundTarget.classList.add("opacity-100", "pointer-events-auto");
      this.backgroundTarget.classList.remove(
        "opacity-0",
        "pointer-events-none",
      );
      this.wrapperTarget.classList.remove("translate-x-full");
      document.body.classList.add("overflow-hidden");
    });
  }

  close() {
    this.backgroundTarget.classList.remove(
      "opacity-100",
      "pointer-events-auto",
    );
    this.backgroundTarget.classList.add("opacity-0", "pointer-events-none");
    this.wrapperTarget.classList.add("translate-x-full");
    this.#restoreBodyScroll();

    setTimeout(() => {
      // For lazy shell creation: remove entire drawer element
      this.element.remove();
    }, 300);
  }

  closeOnSubmit(event) {
    if (event.detail?.success) {
      this.close();
    }
  }

  // Private

  #stackAboveExisting() {
    if (!this.hasBackgroundTarget || !this.hasWrapperTarget) return;

    const allBackgrounds = document.querySelectorAll(
      `[data-${this.identifier}-target="background"]`,
    );
    const allWrappers = document.querySelectorAll(
      `[data-${this.identifier}-target="wrapper"]`,
    );

    const highest = Math.max(
      BASE_Z_INDEX,
      this.#highestZIndex(allBackgrounds),
      this.#highestZIndex(allWrappers),
    );

    this.backgroundTarget.style.zIndex = highest + 1;
    this.wrapperTarget.style.zIndex = highest + 2;
  }

  #highestZIndex(elements) {
    return Math.max(
      0,
      ...Array.from(elements).map(
        (el) => parseInt(getComputedStyle(el).zIndex) || 0,
      ),
    );
  }

  #closeTopmost() {
    const allWrappers = document.querySelectorAll(
      `[data-${this.identifier}-target="wrapper"]`,
    );
    const openWrappers = Array.from(allWrappers).filter(
      (el) => !el.classList.contains("translate-x-full"),
    );
    const zIndexes = openWrappers.map((el) => ({
      el,
      z: parseInt(getComputedStyle(el).zIndex) || 0,
    }));

    const topmost = zIndexes.sort((a, b) => b.z - a.z)[0];
    if (topmost?.el === this.wrapperTarget) {
      this.close();
    }
  }

  #restoreBodyScroll() {
    const openDrawers = document.querySelectorAll(
      `[data-${this.identifier}-target="background"].opacity-100`,
    );
    if (openDrawers.length <= 1) {
      document.body.classList.remove("overflow-hidden");
    }
  }
}
