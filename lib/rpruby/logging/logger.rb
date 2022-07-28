require 'logger'

module Rpruby
  class << self
    # Monkey-patch for built-in Logger class
    def patch_logger
      Logger.class_eval do
        alias_method :orig_add, :add
        alias_method :orig_write, :<<
        def add(severity, message = nil, progname = nil, &block)
          ret = orig_add(severity, message, progname, &block)

          unless severity < @level
            progname ||= @progname
            if message.nil?
              if block_given?
                message = yield
              else
                message = progname
                progname = @progname
              end
            end
            Rpruby.send_log(format_severity(severity), format_message(format_severity(severity), Time.now, progname, message.to_s), Rpruby.now)
          end
          ret
        end

        def <<(msg)
          ret = orig_write(msg)
          Rpruby.send_log(Rpruby::LOG_LEVELS[:unknown], msg.to_s, Rpruby.now)
          ret
        end
      end
    end
  end
end
