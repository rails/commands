module Commands
  module Environment
    extend self
    
    def fork
      Kernel.fork do
        yield
        Kernel.exit
      end

      Process.waitall
    end

    def fork_into(new_env)
      fork do
        switch_to new_env
        yield
      end
    end

    def switch_to(new_env)
      Rails.env = new_env.to_s
      Rails.application

      $:.unshift("./#{new_env}")
      
      reset_active_record
      reload_classes
    end


    def reload_classes
      ActionDispatch::Reloader.cleanup!
      ActionDispatch::Reloader.prepare!
    end
    
    def reset_active_record
      if defined? ::ActiveRecord
        ::ActiveRecord::Base.clear_active_connections!
        ::ActiveRecord::Base.establish_connection
      end
    end 
  end
end