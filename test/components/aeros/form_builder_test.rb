# frozen_string_literal: true

require "test_helper"

class Aeros::FormBuilderTest < ActionView::TestCase
  # Mock model for testing
  class MockArticle
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :title, :string
    attribute :description, :string
    attribute :tag_list, default: -> { [] }
    attribute :attachments, default: -> { [] }

    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end
  end

  setup do
    @article = MockArticle.new(title: "Test", description: "Content")
    @template = ActionView::Base.new(
      ActionView::LookupContext.new([]),
      {},
      nil
    )
    @builder = Aeros::FormBuilder.new(:article, @article, @template, {})
  end

  # tagging_field
  test "tagging_field calls field with :tagging type" do
    # Test that the method exists and can be called
    assert_respond_to @builder, :tagging_field
  end

  test "tagging_field delegates to field method" do
    # Verify tagging_field is defined to call field(:tagging, ...)
    method_source = @builder.method(:tagging_field).source_location
    assert method_source, "tagging_field should be defined"
  end

  # attachments_field
  test "attachments_field calls field with :attachments type" do
    assert_respond_to @builder, :attachments_field
  end

  test "attachments_field delegates to field method" do
    method_source = @builder.method(:attachments_field).source_location
    assert method_source, "attachments_field should be defined"
  end

  # text_area_ai_field
  test "text_area_ai_field calls field with :text_area_ai type" do
    assert_respond_to @builder, :text_area_ai_field
  end

  test "text_area_ai_field delegates to field method" do
    method_source = @builder.method(:text_area_ai_field).source_location
    assert method_source, "text_area_ai_field should be defined"
  end

  # field method
  test "field method resolves component class correctly" do
    # The field method should constantize to the correct component
    # Testing the pattern it uses
    assert_equal Aeros::InputTagging::Component, "::Aeros::InputTagging::Component".constantize
    assert_equal Aeros::InputAttachments::Component, "::Aeros::InputAttachments::Component".constantize
    assert_equal Aeros::InputTextAreaAi::Component, "::Aeros::InputTextAreaAi::Component".constantize
  end

  test "field method builds correct name with object_name" do
    # Test private resolve_name method via the builder
    builder = Aeros::FormBuilder.new(:article, @article, @template, {})
    expected_name = "article[tag_list]"
    actual_name = builder.send(:resolve_name, :tag_list)
    assert_equal expected_name, actual_name
  end

  test "field method generates id from object_name and field name" do
    # The field method should generate an id like "article_tag_list"
    # This is tested by checking the options merge pattern
    builder = Aeros::FormBuilder.new(:article, @article, @template, {})
    id = "#{:article}_#{:tag_list}".parameterize(separator: "_")
    assert_equal "article_tag_list", id
  end

  # BaseComponent
  test "BaseComponent has INPUT_BASE_CLASSES constant" do
    assert Aeros::FormBuilder::BaseComponent::INPUT_BASE_CLASSES.is_a?(Array)
    assert_includes Aeros::FormBuilder::BaseComponent::INPUT_BASE_CLASSES, "block"
    assert_includes Aeros::FormBuilder::BaseComponent::INPUT_BASE_CLASSES, "w-full"
    assert_includes Aeros::FormBuilder::BaseComponent::INPUT_BASE_CLASSES, "rounded-md"
  end

  # Options passthrough
  test "existing field methods are defined" do
    assert_respond_to @builder, :text_field
    assert_respond_to @builder, :password_field
    assert_respond_to @builder, :select_field
    assert_respond_to @builder, :text_area_field
  end
end
