class CreateSourceCodes < ActiveRecord::Migration
  def change
    create_table :source_codes do |t|
      t.belongs_to :entry

      t.string :name, null: false, :default => '*default*'
      t.text :source, null: false, :default => ''
      t.timestamps null: false
    end
  end
end
