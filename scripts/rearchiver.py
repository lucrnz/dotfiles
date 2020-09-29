#!/usr/bin/env python3
import os, sys, errno, subprocess, uuid
from pathlib import Path

def get_filelist_by_extension(folder, ext):
	result = []
	for f in os.listdir(folder):
		if os.path.isfile(os.path.join(folder, f)) and f.find('.') > -1:
			if f.split('.')[1].lower() == ext.lower():
				result.append(f)
	return result

def get_filelist(folder):
	result = []
	for f in os.listdir(folder):
		if os.path.isfile(f):
			result.append(f)
	return result

def compress_folder(folder, zip_file_path):
	file_list = get_filelist(folder)
	arguments = ["7za", "a", "-tzip", "-mx0", zip_file_path]
	arguments += file_list
	process = subprocess.Popen(arguments, cwd=folder, env=os.environ.copy(), stdout=subprocess.DEVNULL)
	process.wait()
	return process.returncode == 0

def decompress_archiver(archiver_file_path, extract_dir):
	env_cpy = os.environ.copy()
	process = subprocess.Popen(["7z", "x", archiver_file_path], cwd=extract_dir, env=os.environ.copy(), stdout=subprocess.DEVNULL)
	process.wait()
	return process.returncode == 0

def remove_folder_recursive(folder):
	if not os.path.exists(folder):
		return False
	process = subprocess.Popen(["rm", "-rf", folder], cwd=Path(folder).parent, env=os.environ.copy(), stdout=subprocess.DEVNULL)
	process.wait()
	return (process.returncode == 0) and os.path.exists(folder) == False

#sys.argv[1] = folder to find files to recompress
target_dir = sys.argv[1]

if os.path.exists(target_dir):
	target_dir = os.path.abspath(target_dir)
else:
	print("Target directory does not exists.")
	sys.exit()

tmp_folder_parent = "/tmp/reachiverpy_" + str(uuid.uuid4())
os.mkdir(tmp_folder_parent)

for zipfile in get_filelist_by_extension(target_dir, "zip"):
	zipfile_fullpath = os.path.join(target_dir, zipfile)
	tmp_folder = os.path.join(tmp_folder_parent, os.path.splitext(zipfile)[0] + "_" + str(uuid.uuid4()))
	os.mkdir(tmp_folder)
	print("Processing " + zipfile)
	if decompress_archiver(zipfile_fullpath, tmp_folder):
		os.remove(zipfile_fullpath)
		compress_folder(tmp_folder, zipfile_fullpath)

remove_folder_recursive(tmp_folder_parent)
