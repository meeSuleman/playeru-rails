class AddAnalysisStatusToUsersTrainingModule < ActiveRecord::Migration[7.2]
  def change
    add_column :users_training_modules, :analysis_status, :integer, default: 0
  end
end
