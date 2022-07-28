require 'logging'

require_relative '../../rpruby'

module Rpruby
  # Custom ReportPortal appender for 'logging' gem
  class LoggingAppender < ::Logging::Appender
    def write(event)
      (str, lvl) = if event.instance_of?(::Logging::LogEvent)
                     [layout.format(event), event.level]
                   else
                     [event.to_s, Rpruby::LOG_LEVELS[:unknown]]
                   end

      Rpruby.send_log(lvl, str, Rpruby.now)
    end
  end
end
