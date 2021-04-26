require 'spec_helper'

ssh_key_provider = Puppet::Type.type(:pnap_ssh_key).provide(:v1)

describe ssh_key_provider do
  let(:resource) do
    Puppet::Type.type(:pnap_ssh_key).new(
      name:    'test',
      default: false,
      key:     'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGL91Kq2wpl8w5FM2nSo6phjT8FB3UxaW8eIUfoQJMHr test@phoenixnap.com',
    )
  end

  let(:provider) { resource.provider }

  it 'is an instance of ProviderV1' do
    expect(provider).to be_an_instance_of Puppet::Type::Pnap_ssh_key::ProviderV1
  end
end
