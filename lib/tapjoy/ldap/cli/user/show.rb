module Tapjoy
  module LDAP
    module CLI
      module User
        # Manipulates data to a format usable
        # by the API structure for user display
        class Show
          # Make the API call to show an LDAP user
          def show
            Tapjoy::LDAP::API::User.show(opts[:username]).each do |entry|
              puts "DN: #{entry.dn}"
              entry.each do |attribute, values|
                puts "   #{attribute}:"
                values.each do |value|
                  puts "      --->#{value}"
                end
              end
            end
          end

          private
          def opts
            @opts ||= Optimist.options do
              # Set help message
              usage "user show [options]"

              opt :username, 'Specify username', type: :string, required: true
            end
          end
        end
      end
    end
  end
end
