class CreateAenoContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :aeno_contacts do |t|
      t.string :name
      t.string :email
      t.string :company
      t.string :job_title
      t.text :notes
      t.date :birth_date
      t.string :address
      t.string :city
      t.string :country

      t.timestamps
    end
  end
end
