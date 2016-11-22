require 'memoist'
module Tapjoy::LDAP::API
  # API methods for managing LDAP Groups
  module Audit
    class << self
      extend Memoist
      def index_by_group
        group_results
      end

      def index_by_user
        user_groups = Hash.new {|h,k| h[k]=[]}
        get_users.each do |user|
          group_results.each do |group, members|
            next unless members.include?(user.uid.first)
            user_groups[user.cn.first] << group
          end
        end

        user_groups
      end

      def index
        Tapjoy::LDAP.client.search.inspect
      end

      private

      def group_results
        # Each key in group_results is automatically assigned an empty array
        results = Hash.new {|h,k| h[k]=[]}
        # With each iteration of this loop, the loop-scope group_results
        # returns values to the method-scoped group_results
        group_index = Tapjoy::LDAP::API::Group.index
        group_index.each_with_object(results) do |entry, group|
          group[entry[:cn].first] = entry[:memberuid]
        end

        results
      end

      def get_users
        Tapjoy::LDAP::API::User.index
      end

      # Get hash of groups with list of members of each group
      def get_groups_with_membership
        filter = Net::LDAP::Filter.eq('objectclass', 'posixGroup')
        attributes = %w(cn memberUid)

        Tapjoy::LDAP.client.search(attributes, filter)
      end
    end
  end
end
