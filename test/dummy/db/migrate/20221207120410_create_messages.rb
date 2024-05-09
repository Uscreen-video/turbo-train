# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration["#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"]
  def change
    create_table :messages do |t|
      t.string :text
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
