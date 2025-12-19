import { describe, it, expect } from "vitest";
import { replaceNewRecord } from "./controller.js";

describe("NestedRecord - Business Logic", () => {
  const FIXED_ID = "1234567890";

  it("replaces all NEW_RECORD when no attribute name provided", () => {
    const template = `
      <input name="contact[siblings_attributes][NEW_RECORD][name]">
      <input name="contact[siblings_attributes][NEW_RECORD][age]">
    `;

    const result = replaceNewRecord(template, null, FIXED_ID);

    expect(result).toContain("siblings_attributes][1234567890][name]");
    expect(result).toContain("siblings_attributes][1234567890][age]");
    expect(result).not.toContain("NEW_RECORD");
  });

  it("replaces only siblings_attributes NEW_RECORD, keeps phones_attributes NEW_RECORD", () => {
    const template = `
      <input name="contact[siblings_attributes][NEW_RECORD][name]">
      <input name="contact[siblings_attributes][NEW_RECORD][phones_attributes][NEW_RECORD][number]">
    `;

    const result = replaceNewRecord(template, "siblings_attributes", FIXED_ID);

    expect(result).toContain("siblings_attributes][1234567890][name]");
    expect(result).toContain(
      "siblings_attributes][1234567890][phones_attributes][NEW_RECORD][number]",
    );
  });

  it("handles deeply nested attributes correctly", () => {
    const template = `
      <input name="contact[siblings_attributes][123][phones_attributes][NEW_RECORD][number]">
      <input name="contact[siblings_attributes][123][phones_attributes][NEW_RECORD][type]">
    `;

    const result = replaceNewRecord(template, "phones_attributes", FIXED_ID);

    expect(result).toContain("phones_attributes][1234567890][number]");
    expect(result).toContain("phones_attributes][1234567890][type]");
    expect(result).not.toContain("phones_attributes][NEW_RECORD]");
  });

  it("all fields for one sibling share same ID", () => {
    const template = `
      <input name="contact[siblings_attributes][NEW_RECORD][name]">
      <input name="contact[siblings_attributes][NEW_RECORD][age]">
      <input name="contact[siblings_attributes][NEW_RECORD][_destroy]">
    `;

    const result = replaceNewRecord(template, "siblings_attributes", FIXED_ID);

    const matches = result.match(/siblings_attributes\]\[(\d+)\]/g);
    expect(matches).toHaveLength(3);
    expect(new Set(matches).size).toBe(1); // All should be identical
  });

  it("sibling ID differs from phone ID in nested forms", () => {
    const siblingTemplate = `
      <input name="contact[siblings_attributes][NEW_RECORD][name]">
      <div data-template="phones">
        <input name="contact[siblings_attributes][NEW_RECORD][phones_attributes][NEW_RECORD][number]">
      </div>
    `;

    // Simulate adding sibling
    const siblingResult = replaceNewRecord(
      siblingTemplate,
      "siblings_attributes",
      "111",
    );

    expect(siblingResult).toContain("siblings_attributes][111][name]");
    expect(siblingResult).toContain(
      "siblings_attributes][111][phones_attributes][NEW_RECORD][number]",
    );

    // Then simulate adding phone (extract the nested template and process it)
    const phoneTemplate = `<input name="contact[siblings_attributes][111][phones_attributes][NEW_RECORD][number]">`;
    const phoneResult = replaceNewRecord(
      phoneTemplate,
      "phones_attributes",
      "222",
    );

    expect(phoneResult).toContain(
      "siblings_attributes][111][phones_attributes][222][number]",
    );
    expect(phoneResult).not.toContain("NEW_RECORD");
  });
});

