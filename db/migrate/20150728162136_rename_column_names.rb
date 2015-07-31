class RenameColumnNames < ActiveRecord::Migration
  def change
    rename_column :entries, :owner_user_id, :user_id
    rename_column :exec_tasks, :owner_ticket_id, :ticket_id
    rename_column :tickets, :owner_entry_id, :entry_id
  end
end
