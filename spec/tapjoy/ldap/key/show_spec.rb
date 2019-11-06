require_relative '../key'
RSpec.describe 'Tapjoy::LDAP::Key::Show.show' do
  include_context 'key'

  let(:ldap_hash) {
    {
      uid: uid,
      sshpublickey: sshPublicKey
    }
  }
  let(:result) { OpenStruct.new ldap_hash}
  let(:uid) { %w(test.user) }
  let(:sshPublicKey) {File.read(filename).split("\n")}

  it "shows a user's keys" do
    ARGV << %w(show -u test.user); ARGV.flatten!
    allow(fake_ldap).to receive(:search).and_return([result])

    expect(Tapjoy::LDAP::Key.get_keys_from_ldap).to eq(uid[0] => sshPublicKey)
    Tapjoy::LDAP::Key.commands
  end
end
