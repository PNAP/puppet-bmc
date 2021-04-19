require 'bmc-sdk'
require 'json'
require 'puppet'

# This is a helper class for common methods used in BMC Tasks
class PnapTaskHelper
  TIMEOUT_SECONDS = 300
  SLEEP_SECONDS   = 15

  def self.init_bmc_client(params)
    client_hash = {
      client_id: params['client_id'],
      client_secret: params['client_secret'],
    }
    Bmc::Sdk.new_client(client_hash)
  end

  def self.servers(bmc_client)
    list = Bmc::Sdk::GetServers.new(bmc_client)
    result = list.execute
    result.body
  end

  def self.server(bmc_client, id)
    server = Bmc::Sdk::GetServer.new(bmc_client, id)
    result = server.execute
    result.body
  end

  def self.ssh_keys(bmc_client)
    list = Bmc::Sdk::GetSSHKeys.new(bmc_client)
    result = list.execute
    result.body
  end

  def self.ssh_key(bmc_client, id)
    ssh_key = Bmc::Sdk::GetSSHKey(bmc_client, id)
    result = ssh_key.execute
    result.body
  end

  def self.wait_for_power_on(bmc_client, id)
    puts("Waiting #{TIMEOUT_SECONDS} seconds for Server ID #{id} to Power On.")

    timeout = Time.now + TIMEOUT_SECONDS

    while Time.now < timeout
      instance = server(bmc_client, id)

      if instance['status'] == 'powered-on'
        return instance
      end
      sleep SLEEP_SECONDS
    end
    raise Puppet::Error, 'Timeout reached, server failed to power on.'
  end
end
