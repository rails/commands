Commands
========

Let you run Rake and Rails commands during a console session. This side-steps the need to load the entire environment over and over again when you run these commands from the shell. This constant reloading of the environment is what causes slow boot time on big applications. Think of this like a baby Zeus or the Turbolinks of commands.


Usage
-----

When your console boots, it'll automatically have a commands object instantiated (aliased to c). It can be used like this:

  > c.generate "scaffold post title:string"
  > c.rake "db:migrate"
  > c.test "models/person"


Work needed
-----------

# The test runner needs to run in the same process, not use Rake (as it shells out). So the test class needs to be instantiated directly and run under the test environment.
# Generating models seem to be bust for some reason.
