require_relative '../ldap'
RSpec.shared_context 'user' do
  include_context 'ldap'
  ARGV.clear

  let(:distinguished_name) {'uid=test.user,ou=People,dc=example,dc=net'}

  before(:each) do
    allow(Tapjoy::LDAP::API::Group).to receive(:lookup_id).and_return(19000)
    allow(fake_ldap).to receive(:get_max_id).and_return(10001)
  end
end
