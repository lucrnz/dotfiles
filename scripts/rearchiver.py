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

def compress_folder(folder, archiver_file_path, compression_level):
	arguments = ["7za", "a", "-tzip" , "-mx" + compression_level, archiver_file_path]
	arguments += os.listdir(folder)
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

def process_folder(target_dir, compression_level):
	for archive_file in get_filelist_by_extension(target_dir, "zip"):
		print("Processing " + archive_file)
		process_file(os.path.join(target_dir, archive_file))

def process_file(archive_file_fullpath, compression_level):
	tmp_folder = "/tmp/reachiverpy_" + str(uuid.uuid4())
	os.mkdir(tmp_folder)
	if decompress_archiver(archive_file_fullpath, tmp_folder):
		os.remove(archive_file_fullpath)
		compress_folder(tmp_folder, archive_file_fullpath, compression_level)
	remove_folder_recursive(tmp_folder)

def main():
	compression_level = sys.argv[1] # compression level = 0 - None - 9 - Best
	target = sys.argv[2] #folder to find files to recompress / Archive file to rearchive

	if target == ".":
		target = os.getcwd()

	if os.path.exists(target):
		target = os.path.abspath(target)
	else:
		print("Target does not exists.")
		sys.exit()

	if os.path.isdir(target):
		process_folder(target, compression_level)
	elif os.path.isfile(target):
		process_file(target, compression_level)
	else:
		print("Unsuported file")

if __name__ == "__main__":
	main()
