module Tapjoy
  module LDAP
    module CLI
      module Group
        # Remove existing user to existing group
        class RemoveUser
          def remove_user
            confirm unless opts[:force]
            puts Tapjoy::LDAP::API::Group.update(
              opts[:group], opts[:username], :delete)
          end

          private

          def opts
            @opts ||= Optimist.options do
              # Set help message
              usage 'group remove_user [options]'
              synopsis "\nThis command is for removing existing users from existing groups"

              opt(:group, 'Specify group', type: :string, required: true)
              opt(:username, 'Specify username', type: :string, required: true)
            end
          end

          def confirm
            puts "Confirm that you want to remove user #{opts[:username]} from group #{opts[:group]} (yes/no)"
            print '>'
            confirm = STDIN.gets.chomp.downcase
            abort("Deletion of #{opts[:name]} aborted") unless confirm.start_with?('y')
          end
        end
      end
    end
  end
end
