class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.belongs_to :owner_user, :class_name => "User"
      t.integer :visibility

      t.integer :viewed_count

      t.timestamps null: false
    end
  end
end
