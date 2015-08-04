class ExecTask < ActiveRecord::Base
  serialize :commands
  serialize :options
  serialize :extra_commands

  serialize :sent_envs
  serialize :sent_commands

  has_many :result_streams

  def self.new_from_hash(hash, index)
    hash ||= {}

    return ExecTask.new(
             index: index,
             commands: hash[:commands] || [],
             options: hash[:options] || [],
             stdin: hash[:stdin] || "",
           )
  end

  def to_show_hash(routput_offset = 0)
    output_offset ||= 0
    return nil if exited.nil?   # result is not saved

    streams = ResultStream.where(exec_task_id: id).offset(output_offset)

    return {
      index: index,
      exited: exited,
      exit_status: exit_status,
      signaled: signaled,
      signal: signal,
      used_cpu_time_sec: used_cpu_time_sec,
      used_memory_bytes: used_memory_bytes,
      system_error_status: system_error_status,
      system_error_message: system_error_message,

      outputs_offset: output_offset,
      outputs_next_offset: streams.length,
      outputs: streams.map {|s| s.to_show_hash },

      created_at: created_at,
      updated_at: updated_at,
    }
  end
end
