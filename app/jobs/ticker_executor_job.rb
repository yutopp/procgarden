require 'torigoya_kit'

class TickerExecutorJob < ActiveJob::Base
  queue_as :high

  # create TorigoyaKit structure from
  # cpu: sec
  # memory: bytes
  def exec_task(exec_ticket, exec_profile, filenames)
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

  # [TorigoyaKit::BuildInstruction, [TorigoyaKit::Input]]
  def hoge(ticket, profile, filenames)
    build = if profile.is_build_required then
              c = exec_task(ticket.compile, profile.compile, filenames)
              l = if profile.is_link_independent then
                    exec_task(ticket.link, profile.link, filenames)
                  else
                    nil
                  end
              TorigoyaKit::BuildInstruction.new(c, l)
            else
              nil
            end

    inputs = ticket.execs.map do |exec|
      es = exec_task(exec, profile.exec, filenames)
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



  def perform(ticket_id, source_code_ids)
    puts ticket_id
    ticket = Ticket.find(ticket_id)
    raise "a" if ticket.nil?
    source_codes = SourceCode.find(source_code_ids)
    raise "b" if source_codes.nil? || source_codes.length == 0

    p ticket, ticket.proc_name, ticket.proc_version

    profile = BridgeFactoryAndCage::FactoryBridge.instance.get_profile(ticket.proc_name, ticket.proc_version)
    raise "b" if profile.nil?


    cage_bridge = BridgeFactoryAndCage::CagesBridge.instance

    addr = cage_bridge.sample
    client = TorigoyaKit::Client.new(addr.host, addr.port)

    #
    s_sources = source_codes.map do |s|
      next TorigoyaKit::SourceData.new(s.name, s.source)
    end

    #
    bi, ri = hoge(ticket, profile, source_codes.map{|s| s.name})


    # ticket!
    s_ticket = TorigoyaKit::Ticket.new("", s_sources, bi, ri)

    client.exec_ticket_with_stream(s_ticket) do |resp|
      p "response: ", resp

      if resp.is_a?(TorigoyaKit::StreamOutputResult) || resp.is_a?(TorigoyaKit::StreamExecutedResult)

        exec_task = case resp.mode
                    when TorigoyaKit::ResultMode::CompileMode
                      ExecTask.where(compile_ticket_id: ticket.id)
                    when TorigoyaKit::ResultMode::LinkMode
                      ExecTask.where(link_ticket_id: ticket.id)
                    when TorigoyaKit::ResultMode::RunMode
                      ExecTask.where(exec_ticket_id: ticket.id)
                    end.where(index: resp.index).take

        raise "exec_task is nil" if exec_task.nil?
        # ticket.phase = Phase::Compiling
        # model.phase = Phase::Linking
        # model.phase = Phase::Running

        #
        if resp.is_a?(TorigoyaKit::StreamOutputResult)
          p "=" * 20

          ResultStream.create!(
            exec_task_id: exec_task.id,
            fd: resp.output.fd,
            buffer: resp.output.buffer,
          )

        elsif resp.is_a?(TorigoyaKit::StreamExecutedResult)
          # result
          exec_task.exited = resp.result.exited
          exec_task.exit_status = resp.result.exit_status
          exec_task.signaled = resp.result.signaled
          exec_task.signal = resp.result.signal
          exec_task.used_cpu_time_sec = resp.result.used_cpu_time_sec
          exec_task.used_memory_bytes = resp.result.used_memory_bytes
          exec_task.system_error_status = resp.result.system_error_status
          exec_task.system_error_message = resp.result.system_error_message

          exec_task.save!
        end

      elsif resp.is_a?(TorigoyaKit::StreamSystemError)
        # error
        raise res.message

      else
        # unexpected
        raise "Unexpected error: unknown message was recieved (#{res.class})"
      end

      ticket.save!

      #Rails.logger.debug res.to_s

    end # do |res|
  end

end
