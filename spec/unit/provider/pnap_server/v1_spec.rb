require 'spec_helper'

server_provider = Puppet::Type.type(:pnap_server).provide(:v1)

describe server_provider do
  let(:resource) do
    Puppet::Type.type(:pnap_server).new(
      name:     'test',
      os:       'ubuntu/bionic',
      type:     's1.c1.medium',
      location: 'PHX',
    )
  end

  let(:provider) { resource.provider }

  it 'is an instance of ProviderV1' do
    expect(provider).to be_an_instance_of Puppet::Type::Pnap_server::ProviderV1
  end
end
