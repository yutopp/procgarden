require 'torigoya_kit'

class ProcGardenLib::TicketExecutionTask
  class Last
  end

  def initialize(ticket_id, source_code_ids)
    @ticket_id = ticket_id
    @source_code_ids = source_code_ids
  end

  def run()
    puts @ticket_id
    ticket = Ticket.find(@ticket_id)
    raise "a" if ticket.nil?

    if ticket.do_execute == 0
      ticket.phase = Ticket::Phase::NotExecuted
      ticket.is_finished = true
      ticket.save
      return
    end

    source_codes = SourceCode.find(@source_code_ids)
    raise "b" if source_codes.nil? || source_codes.length == 0

    p ticket, ticket.proc_name, ticket.proc_version

    profile = BridgeFactoryAndCage::FactoryBridge.instance.get_profile(ticket.proc_name, ticket.proc_version)
    raise "b" if profile.nil?


    cage_bridge = BridgeFactoryAndCage::CagesBridge.instance

    addr = cage_bridge.sample
    client = TorigoyaKit::Client.new(addr.host, addr.port)

    #
    s_ticket = ProcGardenLib.create_kit_ticket_from_model(ticket, source_codes, profile)

    #
    queue = Queue.new
    th = Thread.start do
      update_result_of_db(queue, ticket)
    end

    # execute ticket!
    client.exec_ticket_with_stream(s_ticket) do |resp|
      queue.push resp
    end # do |res|

    th.join unless th.nil?

    ticket.phase = Ticket::Phase::Success
    ticket.is_finished = true
    ticket.save!

  rescue => e
    Rails.logger.error e
    ticket.phase = Ticket::Phase::Error
    ticket.is_finished = true
    ticket.save

    th.kill unless th.nil?
  end

  private
  def update_result_of_db(queue, ticket)
    current_mode = nil
    current_index = nil
    exec_task = nil

    loop do
      resp = queue.pop

      if resp.is_a?(TorigoyaKit::StreamOutputResult) ||
         resp.is_a?(TorigoyaKit::StreamExecutedResult)

        # get model
        if current_mode != resp.mode || current_index != resp.index
          exec_task = case resp.mode
                      when TorigoyaKit::ResultMode::CompileMode
                        ExecTask.where(compile_ticket_id: ticket.id)
                      when TorigoyaKit::ResultMode::LinkMode
                        ExecTask.where(link_ticket_id: ticket.id)
                      when TorigoyaKit::ResultMode::RunMode
                        ExecTask.where(exec_ticket_id: ticket.id)
                      end.where(index: resp.index).take

          current_mode = resp.mode
          current_index = resp.index

          ticket.set_phase case current_mode
                           when TorigoyaKit::ResultMode::CompileMode
                             Ticket::Phase::Compiling
                           when TorigoyaKit::ResultMode::LinkMode
                             Ticket::Phase::Linking
                           when TorigoyaKit::ResultMode::RunMode
                             Ticket::Phase::Running
                           end
          ticket.save!
        end

        raise "exec_task is nil" if exec_task.nil?
      # ticket.phase = Phase::Compiling
      # model.phase = Phase::Linking
      # model.phase = Phase::Running

        #
        if resp.is_a?(TorigoyaKit::StreamOutputResult)
          p "=" * 20

          # push output
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

          ticket.set_phase case current_mode
                           when TorigoyaKit::ResultMode::CompileMode
                             Ticket::Phase::Compiled
                           when TorigoyaKit::ResultMode::LinkMode
                             Ticket::Phase::Linked
                           end
          ticket.save!
        end

      elsif resp.is_a?(TorigoyaKit::StreamSystemError)
        # error
        raise res.message

      elsif resp.is_a?(TorigoyaKit::StreamExit)
        # finish
        break

      else
        # unexpected
        raise "Unexpected error: unknown message was recieved (#{res.class})"
      end
    end # loop
  end # def

end
