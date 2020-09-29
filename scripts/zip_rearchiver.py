#!/usr/bin/env python3
import os, sys, errno, subprocess, uuid

def get_filelist_by_extension(folder, ext):
	result = []
	for f in os.listdir(folder):
		if os.path.isfile(f) and f.find('.') > -1:
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
	env_cpy = os.environ.copy()
	file_list = get_filelist(folder)
	process = subprocess.Popen(["7za", "a", "-tzip", "-mx0", zip_file_path], cwd=folder, env=env_cpy, stdout=subprocess.DEVNULL)
	process.wait()
	return process.returncode == 0

def decompress_archiver(archiver_file_path, extract_dir):
	env_cpy = os.environ.copy()
	process = subprocess.Popen(["7z", "x", archiver_file_path], cwd=extract_dir, env=env_cpy, stdout=subprocess.DEVNULL)
	process.wait()
	return process.returncode == 0

#sys.argv[1] =  folder to find files to recompress

target_dir = sys.argv[1]

for zipfile in get_filelist_by_extension(target_dir, "zip"):
	zipfile_fullpath = os.path.join(target_dir, zipfile)
	tmp_folder = "/tmp/" + str(uuid.uuid4()
	decompress(zipfile_fullpath, tmp_folder))

