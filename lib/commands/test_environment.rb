require 'commands/environment'

module Commands
  module TestEnvironment
    extend self
    
    def fork
      Environment.fork do
        switch_to_test
        yield
      end
    end


    private
      def switch_to_test
        switch_rails
        switch_bundler

        reset_active_record
        reload_classes
        
        add_test_dir_to_load_path
      end

      def switch_rails
        ENV['RAILS_ENV'] = Rails.env = "test"

        Kernel.silence_warnings do
          Dir[Rails.root.join('config', 'initializers', '*.rb')].map { |file| load file }
          load Rails.root.join('config', 'environments', "test.rb")
        end
      end
    
      def switch_bundler
        Bundler.require "test"
      end

    
      def reload_classes
        ActionDispatch::Reloader.cleanup!
        ActionDispatch::Reloader.prepare!
      end
    
      def reset_active_record
        if defined? ActiveRecord
          ActiveRecord::Base.clear_active_connections!
          ActiveRecord::Base.establish_connection
        end
      end

      
      def add_test_dir_to_load_path
        $:.unshift("./test")
      end
  end
end