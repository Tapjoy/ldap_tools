module Tapjoy
  module LDAP
    module Group
      # Add existing user to existing group
      class AddUser
        def add_user
          puts Tapjoy::LDAP::client.modify(dn, operations)
        end

        private
        def opts
          @opts ||= Trollop::options do
            # Set help message
            usage 'group add_user [options]'
            synopsis "\nThis command is for adding existing users to existing groups"

            opt(:group, 'Specify group', :type => :string, :required => true)
            opt(:username, 'Specify username', :type => :string, :required => true)
          end
        end

        def dn
          @dn ||= "cn=#{opts[:group]},ou=Group,#{Tapjoy::LDAP::client.basedn}"
        end

        def operations
          # Format is LDAP operation, attribute modified, value modified
          # i.e, add the username to the memberuid attribute for the specified group
          @operations ||= [[:add, :memberUid, opts[:username]]]
        end
      end
    end
  end
end
