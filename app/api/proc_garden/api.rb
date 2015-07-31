module ProcGarden
  class API < Grape::API
    version 'v1', using: :path
    format :json
    error_formatter :json, Formatter::Error

    helpers do
      def auth
        #@current_user ||= User.authorize!(env)
      end

      def auth!
        #error!('401 Unauthorized', 401) unless current_user
      end
    end

    resource :compilers do
      get do
      end
    end

    resource :entries do
      # post entry
      params do
        optional :visibility, type: Integer, default: 1, values: [0, 1, 2], desc: "0: public / 1: protected / 2: private"
        optional :description, type: String, default: ""

        requires :source_codes, type: Array, desc: "Array<SourceCode>" do
          requires :filename, type: String
          requires :code, type: String
        end

        requires :tickets, type: Array, desc: "Array<Ticket>" do
          requires :use, type: String
          requires :version, type: String
          optional :do_exec, type: Integer, default: 1, values: [0, 1], desc: "0: not execute / 1: execute"

          optional :compile, type: Hash do
            optional :commands, type: Array[String]
            optional :options, type: Array[String]
          end

          optional :link, type: Hash do
            optional :commands, type: Array[String]
            optional :options, type: Array[String]
          end

          optional :execs, type: Array do
            optional :commands, type: Array[String]
            optional :options, type: Array[String]
            optional :extra_commands, type: Array[String]
          end
        end
      end
      post do
        begin
          # source codes
          source_codes = params[:source_codes].map do |s|
            next SourceCode.new(
                   name: s[:filename],
                   source: s[:code],
                 )
          end

          # tickets
          tickets = params[:tickets].map.with_index do |t, index|
            puts "ticket #{index} #{t}"
            profile = BridgeFactoryAndCage::FactoryBridge.instance.get_profile(t.use, t.version)
            raise "compiler not supported: #{t.use}/#{t.version}" if profile.nil?

            if t[:do_exec]
              if t[:execs].nil? || t[:execs].length == 0
                raise "execs required"
              end
            end

            p t

            compile_task = ExecTask.new_from_hash(t[:compile], 0)
            link_task = ExecTask.new_from_hash(t[:link], 0)
            exec_tasks = t[:execs].map.with_index {|h, i| ExecTask.new_from_hash(h, i)}

            p "compile_task => #{compile_task}"
            p "link_task => #{link_task}"
            p "exec_tasks => #{exec_tasks}"

            next Ticket.new(
                   index: index,
                   do_execute: t.do_exec,
                   proc_name: profile.name,
                   proc_version: profile.version,
                   proc_label: profile.display_version,
                   phase: 1,
                   compile: compile_task,
                   link: link_task,
                   execs: exec_tasks
                 )
          end

          entry = Entry.new(
            user: nil,
            visibility: Entry::VisibilityProtected,
            viewed_count: 0,
            source_codes: source_codes,
            tickets: tickets,
          )

          entry.save

          factory_bridge = BridgeFactoryAndCage::FactoryBridge.instance

          p entry
          user = auth

          p tickets

          tickets.each do |ticket|
            TickerExecutorJob.perform_later(ticket.id, source_codes.map{|s| s.id})
          end

          return {
            a: entry.id
          }
        rescue => e
          p e
          puts e.backtrace

          return {
            error: "aaa"
          }
        end
      end

    end
  end
end
