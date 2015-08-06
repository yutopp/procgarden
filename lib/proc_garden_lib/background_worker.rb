require 'singleton'

class ProcGardenLib::BackgroundWorker
  include Singleton

  ThreadNum = 5
  def initialize
    @tickets = Queue.new

    @workers = (0...ThreadNum).map do |id|
      Thread.start do
        Rails.logger.debug "Worker / thread-#{id.to_s}"

        loop do
          begin
            task = @tickets.pop     # pop ticket data from task queue
            Rails.logger.debug "Worker-#{id} /task poped"

            # run!
            ActiveRecord::Base.connection_pool.with_connection do
              task.run()
            end

          rescue => e
            Rails.logger.error "Worker-#{id} / unexpected in Worker thread. ticket[id=#{model.id}]. \n!! class => #{e.class}\n!! detail => #{e}\n!! trace => #{$@.join("\n")}"

          ensure
            Rails.logger.debug "Worker-#{id} / finished work!"
          end
        end # loop
      end # Thread.start
    end # map

    ##
    #start_resume_incomplete_tickets_thread()
  end
  attr_accessor :tickets

  def self.add(task)
    self.instance.tickets.push(task)
  end

end # class Worker
