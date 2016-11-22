module Tapjoy::LDAP::CLI
  module Audit
    # Get a group to user mapping
    class ByUser
      def by_user
        Tapjoy::LDAP::CLI::Audit.print_hash(
          'Groups by user', Tapjoy::LDAP::API::Audit.index_by_user)
      end
    end
  end
end
