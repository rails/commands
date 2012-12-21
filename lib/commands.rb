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
    Rails.application.load_generators
  end
  
  def rake(task, *args)
    ActiveRecord::Base.logger.silence do
      Rake::Task[task].invoke(*args)
      
      # Rake by default only allows tasks to be run once per session
      Rake.application.tasks.each(&:reenable)
    end
    nil
  end

  # FIXME: Turn this into calls directly to the test classes, so we don't have to load environment again.
  def test(what = nil)
    ActiveRecord::Base.logger.silence do
      case what
      when NilClass, :all
        rake "test:units"
      when String
        begin
          old_env, ENV["RAILS_ENV"] = ENV["RAILS_ENV"], "test"
          ENV['TEST'] = "test/#{what}_test.rb"
          rake "test:single"
        ensure
          ENV['TEST'] = nil
          ENV["RAILS_ENV"] = old_env
        end
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
end

require 'rails/console/app'
Rails::ConsoleMethods.send :include, Commands::ConsoleMethods
