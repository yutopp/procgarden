class RemoveUnusedColumnsExecTasks < ActiveRecord::Migration
  def change
    remove_column :exec_tasks, :proc_version
    remove_column :exec_tasks, :proc_label
  end
end
