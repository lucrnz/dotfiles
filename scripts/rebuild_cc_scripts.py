#!/usr/bin/env python3
import os, sys, subprocess
cc_path = os.environ['HOME'] + '/.conf_files/cc_scripts'
bin_path = cc_path + '/bin'

print(">Cleaning old binaries")

for item in os.listdir(bin_path):
    item_fullpath = bin_path + '/' + item
    if os.path.isfile(item_fullpath):
        os.remove(item_fullpath)

for item in os.listdir(cc_path):
    cc_filepath = cc_path + '/' + item
    if not os.path.isfile(cc_filepath):
        continue
    file_name_full, file_ext = os.path.splitext(cc_filepath)
    file_name_arr = file_name_full.split('/')
    file_name = file_name_arr[-1]
    if file_ext.lower() != '.cc':
        continue
    print(f">Compiling {item}")
    bin_filepath = bin_path + '/' + file_name
    if os.path.isfile(bin_filepath):
        os.remove(bin_filepath)
    cc_cmd = ['g++', '-o' + bin_filepath, cc_filepath]
    cc_cwd = cc_path
    cc_env = os.environ.copy()
    subprocess.Popen(cc_cmd, env=cc_env, cwd=cc_cwd).wait()
    subprocess.call(['chmod', '+x', bin_filepath])
