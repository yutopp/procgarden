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
end
