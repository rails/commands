require 'rails/commands/test_environment'

module Rails
  module Commands
    class Tester
      def test(what = nil)
        case what
        when NilClass
          print_test_usage
        when "all"
          run "test/**/**/*_test.rb"
        when /^[^\/]+$/ # models
          run "test/#{what}/**/*_test.rb"
        when /[\/]+/ # models/person
          run "test/#{what}_test.rb"
        end

        "Completed"
      end


      private
        def run(*test_patterns)
          TestEnvironment.fork do
            test_patterns.each do |test_pattern|
              Dir[test_pattern].each do |path|
                require File.expand_path(path)
              end
            end        

            trigger_runner
          end
        end

        def trigger_runner
          if defined?(Test::Unit::TestCase) && ActiveSupport::TestCase.ancestors.include?(Test::Unit::TestCase)
            MiniTest::Unit.runner.run
          else
            # MiniTest::Spec setups in Rails 4.0+ has autorun defined
          end
        end

        def print_test_usage
          puts <<-EOT
    Usage:
      test "WHAT"

    Description:
        Runs either a full set of test suites or single suite.

        If you supply WHAT with either models, controllers, helpers, integration, or performance,
        those whole sets will be run.

        If you supply WHAT with models/person, just test/models/person_test.rb will be run.
    EOT
        end
    end
  end
end