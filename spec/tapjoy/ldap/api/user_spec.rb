require_relative '../user'
RSpec.describe 'Tapjoy::LDAP::API::User' do
  include_context 'user'

  describe '#create' do
    let(:ldap_attr) {{
      uid: "test.user",
      cn:  "Test User",
      objectclass: %w(
        top
        posixAccount
        shadowAccount
        inetOrgPerson
        organizationalPerson
        person
        ldapPublicKey),
      sn:            "User",
      givenname:     "Test",
      homedirectory: "/home/test.user",
      loginshell:    "/bin/bash",
      mail:          "test.user@tapjoy.com",
      uidnumber: 10001,
      gidnumber: 19000,
      userpassword: '{SSHA}testpass'
    }}

    it 'creates a user' do
      ARGV << %w(create -n test user -g users); ARGV.flatten!
      allow(Tapjoy::LDAP::API::User).to receive(:create_password).and_return('testpass')
      expect(fake_ldap).to receive(:add).with(distinguished_name, ldap_attr)

      Tapjoy::LDAP::CLI::User.commands
    end
  end

  describe '#delete' do
    it 'deletes a user' do
      ARGV << %w(delete -u test.user -f); ARGV.flatten!
      # Tapjoy::LDAP::API::User.create(fname, lname,
      #   opts[:type], opts[:group])
      allow(Tapjoy::LDAP::API::User).to receive(:create_password).and_return('testpass')
      expect(fake_ldap).to receive(:delete).with(distinguished_name)

      Tapjoy::LDAP::CLI::User.commands
    end
  end
end
