Puppet::Type.newtype(:pnap_ssh_key) do
  @doc = 'Bare Metal Cloud SSH Key type'

  newproperty(:ensure) do
    defaultto :present

    newvalue(:present) do
      provider.create unless provider.exists?
    end
    newvalue(:absent) do
      provider.delete if provider.exists?
    end
  end

  newproperty(:id) do
    desc 'The id of the ssh key. Read-only property.'
    validate do |_|
      raise Puppet::Error, 'id is read-only.'
    end
  end

  newparam(:name, namevar: true) do
    desc 'Name of the SSH Key. How puppet identifies the SSH Key.'
    validate do |value|
      raise Puppet::Error, 'name must be defined' if value.nil?
      raise Puppet::Error, 'name must be a string' unless value.is_a? String
      raise Puppet::Error, 'name must not contain spaces' if value =~ %r{\s}
    end
  end

  newproperty(:default) do
    desc 'Is the default SSH key?'
    defaultto :false

    newvalue(:true) do
      provider.change if provider.exists?
    end
    newvalue(:false) do
      provider.change if provider.exists?
    end

    def insync?(is)
      is.to_s == should.to_s
    end
  end

  newproperty(:key) do
    desc 'SSH Key value.'
    validate do |value|
      raise Puppet::Error, 'key must defined' if value.nil?
      raise Puppet::Error, 'key must be a string' unless value.is_a? String
    end
  end

  newproperty(:fingerprint) do
    desc 'SSH Key auto-generated SHA-256 fingerprint. Read-only property.'
    validate do |_|
      raise Puppet::Error, 'fingerprint is read-only.'
    end
  end

  newproperty(:created_on) do
    desc 'Date and time of creation. Read-only property.'
    validate do |_|
      raise Puppet::Error, 'created_on is read-only.'
    end
  end

  newproperty(:last_updated_on) do
    desc 'Date and time of last update. Read-only property.'
    validate do |_|
      raise Puppet::Error, 'last_updated_on is read-only.'
    end
  end
end
