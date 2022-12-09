class CreateUsers < ActiveRecord::Migration[ENV['RAILS_VERSION']]
  def change
    create_table :users do |t|
      t.string :name

      t.timestamps
    end
  end
end
