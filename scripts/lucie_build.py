#!/usr/bin/env python3
# Needs configobj
# ArchLinux: sudo pacman -S python-pip --needed && sudo pip install configobj
# Debian: sudo apt install python3-pip -y && sudo pip3 install configobj

import os, sys, errno, socket, subprocess
from configobj import ConfigObj

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
		file_fullpath = sourcepath + '/' + f
		if ignored_files == '' or ignored_files == []:
			result_list.append(file_fullpath)
		elif list_contains(f, ignored_files) == False:
			result_list.append(file_fullpath)
	return result_list

def process_ignored_files(ignored_files):
	result = []
	if ignored_files != '' and ignored_files.find(';') > -1:
		result = ignored_files.split(';')
	return result

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

def process_cpp_flags(cpp_std, cpp_include_path, cpp_output_binary):
	result = []
	if cpp_std != '':
		result += ['-std=' + cpp_std]

	if cpp_include_path != '':
		result += ['-I', cpp_include_path]

	if cpp_output_binary != '':
		result += ['-o', cpp_output_binary]
	return result

def process_build_type(cfg_buildtarget, cfg_debug_flags, cfg_release_flags):
	# @TODO : Find a better way to have a Debug and Target Config? Maybe another file?
	result = []
	if cfg_buildtarget == 'Release':
		result += cfg_release_flags.split(';')
	elif cfg_buildtarget == 'Debug':
		result += cfg_debug_flags.split(';')
	return result

def process_load_config_file(cfg_filepath):
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
	cfg['CppOutputBinary'] = 'Output.bin'

	if os.path.isfile(cfg_filepath):
		for k, v in ConfigObj(cfg_filepath).items():
			cfg[k] = v
	else:
		print("Cannot find config file.", file=sys.stderr)
		sys.exit(1) # @TODO : Find a way to return the error to the main function insted!

	return cfg

def process_generate_build_command(cfg):
	cmd = []
	cmd += [cfg['Compiler']]
	cmd += process_build_type(cfg['BuildTarget'], cfg['DebugFlags'], cfg['ReleaseFlags'])
	cmd += get_source_filelist(cfg['SourcePath'], cfg['FileExt'], process_ignored_files(cfg['IgnoredFiles']))
	cmd += process_libraries(cfg['Libraries'])
	cmd += process_cpp_flags(cfg['CppStandard'], cfg['CppIncludePath'], cfg['CppOutputBinary'])
	return cmd

# Main function:
project_dir = os.getcwd()
cfg = process_load_config_file(project_dir + '/build.cfg')
build_command = process_generate_build_command(cfg)
compiler_env = os.environ.copy()
subprocess.Popen(build_command, env=compiler_env, cwd=project_dir).wait()

#print(*build_command)
