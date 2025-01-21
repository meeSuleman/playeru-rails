class AddDefaultValueToSkillLevelInUser < ActiveRecord::Migration[7.2]
  def up
    change_column :users, :skill_level, :integer, :default => 1
  end

  def down
    change_column :users, :skill_level, :integer, :default => 0
  end
end
