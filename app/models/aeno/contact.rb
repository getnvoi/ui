class Aeno::Contact < ApplicationRecord
  has_many :contact_relationships, dependent: :destroy
  has_many :related_contacts, through: :contact_relationships
  has_many :phones, dependent: :destroy

  accepts_nested_attributes_for :contact_relationships, allow_destroy: true
  accepts_nested_attributes_for :related_contacts, allow_destroy: true
  accepts_nested_attributes_for :phones, allow_destroy: true

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
