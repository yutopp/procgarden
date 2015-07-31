class FixRelations < ActiveRecord::Migration
  def change
    remove_reference :exec_tasks, :owner_ticket

    add_reference :exec_tasks, :compile_ticket, index: true
    add_reference :exec_tasks, :link_ticket, index: true
    add_reference :exec_tasks, :exec_ticket, index: true
  end
end
