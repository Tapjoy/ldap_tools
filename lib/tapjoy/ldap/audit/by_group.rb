module Tapjoy
  module LDAP
    module Audit
      class ByGroup
        def by_group
          group_membership = {}

          group_results.each do |entry|
            group_membership[entry[:cn].first] = entry[:memberUid]
          end

          Tapjoy::LDAP::Audit.print_hash('Users in groups', group_membership)
        end

        private

        def group_results
          @group_results ||= Tapjoy::LDAP::Audit.get_groups_with_membership
        end

      end
    end
  end
end
