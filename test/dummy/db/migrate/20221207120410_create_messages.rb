class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :text
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end