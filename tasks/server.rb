#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../files/pnap_task_helper.rb'

def server_list(bmc_client, params)
  id = params['id']
  return PnapTaskHelper.server(bmc_client, id) unless id.nil?
  PnapTaskHelper.servers(bmc_client)
end

begin
  params = JSON.parse(STDIN.read)
  bmc_client = PnapTaskHelper.init_bmc_client(params)
  list = server_list(bmc_client, params)
  puts({ result: list }.to_json)
rescue => e
  puts({ status: 'failure', error: e }.to_json)
  exit 1
end

exit 0
