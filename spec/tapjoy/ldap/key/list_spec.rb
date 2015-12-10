require_relative '../../../spec_helper'
require_relative '../key'
describe 'Tapjoy::LDAP::Key.list' do
  include_context 'key'

  let(:ldap_hash) {
    {
      uid: uid,
      sshPublicKey: sshPublicKey
    }
  }
  let(:result) { OpenStruct.new ldap_hash}
  let(:uid) { %w(test.user) }
  let(:sshPublicKey) {File.read(filename).split("\n")}

  it 'lists keys' do
    ARGV << %w(list); ARGV.flatten!
    allow(fake_ldap).to receive(:search).and_return([result])

    expect(Tapjoy::LDAP::Key.get_keys_from_ldap).to eq(uid[0] => sshPublicKey)
    Tapjoy::LDAP::Key.commands
  end
end
