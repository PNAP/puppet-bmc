require_relative '../../puppet_x/pnap/provider.rb'

# Pnap SSH Key Provider API
class PuppetX::PNAP::SshKeyProvider < PuppetX::PNAP::Provider
  def self.ssh_keys
    bmc_client = load_bmc_client
    begin
      list = Bmc::Sdk::GetSSHKeys.new(bmc_client)
      result = list.execute
      JSON.parse(result.body)
    rescue => e
      raise Puppet::Error, 'Could not load BMC SSH Key List: ' + parse_error_message(e)
    end
  end

  def create_ssh_key(key)
    bmc_client = load_bmc_client
    begin
      ssh_key = Bmc::Sdk::SSHKeySpec.new(
        nil,
        key[:default],
        key[:name],
        key[:key],
        nil, nil, nil
      )
      create = Bmc::Sdk::CreateSSHKey.new(bmc_client, ssh_key)
      result = create.execute
      JSON.parse(result.body)
    rescue => e
      raise Puppet::Error, 'Could not create BMC SSH Key: ' + parse_error_message(e)
    end
  end

  def edit_ssh_key(key)
    bmc_client = load_bmc_client
    begin
      ssh_key = Bmc::Sdk::SSHKeySpec.new(
        key[:id],
        key[:default],
        key[:name],
        nil, nil, nil, nil
      )

      edit = Bmc::Sdk::EditSSHKey.new(bmc_client, ssh_key)
      result = edit.execute
      JSON.parse(result.body)
    rescue => e
      raise Puppet::Error, e
    end
  end

  def delete_ssh_key(id)
    bmc_client = load_bmc_client
    begin
      delete = Bmc::Sdk::DeleteSSHKey.new(bmc_client, id)
      result = delete.execute
      JSON.parse(result.body)
    rescue => e
      raise Puppet::Error, 'Could not delete BMC SSH Key: ' + parse_error_message(e)
    end
  end
end
