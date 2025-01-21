class CreateSections < ActiveRecord::Migration[7.2]
  def change
    create_table :sections do |t|
      t.string :overview_text
      t.string :name
      t.float :rating

      t.timestamps
    end
  end
end
