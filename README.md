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

When your console boots, it'll automatically have a `commander` object instantiated. The following methods are delegated to this object: rake, test, generate, destroy, update. It's used like this:

    > generate "scaffold post title:string"
    > rake "db:migrate"
    > test "models/person"

You can see the options available for all the commands by running them with no parameters.
