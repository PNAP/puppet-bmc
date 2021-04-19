require_relative '../../../puppet_x/pnap/ssh_key_provider.rb'

Puppet::Type.type(:pnap_ssh_key).provide(
  :v1,
  parent: PuppetX::PNAP::SshKeyProvider,
) do

  desc 'Manage PhoenixNAP SSH Keys.'

  confine feature: :bmc

  mk_resource_methods

  read_only(:key, :name)

  def initialize(value = {})
    super(value)
  end

  def self.instances
    ssh_key_list = []
    ssh_keys.each do |instance|
      hash = instance_to_hash(instance)
      ssh_key_list << new(hash)
    end
    ssh_key_list
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov if resource[:name] == prov.name
      end
    end
  end

  def self.instance_to_hash(instance)
    {
      ensure: :present,
      id: instance['id'],
      name: instance['name'],
      default: instance['default'],
      fingerprint: instance['fingerprint'],
      created_on: instance['createdOn'],
      last_updated_on: instance['lastUpdatedOn'],
    }
  end

  def exists?
    Puppet.info("Checking if SSH Key #{name} exists.")
    Puppet.info((@property_hash[:ensure] == :present) ? 'Exists' : 'Doesnt exist')
    @property_hash[:ensure] == :present
  end

  def create
    raise Puppet::Error, "Ssh key #{name} already exists." if exists?

    Puppet.info("Creating SSH Key #{name}")
    create_ssh_key(resource)
    @property_hash[:ensure] = :creating
  end

  def change
    raise Puppet::Error, 'Could not change a key that doesn\'t exist.' unless exists?
    raise Puppet::Error, 'Missing \'default\' resource property' if resource[:default].nil?

    Puppet.info("Changing SSH key #{name}")

    key_hash = {
      id: @property_hash[:id],
      name: @property_hash[:name],
      default: resource[:default],
    }
    edit_ssh_key(key_hash)
    @property_hash[:default] = resource[:default]
  end

  def delete
    raise Puppet::Error, 'Could not delete a key that doesn\'t exist.' unless exists?

    notice("Deleting SSH Key #{name}")
    delete_ssh_key(@property_hash[:id])

    @property_hash[:ensure] = :absent
  end
end
