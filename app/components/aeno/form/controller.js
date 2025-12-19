import { Controller } from "@hotwired/stimulus";

// Business logic for nested form record ID generation
function generateRecordId() {
  return new Date().getTime().toString();
}

function replaceNewRecord(templateContent, attributeName, recordId = null) {
  const id = recordId || generateRecordId();

  if (attributeName) {
    // Replace only NEW_RECORD that comes after this specific attribute name
    // Pattern matches: attribute_name][NEW_RECORD]
    const escapedAttrName = attributeName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const pattern = new RegExp(`(${escapedAttrName}\\]\\[)NEW_RECORD(\\])`, 'g');
    return templateContent.replace(pattern, `$1${id}$2`);
  } else {
    // Fallback: replace all NEW_RECORD
    return templateContent.replace(/NEW_RECORD/g, id);
  }
}

// Nested form controller adapted for div-based templates (hidden with class="hidden")
// Based on stimulus-rails-nested-form: https://www.stimulus-components.com/docs/stimulus-rails-nested-form/
export default class extends Controller {
  static targets = ["target", "template"];
  static values = {
    wrapperSelector: {
      type: String,
      default: ".nested-form-wrapper",
    },
    debug: {
      type: Boolean,
      default: false,
    },
  };

  add(e) {
    e.preventDefault();

    const templateContent = this.templateTarget.innerHTML;
    const attributeName = this.element.dataset.attributeName;
    const content = replaceNewRecord(templateContent, attributeName);

    // Insert the cloned content
    this.targetTarget.insertAdjacentHTML("beforebegin", content);

    // Find the newly added fieldset and enable all form fields
    const addedElement = this.targetTarget.previousElementSibling;
    if (addedElement) {
      // If the added element is a fieldset, remove disabled from it
      if (addedElement.tagName === "FIELDSET") {
        addedElement.removeAttribute("disabled");
      }
      // Otherwise, find direct child fieldset only (not nested templates)
      const fieldset = addedElement.querySelector(":scope > fieldset[disabled]");
      if (fieldset) {
        fieldset.removeAttribute("disabled");
      }
    }

    const event = new CustomEvent("rails-nested-form:add", { bubbles: true });
    this.element.dispatchEvent(event);
  }

  remove(e) {
    e.preventDefault();

    const wrapper = e.target.closest(this.wrapperSelectorValue);

    if (wrapper.dataset.newRecord === "true") {
      // Remove new records immediately
      wrapper.remove();
    } else {
      // Hide existing records and mark for destruction
      wrapper.style.display = "none";

      const input = wrapper.querySelector("input[name*='_destroy']");
      input.value = "1";
    }

    const event = new CustomEvent("rails-nested-form:remove", {
      bubbles: true,
    });
    this.element.dispatchEvent(event);
  }

  submit(e) {
    if (!this.debugValue) return;

    e.preventDefault();

    // Serialize form data to nested JSON structure
    const formData = new FormData(e.target);
    const json = this.formDataToJSON(formData);

    console.log(json);
  }

  formDataToJSON(formData) {
    const json = {};

    for (const [key, value] of formData.entries()) {
      this.setNestedValue(json, key, value);
    }

    return json;
  }

  setNestedValue(obj, path, value) {
    // Parse Rails nested attributes: "siblings_attributes[123][name]"
    const keys = path.split(/[\[\]]+/).filter((k) => k);

    let current = obj;
    for (let i = 0; i < keys.length - 1; i++) {
      const key = keys[i];
      const nextKey = keys[i + 1];

      // Create nested object/array if doesn't exist
      if (!current[key]) {
        // If next key is numeric, might be an array or object
        current[key] = {};
      }

      current = current[key];
    }

    const lastKey = keys[keys.length - 1];

    // Handle multiple values for same key
    if (current[lastKey] !== undefined) {
      if (Array.isArray(current[lastKey])) {
        current[lastKey].push(value);
      } else {
        current[lastKey] = [current[lastKey], value];
      }
    } else {
      current[lastKey] = value;
    }
  }
}

// Export for testing
export { generateRecordId, replaceNewRecord };
