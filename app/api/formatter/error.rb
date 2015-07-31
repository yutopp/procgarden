module Formatter
  module Error
    def self.call message, backtrace, options, env
      return { :message => message }
    end
  end
end
