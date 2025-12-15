# frozen_string_literal: true

class BlocksController < ApplicationController
  helper Aeno::ApplicationHelper
  before_action :load_menu

  def show
    @component = params[:id]
    @group = :blocks
    render "blocks/#{@component.underscore}"
  end

  private

    def load_menu
      @menu = {
        base: %w[area button card input theme typography],
        primitives: %w[spinner],
        blocks: %w[floating-info-area]
      }
    end
end
