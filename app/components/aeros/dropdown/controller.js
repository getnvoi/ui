import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu", "search", "option", "empty"];
  static values = {
    open: { type: Boolean, default: false },
    searchable: { type: Boolean, default: false },
  };

  connect() {
    this.closeOnClickOutside = this.closeOnClickOutside.bind(this);
    this.handleKeydown = this.handleKeydown.bind(this);
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnClickOutside);
    document.removeEventListener("keydown", this.handleKeydown);
  }

  toggle(event) {
    event.stopPropagation();
    this.openValue ? this.close() : this.open();
  }

  open() {
    this.openValue = true;
    this.menuTarget.classList.remove("hidden");
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
    this.menuTarget.classList.add("hidden");
    document.removeEventListener("click", this.closeOnClickOutside);
    document.removeEventListener("keydown", this.handleKeydown);
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
    if (!this.hasSearchTarget || !this.hasOptionTarget) return;

    const query = this.searchTarget.value.toLowerCase().trim();
    let visibleCount = 0;

    this.optionTargets.forEach((option) => {
      const label = option.dataset.label?.toLowerCase() || option.textContent.toLowerCase();
      const matches = query === "" || label.includes(query);

      option.classList.toggle("hidden", !matches);
      if (matches) visibleCount++;
    });

    if (this.hasEmptyTarget) {
      this.emptyTarget.classList.toggle("hidden", visibleCount > 0);
    }
  }

  select(event) {
    const option = event.currentTarget;
    const value = option.dataset.value;
    const label = option.dataset.label || option.textContent.trim();

    this.dispatch("select", { detail: { value, label } });
    this.close();
  }
}
