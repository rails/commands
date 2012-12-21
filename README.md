Commands
========

Run Rake and Rails commands during a console session. This side-steps the need to load the entire environment over and over again when you run these commands from the shell. This constant reloading of the environment is what causes slow boot time on big applications. Think of this like a baby Zeus or the Turbolinks of commands.


Installation
------------

Add this line to your application's Gemfile:

    gem 'commands'

And then execute:

    $ bundle

Usage
-----

When your console boots, it'll automatically have a `commands` object instantiated. The following methods are delegated to this object: rake, test, generate, destroy, update. It's used like this:

    > generate "scaffold post title:string"
    > rake "db:migrate"
    > test "models/person"


Work needed
-----------

1. The test runner needs to run in the same process, not use Rake (as it shells out). So the test class needs to be instantiated directly and run under the test environment.
