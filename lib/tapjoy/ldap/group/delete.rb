module Tapjoy
  module LDAP
    module Group
      # Delete LDAP group
      class Delete
        def delete
          confirm unless opts[:force]
          puts Tapjoy::LDAP::client.delete(distinguished_name)
        end

        private
        def opts
          @opts ||= Trollop::options do
            # Set help message
            usage 'group delete [options]'
            synopsis "\nThis command is for deleting LDAP groups"

            opt :name, 'Specify group', type: :string, required: true
            opt :force, 'Force delete'
          end
        end

        def distinguished_name
          @distinguished_name ||= "cn=#{opts[:name]},ou=Group,#{Tapjoy::LDAP::client.basedn}"
        end

        def confirm
          puts "Confirm that you want to delete group #{opts[:group]} (yes/no)"
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
