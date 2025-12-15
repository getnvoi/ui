module Aeno::Primitives::Drawer
  class Component < ::Aeno::ApplicationViewComponent
    prop :width, description: "Drawer width (CSS value)", default: -> { "33%" }
    prop :id, description: "HTML id attribute", optional: true
    prop :standalone, description: "Skip turbo frame wrapper", default: -> { false }
    prop :form_submit_close, description: "Close on form submit", default: -> { true }

    renders_one(:header)
    renders_one(:trigger)
    renders_one(:footer)

    examples("Drawer", description: "Slide-in panel from the right") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview
      end

      b.example(:widths, title: "Widths") do |e|
        e.preview width: "25%"
        e.preview width: "50%"
        e.preview width: "400px"
      end
    end

    private

      def data_actions
        actions = []
        actions << "turbo:frame-load->#{controller_name}#open" unless standalone
        actions << "turbo:submit-end->#{controller_name}#closeOnSubmit" if form_submit_close
        actions.join(" ").presence
      end
  end
end
