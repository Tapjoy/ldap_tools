module Tapjoy
  module LDAP
    module CLI
      module User
        # Manipulates data to a format usable by the API structure
        class Create
          # Tapjoy::LDAP::CLI::User::Create#create
          # Make the API call to create an LDAP user
          def create
            verify_arguments
            fname, lname = opts[:name]
            puts Tapjoy::LDAP::API::User.create(fname, lname,
              opts[:type], opts[:group])
          end

          private
          def opts
            @opts ||= Optimist.options do
              # Set help message
              usage 'user create [options]'
              synopsis "\nThis command is for creating new LDAP users"

              # Name is two arguments
              # Optimist will accept more, but we will only parse two later
              # TODO: support given names that include a space
              opt :name, "Specify user's first and last name", type: :strings, required: true

              # Groupname is a single string, for primary group setting
              opt :group, 'Specify name of primary group', type: :string, required: true
              opt :type, 'Specfy if this is a user or service account', type: :string, default: 'user'
            end
          end

          def verify_arguments
            Optimist.die :name, 'argument count must be two' if opts[:name].size != 2
            Optimist.die :type, "argument must be 'user' or 'service'" unless %w(user service).include?(opts[:type])
          end
        end
      end
    end
  end
end
