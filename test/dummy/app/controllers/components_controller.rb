# frozen_string_literal: true

class ComponentsController < ApplicationController
  helper Aeno::ApplicationHelper
  before_action :load_menu

  def index
  end

  def show
    @component = params[:id]
    @group = :base
    render "components/#{@component}"
  end

  private

    def load_menu
      @menu = {
        base: %w[area button card input theme typography],
        primitives: %w[spinner],
        blocks: %w[floating-info-area]
      }
      @group ||= nil
      @component ||= nil
    end
end
