class AddCityAndStateToContacts < ActiveRecord::Migration[8.1]
  def change
    add_column :contacts, :city, :string
    add_column :contacts, :state, :string
  end
end
