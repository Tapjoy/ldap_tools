module Tapjoy
  module LDAP
    module User
      class Delete
        def opts
          @opts ||= Trollop::options do
            # Set help message
            usage "user delete [options]"

            opt(:user, 'Specify username', :type => :string, :required => true)
            opt(:force, 'Force delete')
          end
        end

        def delete
          prompt = '>'
          dn = "uid=#{ opts[:user] },ou=People,#{ Tapjoy::LDAP::client.basedn }"
          unless opts[:force]
            puts "Confirm that you want to delete user: #{ opts[:user] }"
            print prompt
            confirm = STDIN.gets.chomp().downcase
            unless confirm.eql?('y') || confirm.eql?('yes')
              abort("Deletion of #{ opts[:user] } aborted")
            end
          end

          puts Tapjoy::LDAP::client.delete(dn)
        end
      end
    end
  end
end
#       def delete
#         options = {}
