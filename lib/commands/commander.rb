require 'commands/raker'
require 'commands/tester'
require 'commands/generator'

module Commands
  class Commander
    delegate :rake, to: :raker
    delegate :test, to: :tester
    delegate :generate, :destroy, :update, to: :generator

    # Only just ensured that this method is available in rails/master, so need a guard for a bit.
    def self.silence_active_record_logger
      return yield unless defined? ActiveRecord::Base.logger

      begin
        old_logger_level, ActiveRecord::Base.logger.level = ActiveRecord::Base.logger.level, Logger::ERROR
        yield
      ensure
        ActiveRecord::Base.logger.level = old_logger_level
      end
    end

    attr_reader :raker, :tester, :generator

    def initialize
      @raker     = Raker.new
      @tester    = Tester.new
      @generator = Generator.new
    end
  end
end

