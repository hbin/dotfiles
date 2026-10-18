#!/usr/bin/env ruby -w

# Follow the shell's preferred editor (nvim), falling back to vi.
Pry.editor = ENV.fetch('EDITOR', 'vi')


# When you use binding.pry instead of byebug, the short commands like s, n, f, and c do not work. To reinstall them.
if defined?(PryByebug)
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
  Pry.commands.alias_command 'c', 'continue'
end

# You can repeat the last command by just hitting the Enter key
Pry::Commands.command(/^$/, "repeat last command") do
  last_command = Pry.history.to_a.last
  _pry_.run_command(last_command) if last_command
end
