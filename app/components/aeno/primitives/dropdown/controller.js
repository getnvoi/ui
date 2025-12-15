import { Controller } from "@hotwired/stimulus";
import { computePosition, flip, shift, offset, autoUpdate } from "@floating-ui/dom";

export default class extends Controller {
  static targets = ["trigger", "content", "search", "items", "empty"];
  static values = {
    open: { type: Boolean, default: false },
    placement: { type: String, default: "bottom-start" },
    strategy: { type: String, default: "absolute" },
    searchable: { type: Boolean, default: false },
  };

  connect() {
    this.closeOnClickOutside = this.closeOnClickOutside.bind(this);
    this.handleKeydown = this.handleKeydown.bind(this);
  }

  disconnect() {
    this.cleanup?.();
    document.removeEventListener("click", this.closeOnClickOutside);
    document.removeEventListener("keydown", this.handleKeydown);
  }

  toggle(event) {
    event.stopPropagation();
    this.openValue ? this.close() : this.open();
  }

  open() {
    this.openValue = true;
    this.contentTarget.classList.add("cp-dropdown__content--open");
    this.updatePosition();

    this.cleanup = autoUpdate(this.triggerTarget, this.contentTarget, () => {
      this.updatePosition();
    });

    document.addEventListener("click", this.closeOnClickOutside);
    document.addEventListener("keydown", this.handleKeydown);

    if (this.searchableValue && this.hasSearchTarget) {
      this.searchTarget.value = "";
      this.filter();
      setTimeout(() => this.searchTarget.focus(), 0);
    }
  }

  close() {
    this.openValue = false;
    this.contentTarget.classList.remove("cp-dropdown__content--open");
    this.cleanup?.();
    this.cleanup = null;
    document.removeEventListener("click", this.closeOnClickOutside);
    document.removeEventListener("keydown", this.handleKeydown);
  }

  async updatePosition() {
    const { x, y } = await computePosition(this.triggerTarget, this.contentTarget, {
      placement: this.placementValue,
      strategy: this.strategyValue,
      middleware: [
        offset(4),
        flip(),
        shift({ padding: 8 }),
      ],
    });

    Object.assign(this.contentTarget.style, {
      position: this.strategyValue,
      left: `${x}px`,
      top: `${y}px`,
    });
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close();
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }

  filter() {
    if (!this.hasSearchTarget) return;

    const query = this.searchTarget.value.toLowerCase().trim();
    const items = this.itemsTarget.querySelectorAll("[role='menuitem'], [role='menuitemradio'], [role='menuitemcheckbox']");
    let visibleCount = 0;

    items.forEach((item) => {
      const label = item.querySelector(".cp-dropdown__item-label")?.textContent.toLowerCase() || "";
      const matches = query === "" || label.includes(query);

      item.classList.toggle("cp-dropdown__item--hidden", !matches);
      if (matches) visibleCount++;
    });

    if (this.hasEmptyTarget) {
      this.emptyTarget.classList.toggle("cp-dropdown__empty--visible", visibleCount === 0);
    }
  }

  select(event) {
    const item = event.currentTarget;
    const value = item.dataset.value;
    const label = item.querySelector(".cp-dropdown__item-label")?.textContent.trim();

    this.dispatch("select", { detail: { value, label } });
    this.close();
  }

  selectRadio(event) {
    const item = event.currentTarget;
    const name = item.dataset.name;
    const value = item.dataset.value;

    // Update aria-checked for all radio items in the group
    const group = item.closest(".cp-dropdown__radio-group");
    group.querySelectorAll("[role='menuitemradio']").forEach((radio) => {
      const isChecked = radio === item;
      radio.setAttribute("aria-checked", isChecked);
      const checkIcon = radio.querySelector(".cp-dropdown__item-check");
      if (checkIcon) {
        checkIcon.innerHTML = isChecked ? this.checkIconSvg() : "";
      }
    });

    this.dispatch("radio-change", { detail: { name, value } });
  }

  toggleCheckbox(event) {
    const item = event.currentTarget;
    const name = item.dataset.name;
    const isChecked = item.getAttribute("aria-checked") === "true";
    const newChecked = !isChecked;

    item.setAttribute("aria-checked", newChecked);
    const checkIcon = item.querySelector(".cp-dropdown__item-check");
    if (checkIcon) {
      checkIcon.innerHTML = newChecked ? this.checkIconSvg() : "";
    }

    this.dispatch("checkbox-change", { detail: { name, checked: newChecked } });
  }

  checkIconSvg() {
    return `<svg class="cp-dropdown__check-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>`;
  }
}
