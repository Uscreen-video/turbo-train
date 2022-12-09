class CreateUsers < ActiveRecord::Migration[Rails.version]
  def change
    create_table :users do |t|
      t.string :name

      t.timestamps
    end
  end
end
