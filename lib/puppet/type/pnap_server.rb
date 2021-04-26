Puppet::Type.newtype(:pnap_server) do
  @doc = 'Bare Metal Cloud Server type'

  newproperty(:ensure) do
    desc 'Current status of the server.'

    newvalues(:creating, :error)

    newvalue(:present) do
      provider.create unless provider.exists?
    end

    newvalue(:absent) do
      provider.delete if provider.exists?
    end

    newvalue(:poweredon) do
      provider.power_on if provider.exists?
    end

    newvalue(:poweredoff) do
      provider.power_off if provider.exists?
    end

    newvalue(:shutdown) do
      provider.shutdown if provider.exists?
    end

    newvalue(:rebooting) do
      provider.reboot if provider.exists?
    end

    newvalue(:resetting) do
      provider.reset if provider.exists?
    end

    def change_to_s(current, desired)
      desired = :poweredon if desired == :present
      (current == desired) ? current : "changed #{current} to #{desired}"
    end

    def insync?(is)
      is = :present if is == :creating
      is = :present if is == :poweredon
      is = :present if is == :poweredoff
      is = :present if is == :rebooting
      is = :present if is == :resetting
      is.to_s == should.to_s
    end
  end

  newproperty(:id) do
    desc 'The unique identifier of the server. Read-only property.'
    validate do |_|
      raise Puppet::Error, 'id is read-only.'
    end
  end

  newparam(:name, namevar: true) do
    desc 'Hostname of the server. How puppet identifies the server.'
    validate do |value|
      raise Puppet::Error, 'name must be defined' if value.nil?
      raise Puppet::Error, 'name must be a string' unless value.is_a? String
      raise Puppet::Error, 'name must not contain spaces' if value =~ %r{\s}
    end
  end

  newproperty(:description) do
    desc 'Description of the server.'
    validate do |value|
      raise Puppet::Error, 'description must be a string' unless value.is_a? String
    end
  end

  newproperty(:os) do
    desc 'The server\'s OS ID used when the server was created. '
    newvalues(
      'ubuntu/bionic',
      'centos/centos7',
      'windows/srv2019std',
      'windows/srv2019dc',
    )
    validate do |value|
      raise Puppet::Error, 'os must be defined' if value.nil?
      raise Puppet::Error, 'os must be a string' unless value.is_a? String
      raise Puppet::Error, 'os not contain spaces' if value =~ %r{\s}
    end
  end

  newproperty(:type) do
    desc 'Server Type ID. This property is read-only once instance is created.'
    validate do |value|
      raise Puppet::Error, 'type must be defined' if value.nil?
      raise Puppet::Error, 'type name must be a string' unless value.is_a? String
      raise Puppet::Error, 'type must not contain spaces' if value =~ %r{\s}
    end
  end

  newproperty(:location) do
    desc 'Server Location ID. This property is read-only once instance is created.'
    newvalues(
      'PHX',
      'ASH',
      'SGP',
      'NLD',
    )
    validate do |value|
      raise Puppet::Error, 'location must be defined' if value.nil?
      raise Puppet::Error, 'location must be a string' unless value.is_a? String
      raise Puppet::Error, 'location must not contain spaces' if value =~ %r{\s}
    end
  end

  newproperty(:cpu) do
    desc 'A description of the machine cpu. Read-only property.'
    validate do |_|
      raise Puppet::Error, 'cpu is read-only.'
    end
  end

  newproperty(:ram) do
    desc 'A description of the machine ram. Read-only property.'
    validate do |_|
      raise Puppet::Error, 'ram is read-only.'
    end
  end

  newproperty(:storage) do
    desc 'A description of the machine storage. Read-only property.'
    validate do |_|
      raise Puppet::Error, 'storage is read-only.'
    end
  end

  newparam(:install_default_ssh_keys) do
    desc 'Whether or not to install ssh keys marked as default in addition to any ssh keys specified in this request.'
    defaultto :true
    newvalues(:true, :false)
    def insync?(is)
      is.to_s == should.to_s
    end
  end

  newparam(:ssh_key_ids, array_matching: :all) do
    desc 'A list of SSH Key IDs that will be installed on the Linux server in addition to any ssh keys specified in this request.'
    validate do |value|
      raise Puppet::Error, 'ssh_key_ids must be an array of string.' unless value.is_a? Array
    end
  end

  newparam(:ssh_keys, array_matching: :all) do
    desc 'A list of SSH Keys that will be installed on the Linux server.'
    validate do |value|
      raise Puppet::Error, 'ssh_keys must be an array of strings.' unless value.is_a? Array
    end
  end

  newproperty(:private_ip_addresses, array_matching: :all) do
    desc 'Private IP Addresses assigned to server. Read-only property.'
    validate do |_|
      raise Puppet::Error, 'private_ip_addresses is read-only.'
    end
  end

  newproperty(:public_ip_addresses, array_matching: :all) do
    desc 'Public IP Addresses assigned to server. Read-only property.'
    validate do |_|
      raise Puppet::Error, 'public_ip_addresses is read-only.'
    end
  end

  newproperty(:reservation_id) do
    desc 'Server reservation ID.'
    validate do |value|
      raise Puppet::Error, 'reservation_id name must be a string' unless value.is_a? String
      raise Puppet::Error, 'reservation_id must not contain spaces' if value =~ %r{\s}
    end
  end

  newproperty(:pricing_model) do
    desc 'Server pricing model.'
    newvalues(
      'HOURLY',
      'ONE_MONTH_RESERVATION',
      'TWELVE_MONTHS_RESERVATION',
      'TWENTY_FOUR_MONTHS_RESERVATION',
      'THIRTY_SIX_MONTHS_RESERVATION',
    )
    validate do |value|
      raise Puppet::Error, 'pricing_model must be a string' unless value.is_a? String
      raise Puppet::Error, 'pricing_model must not contain spaces' if value =~ %r{\s}
    end
  end

  newproperty(:password) do
    desc 'Password set for user Admin on Windows server which will only be
        returned in response to provisioning a server. Read-only property.'
    validate do |_|
      raise Puppet::Error, 'Password is read-only.'
    end
  end

  newproperty(:network_type) do
    desc 'The type of network configuration for the server.'
    defaultto 'PUBLIC_AND_PRIVATE'
    newvalues('PUBLIC_AND_PRIVATE', 'PRIVATE_ONLY')
    validate do |value|
      raise Puppet::Error, 'network_type must be a string' unless value.is_a? String
      raise Puppet::Error, 'network_type must not contain spaces' if value =~ %r{/s}
    end
  end
end
