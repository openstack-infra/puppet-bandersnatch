#!/usr/bin/python
# Copyright (c) 2014 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import logging
import os
import re
import requests
import subprocess
import time
import urlparse


def setup_logging(logger):
    ch = logging.StreamHandler()
    formatter = logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s')
    ch.setFormatter(formatter)
    logger.setLevel(logging.INFO)
    logger.addHandler(ch)


def normalize(name):
    return re.sub(r"[-_.]+", "-", name).lower()


def get_purge_urls(url):
    res = urlparse.urlparse(url)
    ret = [url]
    ret.append(os.path.join(url, 'json'))
    m = re.match('^/simple/([^/$]*)', res[2])
    if m:
        package = normalize(m.group(1))
        new_url = list(res[:])
        new_url[2] = '/simple/%s/' % package
        ret.append(urlparse.urlunparse(new_url))
        new_url[2] = '/simple/%s/json' % package
        ret.append(urlparse.urlunparse(new_url))
    return ret


def main():
    logger = logging.getLogger('bandersnatch')
    setup_logging(logger)

    stale = dict()
    try:
        output = subprocess.check_output(
            ['bandersnatch', 'mirror'], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        print e.output

    for line in output.split('\n'):
        print(line)
        if 'Expected PyPI serial' in line:
            url = line.split("for request ")[1].split()[0]
            stale[url] = True
    for stale_url in stale.keys():
        logger.info('Purging URLs for stale request %s' % stale_url)
        for url in get_purge_urls(stale_url):
            logger.info('Purging %s' % url)
            response = requests.request('PURGE', url)
            if not response.ok:
                logger.error('Failed to purge %s: %s' % (url, response.text))
            time.sleep(0.1)


if __name__ == '__main__':
    main()
