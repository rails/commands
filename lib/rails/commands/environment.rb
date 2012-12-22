module Rails
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
    end
  end
end