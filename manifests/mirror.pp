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
  $daily_snapshots    = false,
  $group              = 'root',
  $hash_index         = false,
  $mirror_root        = '/srv/static/mirror',
  $snapshot_retention = 5,
  $static_root        = '/srv/static',
  $user               = 'root',
) {

  if ! defined(File[$static_root]) {
    file { $static_root:
      ensure => directory,
    }
  }

  file { $mirror_root:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    require => File[$static_root],
  }

  file { "${mirror_root}/web":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    require => File[$mirror_root],
  }

  file { '/etc/bandersnatch.conf':
    ensure  => present,
    content => template('bandersnatch/bandersnatch.conf.erb'),
  }

  if $daily_snapshots {
    $ensure_snapshot = 'present'
  } else {
    $ensure_snapshot = 'absent'
  }

  file { '/usr/local/bin/run-bandersnatch-snapshotting':
    ensure => $ensure_snapshot,
    source => 'puppet:///modules/bandersnatch/run_snapshotting.sh',
    mode   => '0755',
  }

  cron { 'bandersnatch-snapshot':
    ensure      => $ensure_snapshot,
    user        => $user,
    minute      => '10',
    hour        => '*/1',
    command     => "flock -w 300 /var/run/bandersnatch/mirror.lock run-bandersnatch-snapshotting ${mirror_root}/web ${snapshot_retention} >>/var/log/bandersnatch/mirror.log 2>&1",
    environment => 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
    require     => File['/usr/local/bin/run-bandersnatch-snapshotting'],
  }
}
