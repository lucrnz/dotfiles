#!/usr/bin/env python3
import os, sys, subprocess
cs_path = os.environ['HOME'] + '/.conf_files/mono_scripts'
sh_path = cs_path + '/0_sh'
bin_path = cs_path + '/1_bin'

print(">Cleaning old binaries/shell_scripts")

for item in os.listdir(sh_path):
    item_fullpath = sh_path + '/' + item
    if os.path.isfile(item_fullpath):
        os.remove(item_fullpath)

for item in os.listdir(bin_path):
    item_fullpath = bin_path + '/' + item
    if os.path.isfile(item_fullpath):
        file_name, file_ext = os.path.splitext(item_fullpath)
        if file_ext.lower() == ".exe":
            os.remove(item_fullpath)

for item in os.listdir(cs_path):
    cs_filepath = cs_path + '/' + item
    if not os.path.isfile(cs_filepath):
        continue
    file_name_full, file_ext = os.path.splitext(cs_filepath)
    file_name_arr = file_name_full.split('/')
    file_name = file_name_arr[-1]
    if file_ext.lower() != '.cs':
        continue
    print(f">Compiling {item}")
    sh_filepath = sh_path + '/' + file_name
    bin_filepath = bin_path + '/' + file_name + '.exe'
    if os.path.isfile(bin_filepath):
        os.remove(bin_filepath)
    if os.path.isfile(sh_filepath):
        os.remove(sh_filepath)
    mcs_cmd = ['mcs', cs_filepath, '-out:' + bin_filepath]
    mcs_cwd = cs_path
    mcs_env = os.environ.copy()
    subprocess.Popen(mcs_cmd, env=mcs_env, cwd=mcs_cwd).wait()
    print(f">Building script for {item}")
    with open(sh_filepath, 'w+') as sh_file_h:
        lines = ['#!/bin/sh\n', 'mono "' + bin_filepath + '" $@\n']
        sh_file_h.writelines(lines)
    subprocess.call(['chmod', '+x', sh_filepath])
