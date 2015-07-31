class RemoveUnusedColumnInTaskExec < ActiveRecord::Migration
  def change
    remove_column :exec_tasks, :extra_commands
  end
end
