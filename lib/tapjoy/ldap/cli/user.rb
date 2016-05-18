require_relative 'user/create'
require_relative 'user/delete'
require_relative '../api/user'
module Tapjoy
  module LDAP
    module CLI
      # CLI Module for all user commands
      module User
        class << self
          SUB_COMMANDS = %w(create delete)

          def commands
            Trollop::options do
              usage 'user [SUB_COMMAND] [options]'
              synopsis "\nThis object is used for user management\nAvailable subcommands are: #{SUB_COMMANDS}"

              stop_on SUB_COMMANDS
            end

            cmd = ARGV.shift

            case cmd
            when 'create', 'delete'
              send(cmd) # call method with respective name
            else
              raise Tapjoy::LDAP::InvalidArgument
            end
          end

          def create
            user = Tapjoy::LDAP::CLI::User::Create.new
            user.create
          end

          def delete
            user = Tapjoy::LDAP::CLI::User::Delete.new
            user.delete
          end
        end
      end
    end
  end
end
