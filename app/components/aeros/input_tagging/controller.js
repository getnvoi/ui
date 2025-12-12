import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "search",
    "dropdown",
    "selectedContainer",
    "hiddenInputs",
    "optionsContainer",
    "createOption",
    "createLabel",
    "empty",
    "loading",
    "tag"
  ];

  static values = {
    tagsUrl: String,
    createUrl: String,
    allowCreate: { type: Boolean, default: true },
    maxTags: Number,
    selected: { type: Array, default: [] }
  };

  connect() {
    this.closeDropdown = this.closeDropdown.bind(this);
    this.availableTags = [];
    this.highlightedIndex = -1;

    if (this.tagsUrlValue) {
      this.loadTags();
    }
  }

  disconnect() {
    document.removeEventListener("click", this.closeDropdown);
  }

  async loadTags() {
    if (!this.tagsUrlValue) return;

    this.showLoading();

    try {
      const response = await fetch(this.tagsUrlValue, {
        headers: { "Accept": "application/json" }
      });
      const data = await response.json();
      this.availableTags = Array.isArray(data) ? data : (data.tags || []);
    } catch (error) {
      console.error("Failed to load tags:", error);
      this.availableTags = [];
    }

    this.hideLoading();
  }

  onFocus() {
    this.openDropdown();
    this.filterOptions();
  }

  onSearchInput() {
    this.openDropdown();
    this.filterOptions();
  }

  onKeydown(event) {
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault();
        this.highlightNext();
        break;
      case "ArrowUp":
        event.preventDefault();
        this.highlightPrevious();
        break;
      case "Enter":
        event.preventDefault();
        this.selectHighlighted();
        break;
      case "Escape":
        this.closeDropdown();
        this.searchTarget.blur();
        break;
      case "Backspace":
        if (this.searchTarget.value === "" && this.selectedValue.length > 0) {
          this.removeLastTag();
        }
        break;
      case "Tab":
        this.closeDropdown();
        break;
    }
  }

  filterOptions() {
    const query = this.searchTarget.value.toLowerCase().trim();
    const filtered = this.availableTags.filter(tag => {
      const tagName = typeof tag === "string" ? tag : tag.name;
      const isNotSelected = !this.selectedValue.includes(tagName);
      const matchesQuery = query === "" || tagName.toLowerCase().includes(query);
      return isNotSelected && matchesQuery;
    });

    this.renderOptions(filtered);
    this.updateCreateOption(query, filtered);
    this.updateEmptyState(filtered, query);
    this.highlightedIndex = -1;
  }

  renderOptions(tags) {
    const html = tags.map((tag, index) => {
      const tagName = typeof tag === "string" ? tag : tag.name;
      return `
        <button type="button"
                class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 focus:bg-gray-100 focus:outline-none"
                data-action="click->${this.identifier}#selectOption"
                data-tag-name="${this.escapeHtml(tagName)}"
                data-index="${index}">
          ${this.escapeHtml(tagName)}
        </button>
      `;
    }).join("");

    this.optionsContainerTarget.innerHTML = html;
  }

  updateCreateOption(query, filteredTags) {
    if (!this.allowCreateValue || !this.hasCreateOptionTarget) return;

    const exactMatch = filteredTags.some(tag => {
      const tagName = typeof tag === "string" ? tag : tag.name;
      return tagName.toLowerCase() === query.toLowerCase();
    });

    const alreadySelected = this.selectedValue.some(
      tag => tag.toLowerCase() === query.toLowerCase()
    );

    const showCreate = query.length > 0 && !exactMatch && !alreadySelected;

    this.createOptionTarget.classList.toggle("hidden", !showCreate);
    if (showCreate && this.hasCreateLabelTarget) {
      this.createLabelTarget.textContent = query;
    }
  }

  updateEmptyState(filtered, query) {
    if (!this.hasEmptyTarget) return;

    const hasCreateOption = this.allowCreateValue && query.length > 0;
    const showEmpty = filtered.length === 0 && !hasCreateOption;
    this.emptyTarget.classList.toggle("hidden", !showEmpty);
  }

  openDropdown() {
    this.dropdownTarget.classList.remove("hidden");
    document.addEventListener("click", this.closeDropdown);
  }

  closeDropdown(event) {
    if (event && this.element.contains(event.target)) return;
    this.dropdownTarget.classList.add("hidden");
    document.removeEventListener("click", this.closeDropdown);
    this.highlightedIndex = -1;
  }

  selectOption(event) {
    const tagName = event.currentTarget.dataset.tagName;
    this.addTag(tagName);
    this.searchTarget.value = "";
    this.filterOptions();
    this.searchTarget.focus();
  }

  async createTag() {
    const tagName = this.searchTarget.value.trim();
    if (!tagName) return;

    if (this.createUrlValue) {
      try {
        const response = await fetch(this.createUrlValue, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-CSRF-Token": this.csrfToken()
          },
          body: JSON.stringify({ tag: { name: tagName } })
        });

        if (response.ok) {
          const newTag = await response.json();
          const newTagName = typeof newTag === "string" ? newTag : (newTag.name || tagName);
          this.availableTags.push(newTagName);
        }
      } catch (error) {
        console.error("Failed to create tag:", error);
      }
    }

    this.addTag(tagName);
    this.searchTarget.value = "";
    this.filterOptions();
    this.searchTarget.focus();
  }

  addTag(tagName) {
    if (this.selectedValue.includes(tagName)) return;
    if (this.maxTagsValue && this.selectedValue.length >= this.maxTagsValue) return;

    this.selectedValue = [...this.selectedValue, tagName];
    this.renderSelectedTags();
    this.renderHiddenInputs();
    this.dispatch("change", { detail: { tags: this.selectedValue } });
  }

  removeTag(event) {
    const tagElement = event.currentTarget.closest("[data-tag-name]");
    const tagName = tagElement.dataset.tagName;

    this.selectedValue = this.selectedValue.filter(t => t !== tagName);
    this.renderSelectedTags();
    this.renderHiddenInputs();
    this.filterOptions();
    this.dispatch("change", { detail: { tags: this.selectedValue } });
  }

  removeLastTag() {
    if (this.selectedValue.length === 0) return;
    this.selectedValue = this.selectedValue.slice(0, -1);
    this.renderSelectedTags();
    this.renderHiddenInputs();
    this.filterOptions();
    this.dispatch("change", { detail: { tags: this.selectedValue } });
  }

  renderSelectedTags() {
    const html = this.selectedValue.map(tag => `
      <span class="inline-flex items-center gap-x-1 rounded-md bg-indigo-50 px-2 py-1 text-xs font-medium text-indigo-700 ring-1 ring-inset ring-indigo-700/10"
            data-${this.identifier}-target="tag"
            data-tag-name="${this.escapeHtml(tag)}">
        ${this.escapeHtml(tag)}
        <button type="button"
                class="group relative -mr-1 h-3.5 w-3.5 rounded-sm hover:bg-indigo-600/20"
                data-action="click->${this.identifier}#removeTag">
          <svg class="h-3 w-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </span>
    `).join("");

    this.selectedContainerTarget.innerHTML = html;
  }

  renderHiddenInputs() {
    const baseName = this.element.querySelector("input[type='hidden']")?.name ||
                     this.searchTarget.name?.replace(/\[\]$/, "") + "[]";
    const inputName = baseName.endsWith("[]") ? baseName : baseName + "[]";

    const html = this.selectedValue.map(tag =>
      `<input type="hidden" name="${inputName}" value="${this.escapeHtml(tag)}">`
    ).join("");

    this.hiddenInputsTarget.innerHTML = html;
  }

  highlightNext() {
    const options = this.optionsContainerTarget.querySelectorAll("button");
    if (options.length === 0) return;

    this.highlightedIndex = Math.min(this.highlightedIndex + 1, options.length - 1);
    this.updateHighlight(options);
  }

  highlightPrevious() {
    const options = this.optionsContainerTarget.querySelectorAll("button");
    if (options.length === 0) return;

    this.highlightedIndex = Math.max(this.highlightedIndex - 1, 0);
    this.updateHighlight(options);
  }

  updateHighlight(options) {
    options.forEach((opt, idx) => {
      opt.classList.toggle("bg-gray-100", idx === this.highlightedIndex);
    });

    if (this.highlightedIndex >= 0 && options[this.highlightedIndex]) {
      options[this.highlightedIndex].scrollIntoView({ block: "nearest" });
    }
  }

  selectHighlighted() {
    const options = this.optionsContainerTarget.querySelectorAll("button");
    if (this.highlightedIndex >= 0 && this.highlightedIndex < options.length) {
      options[this.highlightedIndex].click();
    } else if (this.allowCreateValue && this.searchTarget.value.trim()) {
      this.createTag();
    }
  }

  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove("hidden");
    }
  }

  hideLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add("hidden");
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || "";
  }
}
