require_relative '../audit'
describe 'Tapjoy::LDAP::Audit.raw' do
  include_context 'audit'
  # let(:operations) {[[:add, :memberUid, 'test.user']]}

  let(:ldap_hash) {
    {dn: dn, uid: [username]}
  }
  let(:ldap_group_hash) {
    [
      { dn: ['cn=test_group,ou=Group,dc=example,dc=net'],
        cn: ['test_group'],
        memberUid: [username]
      },
      {
        dn: ['cn=test_group2,ou=Group,dc=example,dc=net'],
        cn: ['test_group2'],
        memberUid: ['notTest']
      }
    ]
  }
  let(:dn) {"uid=#{username},ou=People,dc=example,dc=net"}
  let(:username) {'test.user'}
  let(:results) { OpenStruct.new ldap_hash}
  let(:printed_hash) {
    {'test.user' => ['test_group']}
  }

  it 'audits by group' do
    ARGV << %w(raw); ARGV.flatten!

    expect(fake_ldap).to receive(:search).and_return([results])
    Tapjoy::LDAP::Audit.commands
  end
end
