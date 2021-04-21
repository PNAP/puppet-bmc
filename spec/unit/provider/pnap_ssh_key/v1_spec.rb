require 'spec_helper'

ssh_key_provider = Puppet::Type.type(:pnap_ssh_key).provide(:v1)

describe ssh_key_provider do
  let(:resource) do
    Puppet::Type.type(:pnap_ssh_key).new(
      name:    'test',
      default: false,
      key:     'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQXdz98ZSsCjUVLHLU1ZN/v5ynCU9kLCC8l1KP1RfUJ8Xy+pmWm4lWGtiGsqFLle+X1F+2pfLSCeQWbYM7/BNNkksAFTwt4uiq4TVC03rEVt2TShWDfTOTkdez3I+XppMLRVJRPEGgXCQ8tpnEacDXbE75vPGJcT93VMjw/N/Dswg4xndoe1A4LvRHfRwhXqpFjySp6ZLPFKgfb1G8gyPZZ6PvMmw1/DQENY4mYNT1OA+Z82OQ/1A7XrmX15Yr9PWPvI+ZJSVCzvBBI895MZunLju0iX93kgFzwMzELZ30ktkwbP2NJkwem5QQaMBmUPk/HJC5ndhCt0FZtJpxO1zHSo7lLOolfH1g2vRIVOiGMKKQiLCFJMlzG9pfgYsCpa7u9CqkXQR34gxlhnheqUMmiGk4+3VwR+huMN+6QIfpbyuakyxP3wPSMtU9T6xhF2mD4vVH6br0KGjtwBhsKXLp1YcTRlYT6763uvdSFLAUc3K0jSe7ygyddv5RweoKQKOy0D9+sV1PHs40VGlncch7fAfbqhhRragUe8yiFVfCUXqaHkkYYdIOLAZ16+UKPIsZc/XsftthtbhJ5WMwOV5g1LSlliZ0KY6HKvhHb/zAOgR3r46kfQNzRiW9QfuFMPREHDayavTsV2j/E3gIKsAINheoiizoT6YmgfsA4k2eAw== markome@phoenixnap.com'
    )
  end

  let(:provider) { resource.provider }

  it 'is an instance of ProviderV1' do
    expect(provider).to be_an_instance_of Puppet::Type::Pnap_ssh_key::ProviderV1
  end
end
