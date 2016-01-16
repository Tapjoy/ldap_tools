module Tapjoy
  module LDAP
    module Group
      # Remove existing user to existing group
      class RemoveUser
        def remove_user
          confirm unless opts[:force]
          puts Tapjoy::LDAP::client.modify(distinguished_name, operations)
        end

        private
        def opts
          @opts ||= Trollop::options do
            # Set help message
            usage 'group remove_user [options]'
            synopsis "\nThis command is for removing existing users from existing groups"

            opt(:group, 'Specify group', :type => :string, :required => true)
            opt(:username, 'Specify username', :type => :string, :required => true)
          end
        end

        def distinguished_name
          @distinguished_name ||= "cn=#{opts[:group]},ou=Group,#{Tapjoy::LDAP::client.basedn}"
        end

        def operations
          # Format is LDAP operation, attribute modified, value modified
          # i.e, remove the username to the memberuid attribute for the specified group
          @operations ||= [[:delete, :memberUid, opts[:username]]]
        end

        def confirm
          puts "Confirm that you want to remove user #{opts[:username]} from group #{opts[:group]} (yes/no)"
          print '>'
          confirm = STDIN.gets.chomp().downcase
          unless confirm.eql?('y') || confirm.eql?('yes')
            abort("Deletion of #{ opts[:name] } aborted")
          end
        end
      end
    end
  end
end
