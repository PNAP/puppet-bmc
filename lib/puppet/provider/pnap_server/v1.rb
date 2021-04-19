require_relative '../../../puppet_x/pnap/server_provider.rb'

Puppet::Type.type(:pnap_server).provide(
  :v1,
  parent: PuppetX::PNAP::ServerProvider,
) do
  desc 'Manage PhoenixNAP Bare Metal Servers.'

  confine feature: :bmc

  mk_resource_methods

  read_only(:name, :description, :os, :type, :location,
            :install_default_ssh_keys)

  def initialize(value = {})
    super(value)
  end

  def self.instances
    server_list = []
    servers.each do |instance|
      hash = instance_to_hash(instance)
      server_list << new(hash)
    end
    server_list
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov if resource[:name] == prov.name
      end
    end
  end

  def self.instance_to_hash(instance)
    state = case instance['status']
            when 'powered-on'
              :poweredon
            when 'powered-off'
              :poweredoff
            when 'shutdown'
              :shutdown
            when 'rebooting'
              :rebooting
            when 'resetting'
              :resetting
            when 'creating'
              :creating
            else
              :error
            end

    config = {
      id:                   instance['id'],
      ensure:               state,
      name:                 instance['hostname'],
      description:          instance['description'],
      os:                   instance['os'],
      type:                 instance['type'],
      location:             instance['location'],
      cpu:                  instance['cpu'],
      ram:                  instance['ram'],
      storage:              instance['storage'],
      private_ip_addresses: instance['privateIpAddresses'],
      public_ip_addresses:  instance['publicIpAddresses'],
      reservation_id:       instance['reservationId'],
      pricing_model:        instance['pricingModel'],
      password:             instance['password'],
      network_type:         instance['networkType'],
    }

    config
  end

  def exists?
    Puppet.info("Checking if server #{name} exists.")
    powered_on? || powered_off? || creating? || rebooting? || resetting?
  rescue
    false
  end

  def creating?
    Puppet.info("Checking if server #{name} is being created.")
    @property_hash[:ensure] == :creating
  end

  def powered_on?
    Puppet.info("Checking if server #{name} is running.")
    [:present, :poweredon].include? @property_hash[:ensure]
  end

  def powered_off?
    Puppet.info("Checking if server #{name} is powered off.")
    @property_hash[:ensure] == :poweredoff
  end

  def rebooting?
    Puppet.info("Checking if server #{name} is rebooting.")
    @property_hash[:ensure] == :rebooting
  end

  def resetting?
    Puppet.info("Checking if server #{name} is rebooting.")
    @property_hash[:ensure] == :resetting
  end

  def create
    if powered_off?
      notice("Server #{name} already exists and is powered off, trying to power on...")
      power_on
    else
      notice("Creating server #{name} in #{resource[:location]} location.")

      server_hash = {
        hostname:               resource[:name],
        os:                     resource[:os],
        type:                   resource[:type],
        location:               resource[:location],
        description:            resource[:description],
        networkType:            resource[:network_type],
        pricingModel:           resource[:pricing_model],
        reservationId:          resource[:reservation_id],
        installDefaultSshKeys:  resource[:install_default_ssh_keys],
        sshKeyIds:              resource[:ssh_key_ids],
        sshKeys:                resource[:ssh_keys],
      }
      server_hash = clean_hash(server_hash)

      server = create_server(server_hash)

      @property_hash[:id] = server['id']
      @property_hash[:ensure] = :poweredon
    end
  end

  def power_on
    raise Puppet::Error, 'Could not power on a server that isnt\'t powered off.' unless powered_off?

    notice("Starting server #{name}.")
    power_on_server(@property_hash[:id])

    @property_hash[:ensure] = :poweredon
  end

  def shutdown
    raise Puppet::Error, 'Could not shutdown a server that isnt\'t powered on.' unless powered_on?

    notice("Shutting down server #{name}")
    shutdown_server(@property_hash[:id])

    @property_hash[:ensure] = :shutdown
  end

  def power_off
    raise Puppet::Error, 'Could not power off a server that isnt\'t powered on.' unless powered_on?

    notice("Powering off server #{name}")
    power_off_server(@property_hash[:id])

    @property_hash[:ensure] = :poweredoff
  end

  def reboot
    raise Puppet::Error, 'Can\'t reboot a server that isn\'t powered on.' unless powered_on?

    notice("Rebooting server #{name}")
    reboot_server(@property_hash[:id])

    @property_hash[:ensure] = :rebooting
  end

  def reset
    raise Puppet::Error, 'Could not reset a server that doesn\'t exist.' unless exists?
    raise Puppet::Error, 'Can\'t reset server while status is creating.' if creating?

    server = {
      id: @property_hash[:id],
      sshKeyIds: resource[:ssh_key_ids],
      sshKeys: resource[:ssh_keys],
      installDefaultSshKeys: resource[:install_default_ssh_keys],
    }

    notice("Resetting server #{name}")
    reset_server(server)

    @property_hash[:ensure] = :resetting
  end

  def delete
    raise Puppet::Error, 'Could not delete a server that doesn\'t exist.' unless exists?
    raise Puppet::Error, 'Can\'t delete server while status is creating.' if creating?

    notice("Deleting server #{name}")
    delete_server(@property_hash[:id])

    @property_hash[:ensure] = :absent
  end
end
