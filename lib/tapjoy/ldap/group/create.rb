module Tapjoy
  module LDAP
    module Group
      # Create LDAP group
      class Create
        def create
          # Check for errors
          Trollop::die :type, "argument must be 'user' or 'service'" unless ['user', 'service'].include?opts[:type]

          puts Tapjoy::LDAP::client.add(dn, ldap_attr)
        end

        private

        def opts
          @opts ||= Trollop::options do
            # Set help message
            usage 'group create [options]'
            synopsis "\nThis command is for creating new LDAP groups"

            opt :name, 'Specify group to create', type: :string, required: true
            opt :type, 'Specfy if this is a user or service group', type: :string, default: 'user'
          end
        end

        def dn
          @dn ||= "cn=#{opts[:name]},ou=Group,#{Tapjoy::LDAP::client.basedn}"
        end

        def ldap_attr
          @ldap_attr ||= {
            :cn          => opts[:name],
            :objectclass => %w(top posixGroup),
            :gidnumber   => Tapjoy::LDAP::client.get_max_id('group', opts[:type])
          }
        end
      end
    end
  end
end
