class AddSequenceToCourse < ActiveRecord::Migration[7.2]
  def change
    add_column :courses, :sequence, :integer
  end
end
