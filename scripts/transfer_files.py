#!/usr/bin/env python3
# Lucie: 20221031 - I have no idea why I wrote this script in the first place

import os, sys, shutil
if len(sys.argv) != 3:
    print("Usage: transfer_files.py <extension> <target_path>")
    print("\t-Multiple extensions might be specified with a comma.")
    print("\t-Example:")
    print("\t\ttransfer_files.py mp4,mkv /mnt/ftp/Videos")
    exit()

if sys.argv[1].find(',') != -1:
    exts = sys.argv[1].split(',')
else:
    exts = [sys.argv[1]]

dest_dir = sys.argv[2]

if not os.path.isdir(dest_dir):
    print('Target directory does not exists')
    exit()

cwd = os.getcwd()
for item in os.listdir(cwd):
    if os.path.isfile(item):
        file_name, file_ext_full = os.path.splitext(item)
        file_ext = file_ext_full[1:]
        if file_ext.lower() in exts:
            source_file_path = f'{cwd}/{item}'
            dest_file_path = f'{dest_dir}/{file_name}.{file_ext}'
            if dest_file_path.find('//'):
                dest_file_path = dest_file_path.replace('//', '/')
            if not os.path.isfile(dest_file_path):
                print(f'>Copying {item}...')
                shutil.copyfile(source_file_path, dest_file_path)
