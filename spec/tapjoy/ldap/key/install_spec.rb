require_relative '../key'
RSpec.describe 'Tapjoy::LDAP::Key::Install.install' do
  include_context 'key'

  let(:ldap_hash) {
    {
      uid: [username],
      sshpublickey: File.read(filename_ldap).split("\n")
    }
  }

  let(:dn) {"uid=#{username},ou=People,dc=example,dc=net"}
  let(:username) {'test.user'}
  let(:filename_ldap) {
    "#{File.expand_path("#{'../'*4}fixtures", __FILE__)}/keyfile_user_main"
  }
  let(:ssh_dir) {
    "#{File.expand_path("#{'../'*4}fixtures", __FILE__)}"
  }
  let(:authorized_key_file) {
    File.join(ssh_dir, 'authorized_keys')
  }
  let(:result) { OpenStruct.new ldap_hash}

  it 'installs keys to authorized_keys' do
    ARGV << %w(install); ARGV.flatten!
    allow(fake_ldap).to receive(:search).and_return([result])
    allow_any_instance_of(Tapjoy::LDAP::Key::Install).to receive(
      :directory).with(username).and_return(ssh_dir)

    Tapjoy::LDAP::Key.commands
    expect(File.read(authorized_key_file)).to match File.read(filename_ldap)
  end

  after do
    File.delete(authorized_key_file)
  end
end
