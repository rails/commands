require 'commands/raker'
require 'commands/tester'
require 'commands/generator'

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

