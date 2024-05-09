# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration["#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"]
  def change
    create_table :users do |t|
      t.string :name

      t.timestamps
    end
  end
end
