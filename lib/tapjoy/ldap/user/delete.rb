module Tapjoy
  module LDAP
    module User
      # Delete LDAP user
      class Delete
        def delete
          confirm unless opts[:force]
          puts Tapjoy::LDAP::client.delete(distinguished_name)
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

        def distinguished_name
          @distinguished_name ||= "uid=#{opts[:user]},ou=#{organizational_unit},#{Tapjoy::LDAP::client.basedn}"
        end

        def confirm
          puts "Confirm that you want to delete user: #{opts[:user]} (yes/no)"
          print '>'
          confirm = STDIN.gets.chomp().downcase
          unless confirm.eql?('y') || confirm.eql?('yes')
            abort("Deletion of #{ opts[:user] } aborted")
          end
        end

        def organizational_unit
          @organizational_unit ||= begin
            case opts[:type]
            when 'user'
              'People'
            when 'service'
              Tapjoy::LDAP::client.service_ou
            else
              puts 'Unknown type'
            end
          end
        end
      end
    end
  end
end
