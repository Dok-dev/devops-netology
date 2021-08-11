#! /usr/bin/python3

import os
import time
import json
from collections import namedtuple


def setLogName(path):
    ''' Get time structure "time.struct_time" and set log name. '''

    struct = time.localtime()
    filename = os.path.join(path, time.strftime('%Y-%m-%d', struct) + '-awesome-monitoring.log')
    return filename


def cpu_load():
    ''' Return the information in /proc/loadavg
    as a dictionary.
    '''

    with open('/proc/loadavg', 'r', encoding='utf-8') as f:
        one_line = f.read()
        cpu_info = {'LoadPerMinute': one_line.split(' ')[0],
                    'RunningProcesses': one_line.split(' ')[3].split('/')[0],
                    'TotalProcesses': one_line.split(' ')[3].split('/')[1]
                    }
    return cpu_info


def meminfo():
    ''' Return the information in /proc/meminfo
    as a dictionary. '''

    meminfo_dict = {}

    with open('/proc/meminfo', 'r', encoding='utf-8') as f:
        # Let's take only the necessary elements
        mertrics_list = [
            'MemAvailable',
            'SwapFree'
        ]
        for one_line in f:
            if mertrics_list.count(one_line.split(':')[0]) > 0:
                meminfo_dict[one_line.split(':')[0]] = one_line.split(':')[1].strip().split(' ')[0].strip()
    return meminfo_dict


def netdevs():
    ''' RX and TX bytes for each of the network devices '''

    with open('/proc/net/dev') as f:
        net_dump = f.readlines()

    device_data = {}
    data = namedtuple('data', ['rx', 'tx'])
    for line in net_dump[2:]:
        line = line.split(':')
        if line[0].strip() != 'lo':
            device_data[line[0].strip()] = data(float(line[1].split()[0]) / (1024.0 * 1024.0),
                                                float(line[1].split()[8]) / (1024.0 * 1024.0))

    return device_data

def disk_usage(path):
    ''' Return disk usage statistics about the given path. '''

    st = os.statvfs(path)
    free = st.f_bavail * st.f_frsize
    total = st.f_blocks * st.f_frsize
    # used = (st.f_blocks - st.f_bfree) * st.f_frsize
    diskusage = {'TotalDiskSpace': total, 'FreeDiskSpace': free}
    return diskusage


if __name__ == '__main__':

    try:
        metrics_dict = {**{'Timestamp': int(time.time())}, **cpu_load(), **meminfo(), **disk_usage('/'), **netdevs()}
        with open(setLogName('/var/log'), 'a', encoding='utf-8') as file:
            json.dump(metrics_dict, file)
            file.write('\n')
    except OSError as err:
        print('OS error: {0}'.format(err))
