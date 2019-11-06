require_relative 'user/create'
require_relative 'user/delete'
require_relative 'user/show'
require_relative '../api/user'
module Tapjoy
  module LDAP
    module CLI
      # CLI Module for all user commands
      module User
        class << self
          SUB_COMMANDS = %w(create delete index show)

          def commands
            Optimist.options do
              usage 'user [SUB_COMMAND] [options]'
              synopsis "\nThis object is used for user management\nAvailable subcommands are: #{SUB_COMMANDS}"

              stop_on SUB_COMMANDS
            end

            cmd = ARGV.shift

            case cmd
            when 'create', 'delete', 'index', 'show'
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

          def index
            Tapjoy::LDAP::API::User.index.each do |entry|
              puts "DN: #{entry.dn}"
              entry.each do |attribute, values|
                puts "   #{attribute}:"
                values.each do |value|
                  puts "      --->#{value}"
                end
              end
            end
          end

          def show
            user = Tapjoy::LDAP::CLI::User::Show.new
            user.show
          end

        end
      end
    end
  end
end
