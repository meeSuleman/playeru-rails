class AddCloudFrontUrlToTrainingModule < ActiveRecord::Migration[7.2]
  def change
    add_column :training_modules, :cloudfront_url, :string
  end
end
