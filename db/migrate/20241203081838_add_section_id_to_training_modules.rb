class AddSectionIdToTrainingModules < ActiveRecord::Migration[7.2]
  def change
    add_reference :training_modules, :section, foreign_key: true
  end
end
