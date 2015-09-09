class { '::bandersnatch':
} -> class { '::bandersnatch::mirror':
  vhost_name => '127.0.0.1',
}
