module Aeno::Toast
  class Component < ::Aeno::ApplicationViewComponent
    option :message
    option :type, default: proc { :notice } # :notice, :alert, :error
    option :duration, default: proc { 5000 } # milliseconds
    option :dismissible, default: proc { true }

    style :container do
      base { "pointer-events-auto w-full max-w-sm rounded-lg shadow-lg ring-1 ring-black ring-opacity-5 overflow-hidden" }

      variants do
        type do
          notice { "bg-green-50 border border-green-200" }
          alert { "bg-yellow-50 border border-yellow-200" }
          error { "bg-red-50 border border-red-200" }
        end
      end
    end

    style :icon_color do
      variants do
        type do
          notice { "text-green-400" }
          alert { "text-yellow-400" }
          error { "text-red-400" }
        end
      end
    end

    def icon_name
      case type.to_sym
      when :notice then "check-circle"
      when :alert then "alert-triangle"
      when :error then "x-circle"
      else "info"
      end
    end
  end
end
