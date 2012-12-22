require 'rails/commands/commander'

module Rails
  module Commands
    module ConsoleDelegation
      def commander
        @commander ||= Commander.new
      end

      delegate :rake, :test, :generate, :destroy, :update, to: :commander
    end
  end
end