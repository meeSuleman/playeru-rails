class CreateCourses < ActiveRecord::Migration[7.2]
  def change
    create_table :courses do |t|
      t.string :title
      t.string :description
      t.json :meta_data

      t.timestamps
    end
  end
end
