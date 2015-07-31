class AllowNullExecTasks < ActiveRecord::Migration
  def change
    # allow nulls
    change_column_null :exec_tasks, :exited, true
    change_column_null :exec_tasks, :exit_status, true
    change_column_null :exec_tasks, :signaled, true
    change_column_null :exec_tasks, :signal, true
    change_column_null :exec_tasks, :used_cpu_time_sec, true
    change_column_null :exec_tasks, :used_memory_bytes, true
    change_column_null :exec_tasks, :system_error_status, true
    change_column_null :exec_tasks, :system_error_message, true
  end
end
