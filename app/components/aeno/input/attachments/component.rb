# frozen_string_literal: true

module Aeno::Input::Attachments
  class Component < ::Aeno::FormBuilder::BaseComponent
    option(:accept, default: proc { "*/*" })
    option(:max_files, optional: true)
    option(:max_size, optional: true) # in bytes
    option(:existing, default: proc { [] }) # Array of existing attachments with {id, url, filename, position}
    option(:direct_upload_url, optional: true)

    def stimulus_values
      values = {
        "#{controller_name}-accept-value" => accept,
        "#{controller_name}-attachments-value" => normalized_existing.to_json
      }
      values["#{controller_name}-max-files-value"] = max_files if max_files
      values["#{controller_name}-max-size-value"] = max_size if max_size
      values["#{controller_name}-direct-upload-url-value"] = direct_upload_url if direct_upload_url
      values
    end

    def input_name
      "#{name}[]"
    end

    def positions_name
      "#{name}_positions"
    end

    examples("Input Attachments", description: "File attachment input") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "attachments"
      end
    end

    private

      def normalized_existing
        existing.map.with_index do |item, idx|
          item.merge(position: item[:position] || idx)
        end
      end
  end
end
