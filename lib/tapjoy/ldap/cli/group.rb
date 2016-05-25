require_relative 'group/create'
require_relative 'group/delete'
require_relative 'group/add_user'
require_relative 'group/remove_user'
require_relative 'group/index'
require_relative '../api/group'

module Tapjoy
  module LDAP
    module CLI
      # Entry point for all group subcommands
      module Group
        class << self

          SUB_COMMANDS = %w(create delete add_user remove_user)

          def commands
            Trollop.options do
              usage 'group [SUB_COMMAND] [options]'
              synopsis "\nThis object is used for group management\nAvailable subcommands are: #{SUB_COMMANDS}"

              stop_on SUB_COMMANDS
            end

            cmd = ARGV.shift

            case cmd
            when 'create', 'delete', 'add_user', 'remove_user', 'index'
              send(cmd) # call method with respective name
            else
              raise Tapjoy::LDAP::InvalidArgument
            end
          end

          # Create Group
          def create
            group = Tapjoy::LDAP::CLI::Group::Create.new
            group.create
          end

          # Delete group
          def delete
            group = Tapjoy::LDAP::CLI::Group::Delete.new
            group.delete
          end

          def add_user
            group = Tapjoy::LDAP::CLI::Group::AddUser.new
            group.add_user
          end

          def remove_user
            group = Tapjoy::LDAP::CLI::Group::RemoveUser.new
            group.remove_user
          end

          def index
            group = Tapjoy::LDAP::CLI::Group::Index.new
            group.index
          end
        end
      end
    end
  end
end
