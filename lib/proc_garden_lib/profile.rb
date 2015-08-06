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


  #
  def self.create_kit_ticket_from_model(ticket, source_codes, profile)
    filenames = source_codes.map{|s| s.name}
    s_sources = source_codes.map do |s|
      next TorigoyaKit::SourceData.new(s.name, s.source)
    end

    bi, ri = self.create_kit_inst_from_model(ticket, profile, filenames)

    return TorigoyaKit::Ticket.new("", s_sources, bi, ri)
  end

  def self.create_kit_inst_from_model(ticket, profile, filenames)
    build = if profile.is_build_required then
              c = self.create_kit_exec_task_from_model(
                ticket.compile,
                profile.compile,
                filenames
              )
              l = if profile.is_link_independent then
                    self.create_kit_exec_task_from_model(
                      ticket.link,
                      profile.link,
                      filenames
                    )
                  else
                    nil
                  end
              TorigoyaKit::BuildInstruction.new(c, l)
            else
              nil
            end

    inputs = ticket.execs.map do |exec|
      es = self.create_kit_exec_task_from_model(exec, profile.exec, filenames)
      stdin = unless exec.stdin.nil?
                TorigoyaKit::SourceData.new("", exec.stdin)
              else
                nil
              end
      # TODO: stdin length check
      next TorigoyaKit::Input.new(stdin, es)
    end
    run = TorigoyaKit::RunInstruction.new(inputs)

    return build, run
  end

  # create TorigoyaKit structure from
  # cpu: sec
  # memory: bytes
  def self.create_kit_exec_task_from_model(exec_ticket, exec_profile, filenames)
    raise "this section must be empty" if exec_profile.nil? && !exec_ticket.nil?
    raise "filenames must have at least 1 elements" if filenames.length == 0

    return if exec_profile.nil?

    p "-" * 20
    p filenames
    p exec_ticket, exec_profile

    cmds = exec_profile.raw_commands.map do |c|
      case c
      when "*CMD*"
        arr = []
        arr += exec_ticket.commands unless exec_ticket.nil?
        arr += exec_ticket.options.map do |tc|
          raise "there are no selectable options in this profile" if fixed_commands.nil?
          raise "" unless fixed_commands.has_key?(tc)
          next fixed_commands[tc]
        end unless exec_ticket.nil?
        arr += exec_profile.fixed_commands || []
        arr
      when "*FILES*"
        filenames
      else
        c
      end
    end.flatten

    #
    envs = exec_profile.raw_envs.map do |k, v|
      next "#{k}=#{v}"
    end

    #
    return TorigoyaKit::ExecutionSetting.new(
             cmds,
             envs,
             exec_profile.cpu_limit,
             exec_profile.memory_limit
           )
  end
end # module ProcGardenLib
