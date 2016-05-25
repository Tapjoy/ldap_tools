module Tapjoy
  module LDAP
    module CLI
      module Group
        # Delete LDAP group
        class Delete
          def delete
            confirm unless opts[:force]
            puts Tapjoy::LDAP::API::Group.destroy(opts[:name])
          end

          private

          def opts
            @opts ||= Trollop.options do
              # Set help message
              usage 'group delete [options]'
              synopsis "\nThis command is for deleting LDAP groups"

              opt :name, 'Specify group', type: :string, required: true
              opt :force, 'Force delete'
            end
          end

          def confirm
            puts "Confirm that you want to delete group #{opts[:name]} (yes/no)"
            print '>'
            confirm = STDIN.gets.chomp.downcase
            abort("Deletion of #{opts[:name]} aborted") unless confirm.start_with?('y')
          end
        end
      end
    end
  end
end
