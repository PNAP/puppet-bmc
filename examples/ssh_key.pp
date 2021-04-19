
pnap_ssh_key { 'puppet':
  ensure  => present,
  default => true,
  key     => file('/home/markome/.ssh/id_rsa.pub')
}
