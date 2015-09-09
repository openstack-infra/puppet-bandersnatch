# Installing pip since bandersnatch dependencies are managed by it
exec { 'download get-pip.py':
  command => 'wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py',
  path    => '/bin:/usr/bin:/usr/local/bin',
  creates => '/tmp/get-pip.py',
}

exec { 'install pip using get-pip':
  command     => 'python /tmp/get-pip.py',
  path        => '/bin:/usr/bin:/usr/local/bin',
  refreshonly => true,
  subscribe   => Exec['download get-pip.py'],
}
