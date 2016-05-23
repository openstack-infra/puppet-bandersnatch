class { '::bandersnatch':
}

class { '::bandersnatch::cron':
}

class { '::bandersnatch::httpd':
  vhost_name => '127.0.0.1',
}

class { '::bandersnatch::mirror':
  require    => Class['::bandersnatch'],
}

if $::osfamily == 'RedHat' {
  exec { 'manage selinux':
    command => 'semanage fcontext -a -t httpd_sys_content_t "/srv/static(/.*)?" && restorecon -R -v /srv',
    unless  => 'ls -lZ /srv | grep httpd_sys_content_t',
    path    => '/bin:/sbin',
    require => Class['::bandersnatch::mirror'],
  }
}
