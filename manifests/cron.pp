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
# = Class: bandersnatch::cron
#
# Class to set up bandersnatch cron job.
#
# === Parameters
#
# [*timeout_duration*]
#  The bandersnatch command has been know to hang, causing the local mirror
#  to get out of sync. After an initial full-sync is complete (which takes
#  several hours), subsequent delta invocations are usually complete in
#  minutes. Set this option to e.g. '4h' duration to limit the amount of time
#  the process is possibly hanged, while still allowing longer deltas to sync.
#  You should NOT use this setting until after a full sync has been completed.
#  Otherwise, if the process aborts before the full sync completed, the full
#  sync will start over from the beginning and may never complete.
#  See 'man timeout'
#
# [*timeout_kill_duration*]
#   Optionally, force the bandersnatch process to be killed if it is still
#   running e.g. '2m' after the timeout period. See 'man timeout' option -k.
#
# [*user*]
#   The user to run the bandersnatch cron job
#

class bandersnatch::cron (
  $timeout_duration = undef,
  $timeout_kill_duration = undef,
  $user = 'root',
) {

  $cron_timeout = inline_template("<% if @timeout_duration -%> timeout <% if @timeout_kill_duration -%> -k ${timeout_kill_duration} <% end -%> ${timeout_duration} <% end -%>")

  cron { 'bandersnatch':
    user        => $user,
    minute      => '*/5',
    command     => "flock -n /var/run/bandersnatch/mirror.lock ${cron_timeout} run-bandersnatch >>/var/log/bandersnatch/mirror.log 2>&1",
    environment => 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
  }
}
