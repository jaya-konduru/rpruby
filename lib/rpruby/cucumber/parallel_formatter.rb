require_relative 'formatter'
require_relative 'parallel_report'

module Rpruby
  module Cucumber
    class ParallelFormatter < Formatter
      private

      def report
        @report ||= Rpruby::Cucumber::ParallelReport.new
      end
    end
  end
end
