require 'spec_helper'

type = Puppet::Type.type(:pnap_server)

describe type do
  let :params do
    [
      :name,
      :install_default_ssh_keys,
      :ssh_key_ids,
      :ssh_keys,
    ]
  end

  let :properties do
    [
      :ensure,
      :id,
      :description,
      :os,
      :type,
      :location,
      :cpu,
      :ram,
      :storage,
      :private_ip_addresses,
      :public_ip_addresses,
      :reservation_id,
      :pricing_model,
      :password,
      :network_type,
    ]
  end

  it 'has expected properties' do
    properties.each do |property|
      expect(type.properties.map(&:name)).to be_include(property)
    end
  end

  it 'has expected parameters' do
    params.each do |param|
      expect(type.parameters).to be_include(param)
    end
  end

  it 'requires a name' do
    expect {
      type.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'install_default_ssh_keys defaults to true' do
    server = type.new(name: 'test')
    expect(server[:install_default_ssh_keys]).to eq(:true)
  end

  it 'network_type defaults to PUBLIC_AND_PRIVATE' do
    server = type.new(name: 'test')
    expect(server[:network_type]).to eq(:PUBLIC_AND_PRIVATE)
  end

  [
    :name,
    :description,
    :os,
    :location,
    :pricing_model,
    :network_type,
  ].each do |property|
    it "#{property} value is required to be a string" do
      expect(type).to require_string_for(property)
    end
  end
end
