# frozen_string_literal: true

module Aeno::Input::TextAreaAi
  class Component < ::Aeno::FormBuilder::BaseComponent
    option(:rows, default: proc { 6 })
    option(:ai_url)
    option(:ai_prompt, optional: true)
    option(:system_prompts, default: proc { [] })
    option(:model, optional: true)
    option(:ai_button_label, default: proc { "AI Assist" })
    option(:ai_button_position, default: proc { :bottom_right })

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

    examples("Input Text Area AI", description: "AI-enhanced text area") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "content", ai_url: "/ai/assist"
      end
    end
  end
end
