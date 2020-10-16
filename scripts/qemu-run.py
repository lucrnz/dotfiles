#!/usr/bin/env python3
"""
Copyright (c) 2020, Lucie Cupcakes <https://github.com/lucie-cupcakes> <cirno9moe@gmail.com>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""
# Needs configobj
# ArchLinux: sudo pacman -S python-pip --needed && sudo pip install configobj
# Debian/Ubuntu: sudo apt install python3-pip -y && sudo pip3 install configobj
# ===============================================
# Shared folders needs samba and gawk:
# Debian/Ubuntu: sudo apt install samba gawk

# Start Imports
import os, sys, errno, socket, subprocess
from configobj import ConfigObj
# End Imports

# Start Functions
def get_disk_format(file_path):
	out = subprocess.check_output(['qemu-img','info', file_path], universal_newlines=True).split()
	prev_was_fmt = False
	result = ''
	for s in out:
		if prev_was_fmt:
			result = s
			break
		else:
			if s == 'format:':
				prev_was_fmt = True
	return result

def spawn_daemon(func):
	# do the UNIX double-fork magic, see Stevens' 'Advanced
	# Programming in the UNIX Environment' for details (ISBN 0201563177)
	try:
		pid = os.fork()
		if pid > 0:
			return
	except OSError as e:
		print('fork #1 failed: %d (%s)' % (e.errno, e.strerror), file=sys.stderr)
		sys.exit(1)
	os.setsid()
	try:
		pid = os.fork()
		if pid > 0:
			sys.exit(0)
	except OSError as e:
		print('fork #2 failed: %d (%s)' % (e.errno, e.strerror), file=sys.stderr)
		sys.exit(1)
	func()
	os._exit(os.EX_OK)
	
def get_qemu_version():
    result = []
    str_ver = subprocess.check_output(['qemu-system-i386', '--version']).decode(sys.stdout.encoding).strip()
    str_ver = str_ver.splitlines()[0].lower() # grab first line
    #check for shit added by distros : for example: '(Debian)'
    if str_ver.find('(') > -1:
        str_ver = str_ver.split('(')[0].strip()
    str_ver = str_ver.split('version')[1].strip().split('.')
    for i in str_ver: #convert array<str> to array<int>
        result.append(int(i))
    return result

def get_usable_port():
	port = 0
	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	sock.bind(('127.0.0.1', 0))
	port = sock.getsockname()[1]
	sock.close()
	return port

# End Functions

# Use environment variable to find where the VM is
vm_name = ''
vm_dir = ''
if len(sys.argv) == 1: # No args.
	print('Warning: No arguments, assuming the VM is in CWD.', file=sys.stderr)
	vm_dir = os.getcwd()
else:   # Normal lookup using ENV var
	try:
		vm_dir_env = os.environ["QEMURUN_VM_PATH"].split(":")
	except:
		print("Cannot find environment variable QEMURUN_VM_PATH.\nPython error \#%d (%s)" % (e.errno, e.strerror), file=sys.stderr)
	vm_name = sys.argv[1]
	for p in vm_dir_env:
		vm_dir = '{}/{}'.format(p, vm_name)
		if os.path.exists(vm_dir):
			break
	if not os.path.exists(vm_dir):
		print('Cannot find VM: {}, Check your VM_PATH env. variable ?.'.format(vm_dir), file=sys.stderr)
		sys.exit(1)

# Start Default config
cfg = {}
cfg["System"] = 'x64'
cfg['UseUefi'] = 'No'
cfg['CpuType'] = 'host'
cfg['CpuCores'] = subprocess.check_output(['nproc']).decode(sys.stdout.encoding).strip()
cfg['MemorySize'] = '2G'
cfg['Acceleration'] = 'Yes'
cfg['DisplayDriver'] = 'virtio'
cfg['SoundDriver'] = 'hda'
cfg['Boot'] = 'c'
cfg['FwdPorts'] = ''
cfg['HardDiskVirtio'] = 'Yes'
cfg['SharedFolder'] = 'shared'
cfg['NetworkDriver'] = 'virtio-net-pci'
cfg['RngDevice'] = 'Yes'
cfg['HostVideoAcceleration'] = 'No'
cfg['LocalTime'] = 'No'
cfg['Headless'] = 'No'
cfg['MonitorPort'] = 5510
cfg['CDRomISO'] = '{}/cdrom'.format(vm_dir) if os.path.isfile('{}/cdrom'.format(vm_dir)) else 'No'
cfg['HardDisk'] = '{}/disk'.format(vm_dir) if os.path.isfile('{}/disk'.format(vm_dir)) else 'No'

if os.path.exists('{}/{}'.format(vm_dir, cfg['SharedFolder'])):
	cfg['SharedFolder'] = '{}/{}'.format(vm_dir, cfg['SharedFolder'])

# Load Config File
vm_cfg_file_path = '{}/config'.format(vm_dir)
if os.path.isfile(vm_cfg_file_path):
	vm_cfg_file = ConfigObj(vm_cfg_file_path)
	for k, v in vm_cfg_file.items():
		cfg[k] = v
else:
	print('Cannot find config file.', file=sys.stderr)
	sys.exit(1)

# Start QEMU CMD Line
qemu_cmd = []
qemu_ver = get_qemu_version()
current_user_id = str(subprocess.check_output(['id','-u'], universal_newlines=True).rstrip())

if cfg['System'] == 'x32':
	qemu_cmd.append('qemu-system-i386')
elif cfg['System'] == 'x64':
	qemu_cmd.append('qemu-system-x86_64')

if cfg['Acceleration'].lower() == 'yes':
	qemu_cmd.append('--enable-kvm')

if vm_name != '':
	qemu_cmd += ['-name', vm_name]

if cfg['UseUefi'].lower() == 'yes':
    qemu_cmd += ['-L', '/usr/share/qemu', '-bios', 'OVMF.fd']

if not (cfg['CpuType'].lower() == 'host' and cfg['Acceleration'].lower() != 'yes'):
	# Avoiding a non possible config..
	qemu_cmd += ['-cpu', cfg['CpuType']]

pulseaudio_socket = '/run/pulse/native'
# pulseaudio_socket = '/run/user/' + current_user_id + '/pulse/native'

qemu_cmd += ['-smp', cfg['CpuCores'],
			'-m', cfg['MemorySize'],
			'-boot', 'order=' + cfg['Boot'],
			'-usb', '-device', 'usb-tablet',
			'-soundhw', cfg['SoundDriver']]

usable_telnet_port = 0

if cfg['Headless'].lower() == 'yes':
	usable_telnet_port = get_usable_port()
	qemu_cmd += ['-monitor', 'telnet:127.0.0.1:{},server,nowait'.format(usable_telnet_port)]
	qemu_cmd += ['-display', 'none']
else:
	qemu_cmd += ['-vga', cfg['DisplayDriver']]
	if cfg['HostVideoAcceleration'].lower() == 'yes':
		qemu_cmd += ['-display', 'gtk,gl=on']
	else:
		qemu_cmd += ['-display', 'gtk,gl=off']

if qemu_ver[0] >= 4:
    qemu_cmd += ['-audiodev', 'pa,id=pa1,server=' + pulseaudio_socket]

if cfg['RngDevice'].lower() == 'yes':
	qemu_cmd += ['-object', 'rng-random,id=rng0,filename=/dev/random', '-device', 'virtio-rng-pci,rng=rng0']

sf_str = ''
if os.path.exists(cfg['SharedFolder']):
	sf_str = ',smb=' + cfg['SharedFolder']

fwd_ports_str = ''
if cfg['FwdPorts'] != '':
	ports_split = cfg['FwdPorts'].split(',')
	for pair_str in ports_split:
		if pair_str.find(':') != -1: # If have FordwardPorts = <HostPort>:<GuestPort>
			pair = pair_str.split(':')
			fwd_ports_str += ',hostfwd=tcp::{}-:{},hostfwd=udp::{}-:{}'.format(pair[0], pair[1], pair[0], pair[1]);
		else:   # Else use the same port for Host and Guest.
			fwd_ports_str += ',hostfwd=tcp::{}-:{},hostfwd=udp::{}-:{}'.format(pair_str, pair_str, pair_str, pair_str);

qemu_cmd += ['-nic', 'user,model={}{}{}'.format(cfg['NetworkDriver'], sf_str, fwd_ports_str)]

drive_index = 0

if os.path.isfile(cfg['HardDisk']):
	hdd_fmt = get_disk_format(cfg['HardDisk'])
	hdd_virtio = ''
	if cfg['HardDiskVirtio'].lower() == 'yes':
		hdd_virtio = ',if=virtio'
	qemu_cmd += ['-drive', 'file={},format={}{},index={}'.format(cfg['HardDisk'], hdd_fmt, hdd_virtio, str(drive_index))]
	drive_index += 1

if os.path.isfile(cfg['CDRomISO']):
	qemu_cmd += ['-drive', 'file={},media=cdrom,index={}'.format(cfg['CDRomISO'], str(drive_index))]
	drive_index += 1

if cfg['LocalTime'] == 'Yes':
	qemu_cmd += ['-rtc', 'base=localtime']

# END QEMU CMD Line

qemu_env = os.environ.copy()
qemu_env['SDL_VIDEO_X11_DGAMOUSE'] = '0'
qemu_env['QEMU_AUDIO_DRV'] = 'pa'
#qemu_env['QEMU_PA_SERVER'] = pulseaudio_socket

def subprocess_qemu():
	sp = subprocess.Popen(qemu_cmd, env=qemu_env, cwd=vm_dir)
	print('QEMU Running at PID: {}'.format(str(sp.pid)))
	if usable_telnet_port != 0:
		print('Telnet monitor port: {}'.format(str(usable_telnet_port)))
	return sp

def subprocess_fix_smb():
	if os.path.exists(cfg['SharedFolder']):
		env_cpy = os.environ.copy()
		fix_smb_sp = subprocess.Popen(['bash', '/home/lucie/.conf_files/scripts/qemu_fix_smb.sh'], env=env_cpy)

print_cmd = False

if len(sys.argv) == 3:
	if sys.argv[2] == '--print-cmd':
		print_cmd = True

if print_cmd:
	#print(' '.join(qemu_cmd))
	print(*qemu_cmd)
else:
	spawn_daemon(subprocess_fix_smb)
	subprocess_qemu().wait()
