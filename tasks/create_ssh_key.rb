#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../files/pnap_task_helper.rb'

def create_ssh_key(bmc_client, params)
  ssh_key = Bmc::Sdk::SSHKeySpec.new(
    nil,
    params['default'],
    params['name'],
    params['key'],
    nil, nil, nil
  )
  create = Bmc::Sdk::CreateSSHKey.new(bmc_client, ssh_key)
  result = create.execute
  puts(result.body)
end

begin
  params = JSON.parse(STDIN.read)
  bmc_client = PnapTaskHelper.init_bmc_client(params)
  create_ssh_key(bmc_client, params)
rescue => e
  puts({ status: 'failure', error: e }.to_json)
  exit 1
end

exit 0
