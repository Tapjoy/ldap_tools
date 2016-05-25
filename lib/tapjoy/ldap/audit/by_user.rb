module Tapjoy
  module LDAP
    module Audit
      # Get a group to user mapping
      class ByUser
        def by_user
          user_groups = {}
          get_users.each do |user|
            user_groups[user] = group_results.reduce([]) do |group, entry|
              group << entry[:cn].first if entry[:memberUid].include?(user)
              group
            end
          end

          # print user_groups

          Tapjoy::LDAP::Audit.print_hash('Groups by user', user_groups)
        end

        private
        # Get list of users
        def get_users
          @get_users ||= results.map {|entry| entry['uid'].first}.sort
        end

        def filter
          @filter ||= Net::LDAP::Filter.eq('objectclass', 'posixAccount')
        end

        def attributes
          @attributes ||= ['uid']
        end

        def results
          @results ||= Tapjoy::LDAP.client.search(attributes, filter)
        end

        def group_results
          @group_results ||= Tapjoy::LDAP::Audit.get_groups_with_membership
        end

      end
    end
  end
end
