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
