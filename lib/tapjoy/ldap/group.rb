require_relative 'group/create'
require_relative 'group/delete'
require_relative 'group/add_user'
require_relative 'group/remove_user'

module Tapjoy
  module LDAP
    # Entry point for all group subcommands
    module Group
      class << self

        SUB_COMMANDS = %w(create delete add_user remove_user)

        def commands
          Trollop::options do
            usage 'group [SUB_COMMAND] [options]'
            synopsis "\nThis object is used for group management\nAvailable subcommands are: #{SUB_COMMANDS}"

            stop_on SUB_COMMANDS
          end

          cmd = ARGV.shift

          case cmd
          when 'create', 'delete', 'add_user', 'remove_user'
            send(cmd) # call method with respective name
          else
            raise Tapjoy::LDAP::InvalidArgument
          end
        end

        # Lookup GID for the given group
        def lookup_id(groupname)
          gidnumber = []

          oc_filter = Net::LDAP::Filter.eq('objectclass', 'posixGroup')
          cn_filter = Net::LDAP::Filter.eq('cn', groupname)
          filter    = Net::LDAP::Filter.join(oc_filter, cn_filter)

          results = Tapjoy::LDAP::client.search(['gidNumber'], filter)

          # Make sure we return one, and only one group
          if results.size < 1
            abort('Group not found')
          elsif results.size > 1
            abort('Multiple groups found. Please narrow your search.')
          end

          results.each { |result| gidnumber = result.gidnumber }
          return gidnumber[0]
        end

        # Create Group
        def create
          group = Tapjoy::LDAP::Group::Create.new
          group.create
        end

        # Delete group
        def delete
          group = Tapjoy::LDAP::Group::Delete.new
          group.delete
        end

        def add_user
          group = Tapjoy::LDAP::Group::AddUser.new
          group.add_user
        end

        def remove_user
          group = Tapjoy::LDAP::Group::RemoveUser.new
          group.remove_user
        end
      end
    end
  end
end
