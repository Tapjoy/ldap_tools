module Tapjoy::LDAP::CLI::Audit
  # CLI for printing LDAP users by group
  class ByGroup
    def by_group
      Tapjoy::LDAP::CLI::Audit.print_hash(
        'Users in groups',
        Tapjoy::LDAP::API::Audit.index_by_group)
    end
  end
end
