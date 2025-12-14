# frozen_string_literal: true

module Aeros::Primitives::InputTagging
  class Component < ::Aeros::FormBuilder::BaseComponent
    prop :tags_url, description: "URL to fetch tags", optional: true
    prop :create_url, description: "URL to create new tags", optional: true
    prop :selected_tags, description: "Pre-selected tags", default: -> { [] }
    prop :allow_create, description: "Allow creating new tags", default: -> { true }
    prop :max_tags, description: "Maximum number of tags", optional: true

    examples("Input Tagging", description: "Tag input with autocomplete") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "tags"
      end

      b.example(:with_selected, title: "With Selected Tags") do |e|
        e.preview name: "tags", selected_tags: [{ id: 1, name: "Ruby" }, { id: 2, name: "Rails" }]
      end

      b.example(:limited, title: "Limited Tags") do |e|
        e.preview name: "tags", max_tags: 3
      end
    end

    def stimulus_values
      values = {
        "#{controller_name}-selected-value" => selected_tags.to_json,
        "#{controller_name}-allow-create-value" => allow_create
      }
      values["#{controller_name}-tags-url-value"] = tags_url if tags_url
      values["#{controller_name}-create-url-value"] = create_url if create_url
      values["#{controller_name}-max-tags-value"] = max_tags if max_tags
      values
    end

    def input_name
      name.to_s.end_with?("[]") ? name : "#{name}[]"
    end
  end
end
