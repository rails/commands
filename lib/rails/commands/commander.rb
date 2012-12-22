require 'rails/commands/raker'
require 'rails/commands/tester'
require 'rails/commands/generator'

module Rails
  module Commands
    class Commander
      delegate :rake, to: :raker
      delegate :test, to: :tester
      delegate :generate, :destroy, :update, to: :generator

      attr_reader :raker, :tester, :generator

      def initialize
        @raker     = Raker.new
        @tester    = Tester.new
        @generator = Generator.new
      end
    end
  end
end