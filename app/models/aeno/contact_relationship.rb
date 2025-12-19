class Aeno::ContactRelationship < ApplicationRecord
  belongs_to :contact, class_name: "Aeno::Contact"
  belongs_to :related_contact, class_name: "Aeno::Contact"

  accepts_nested_attributes_for :related_contact
end
