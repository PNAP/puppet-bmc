#!/bin/bash

PUPPET_VERSION='2019.8.4'

PUBLIC_HOSTNAME='puppet-master.local' # must be same as hostname
INTERNAL_HOSTNAME='puppet-master' # must be same as hostname

CONSOLE_PASSWORD='admin'

CLIENT_ID=''
CLIENT_SECRET=''

RESULTS_FILE='/tmp/puppet_bootstrap_output'

function check_exit_status() {
  if [ ! -f $RESULTS_FILE ]; then
    echo '1' > $RESULTS_FILE
  fi
}

trap check_exit_status INT TERM EXIT

function write_hosts_file() {
  sed -i "/$INTERNAL_HOSTNAME/ s/.*/127.0.1.1 $PUBLIC_HOSTNAME $INTERNAL_HOSTNAME/g" /etc/hosts
}

function write_masterconfig() {
  cat > /opt/puppet-enterprise.conf << CONFIG
{
    "console_admin_password": "$CONSOLE_PASSWORD"
    "puppet_enterprise::puppet_master_host": "$PUBLIC_HOSTNAME"
    "pe_install::puppet_master_dnsaltnames": ["$PUBLIC_HOSTNAME", "$INTERNAL_HOSTNAME"]
}
CONFIG
}

function install_pe_master() {
  if [ ! -d /opt/puppet-enterprise ]; then
    mkdir -p /opt/puppet-enterprise
  fi
  if [ ! -f /opt/puppet-enterprise/puppet-enterprise-installer ]; then
    echo "Downloading $PUPPET_VERSION installer to /opt/puppet-enterprise/ - this might take a while..."
    curl -L -s -o /opt/pe-installer.tar.gz "https://pm.puppet.com/cgi-bin/download.cgi?dist=ubuntu&rel=18.04&arch=amd64&ver=$PUPPET_VERSION"
    tar --extract --file=/opt/pe-installer.tar.gz --strip-components=1 --directory=/opt/puppet-enterprise
  fi
  write_masterconfig
  /opt/puppet-enterprise/puppet-enterprise-installer -c /opt/puppet-enterprise.conf
}

function download_pnap_module() {
  echo "Installing the PNAP Module with tasks..."
  /opt/puppetlabs/puppet/bin/gem install bmc-sdk-development
  curl -L -s -o /opt/phoenixnap-bmc-0.0.1.tar.gz https://github.com/markome-pnap/phoenixnap-bmc-puppet/releases/download/0.0.1/phoenixnap-bmc-0.0.1.tar.gz
  puppet module install --force /opt/phoenixnap-bmc-0.0.1.tar.gz
  if [ ! -d ~/.pnap ]; then
    mkdir -p ~/.pnap
  fi
  echo -e "client_id: $CLIENT_ID\nclient_secret: $CLIENT_SECRET" > ~/.pnap/config
  echo "PNAP Module Installation Finished"
}

function cleanup() {
  echo "Removing installation files (/opt/puppet-enterprise)"
  rm -rf /opt/puppet-enterprise
}

function provision_puppet() {
  distro=`lsb_release -d | awk -F"\t" '{print $2}' | awk -F " " '{print $1}'`
  if [[ "${distro,,}" != "ubuntu" ]]; then
    echo "This OS is not supported"
    exit 1
  fi

  write_hosts_file
  install_pe_master
  download_pnap_module

  echo "*" > /etc/puppetlabs/puppet/autosign.conf

  /opt/puppetlabs/bin/puppet agent --onetime --no-daemonize --color=false --verbose

  echo $? > $RESULTS_FILE
  echo "Puppet installation finished!"
    cleanup
  exit 0
}

provision_puppet
