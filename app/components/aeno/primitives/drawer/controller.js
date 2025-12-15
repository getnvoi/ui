import { Controller } from "@hotwired/stimulus";

const BASE_Z_INDEX = 40;

export default class extends Controller {
  static targets = ["background", "wrapper"];

  connect() {
    this.#stackAboveExisting();
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
    requestAnimationFrame(() => {
      this.backgroundTarget.classList.add("cp-drawer__backdrop--open");
      this.wrapperTarget.classList.add("cp-drawer__panel--open");
      document.body.style.overflow = "hidden";
    });
  }

  close() {
    this.backgroundTarget.classList.remove("cp-drawer__backdrop--open");
    this.wrapperTarget.classList.remove("cp-drawer__panel--open");
    this.#restoreBodyScroll();

    setTimeout(() => {
      const frame = this.element.querySelector("turbo-frame");
      if (frame) {
        frame.src = undefined;
        frame.innerHTML = "";
      }
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
    const zIndexes = Array.from(allWrappers).map((el) => ({
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
      ".cp-drawer__backdrop--open",
    );
    if (openDrawers.length <= 1) {
      document.body.style.overflow = "";
    }
  }
}
