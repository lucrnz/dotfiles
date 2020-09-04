#!/usr/bin/env python3
# Needs configobj
# ArchLinux: sudo pacman -S python-pip --needed && sudo pip install configobj
# Debian: sudo apt install python3-pip -y && sudo pip3 install configobj

import os, sys, errno, socket, subprocess
from configobj import ConfigObj

# Start: Functions
def list_contains(needle, haystack):
	#@TODO : There might be a better way of doing this
    for i in haystack:
        if(i == needle):
            return True
    return False

def execute_proc(command):
    return subprocess.check_output(command).decode(sys.stdout.encoding).strip()

def get_filelist_by_extension(folder, ext):
	result = []
	for f in os.listdir(folder):
		if f.find('.') > -1:
			if f.split('.')[1] == ext:
				result.append(f)
	return result

def get_source_filelist(sourcepath, file_ext, ignored_files):
	flist = get_filelist_by_extension(sourcepath, file_ext)
	result_list = []
	for f in flist:
		if f.find(file_ext) > -1:
			file_fullpath = sourcepath + '/' + f
			if ignored_files == '' or ignored_files == []:
				result_list.append(file_fullpath)
			elif list_contains(f, ignored_files) == False:
					result_list.append(file_fullpath)
	return result_list

def process_ignored_files(ignored_files):
	result = []
	if ignored_files != '' and ignored_files.find(';') > -1:
		result = ignored_files.split('')
	return result

def process_compiler_binary(compiler):
	return [execute_proc(['which', compiler])]

def library_cpp_curl_getcmd():
	ret_str = execute_proc(['curl-config', '--cflags'])
	ret_str += execute_proc(['curl-config', '--libs'])
	return ret_str.split(' ')

def process_libraries(libraries):
	result_cmd = []
	libraries = libraries.split(';')
	for lib in libraries:
		if lib == 'cpp_curl': # @TODO : Reflection, maybe?
			result_cmd += library_cpp_curl_getcmd()
	return result_cmd

def process_cpp_flags(cpp_std, cpp_include_path):
	result = []
	if cpp_std != '':
		result += ['-std=' + cpp_std]

	if cpp_include_path != '':
		result += ['-I', cpp_include_path]
	return result

def process_build_type(cfg_buildtarget, cfg_debug_flags, cfg_release_flags):
	# @TODO : Find a better way to have a Debug and Target Config? Maybe another file?
	result = []
	if cfg_buildtarget == 'Release':
		result += cfg_release_flags.split(';')
	elif cfg_buildtarget == 'Debug':
		result += cfg_debug_flags.split(';')
	return result

def spawn_daemon(func):
	# do the UNIX double-fork magic, see Stevens' "Advanced
	# Programming in the UNIX Environment" for details (ISBN 0201563177)
	try:
		pid = os.fork()
		if pid > 0:
			return
	except OSError as e:
		print("fork #1 failed: %d (%s)" % (e.errno, e.strerror), file=sys.stderr)
		sys.exit(1)
	os.setsid()
	try:
		pid = os.fork()
		if pid > 0:
			sys.exit(0)
	except OSError as e:
		print("fork #2 failed: %d (%s)" % (e.errno, e.strerror), file=sys.stderr)
		sys.exit(1)
	func()
	os._exit(os.EX_OK)
#End Functions

# Default configuration
cfg = {}
cfg['Compiler'] = 'g++'
cfg['FileExt'] = 'cpp'
cfg['SourcePath'] = os.getcwd() + '/Lucie'
cfg['BuildTarget'] = 'Debug'
cfg['DebugFlags'] = '-g' # Separated by ';'
cfg['ReleaseFlags'] = '-O2' # Separated by ';'
cfg['IgnoredFiles'] = '' # Separated by ';'
cfg['Libraries'] = 'cpp_curl' # Separated by ';'
# Specific Programming languages flags
cfg['CppStandard'] = 'c++17'
cfg['CppIncludePath'] = os.getcwd()

cfg_filepath = os.getcwd() + '/build.cfg'

if os.path.isfile(cfg_filepath):
	for k, v in ConfigObj(cfg_filepath).items():
		cfg[k] = v
else:
	print("Cannot find config file.", file=sys.stderr)
	sys.exit(1)

build_command = [
	process_compiler_binary(cfg['Compiler']) +
	process_build_type(cfg['BuildTarget'], cfg['DebugFlags'], cfg['ReleaseFlags']) +
	get_source_filelist(cfg['SourcePath'], cfg['FileExt'], process_ignored_files(cfg['IgnoredFiles'])) +
	process_libraries(cfg['Libraries']) +
	process_cpp_flags(cfg['CppStandard'], cfg['CppIncludePath'])
]

print(*build_command)
