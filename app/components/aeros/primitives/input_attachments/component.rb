# frozen_string_literal: true

module Aeros::Primitives::InputAttachments
  class Component < ::Aeros::FormBuilder::BaseComponent
    prop :accept, description: "Accepted file types", default: -> { "*/*" }
    prop :max_files, description: "Maximum number of files", optional: true
    prop :max_size, description: "Maximum file size in bytes", optional: true
    prop :existing, description: "Existing attachments", default: -> { [] }
    prop :direct_upload_url, description: "Direct upload URL", optional: true

    examples("Input Attachments", description: "File upload with drag and drop") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview name: "attachments"
      end

      b.example(:images_only, title: "Images Only") do |e|
        e.preview name: "images", accept: "image/*"
      end

      b.example(:limited, title: "Limited Files") do |e|
        e.preview name: "documents", max_files: 5
      end
    end

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

    private

      def normalized_existing
        existing.map.with_index do |item, idx|
          item.merge(position: item[:position] || idx)
        end
      end
  end
end
