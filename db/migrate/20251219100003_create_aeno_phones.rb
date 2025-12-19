class CreateAenoPhones < ActiveRecord::Migration[8.1]
  def change
    create_table :aeno_phones do |t|
      t.references :contact, null: false, foreign_key: { to_table: :aeno_contacts }
      t.string :number
      t.string :phone_type

      t.timestamps
    end
  end
end
