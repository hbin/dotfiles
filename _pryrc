#!/usr/bin/env ruby -w

Pry.editor = 'vi'


# When you use binding.pry instead of byebug, the short commands like s, n, f, and c do not work. To reinstall them.
if defined?(PryByebug)
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
  Pry.commands.alias_command 'c', 'continue'
end

# You can repeat the last command by just hitting the Enter key
Pry::Commands.command /^$/, "repeat last command" do
  _pry_.run_command Pry.history.to_a.last
end
