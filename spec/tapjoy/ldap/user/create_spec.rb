require_relative '../../../spec_helper'
require_relative '../user'
describe 'Tapjoy::LDAP::User::Create.create' do
  include_context 'user'

  let(:ldap_attr) {{
    uid: "test.user",
    cn:  "testuser",
    objectclass: %w(
      top
      posixAccount
      shadowAccount
      inetOrgPerson
      organizationalPerson
      person
      ldapPublicKey),
    sn:            "user",
    givenname:     "test",
    homedirectory: "/home/test.user",
    loginshell:    "/bin/bash",
    mail:          "test.user@tapjoy.com",
    uidnumber: 10001,
    gidnumber: 19000,
    userpassword: '{SSHA}testpass'
  }}

  it 'creates a user' do
    ARGV << %w(create -u test user -g users); ARGV.flatten!
    allow_any_instance_of(Tapjoy::LDAP::User::Create).to receive(:create_password).and_return('testpass')
    expect(fake_ldap).to receive(:add).with(dn, ldap_attr)
    Tapjoy::LDAP::User.commands
  end
end
