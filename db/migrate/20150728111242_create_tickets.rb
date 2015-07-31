class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.belongs_to :owner_entry, :class_name => "Entry"

      t.integer :index, null: false
      t.boolean :do_execute, null: false

      t.string :proc_name, null: false      # len(255)
      t.string :proc_version, null: false   # len(255)
      t.string :proc_label, null: false     # len(255)

      t.integer :phase, null: false

      t.timestamps null: false
    end
  end
end
