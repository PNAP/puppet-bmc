
pnap_ssh_key { 'puppet':
  ensure  => present,
  default => true,
  key     => file('/path/to/public-key')
}
