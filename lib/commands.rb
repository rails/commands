require 'rake'

class Commands
  module ConsoleMethods
    def commands
      @commands ||= Commands.new
    end
    
    alias_method :c, :commands
    
    delegate :rake, :test, :generate, :destroy, :update, to: :commands
  end

  include Rake::DSL
  
  def initialize
    load Rails.root.join('Rakefile')
  end
  
  def rake(task, *args)
    silencer do
      Rake::Task[task].invoke(*args)
      
      # Rake by default only allows tasks to be run once per session
      Rake.application.tasks.each(&:reenable)
    end
    nil
  end

  # FIXME: Turn this into calls directly to the test classes, so we don't have to load environment again.
  # Also need to toggle the environment to test and back to dev after running.
  def test(what = nil)
    silencer do
      case what
      when NilClass, :all
        rake "test:units"
      when String
        ENV['TEST'] = "test/#{what}_test.rb"
        rake "test:single"
        ENV['TEST'] = nil
      end
    end
    nil
  rescue SystemExit
    nil
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
    def generator(name, argv = nil)
      if argv.nil?
        # FIXME: I don't know why we can't just catch SystemExit here, then we wouldn't need this if block
        require 'rails/generators'
        Rails::Generators.help name
      else
        ARGV.replace argv.nil? ? [nil] : argv.split(" ")
        load "rails/commands/#{name}.rb"
        ARGV.replace [nil]
      end

      nil
    end

    def silencer &block
      if defined? ActiveRecord::Base
        ActiveRecord::Base.logger.silence &block
      else
        yield
      end
    end
end

require 'rails/console/app'
Rails::ConsoleMethods.send :include, Commands::ConsoleMethods
