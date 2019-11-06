module Tapjoy
  module LDAP
    module CLI
      module Group
        # Create LDAP group
        class Create
          def create
            # Check for errors
            Optimist.die :type, "argument must be 'user' or 'service'" unless ['user', 'service'].include?(opts[:type])

            puts Tapjoy::LDAP::API::Group.create(opts[:name], opts[:type])
          end

          private def opts
            @opts ||= Optimist.options do
              # Set help message
              usage 'group create [options]'
              synopsis "\nThis command is for creating new LDAP groups"

              opt :name, 'Specify group to create', type: :string, required: true
              opt :type, 'Specfy if this is a user or service group', type: :string, default: 'user'
            end
          end
        end
      end
    end
  end
end
