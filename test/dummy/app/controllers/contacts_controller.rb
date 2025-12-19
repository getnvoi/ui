class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  def index
    @contacts = Aeno::Contact.includes(:contact_relationships, :phones).all
  end

  def show
  end

  def new
    @contact = Aeno::Contact.new
  end

  def edit
  end

  def create
    Rails.logger.info "=" * 80
    Rails.logger.info "RECEIVED PARAMS:"
    Rails.logger.info params.to_unsafe_h.inspect
    Rails.logger.info "=" * 80

    @contact = Aeno::Contact.new(contact_params)

    if @contact.save
      Rails.logger.info "SUCCESS: Contact created with ID #{@contact.id}"
      Rails.logger.info "Relationships count: #{@contact.contact_relationships.count}"
      Rails.logger.info "Phones count: #{@contact.phones.count}"

      redirect_to @contact, notice: "Contact was successfully created."
    else
      Rails.logger.error "FAILED: #{@contact.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    Rails.logger.info "=" * 80
    Rails.logger.info "UPDATE PARAMS:"
    Rails.logger.info params.to_unsafe_h.inspect
    Rails.logger.info "=" * 80

    if @contact.update(contact_params)
      Rails.logger.info "SUCCESS: Contact updated"
      redirect_to @contact, notice: "Contact was successfully updated."
    else
      Rails.logger.error "FAILED: #{@contact.errors.full_messages}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_url, notice: "Contact was successfully destroyed."
  end

  private

    def set_contact
      @contact = Aeno::Contact.find(params[:id])
    end

    def contact_params
      params.require(:contact).permit(
        :name,
        :email,
        :company,
        :job_title,
        :notes,
        :birth_date,
        :address,
        :city,
        :country,
        phones_attributes: [
          :id, :number, :phone_type, :_destroy
        ],
        related_contacts_attributes: [
          :id, :name, :email, :company, :job_title, :notes, :birth_date, :address, :city, :country, :_destroy,
          phones_attributes: [:id, :number, :phone_type, :_destroy]
        ],
        contact_relationships_attributes: [
          :id, :relation_type, :_destroy,
          related_contact_attributes: [
            :id, :name, :email, :company, :job_title, :notes, :birth_date, :address, :city, :country,
            phones_attributes: [:id, :number, :phone_type, :_destroy]
          ]
        ]
      )
    end
end
