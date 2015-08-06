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

  def to_show_hash(output_offset = 0)
    output_offset ||= 0
    # return nil if exited.nil?   # result is not saved

    streams = ResultStream.where(exec_task_id: id).offset(output_offset)

    return {
      index: self.index,
      exited: self.exited,
      exit_status: self.exit_status,
      signaled: self.signaled,
      signal: self.signal,
      used_cpu_time_sec: self.used_cpu_time_sec,
      used_memory_bytes: self.used_memory_bytes,
      system_error_status: self.system_error_status,
      system_error_message: self.system_error_message,

      outputs_offset: output_offset,
      outputs_next_offset: streams.length,
      outputs: streams.map {|s| s.to_show_hash },

      created_at: self.created_at,
      updated_at: self.updated_at,
    }
  end
end
