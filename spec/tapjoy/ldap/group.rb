require_relative '../ldap'
RSpec.shared_context 'group' do
  include_context 'ldap'
  ARGV.clear
  let(:distinguished_name) {'cn=testgroup,ou=Group,dc=example,dc=net'}
  before(:each) do
    allow(fake_ldap).to receive(:get_max_id).and_return(10001)
  end
end
