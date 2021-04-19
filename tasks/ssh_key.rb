#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../files/pnap_task_helper.rb'

def key_list(bmc_client, params)
  name = params['name']
  keys = PnapTaskHelper.ssh_keys(bmc_client)

  return keys if name.nil?
  keys.each do |key|
    if key['name'] == name
      return key
    end
  end
end

begin
  params = JSON.parse(STDIN.read)
  bmc_client = PnapTaskHelper.init_bmc_client(params)
  list = key_list(bmc_client, params)
  puts(JSON.pretty_generate({ result: list }.to_json))
rescue => e
  puts({ status: 'failure', error: e }.to_json)
  exit 1
end

exit 0
