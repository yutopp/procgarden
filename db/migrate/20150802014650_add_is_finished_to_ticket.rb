class AddIsFinishedToTicket < ActiveRecord::Migration
  def change
    add_column :tickets, :is_finished, :boolean, null: false, default: false
  end
end
