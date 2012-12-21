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
    load Rails.root.join('Rakefile')
    Rails.application.load_generators
  end
  
  def rake(task, *args)
    ActiveRecord::Base.logger.silence { Rake::Task[task].invoke(*args) }
      
    # Rake by default only allows tasks to be run once per session
    Rake.application.tasks.each(&:reenable)

    nil
  rescue SystemExit
    # Swallow exit/abort calls as we'll never want to exit the IRB session
    nil
  end

  # FIXME: Turn this into calls directly to the test classes, so we don't have to load environment again.
  # Also need to toggle the environment to test and back to dev after running.
  def test(what = nil)
    case what
    when NilClass, :all
      rake "test:units"
    when String
      ENV['TEST'] = "test/#{what}_test.rb"
      rake "test:single"
      ENV['TEST'] = nil
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
    def generator(name, argv = nil)
      if argv.nil?
        # FIXME: I don't know why we can't just catch SystemExit here, then we wouldn't need this if block
        Rails::Generators.help name
      else
        ARGV.replace argv.nil? ? [nil] : argv.split(" ")
        load "rails/commands/#{name}.rb"
        ARGV.replace [nil]
      end

      nil
    end
end

require 'rails/console/app'
Rails::ConsoleMethods.send :include, Commands::ConsoleMethods
