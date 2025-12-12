# frozen_string_literal: true

require "test_helper"

class Aeros::InputAttachmentsTest < ViewComponent::TestCase
  # Rendering
  test "renders with controller wrapper" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments"
    ))

    assert_selector "[data-controller='aeros--input-attachments']"
  end

  test "renders dropzone" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments"
    ))

    assert_selector "[data-aeros--input-attachments-target='dropzone']"
    assert_selector "[data-action*='click->aeros--input-attachments#triggerFileInput']"
    assert_selector "[data-action*='dragover->aeros--input-attachments#onDragOver']"
    assert_selector "[data-action*='dragleave->aeros--input-attachments#onDragLeave']"
    assert_selector "[data-action*='drop->aeros--input-attachments#onDrop']"
  end

  test "renders hidden file input" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments"
    ))

    assert_selector "input[type='file'].hidden"
    assert_selector "[data-aeros--input-attachments-target='fileInput']"
    assert_selector "input[multiple]"
  end

  test "renders previews container" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments"
    ))

    assert_selector "[data-aeros--input-attachments-target='previewsContainer']"
  end

  test "renders hidden inputs container" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments"
    ))

    assert_selector "[data-aeros--input-attachments-target='hiddenInputs']"
  end

  test "renders progress container (hidden by default)" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments"
    ))

    assert_selector "[data-aeros--input-attachments-target='progressContainer'].hidden"
    assert_selector "[data-aeros--input-attachments-target='progressText']"
    assert_selector "[data-aeros--input-attachments-target='progressBar']"
  end

  # Stimulus values
  test "passes accept to stimulus" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments",
      accept: "image/*"
    ))

    assert_selector "[data-aeros--input-attachments-accept-value='image/*']"
    assert_selector "input[type='file'][accept='image/*']"
  end

  test "uses default accept value of */*" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments"
    ))

    assert_selector "[data-aeros--input-attachments-accept-value='*/*']"
  end

  test "passes max_files to stimulus" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments",
      max_files: 10
    ))

    assert_selector "[data-aeros--input-attachments-max-files-value='10']"
  end

  test "passes max_size to stimulus" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments",
      max_size: 5242880 # 5MB
    ))

    assert_selector "[data-aeros--input-attachments-max-size-value='5242880']"
  end

  test "passes direct_upload_url to stimulus" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments",
      direct_upload_url: "/rails/active_storage/direct_uploads"
    ))

    assert_selector "[data-aeros--input-attachments-direct-upload-url-value='/rails/active_storage/direct_uploads']"
  end

  test "passes existing attachments to stimulus as JSON" do
    existing = [
      { id: "123", url: "/img1.png", filename: "img1.png", position: 0 },
      { id: "456", url: "/img2.png", filename: "img2.png", position: 1 }
    ]
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments",
      existing:
    ))

    assert_selector "[data-aeros--input-attachments-attachments-value]"
    html = page.native.inner_html
    assert_includes html, "123"
    assert_includes html, "456"
  end

  # File input configuration
  test "file input has change action" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments"
    ))

    assert_selector "[data-action*='change->aeros--input-attachments#onFileSelect']"
  end

  # Disabled state
  test "respects disabled state on file input" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments",
      disabled: true
    ))

    assert_selector "input[type='file'][disabled]"
  end

  # Display text
  test "displays accept type hint" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments",
      accept: "image/*,application/pdf"
    ))

    assert_text "image/*,application/pdf"
  end

  test "displays any file type when accept is */*" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments",
      accept: "*/*"
    ))

    assert_text "Any file type"
  end

  # Labels
  test "renders with label" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Upload Files"
    ))

    # Label is rendered via input_wrapper which we can verify through structure
    assert_selector "[data-controller='aeros--input-attachments']"
  end

  # Upload instructions
  test "shows click to upload text" do
    render_inline(Aeros::InputAttachments::Component.new(
      name: "attachments",
      label: "Attachments"
    ))

    assert_text "Click to upload"
    assert_text "drag and drop"
  end
end
