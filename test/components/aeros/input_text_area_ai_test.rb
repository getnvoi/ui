# frozen_string_literal: true

require "test_helper"

class Aeros::InputTextAreaAiTest < ViewComponent::TestCase
  # Rendering
  test "renders with controller wrapper" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "description",
      label: "Description",
      ai_url: "/ai/generate"
    ))

    assert_selector "[data-controller='aeros--input-text-area-ai']"
  end

  test "renders textarea with attributes" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      id: "article_content",
      label: "Content",
      ai_url: "/ai/generate",
      placeholder: "Enter content...",
      rows: 10
    ))

    assert_selector "textarea[name='content']"
    assert_selector "textarea[id='article_content']"
    assert_selector "textarea[placeholder='Enter content...']"
    assert_selector "textarea[rows='10']"
    assert_selector "[data-aeros--input-text-area-ai-target='textarea']"
  end

  test "renders textarea with default rows" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate"
    ))

    assert_selector "textarea[rows='6']"
  end

  test "renders textarea with value" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate",
      value: "Existing content"
    ))

    assert_text "Existing content"
  end

  # AI Assist Button
  test "renders AI assist button" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate"
    ))

    assert_selector "[data-aeros--input-text-area-ai-target='aiButton']"
    assert_selector "[data-action='click->aeros--input-text-area-ai#generateAi']"
  end

  test "renders button with default label" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate"
    ))

    assert_selector "[data-aeros--input-text-area-ai-target='buttonLabel']", text: "AI Assist"
  end

  test "renders button with custom label" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate",
      ai_button_label: "Generate"
    ))

    assert_selector "[data-aeros--input-text-area-ai-target='buttonLabel']", text: "Generate"
  end

  test "renders button icon and spinner targets" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate"
    ))

    assert_selector "[data-aeros--input-text-area-ai-target='buttonIcon']"
    assert_selector "[data-aeros--input-text-area-ai-target='buttonSpinner'].hidden"
  end

  # Button positioning
  test "positions button at bottom_right by default" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate"
    ))

    assert_selector ".bottom-2.right-2"
  end

  test "positions button at top_right" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate",
      ai_button_position: :top_right
    ))

    assert_selector ".top-2.right-2"
  end

  test "positions button at top_left" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate",
      ai_button_position: :top_left
    ))

    assert_selector ".top-2.left-2"
  end

  test "positions button at bottom_left" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate",
      ai_button_position: :bottom_left
    ))

    assert_selector ".bottom-2.left-2"
  end

  # Streaming indicator
  test "renders streaming indicator (hidden by default)" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate"
    ))

    assert_selector "[data-aeros--input-text-area-ai-target='streamingIndicator'].hidden"
    assert_text "Generating..."
  end

  # Stimulus values
  test "passes ai_url to stimulus" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/text/generate"
    ))

    assert_selector "[data-aeros--input-text-area-ai-ai-url-value='/ai/text/generate']"
  end

  test "passes ai_prompt to stimulus" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate",
      ai_prompt: "Write about {{topic}}"
    ))

    assert_selector "[data-aeros--input-text-area-ai-ai-prompt-value='Write about {{topic}}']"
  end

  test "passes system_prompts to stimulus as JSON" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate",
      system_prompts: ["Be concise", "Write professionally"]
    ))

    assert_selector "[data-aeros--input-text-area-ai-system-prompts-value]"
    html = page.native.inner_html
    assert_includes html, "Be concise"
    assert_includes html, "Write professionally"
  end

  test "passes model to stimulus" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate",
      model: "gpt-4"
    ))

    assert_selector "[data-aeros--input-text-area-ai-model-value='gpt-4']"
  end

  test "passes button label to stimulus" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate",
      ai_button_label: "Magic"
    ))

    assert_selector "[data-aeros--input-text-area-ai-ai-button-label-value='Magic']"
  end

  # Disabled state
  test "respects disabled state on textarea" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate",
      disabled: true
    ))

    assert_selector "textarea[disabled]"
  end

  test "respects disabled state on button" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate",
      disabled: true
    ))

    assert_selector "button[disabled]"
  end

  # Required attribute
  test "sets required attribute when required" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate",
      required: true
    ))

    assert_selector "textarea[required]"
  end

  # Data attributes passthrough
  test "passes custom data attributes" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate",
      data: { custom: "value", another: "test" }
    ))

    assert_selector "textarea[data-custom='value']"
    assert_selector "textarea[data-another='test']"
  end

  # Optional values not rendered when nil
  test "does not render ai_prompt if not provided" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate"
    ))

    assert_no_selector "[data-aeros--input-text-area-ai-ai-prompt-value]"
  end

  test "does not render model if not provided" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate"
    ))

    assert_no_selector "[data-aeros--input-text-area-ai-model-value]"
  end

  test "does not render system_prompts if empty" do
    render_inline(Aeros::InputTextAreaAi::Component.new(
      name: "content",
      label: "Content",
      ai_url: "/ai/generate",
      system_prompts: []
    ))

    assert_no_selector "[data-aeros--input-text-area-ai-system-prompts-value]"
  end
end
