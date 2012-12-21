require 'rake'
require 'rails/generators'

class Commands
  module ConsoleMethods
    def commands
      @commands ||= Commands.new
    end

    delegate :rake, :test, :generate, :destroy, :update, to: :commands
  end

  include Rake::DSL

  def initialize
    load_rake_tasks
    load_rails_generators
  end

  def rake(task = nil, *args)
    task.nil? ? print_rake_tasks : invoke_rake_task(task, *args)
    "Completed"
  rescue SystemExit, RuntimeError
    "Failed"
  end

  # FIXME: Turn this into calls directly to the test classes, so we don't have to load environment again.
  # Also need to toggle the environment to test and back to dev after running.
  def test(what = nil)
    require 'm'

    args = if what
      directory = File.join("test", what)

      if File.directory?(directory)
        [directory]
      else
        path, line_number = directory.split(":")
        file = "#{path}_test.rb"
        file << ":#{line_number}" if line_number
        [file]
      end
    else
      []
    end

    forking do
      M::Runner.new(args).run
    end
  end

  def generate(argv = nil)
    generator :generate, argv
  end

  def update(argv = nil)
    generator :update, argv
  end

  def destroy(argv = nil)
    generator :destroy, argv
  end


  private
    def load_rake_tasks
      Rake::TaskManager.record_task_metadata = true # needed to capture comments from define_task
      load Rails.root.join('Rakefile')
    end

    def load_rails_generators
      Rails.application.load_generators
    end

    def print_rake_tasks
      Rake.application.options.show_tasks = :tasks
      Rake.application.options.show_task_pattern = Regexp.new('')
      Rake.application.display_tasks_and_comments
    end

    def invoke_rake_task(task, *args)
      silence_active_record_logger { Rake::Task[task].invoke(*args) }
      Rake.application.tasks.each(&:reenable) # Rake by default only allows tasks to be run once per session
    end

    def forking
      pid = Kernel.fork do
        yield
        Kernel.exit
      end
      Process.wait pid
      true
    end

    def generator(name, argv = nil)
      if argv.nil?
        # FIXME: I don't know why we can't just catch SystemExit here, then we wouldn't need this if block
        Rails::Generators.help name
      else
        ARGV.replace argv.nil? ? [nil] : argv.split(" ")
        load "rails/commands/#{name}.rb"
        ARGV.replace [nil]
      end

      "Completed"
    end

    # Only just ensured that this method is available in rails/master, so need a guard for a bit.
    def silence_active_record_logger
      begin
        old_logger_level, ActiveRecord::Base.logger.level = ActiveRecord::Base.logger.level, Logger::ERROR
        yield
      ensure
        ActiveRecord::Base.logger.level = old_logger_level
      end
    end
end

require 'rails/console/app'
Rails::ConsoleMethods.send :include, Commands::ConsoleMethods
