class CreateExecTasks < ActiveRecord::Migration
  def change
    create_table :exec_tasks do |t|
      t.belongs_to :owner_ticket, :class_name => "Ticket"

      t.integer :index, null: false

      t.text :commands          # selialized
      t.text :options           # selialized
      t.text :extra_commands    # selialized
      t.text :stdin
      t.boolean :is_stdout_merged, null: false, default: false

      t.text :sent_envs
      t.text :sent_commands

      # result
      t.boolean :exited, null: false
      t.integer :exit_status, null: false

      t.boolean :signaled, null: false
      t.integer :signal, null: false

      t.float :used_cpu_time_sec, null: false
      t.integer :used_memory_bytes, null: false

      t.integer :system_error_status, null: false
      t.string :system_error_message, null: false

      t.string :proc_version, null: false   # len(255)
      t.string :proc_label, null: false     # len(255)

      t.timestamps null: false
    end
  end
end
