require_relative '../../puppet_x/pnap/provider.rb'
require 'time'

# Pnap Server Provider API
class PuppetX::PNAP::ServerProvider < PuppetX::PNAP::Provider
  TIMEOUT_SECONDS = 300
  SLEEP_SECONDS   = 15
  def self.servers
    list = Bmc::Sdk::GetServers.new(load_bmc_client)
    result = list.execute
    JSON.parse(result.body)
  rescue => e
    raise Puppet::Error, 'Could not load BMC Server List: ' + parse_error_message(e)
  end

  def create_server(server)
    bmc_client = load_bmc_client
    create = Bmc::Sdk::CreateServer.new(bmc_client, server)
    result = create.execute

    server = JSON.parse(result.body)

    wait_for_power_on(bmc_client, server['id'])
  rescue => e
    raise Puppet::Error, e
  end

  def delete_server(id)
    destroy = Bmc::Sdk::DeleteServer.new(load_bmc_client, id)
    result = destroy.execute
    JSON.parse(result.body)
  rescue => e
    raise Puppet::Error, 'Could not destroy BMC Server: ' + parse_error_message(e)
  end

  def power_on_server(id)
    destroy = Bmc::Sdk::PowerOn.new(load_bmc_client, id)
    result = destroy.execute
    JSON.parse(result.body)
  rescue => e
    raise Puppet::Error, 'Could not power on BMC Server: ' + parse_error_message(e)
  end

  def power_off_server(id)
    power_off = Bmc::Sdk::PowerOff.new(load_bmc_client, id)
    result = power_off.execute
    JSON.parse(result.body)
  rescue => e
    raise Puppet::Error, 'Could not power off BMC Server: ' + parse_error_message(e)
  end

  def shutdown_server(id)
    shutdown = Bmc::Sdk::Shutdown.new(load_bmc_client, id)
    result = shutdown.execute
    JSON.parse(result.body)
  rescue => e
    raise Puppet::Error, 'Could not shutdown BMC Server: ' + parse_error_message(e)
  end

  def reboot_server(id)
    reboot = Bmc::Sdk::Reboot.new(load_bmc_client, id)
    result = reboot.execute
    JSON.parse(result.body)
  rescue => e
    raise Puppet::Error, 'Could not reboot BMC Server: ' + parse_error_message(e)
  end

  def reset_server(config)
    resetspec = Bmc::Sdk::ServerResetSpec.new(
      config[:id],
      config[:sshKeys],
      config[:sshKeyIds],
      config[:installDefaultSshKeys],
    )
    reset = Bmc::Sdk::Reset.new(load_bmc_client, resetspec)
    result = reset.execute
    JSON.parse(result.body)
  rescue => e
    raise Puppet::Error, 'Could not reset BMC Server: ' + parse_error_message(e)
  end

  def self.wait_for_power_on(bmc_client, server_id)
    notice("Waiting for Server ID #{server_id} to Power On.")
    get = Bmc::Sdk::GetServer.new(bmc_client, server_id)

    timeout = Time.now + TIMEOUT_SECONDS
    while Time.now < timeout
      result = get.execute
      server = JSON.parse(result.body)

      if server['status'] == 'powered-on'
        return server
      end
      sleep SLEEP_SECONDS
    end
    raise Puppet::Error, 'Timeout reached, server failed to power on.'
  rescue => e
    raise Puppet::Error, e
  end

  def wait_for_power_on(bmc_client, server_id)
    self.class.wait_for_power_on(bmc_client, server_id)
  end
end
