require 'rake'

module Rails
  module Commands
    class Raker
      include Rake::DSL

      def initialize
        load_rake_tasks
      end

      def rake(task = nil)
        task.nil? ? print_rake_tasks : invoke_rake_task(task)
        "Completed"
      rescue SystemExit, RuntimeError => e
        "Failed: #{e.message}"
      end
    
    
      private
        def load_rake_tasks
          Rake::TaskManager.record_task_metadata = true # needed to capture comments from define_task
          load Rails.root.join('Rakefile')
        end
      
        def print_rake_tasks
          Rake.application.options.show_tasks = :tasks
          Rake.application.options.show_task_pattern = Regexp.new('')
          Rake.application.display_tasks_and_comments
        end

        def invoke_rake_task(task)
          task, *options = task.split(" ")

          ARGV.replace options

          # FIXME: Before we can use this, we need a way to reset the options again
          # Rake.application.handle_options

          expose_argv_arguments_via_env { Rake::Task[task].invoke }
          Rake.application.tasks.each(&:reenable) # Rake by default only allows tasks to be run once per session
        ensure
          ARGV.replace([])
        end
      
        def expose_argv_arguments_via_env
          argv_arguments.each { |key, value| ENV[key] = value }
          yield
        ensure
          argv_arguments.keys.each { |key| ENV.delete(key) }
        end
      
        def argv_arguments
          ARGV.each_with_object({}) do |arg, arguments|
            if arg =~ /^(\w+)=(.*)$/
              arguments[$1] = $2
            end
          end
        end
    end
  end
end