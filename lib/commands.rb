require 'rails/console/app'
require 'commands/console_delegation'

Rails::ConsoleMethods.send :include, Commands::ConsoleDelegation
