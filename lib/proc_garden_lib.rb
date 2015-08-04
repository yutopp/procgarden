module ProcGardenLib

  class Profile
    def initialize(hash)
      @name = hash['name']
      @version = hash['version']
      @display_version = hash['display_version']
      @is_build_required = hash['is_build_required']
      @is_link_independent = hash['is_link_independent']
      @compile = hash['compile'].nil? ? nil : ExecProfile.new(hash['compile'])
      @link = hash['link'].nil? ? nil : ExecProfile.new(hash['link'])
      @exec = hash['exec'].nil? ? nil : ExecProfile.new(hash['exec'])
    end
    attr_reader :name, :version, :display_version
    attr_reader :is_build_required, :is_link_independent
    attr_reader :compile, :link, :exec
  end

  class ExecProfile
    def initialize(hash)
      @extention = hash['extension']    # string
      @raw_commands = hash['commands']  # []string
      @raw_envs = hash['envs']          # map[string]string
      @fixed_commands = hash['fixed_commands']          # [][]string
      @selectable_options = hash['selectable_options']  # map[string][]string
      @cpu_limit = hash['cpu_limit']        # number
      @memory_limit = hash['memory_limit']  # number
    end
    attr_reader :extention, :raw_commands, :raw_envs, :fixed_commands, :selectable_options
    attr_reader :cpu_limit, :memory_limit
  end

  def self.create_kit_ticket_from_model(ticket, source_codes, profile)
  end
end # module ProcGardenLib
