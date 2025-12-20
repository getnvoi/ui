module Aeno
  module TurboHelpers
    def render_flash_toasts
      return unless flash.any?

      turbo_stream.prepend "flash" do
        flash.map { |type, message|
          render Aeno::Toast::Component.new(type: type, message: message)
        }.join.html_safe
      end
    end
  end
end
