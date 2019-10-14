# frozen_string_literal: true

# This is called monkeypatching.
# Monkeypatching adds methods to classes that already exist.
# Here we are adding a method called "red" to the String class,
# so our errors stand out on the command line.
# Monkeypatching is not usually recommended as it can have unexpected
# side-effects.
class String
  def red
    "\e[31m#{self}\e[0m"
  end

  def green
    "\e[32m#{self}\e[0m"
  end
end
