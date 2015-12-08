module Tapjoy
  module LDAP
    module User
      # Delete LDAP user
      class Delete
        def delete
          confirm unless opts[:force] 
          puts Tapjoy::LDAP::client.delete(dn)
        end

        private
        def opts
          @opts ||= Trollop::options do
            # Set help message
            usage "user delete [options]"

            opt :user, 'Specify username', type: :string, required: true
            opt :force, 'Force delete'
            opt :type, 'Specfy if this is a user or service account', type: :string, default: 'user'
          end
        end

        def dn
          @dn ||= "uid=#{opts[:user]},ou=#{ou},#{Tapjoy::LDAP::client.basedn}"
        end

        def confirm
          puts "Confirm that you want to delete user: #{ opts[:user] }"
          print '>'
          confirm = STDIN.gets.chomp().downcase
          unless confirm.eql?('y') || confirm.eql?('yes')
            abort("Deletion of #{ opts[:user] } aborted")
          end
        end

        def ou
          @ou ||= begin
            case opts[:type]
            when 'user'
              ou = 'People'
            when 'service'
              ou = Tapjoy::LDAP::client.service_ou
            else
              puts 'Unknown type'
            end
          end
        end
      end
    end
  end
end
