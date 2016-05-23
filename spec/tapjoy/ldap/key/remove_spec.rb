require_relative '../key'
RSpec.describe 'Tapjoy::LDAP::Key::Remove.remove' do
  include_context 'key'

  let(:ldap_hash) {
    {
      dn: dn,
      sshpublickey: File.read(filename_ldap).split("\n")
    }
  }
  let(:dn) {"uid=#{username},ou=People,dc=example,dc=net"}
  let(:username) {'test.user'}
  let(:filename_in) {
    "#{File.expand_path("#{'../'*4}fixtures", __FILE__)}/keyfile_user_extra"
  }
  let(:filename_ldap) {
    "#{File.expand_path("#{'../'*4}fixtures", __FILE__)}/keyfile_user_main"
  }
  let(:ldap_attr) { OpenStruct.new ldap_hash}

  it 'removes keys' do
    ARGV << %w(remove -u test.user -F -f); ARGV.flatten!; ARGV << filename_in
    allow(fake_ldap).to receive(:search).and_return(ldap_attr)
    allow(Tapjoy::LDAP::Key).to receive(:verify_user).with(username, ldap_attr)
    allow_any_instance_of(Tapjoy::LDAP::Key::Remove).to receive(:current_keys).and_return(ldap_attr.sshpublickey)

    # @TODO: Figure out how to surface dn in a reasonable way to #replace_attribute
    expect(fake_ldap).to receive(:replace_attribute).with(nil, :sshPublicKey,
      [ldap_attr.sshpublickey[0]])
    Tapjoy::LDAP::Key.commands
  end
end
