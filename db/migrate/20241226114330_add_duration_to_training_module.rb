class AddDurationToTrainingModule < ActiveRecord::Migration[7.2]
  def change
    add_column :training_modules, :duration, :string
  end
end
