require_relative '../../rpruby'

CucumberMessagesVersion=[8,0,0]

module Rpruby
  module Cucumber
    class Formatter
      # @api private
      def initialize(config)
        ENV['REPORT_PORTAL_USED'] = 'true'

        setup_message_processing

        @io = config.out_stream

        @ast_lookup = if (::Cucumber::VERSION.split('.').map(&:to_i) <=> CucumberMessagesVersion) > 0
                        require 'cucumber/formatter/ast_lookup'
                        ::Cucumber::Formatter::AstLookup.new(config)
                      else
                        nil
                      end

        %i[test_case_started test_case_finished test_step_started test_step_finished test_run_finished].each do |event_name|
          config.on_event event_name do |event|
            process_message(event_name, event)
          end
        end
        config.on_event(:test_run_finished) { finish_message_processing }
      end

      def puts(message)
        process_message(:puts, message)
        @io.puts(message)
        @io.flush
      end

      def embed(*args)
        process_message(:embed, *args)
      end

      private

      def report
        if @ast_lookup.nil?
          require_relative 'report'
          @report ||= Rpruby::Cucumber::Report.new
        else
          require_relative 'messagesreport'
          @report ||= Rpruby::Cucumber::MessagesReport.new(@ast_lookup)
        end
      end

      def setup_message_processing
        return if use_same_thread_for_reporting?

        @queue = Queue.new
        @thread = Thread.new do
          loop do
            method_arr = @queue.pop
            report.public_send(*method_arr)
          end
        end
        @thread.abort_on_exception = true
      end

      def finish_message_processing
        return if use_same_thread_for_reporting?

        sleep 0.03 while !@queue.empty? || @queue.num_waiting.zero? # TODO: how to interrupt launch if the user aborted execution
        @thread.kill
      end

      def process_message(report_method_name, *method_args)
        args = [report_method_name, *method_args, Rpruby.now]
        if use_same_thread_for_reporting?
          report.public_send(*args)
        else
          @queue.push(args)
        end
      end

      def use_same_thread_for_reporting?
        Rpruby::Settings.instance.formatter_modes.include?('use_same_thread_for_reporting')
      end
    end
  end
end
