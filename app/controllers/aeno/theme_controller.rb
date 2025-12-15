module Aeno
  class ThemeController < ApplicationController
    def update
      session[:theme] = params[:theme] if %w[slate zinc].include?(params[:theme])
      session[:mode] = params[:mode] if %w[light dark].include?(params[:mode])

      redirect_back(fallback_location: root_path, status: :see_other)
    end
  end
end
