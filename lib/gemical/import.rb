require 'gemical'
require 'commander/import'

program :version, Gemical::VERSION::STRING
program :name, 'Gemical command-line client ~ http://gemical.com'
program :description, '-'
program :help_formatter, Gemical::Format

command :bundle do |c|
  c.summary = 'Bundle a vault with your project'
  c.description = 'This command will add one of your vaults as a source to the Gemfile'
  c.example 'Bundle your primary vault', 'cd my-project; gemical bundle'
  c.example 'Bundle a specific vault', 'cd my-project; gemical bundle --vault my-vault'
  c.option '--vault VAULT', 'Specify a vault'
  c.when_called Gemical::Commands::Bundle, :create
end

command :vaults do |c|
  c.syntax = 'gemical vaults'
  c.summary = 'List all vaults'
  c.description = 'This command will list all vaults you have access to'
  c.description = 'Display all my vaults'
  c.when_called Gemical::Commands::Vaults, :index
end

command :gems do |c|
  c.summary = 'List all gems within a vault'
  c.description = 'This command will list all Gems within a vault (primary, unless specified)'
  c.option '--vault [VAULT]', 'Specify a vault'
  c.when_called Gemical::Commands::Gems, :index
end

command :"gems:add" do |c|
  c.syntax = 'gemical gems:add GEM [options]'
  c.summary = 'Add a gem to a vault'
  c.description = 'This command will upload the specified Gem to one of your vaults (primary, unless specified)'
  c.example 'Push a Gem to your primary vault', 'gemical gems:add my-gem-1.0.0.gem'
  c.example 'Push a Gem to a specific vault', 'gemical gems:add my-gem-1.0.0.gem --vault my-vault'
  c.option '--vault VAULT', 'Specify a vault'
  c.when_called Gemical::Commands::Gems, :create
end
alias_command :push, :'gems:add'

command :"gems:remove" do |c|
  c.syntax = 'gemical gems:remove GEM VERSION [options]'
  c.summary = 'Remove gem from a vault'
  c.description = 'This command will remove the specified Gem version from one of your vaults (primary, unless specified)'
  c.example 'Remove a Gem from your primary vault', 'gemical gems:remove my-gem 1.0.0'
  c.example 'Remove a Gem from a specific vault', 'gemical gems:remove my-gem 1.0.0 --vault my-vault'
  c.option '--vault VAULT', 'Specify a vault'
  c.when_called Gemical::Commands::Gems, :destroy
end
