module Aeno
  class ApplicationController < ActionController::Base
    include Aeno::ApplicationHelper

    helper_method :current_theme, :current_mode

    def current_theme
      session[:theme] || "slate"
    end

    def current_mode
      session[:mode] || "light"
    end
  end
end
