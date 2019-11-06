module Tapjoy
  module LDAP
    module CLI
      module Group
        # Add existing user to existing group
        class AddUser
          def add_user
            puts Tapjoy::LDAP::API::Group.update(
              opts[:group], opts[:username], :add)
          end

          private

          def opts
            @opts ||= Optimist.options do
              # Set help message
              usage 'group add_user [options]'
              synopsis "\nThis command is for adding existing users to existing groups"

              opt(:group, 'Specify group', type: :string, required: true)
              opt(:username, 'Specify username', type: :string, required: true)
            end
          end
        end
      end
    end
  end
end
