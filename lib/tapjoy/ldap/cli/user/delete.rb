module Tapjoy
  module LDAP
    module CLI
      module User
        # Manipulates data to a format usable
        # by the API structure for user removal
        class Delete
          # Make the API call to remove an LDAP user
          def delete
            verify_arguments
            confirm unless opts[:force]
            puts Tapjoy::LDAP::API::User.destroy(opts[:user], opts[:type])
          end

          private
          def opts
            @opts ||= Trollop.options do
              # Set help message
              usage "user delete [options]"

              opt :user, 'Specify username', type: :string, required: true
              opt :force, 'Force delete'
              opt :type, 'Specfy if this is a user or service account', type: :string, default: 'user'
            end
          end

          def confirm
            puts "Confirm that you want to delete user: #{opts[:user]} (yes/no)"
            print '>'
            confirm = STDIN.gets.chomp.downcase
            abort("Deletion of #{opts[:user]} aborted") unless confirm.start_with?('y')
          end

          def verify_arguments
            Trollop.die :type, "argument must be 'user' or 'service'" unless %w(user service).include?(opts[:type])
          end
        end
      end
    end
  end
end
