# frozen_string_literal: true

require "test_helper"

class Aeros::InputTaggingTest < ViewComponent::TestCase
  # Rendering
  test "renders with label and wrapper" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags"
    ))

    assert_selector "[data-controller='aeros--input-tagging']"
  end

  test "renders selected tags as pills" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags",
      selected_tags: ["ruby", "rails"]
    ))

    assert_selector "[data-aeros--input-tagging-target='selectedContainer']"
    assert_selector "[data-aeros--input-tagging-target='tag']", count: 2
    assert_selector "[data-tag-name='ruby']"
    assert_selector "[data-tag-name='rails']"
  end

  test "renders hidden inputs for form submission" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "article[tag_list]",
      label: "Tags",
      selected_tags: ["ruby", "rails"]
    ))

    assert_selector "[data-aeros--input-tagging-target='hiddenInputs']"
    assert_selector "input[type='hidden'][name='article[tag_list][]'][value='ruby']", visible: false
    assert_selector "input[type='hidden'][name='article[tag_list][]'][value='rails']", visible: false
  end

  test "renders search input with placeholder" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags",
      placeholder: "Find tags..."
    ))

    assert_selector "input[type='text'][placeholder='Find tags...']"
    assert_selector "[data-aeros--input-tagging-target='search']"
  end

  test "renders search input with default placeholder" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags"
    ))

    assert_selector "input[type='text'][placeholder='Search or add tags...']"
  end

  test "renders dropdown container" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags"
    ))

    assert_selector "[data-aeros--input-tagging-target='dropdown']"
    assert_selector "[data-aeros--input-tagging-target='optionsContainer']"
  end

  # Stimulus values
  test "passes tags_url to stimulus" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags",
      tags_url: "/tags.json"
    ))

    assert_selector "[data-aeros--input-tagging-tags-url-value='/tags.json']"
  end

  test "passes create_url to stimulus" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags",
      create_url: "/tags"
    ))

    assert_selector "[data-aeros--input-tagging-create-url-value='/tags']"
  end

  test "passes allow_create to stimulus" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags",
      allow_create: false
    ))

    assert_selector "[data-aeros--input-tagging-allow-create-value='false']"
  end

  test "passes max_tags to stimulus" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags",
      max_tags: 5
    ))

    assert_selector "[data-aeros--input-tagging-max-tags-value='5']"
  end

  test "passes selected array to stimulus" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags",
      selected_tags: ["ruby", "rails"]
    ))

    assert_selector "[data-aeros--input-tagging-selected-value]"
    html = page.native.inner_html
    assert_includes html, '["ruby","rails"]'
  end

  # Create option
  test "renders create option when allow_create is true" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags",
      allow_create: true
    ))

    assert_selector "[data-aeros--input-tagging-target='createOption']"
    assert_selector "[data-action='click->aeros--input-tagging#createTag']"
  end

  test "does not render create option when allow_create is false" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags",
      allow_create: false
    ))

    assert_no_selector "[data-aeros--input-tagging-target='createOption']"
  end

  # Disabled state
  test "respects disabled state" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags",
      disabled: true
    ))

    assert_selector "input[type='text'][disabled]"
  end

  # Input name
  test "appends [] to input name for array params" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags",
      selected_tags: ["ruby"]
    ))

    assert_selector "input[type='hidden'][name='tags[]']", visible: false
  end

  test "preserves [] in input name if already present" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "article[tags][]",
      label: "Tags",
      selected_tags: ["ruby"]
    ))

    assert_selector "input[type='hidden'][name='article[tags][]']", visible: false
  end

  # Loading and empty states
  test "renders loading indicator target" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags"
    ))

    assert_selector "[data-aeros--input-tagging-target='loading']"
  end

  test "renders empty state target" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags"
    ))

    assert_selector "[data-aeros--input-tagging-target='empty']"
  end

  # Remove button
  test "renders remove button for each tag" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags",
      selected_tags: ["ruby"]
    ))

    assert_selector "[data-action='click->aeros--input-tagging#removeTag']"
  end

  # Keyboard navigation actions
  test "wires keyboard events to search input" do
    render_inline(Aeros::InputTagging::Component.new(
      name: "tags",
      label: "Tags"
    ))

    assert_selector "[data-action*='input->aeros--input-tagging#onSearchInput']"
    assert_selector "[data-action*='focus->aeros--input-tagging#onFocus']"
    assert_selector "[data-action*='keydown->aeros--input-tagging#onKeydown']"
  end
end
