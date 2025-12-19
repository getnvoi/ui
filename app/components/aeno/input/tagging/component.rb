# frozen_string_literal: true

module Aeno::Input::Tagging
  class Component < ::Aeno::FormBuilder::BaseComponent
    option(:tags_url, optional: true)
    option(:create_url, optional: true)
    option(:selected_tags, default: proc { [] })
    option(:allow_create, default: proc { true })
    option(:max_tags, optional: true)

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

    examples("Input Tagging", description: "Tag input field") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "tags"
      end
    end
  end
end