describe("Form Submission Payload", () => {
  function serializeForm(form) {
    const formData = new FormData(form);
    const data = {};

    for (const [key, value] of formData.entries()) {
      const keys = key.split(/[\[\]]+/).filter((k) => k);
      let current = data;

      for (let i = 0; i < keys.length - 1; i++) {
        const k = keys[i];
        if (!current[k]) {
          current[k] = {};
        }
        current = current[k];
      }

      const lastKey = keys[keys.length - 1];
      current[lastKey] = value;
    }

    return data;
  }

  it("single sibling with all fields under same ID", () => {
    const form = document.createElement("form");
    const template = `
      <input name="contact[siblings_attributes][NEW_RECORD][name]" value="John">
      <input name="contact[siblings_attributes][NEW_RECORD][age]" value="25">
      <input name="contact[siblings_attributes][NEW_RECORD][_destroy]" value="0">
    `;

    const html = replaceNewRecord(template, "siblings_attributes", "123");
    form.innerHTML = html;

    const payload = serializeForm(form);

    expect(payload.contact.siblings_attributes["123"]).toBeDefined();
    expect(payload.contact.siblings_attributes["123"].name).toBe("John");
    expect(payload.contact.siblings_attributes["123"].age).toBe("25");
    expect(payload.contact.siblings_attributes["123"]._destroy).toBe("0");
    expect(payload.contact.siblings_attributes["NEW_RECORD"]).toBeUndefined();
  });

  it("multiple siblings with unique IDs", () => {
    const form = document.createElement("form");
    const template =
      '<input name="contact[siblings_attributes][NEW_RECORD][name]" value="test">';

    const sibling1 = replaceNewRecord(template, "siblings_attributes", "111");
    const sibling2 = replaceNewRecord(template, "siblings_attributes", "222");
    const sibling3 = replaceNewRecord(template, "siblings_attributes", "333");

    form.innerHTML = sibling1 + sibling2 + sibling3;

    const payload = serializeForm(form);

    expect(Object.keys(payload.contact.siblings_attributes)).toHaveLength(3);
    expect(payload.contact.siblings_attributes["111"]).toBeDefined();
    expect(payload.contact.siblings_attributes["222"]).toBeDefined();
    expect(payload.contact.siblings_attributes["333"]).toBeDefined();
  });

  it("nested sibling with phone - different IDs", () => {
    const form = document.createElement("form");

    const siblingTemplate = `
      <input name="contact[siblings_attributes][NEW_RECORD][name]" value="Jane">
      <input name="contact[siblings_attributes][NEW_RECORD][phones_attributes][NEW_RECORD][number]" value="555-1234">
    `;

    const siblingHtml = replaceNewRecord(
      siblingTemplate,
      "siblings_attributes",
      "100",
    );
    const finalHtml = replaceNewRecord(siblingHtml, "phones_attributes", "200");

    form.innerHTML = finalHtml;

    const payload = serializeForm(form);

    expect(payload.contact.siblings_attributes["100"]).toBeDefined();
    expect(payload.contact.siblings_attributes["100"].name).toBe("Jane");
    expect(
      payload.contact.siblings_attributes["100"].phones_attributes["200"],
    ).toBeDefined();
    expect(
      payload.contact.siblings_attributes["100"].phones_attributes["200"]
        .number,
    ).toBe("555-1234");
    expect(payload.contact.siblings_attributes["NEW_RECORD"]).toBeUndefined();
  });

  it("deeply nested: sibling with multiple phones", () => {
    const form = document.createElement("form");

    const siblingTemplate = `
      <input name="contact[siblings_attributes][NEW_RECORD][name]" value="Bob">
      <input name="contact[siblings_attributes][NEW_RECORD][phones_attributes][NEW_RECORD][number]">
    `;

    const siblingHtml = replaceNewRecord(
      siblingTemplate,
      "siblings_attributes",
      "10",
    );

    const phone1 = replaceNewRecord(
      '<input name="contact[siblings_attributes][10][phones_attributes][NEW_RECORD][number]" value="111-1111">',
      "phones_attributes",
      "20",
    );

    const phone2 = replaceNewRecord(
      '<input name="contact[siblings_attributes][10][phones_attributes][NEW_RECORD][number]" value="222-2222">',
      "phones_attributes",
      "30",
    );

    form.innerHTML =
      siblingHtml.replace(
        'phones_attributes][NEW_RECORD][number]">',
        'phones_attributes][NEW_RECORD][number]" disabled>',
      ) +
      phone1 +
      phone2;

    const payload = serializeForm(form);

    expect(payload.contact.siblings_attributes["10"].name).toBe("Bob");
    expect(
      payload.contact.siblings_attributes["10"].phones_attributes["20"].number,
    ).toBe("111-1111");
    expect(
      payload.contact.siblings_attributes["10"].phones_attributes["30"].number,
    ).toBe("222-2222");
    expect(
      Object.keys(payload.contact.siblings_attributes["10"].phones_attributes),
    ).toHaveLength(2);
  });
});
