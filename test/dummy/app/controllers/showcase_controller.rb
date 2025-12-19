# frozen_string_literal: true

class ShowcaseController < ApplicationController
  helper Aeno::ApplicationHelper

  def index
    @components = discover_components
  end

  def show
    component_class = "Aeno::#{params[:id].camelize}::Component".constantize
    @component = component_class
    @title = component_class.examples_title
    @description = component_class.examples_description
    @examples = component_class.examples_list
  rescue NameError
    render plain: "Component not found", status: :not_found
  end

  private

    def discover_components
      Dir.glob(Rails.root.join("../../app/components/aeno/**/component.rb")).map do |path|
        path.match(/aeno\/(.+)\/component\.rb/)[1]
      end.sort
    end
end
