require 'rails/console/app'
require 'rails/commands/console_delegation'

Rails::ConsoleMethods.send :include, Rails::Commands::ConsoleDelegation
