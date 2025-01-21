class CreateUsersTrainingModules < ActiveRecord::Migration[7.2]
  def change
    create_table :users_training_modules do |t|
      t.references :user, null: false, foreign_key: true
      t.references :training_module, null: false, foreign_key: true
      t.integer :status
      t.boolean :is_favorite, default: false

      t.timestamps
    end
  end
end
