# frozen_string_literal: true

module Aeno::Primitives::InputTextAreaAi
  class Component < ::Aeno::FormBuilder::BaseComponent
    prop :rows, description: "Number of visible rows", default: -> { 6 }
    prop :ai_url, description: "AI endpoint URL"
    prop :ai_prompt, description: "AI prompt template", optional: true
    prop :system_prompts, description: "System prompts array", default: -> { [] }
    prop :model, description: "AI model to use", optional: true
    prop :ai_button_label, description: "AI button label", default: -> { "AI Assist" }
    prop :ai_button_position, description: "AI button position", default: -> { :bottom_right }

    examples("Input Text Area AI", description: "Text area with AI assistance") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "content", ai_url: "/api/ai/complete"
      end

      b.example(:custom_label, title: "Custom Button") do |e|
        e.preview name: "description", ai_url: "/api/ai", ai_button_label: "Generate"
      end
    end

    def stimulus_values
      values = {
        "#{controller_name}-ai-url-value" => ai_url,
        "#{controller_name}-ai-button-label-value" => ai_button_label
      }
      values["#{controller_name}-ai-prompt-value"] = ai_prompt if ai_prompt.present?
      values["#{controller_name}-system-prompts-value"] = system_prompts.to_json if system_prompts.any?
      values["#{controller_name}-model-value"] = model if model.present?
      values
    end

    def button_position_classes
      case ai_button_position.to_sym
      when :top_right
        "top-2 right-2"
      when :top_left
        "top-2 left-2"
      when :bottom_left
        "bottom-2 left-2"
      else
        "bottom-2 right-2"
      end
    end
  end
end
