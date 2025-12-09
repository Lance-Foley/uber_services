import { Controller } from "@hotwired/stimulus";

// Generic controller for showing/hiding fields based on a source input value
// Usage:
//   <div data-controller="shared--conditional-fields">
//     <select data-action="change->shared--conditional-fields#toggle" data-shared--conditional-fields-target="source">
//       <option value="option1">Option 1</option>
//       <option value="option2">Option 2</option>
//     </select>
//
//     <div data-shared--conditional-fields-target="field" data-show-when="option1">
//       Shows when option1 is selected
//     </div>
//
//     <div data-shared--conditional-fields-target="field" data-show-when="option2,option3">
//       Shows when option2 or option3 is selected
//     </div>
//   </div>

export default class extends Controller {
  static targets = ["source", "field"];

  connect() {
    // Initialize visibility on load
    this.toggle();
  }

  toggle() {
    const sourceValue = this.getSourceValue();

    this.fieldTargets.forEach((field) => {
      const showWhen = field.dataset.showWhen;

      if (!showWhen) {
        // No condition specified, always show
        this.show(field);
        return;
      }

      // Support multiple values separated by commas
      const allowedValues = showWhen.split(",").map((v) => v.trim());

      if (allowedValues.includes(sourceValue)) {
        this.show(field);
      } else {
        this.hide(field);
      }
    });
  }

  getSourceValue() {
    if (!this.hasSourceTarget) return null;

    const source = this.sourceTarget;

    // Handle different input types
    if (source.tagName === "SELECT") {
      return source.value;
    } else if (source.type === "radio") {
      const checked = this.sourceTargets.find((radio) => radio.checked);
      return checked ? checked.value : null;
    } else if (source.type === "checkbox") {
      return source.checked ? source.value : null;
    } else {
      return source.value;
    }
  }

  show(element) {
    element.classList.remove("hidden");
    // Re-enable inputs inside the field
    this.setFieldsDisabled(element, false);
  }

  hide(element) {
    element.classList.add("hidden");
    // Disable inputs inside the field to prevent submission
    this.setFieldsDisabled(element, true);
  }

  setFieldsDisabled(element, disabled) {
    const inputs = element.querySelectorAll("input, select, textarea");
    inputs.forEach((input) => {
      if (disabled) {
        input.setAttribute("disabled", "disabled");
      } else {
        input.removeAttribute("disabled");
      }
    });
  }
}
