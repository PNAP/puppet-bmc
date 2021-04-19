#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../files/pnap_task_helper.rb'

def create_server(bmc_client, params)
  server_hash = {
    hostname:               params['hostname'],
    os:                     params['os'],
    type:                   params['type'],
    location:               params['location'],
    description:            params['description'],
    networkType:            params['network_type'],
    pricingModel:           params['pricing_model'],
    reservationId:          params['reservation_id'],
    installDefaultSshKeys:  params['install_default_ssh_keys'],
    sshKeyIds:              params['ssh_key_ids'],
    sshKeys:                params['ssh_keys'],
  }

  create = Bmc::Sdk::CreateServer.new(bmc_client, server_hash)
  result = create.execute
  server = JSON.parse(result.body)

  PnapTaskHelper.wait_for_power_on(bmc_client, server['id'])

  puts(server.to_json)
end

begin
  params = JSON.parse(STDIN.read)
  bmc_client = PnapTaskHelper.init_bmc_client(params)
  create_server(bmc_client, params)
rescue => e
  puts({ status: 'failure', error: e }.to_json)
  exit 1
end

exit 0
