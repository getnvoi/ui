module Aeno::Examples
  class ContactsController < ::Aeno::ApplicationController
    layout "aeno/application"
    before_action :set_contact, only: [:edit, :update, :destroy]

    def index
      @contacts = Aeno::Contact.all
      render Aeno::Examples::Contacts::IndexComponent.new(contacts: @contacts)
    end

    def new
      @contact = Aeno::Contact.new

      render turbo_stream: turbo_stream.append("drawers-container") do
        render Aeno::Drawer::Component.new(
          id: "drawer-new-contact",
          frame_id: "drawer-content-new-contact",
          width: "w-2/5"
        ) do
          render Aeno::Examples::Contacts::DrawerContentComponent.new(contact: @contact)
        end
      end
    end

    def create
      @contact = Aeno::Contact.new(contact_params)

      if @contact.save
        flash.now[:notice] = "Contact created successfully"
        render turbo_stream: [
          turbo_stream.remove("drawer-new-contact"),
          render_flash_toasts,
          turbo_stream.prepend("contacts-list") do
            render Aeno::Examples::Contacts::ListItemComponent.new(contact: @contact)
          end
        ]
      else
        # Error: Update ONLY content - NO re-animation!
        render turbo_stream: turbo_stream.update("drawer-content-new-contact") do
          render Aeno::Examples::Contacts::DrawerContentComponent.new(contact: @contact)
        end
      end
    end

    def edit
      render turbo_stream: turbo_stream.append("drawers-container") do
        render Aeno::Drawer::Component.new(
          id: "drawer-#{dom_id(@contact)}",
          frame_id: "drawer-content-#{dom_id(@contact)}",
          width: "w-2/5"
        ) do
          render Aeno::Examples::Contacts::DrawerContentComponent.new(contact: @contact)
        end
      end
    end

    def update
      if @contact.update(contact_params)
        flash.now[:notice] = "Contact updated successfully"
        render turbo_stream: [
          turbo_stream.remove("drawer-#{dom_id(@contact)}"),
          render_flash_toasts,
          turbo_stream.replace(dom_id(@contact)) do
            render Aeno::Examples::Contacts::ListItemComponent.new(contact: @contact)
          end
        ]
      else
        # Error: Update ONLY content - NO re-animation!
        render turbo_stream: turbo_stream.update("drawer-content-#{dom_id(@contact)}") do
          render Aeno::Examples::Contacts::DrawerContentComponent.new(contact: @contact)
        end
      end
    end

    def destroy
      @contact.destroy
      flash.now[:notice] = "Contact deleted"
      render turbo_stream: [
        turbo_stream.remove(dom_id(@contact)),
        render_flash_toasts
      ]
    end

    private

    def set_contact
      @contact = Aeno::Contact.find(params[:id])
    end

    def contact_params
      params.require(:contact).permit(:name, :email, :city, :state)
    end
  end
end
