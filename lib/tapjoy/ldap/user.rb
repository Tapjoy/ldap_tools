require_relative 'user/create'
require_relative 'user/delete'

module Tapjoy
  module LDAP
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
          user = Tapjoy::LDAP::User::Create.new
          user.create
        end

        def delete
          user = Tapjoy::LDAP::User::Delete.new
          user.delete
        end
      end
    end
  end
end
#
#       # Instantiate class
#       def initialize
#         command = ARGV.shift
#
#         case command
#         when 'create', 'delete'
#           send(command)
#         else
#           raise Tapjoy::LDAP::InvalidArgument
#         end
#       end
#
#       private
#       # Create user in LDAP

#
#       # Delete user from LDAP

#       end
#
#     end
#   end
# end
