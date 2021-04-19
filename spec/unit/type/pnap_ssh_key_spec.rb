require 'spec_helper'

type = Puppet::Type.type(:pnap_ssh_key)

describe type do
  let :params do
    [
      :name,
    ]
  end

  let :properties do
    [
      :ensure,
      :id,
      :default,
      :key,
      :fingerprint,
      :created_on,
      :last_updated_on,
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

  it 'ensure defaults to present' do
    ssh_key = type.new(name: 'test')
    expect(ssh_key[:ensure]).to eq(:present)
  end

  it 'default defaults to false' do
    ssh_key = type.new(name: 'test')
    expect(ssh_key[:default]).to eq(:false)
  end

  [
    :name,
    :key,
  ].each do |property|
    it "#{property} value is required to be a string" do
      expect(type).to require_string_for(property)
    end
  end
end
