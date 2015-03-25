# Copyright 2015 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# = Class: bandersnatch::mirror
#
# Class to set up bandersnatch mirroring.
#
class bandersnatch::mirror (
  $vhost_name,
  $mirror_root = '/srv/static/mirror',
  $static_root = '/srv/static'
) {

  if ! defined(File[$static_root]) {
    file { $static_root:
      ensure => directory,
    }
  }

  file { $mirror_root:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    require => File[$static_root],
  }

  file { "${mirror_root}/web":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    require => File[$mirror_root],
  }

  include apache

  apache::vhost { $vhost_name:
    port     => 80,
    priority => '50',
    docroot  => "${mirror_root}/web",
    require  => File["${mirror_root}/web"],
  }

  file { "${mirror_root}/web/robots.txt":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/bandersnatch/robots.txt',
    require => File["${mirror_root}/web"],
  }

  file { '/etc/bandersnatch.conf':
    ensure   => present,
    content  => template('bandersnatch/bandersnatch.conf.erb'),
  }

  cron { 'bandersnatch':
    minute      => '*/5',
    command     => 'flock -n /var/run/bandersnatch/mirror.lock timeout -k 2m 30m run-bandersnatch >>/var/log/bandersnatch/mirror.log 2>&1',
    environment => 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
  }
}