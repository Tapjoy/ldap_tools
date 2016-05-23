require_relative '../key'
RSpec.describe 'Tapjoy::LDAP::Key::Add.add' do
  include_context 'key'

  let(:ldap_hash) {{
    dn: dn,
    objectclass: %w(
      top
      posixAccount
      shadowAccount
      inetOrgPerson
      organizationalPerson
      person,
      ldapPublicKey),
    sshpublickey: File.read(filename).split("\n")
  }}
  let(:ldap_attr) { OpenStruct.new ldap_hash}
  let(:dn) {'uid=test.user,ou=People,dc=example,dc=net'}


  it 'adds a key' do
    ARGV << %w(add -u test.user -f); ARGV.flatten!; ARGV << filename
    allow(fake_ldap).to receive(:search).and_return([ldap_attr])

    expect(fake_ldap).to receive(:add_attribute).with(dn, :sshPublicKey,
      ldap_attr.sshpublickey[0])
      expect(fake_ldap).to receive(:add_attribute).with(dn, :sshPublicKey,
        ldap_attr.sshpublickey[1])
    Tapjoy::LDAP::Key.commands
  end
end
