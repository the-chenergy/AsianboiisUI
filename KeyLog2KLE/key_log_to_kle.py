'''
Generates the script to create a heatmap image on
http://keyboard-layout-editor.com for the key-log data.

Usage: ensure that there exists the key-log data (/KeyLogs.txt) and run this
script from the project's root directory.

v4.1 Beta
T 04/20/21
'''

import math
import re
import sys

KLE_RAW_FILENAME = 'KeyLog2KLE/key_log_kle_raw%s.txt'
CHARS_FILENAME = 'KeyLog2KLE/key_log_key_names%s.txt'
LABELS_FILESNAME = 'KeyLog2KLE/key_log_key_labels%s.txt'
LOG_FILENAME = 'KeyLogs.txt'
FULL_COLOR = tuple(int(s, 16) for s in re.findall('..', '6c71c4'))
NONE_COLOR = tuple(int(s, 16) for s in re.findall('..', 'ffffff'))

layout_name = ''
if len(sys.argv) > 1: layout_name = sys.argv[1]
KLE_RAW_FILENAME %= layout_name
CHARS_FILENAME %= layout_name
LABELS_FILESNAME %= layout_name

keys = {}
data = []
for i, (char, label) in enumerate(
        zip(
            open(CHARS_FILENAME, 'r').read().strip().split('\n'),
            open(LABELS_FILESNAME, 'r').read().strip().split('\n'))):
    char_low, char_up = char.split()
    label_low, label_up = label.split()
    keys[char_up] = (i, 'up')
    keys[char_low] = (i, 'low')
    data.append([None, label_up, label_low, 0, 0, 0])
    # color, upper, lower, freq_key, freq_up, freq_low

for i, log in enumerate(open(LOG_FILENAME).read().strip().split('\n')):
    if i == 0: continue # table header
    char, freq = log.split()
    freq = int(freq)
    key_index, case = keys[char]
    data[key_index][3] += freq
    if case == 'up': data[key_index][4] = freq
    else: data[key_index][5] = freq
total_freq = sum(key[3] for key in data)
min_freq = min(key[3] for key in data)
max_freq = max(key[3] for key in data)

data_combined = []
data_individual = []
for key in data:
    shade = math.log(key[3] / min_freq) / math.log(max_freq / min_freq)
    color = key[0] or ''.join(
        f'{round(NONE_COLOR[j] + (FULL_COLOR[j] - NONE_COLOR[j]) * shade):02x}'
        for j in range(3))
    char_up = key[1]
    char_low = key[2]
    freq_key = f'{key[3] / total_freq * 100:.1f}'
    freq_up = f'{key[4] / total_freq * 100:.1f}'
    freq_low = f'{key[5] / total_freq * 100:.1f}'
    data_combined.extend((color, char_up, char_low, freq_key))
    data_individual.extend((color, char_up, char_low, freq_up, freq_low))

data_combined.insert(0, f'{total_freq:,}') # metadata
kle_raw = open(KLE_RAW_FILENAME, 'r').read()
print(kle_raw % tuple(data_combined + data_individual))
