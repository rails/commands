require 'rake'

module Commands
  class Raker
    include Rake::DSL

    def initialize
      load_rake_tasks
    end

    def rake(task = nil, *args)
      task.nil? ? print_rake_tasks : invoke_rake_task(task, *args)
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

      def invoke_rake_task(task, *args)
        Rake::Task[task].invoke(*args)
        Rake.application.tasks.each(&:reenable) # Rake by default only allows tasks to be run once per session
      end
  end
end