if ($::osfamily == 'Debian') {
  # Installing pip since bandersnatch dependencies are managed by it
  package { 'python-setuptools':
    ensure => present,
  } -> exec { 'install pip using easy_install':
    command => 'easy_install -U pip',
    path    => '/bin:/usr/bin:/usr/local/bin'
  }
}
