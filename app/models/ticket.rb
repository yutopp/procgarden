class Ticket < ActiveRecord::Base
  class Phase
    Waiting = 0
    NotExecuted = 10
    Compiling = 200
    Compiled = 250
    Linking = 280
    Linked = 281
    Running = 300
    Success = 400
    Error = 401
  end

  belongs_to :entry

  has_one :compile, :class_name => "ExecTask", :foreign_key => "compile_ticket_id"
  has_one :link, :class_name => "ExecTask", :foreign_key => "link_ticket_id"
  has_many :execs, :class_name => "ExecTask", :foreign_key => "exec_ticket_id"

  def to_show_hash(offsets)
    compile_offset = if offsets.nil? then 0 else offsets['compile'] end
    link_offset = if offsets.nil? then 0 else offsets['link'] end
    execs_offsets = if offsets.nil? then [] else offsets['execs'] end

    return {
      index: index,
      do_execute: do_execute,
      proc_name: proc_name,
      proc_version: proc_version,
      proc_label: proc_label,
      phase: phase,
      is_finished: is_finished,

      created_at: created_at,
      updated_at: updated_at,

      compile: compile.to_show_hash(compile_offset),
      link: link.to_show_hash(link_offset),
      execs: execs.sort{|a, b| a.index <=> b.index }.map.with_index{|e, i| e.to_show_hash(execs_offsets[i]) },
    }
  end
end
