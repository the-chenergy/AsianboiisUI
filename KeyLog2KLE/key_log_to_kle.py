'''
Generates the script to create a heatmap image on
http://keyboard-layout-editor.com for the key-log data.

Usage: ensure that there exists the key-log data (/KeyLogs.txt) and run this
script from the project's root directory.

v4.1 Beta
F 01/22/21
'''

import re
KLE_RAW_FILENAME = 'KeyLog2KLE/key_log_kle_raw.txt'
CHARS_FILENAME = 'KeyLog2KLE/key_log_key_names.txt'
LABELS_FILESNAME = 'KeyLog2KLE/key_log_key_labels.txt'
LOG_FILENAME = 'KeyLogs.txt'
FULL_COLOR = tuple(int(s, 16) for s in re.findall('..', '6c71c4'))
NONE_COLOR = tuple(int(s, 16) for s in re.findall('..', 'ffffff'))

keys = {}
data = []
for i, (char, label) in enumerate(
        zip(
            open(CHARS_FILENAME, 'r').read().strip().split('\n'),
            open(LABELS_FILESNAME, 'r').read().strip().split('\n'))):
    char_low, char_up = char.split()
    label_low, label_up = label.split()
    keys[char_up] = keys[char_low] = i
    data.extend((None, label_up, label_low, 0)) # color, upper, lower, freq

for i, log in enumerate(open(LOG_FILENAME).read().strip().split('\n')):
    if i == 0: continue # table header
    char, freq = log.split()
    freq = int(freq)
    data[keys[char] * 4 + 3] += freq
total_freq = sum(data[i + 3] for i in range(0, len(data), 4))
min_freq = min(data[i + 3] for i in range(0, len(data), 4))
max_freq = max(data[i + 3] for i in range(0, len(data), 4))

import math
for i in range(0, len(data), 4):
    shade = math.log(data[i + 3] / min_freq) / math.log(max_freq / min_freq)
    data[i + 0] = ''.join(
        f'{round(NONE_COLOR[j] + (FULL_COLOR[j] - NONE_COLOR[j]) * shade):02x}'
        for j in range(3))
    data[i + 3] = f'{data[i + 3] / total_freq * 100:.1f}'

data.insert(0, f'{total_freq:,}') # metadata
kle_raw = open(KLE_RAW_FILENAME, 'r').read()
print(kle_raw % tuple(data))