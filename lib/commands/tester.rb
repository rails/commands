module Commands
  class Tester
    # FIXME: Turn this into calls directly to the test classes, so we don't have to load environment again.
    # Also need to toggle the environment to test and back to dev after running.
    def test(what = nil)
      case what
      when NilClass
        print_test_usage
      when "all"
        # test/**/*_test.rb doesn't work because of performance tests
        run "test/models/**/*_test.rb", "test/controllers/**/*_test.rb", "test/integration/**/*_test.rb"
      when /^[^\/]+$/ # models
        run "test/#{what}/**/*_test.rb"
      when /[\/]+/ # models/person
        run "test/#{what}_test.rb"
      end

      "Completed"
    end


    private
      # Executes the tests matching the passed filename globs
      def run(*test_patterns)
        forking do
          switch_env_to :test
          redirect_active_record_logger
          require_test_files(test_patterns)
        end
      end

      def switch_env_to(new_env)
        Rails.env = new_env.to_s
        Rails.application

        $:.unshift("./#{new_env}")
        
        reset_active_record
      end

      def reset_active_record
        if defined? ::ActiveRecord
          ::ActiveRecord::Base.clear_active_connections!
          ::ActiveRecord::Base.establish_connection
        end
      end

      def require_test_files(test_patterns)
        # load the test files
        test_patterns.each do |test_pattern|
          Dir[test_pattern].each do |path|
            require File.expand_path(path)
          end
        end        
      end

      def forking
        Kernel.fork do
          yield
          Kernel.exit
        end

        Process.waitall
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