class CreateAenoContactRelationships < ActiveRecord::Migration[8.1]
  def change
    create_table :aeno_contact_relationships do |t|
      t.references :contact, null: false, foreign_key: { to_table: :aeno_contacts }
      t.references :related_contact, null: false, foreign_key: { to_table: :aeno_contacts }
      t.string :relation_type

      t.timestamps
    end
  end
end
