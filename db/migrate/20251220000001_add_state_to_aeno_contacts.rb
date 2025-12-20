class AddStateToAenoContacts < ActiveRecord::Migration[8.1]
  def change
    add_column :aeno_contacts, :state, :string
  end
end
