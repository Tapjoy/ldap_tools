module Tapjoy
  module LDAP
    class Audit

      # Instantiate class
      def initialize
        command = ARGV.shift

        case command
        when 'by_user', 'by_group', 'raw'
          send(command)
        else
          raise Tapjoy::LDAP::InvalidArgument
        end
      end

      private

      # Clean output of hashes
      def print_hash(header_string, object_hash)
        puts header_string
        puts "=" * header_string.length
        object_hash.each_pair do |key, values|
          next if values.empty?
          puts "- #{key}"
          values.each { |value| puts "  - #{value}" }
        end
      end

      # Get list of users
      def get_users
        user_list = Array.new

        filter = Net::LDAP::Filter.eq('objectclass', 'posixAccount')
        attributes = ['uid']

        results = Tapjoy::LDAP::client.search(attributes, filter)
        results.each do |entry|
          user_list << entry['uid'].first
        end

        return user_list.sort
      end

      # Get hash of groups with list of members of each group
      def get_groups_with_membership
        filter = Net::LDAP::Filter.eq('objectclass', 'posixGroup')
        attributes = ['cn', 'memberUid']

        results = Tapjoy::LDAP::client.search(attributes, filter)

      end

      # Get a group to user mapping
      def by_user
        user_groups = Hash.new
        user_list = get_users
        group_results = get_groups_with_membership

        user_list.each do |user|
          user_groups[user] = Array.new
          group_results.each do |entry|
            user_groups[user] << entry['cn'].first if entry['memberUid'].include?(user)
          end
        end

        print_hash('Groups by user', user_groups)
      end

      # Get a user to group mapping
      def by_group
        group_membership = Hash.new

        get_groups_with_membership.each do |entry|
          group_membership[entry['cn'].first] = entry['memberUid']
        end

        print_hash('Users in groups', group_membership)
      end

      # Print raw output
      def raw
        results = Tapjoy::LDAP::client.search
        puts results.inspect
      end
    end
  end
end
