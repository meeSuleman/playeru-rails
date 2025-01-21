class CreateTrainingModules < ActiveRecord::Migration[7.2]
  def change
    create_table :training_modules do |t|
      t.string :name
      t.integer :sequence
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
