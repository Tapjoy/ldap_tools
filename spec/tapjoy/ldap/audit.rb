require_relative '../ldap'
RSpec.shared_context 'audit' do
  include_context 'ldap'
  ARGV.clear
end
