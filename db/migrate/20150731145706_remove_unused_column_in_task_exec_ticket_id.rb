class RemoveUnusedColumnInTaskExecTicketId < ActiveRecord::Migration
  def change
    remove_column :exec_tasks, :ticket_id
  end
end
