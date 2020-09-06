#!/usr/bin/env python3
# Needs configobj
# ArchLinux: sudo pacman -S python-pip --needed && sudo pip install configobj
# Debian: sudo apt install python3-pip -y && sudo pip3 install configobj

# Start Imports
import os, sys, errno, socket, subprocess
from configobj import ConfigObj
# End Imports

# Start Functions
def get_disk_format(file_path):
	out = subprocess.check_output(['qemu-img','info', file_path], universal_newlines=True).split()
	prev_was_fmt = False
	result = ""
	for s in out:
		if prev_was_fmt:
			result = s
			break
		else:
			if s == "format:":
				prev_was_fmt = True
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
	
def get_qemu_version():
    result = []
    str_ver = subprocess.check_output(['qemu-system-i386', '--version']).decode(sys.stdout.encoding).strip()
    str_ver = str_ver.splitlines()[0].lower() # grab first line
    #check for shit added by distros : for example: "(Debian)"
    if str_ver.find('(') > -1:
        str_ver = str_ver.split('(')[0].strip()
    str_ver = str_ver.split('version')[1].strip().split('.')
    for i in str_ver: #convert array<str> to array<int>
        result.append(int(i))
    return result

# End Functions

# Use environment variable to find where the VM is
vm_name = ""
vm_dir = ""
if len(sys.argv) == 1: # No args.
	print("Warning: No arguments, assuming the VM is in CWD.", file=sys.stderr)
	vm_dir = os.getcwd()
else:   # Normal lookup using ENV var
	try:
		vm_dir_env = os.environ["QEMURUN_VM_PATH"].split(":")
	except:
		print("Cannot find environment variable QEMURUN_VM_PATH.\nPython error \#%d (%s)" % (e.errno, e.strerror), file=sys.stderr)
	vm_name = sys.argv[1]
	for p in vm_dir_env:
		vm_dir = p + "/" + vm_name
		if os.path.exists(vm_dir):
			break
	if not os.path.exists(vm_dir):
		print("Cannot find VM: %s, Check your VM_PATH env. variable ?." % (vm_dir), file=sys.stderr)
		sys.exit(1)

# Start Default config
cfg = {}
cfg["System"] = "x64"
cfg["UseUefi"] = "No"
cfg["CpuType"] = "host"
cfg["CpuCores"] = subprocess.check_output(["nproc"]).decode(sys.stdout.encoding).strip()
cfg["MemorySize"] = "2G"
cfg["Acceleration"] = "Yes"
cfg["DisplayDriver"] = "virtio"
cfg["SoundDriver"] = "hda"
cfg["Boot"] = "c"
cfg["FwdPorts"] = ""
cfg["HardDiskVirtio"] = "No"
cfg["SharedFolder"] = "shared"
cfg["NetworkDriver"] = "virtio-net-pci"
cfg["RngDevice"] = "Yes"
cfg["HostVideoAcceleration"] = "Yes"
cfg["LocalTime"] = "No"

if os.path.isfile(vm_dir + "/cdrom"):
	cfg["CDRomISO"] = "cdrom"
else:
	cfg["CDRomISO"] = "No"

if os.path.isfile(vm_dir + "/disk"):
	cfg["HardDisk"] = vm_dir + "/disk"

if os.path.exists(vm_dir + "/" + cfg["SharedFolder"]):
	cfg["SharedFolder"] = vm_dir + "/" + cfg["SharedFolder"]

# Load Config File
vm_cfg_file_path = vm_dir + "/config"
if os.path.isfile(vm_cfg_file_path):
	vm_cfg_file = ConfigObj(vm_cfg_file_path)
	for k, v in vm_cfg_file.items():
		cfg[k] = v
else:
	print("Cannot find config file.", file=sys.stderr)
	sys.exit(1)

# Start QEMU CMD Line
qemu_cmd = []
qemu_ver = get_qemu_version()
current_user_id = str(subprocess.check_output(["id","-u"], universal_newlines=True).rstrip())

if cfg["System"] == "x32":
	qemu_cmd.append("qemu-system-i386")
elif cfg["System"] == "x64":
	qemu_cmd.append("qemu-system-x86_64")
if cfg["Acceleration"].lower() == "yes":
	qemu_cmd.append("--enable-kvm")

if vm_name != "":
	qemu_cmd += ["-name", vm_name]

if cfg["UseUefi"].lower() == "yes":
    qemu_cmd += ["-L", "/usr/share/qemu", "-bios", "OVMF.fd"]

if not (cfg["CpuType"].lower() == "host" and cfg["Acceleration"].lower() != "yes"):
	# Avoiding a non possible config..
	qemu_cmd += ["-cpu", cfg["CpuType"]]

pulseaudio_socket = "/run/pulse/native"
# pulseaudio_socket = "/run/user/" + current_user_id + "/pulse/native"

qemu_cmd += ["-smp", cfg["CpuCores"],
			"-m", cfg["MemorySize"],
			"-boot", "order=" + cfg["Boot"],
			"-usb", "-device", "usb-tablet",
			"-vga", cfg["DisplayDriver"],
			"-soundhw", cfg["SoundDriver"]]

if qemu_ver[0] >= 4:
    qemu_cmd += ["-audiodev", "pa,id=pa1,server=" + pulseaudio_socket]

#qemu_cmd += ["-monitor", "telnet:127.0.0.1:" + cfg["MonitorPort"] + ",server,nowait"]

if cfg["HostVideoAcceleration"].lower() == "yes":
	qemu_cmd += ["-display", "gtk,gl=off"]
else:
	qemu_cmd += ["-display", "gtk,gl=off"]

if cfg["RngDevice"].lower() == "yes":
	qemu_cmd += ["-object", "rng-random,id=rng0,filename=/dev/random", "-device", "virtio-rng-pci,rng=rng0"]

sf_str = ""
if os.path.exists(cfg["SharedFolder"]):
	sf_str = ",smb=" + cfg["SharedFolder"]

fwd_ports_str = ""
if cfg["FwdPorts"] != "":
	ports_split = cfg["FwdPorts"].split(",")
	for pair_str in ports_split:
		if pair_str.find(":") != -1: # If have FordwardPorts = <HostPort>:<GuestPort>
			pair = pair_str.split(":")
			fwd_ports_str += ",hostfwd=tcp::" + pair[0] + "-:" + pair[1] + ",hostfwd=udp::" + pair[0] + "-:" + pair[1];
		else:   # Else use the same port for Host and Guest.
			fwd_ports_str += ",hostfwd=tcp::" + pair_str + "-:" + pair_str + ",hostfwd=udp::" + pair_str + "-:" + pair_str;

qemu_cmd += ["-nic", "user,model=" + cfg["NetworkDriver"] + sf_str + fwd_ports_str]

drive_index = 0

if os.path.isfile(cfg["HardDisk"]):
	hdd_fmt = get_disk_format(cfg["HardDisk"])
	hdd_virtio = ""
	if cfg["HardDiskVirtio"].lower() == "yes":
		hdd_virtio = ",if=virtio"
	qemu_cmd += ["-drive", "file=" + cfg["HardDisk"] + ",format=" + hdd_fmt + hdd_virtio + ",index=" + str(drive_index)]
	drive_index += 1

if os.path.isfile(cfg["CDRomISO"]):
	qemu_cmd += ["-drive", "file=" + cfg["CDRomISO"] + ",media=cdrom,index=" + str(drive_index)]
	drive_index += 1

if cfg["LocalTime"] == "Yes":
	qemu_cmd += ["-rtc", "base=localtime"]

# END QEMU CMD Line

qemu_env = os.environ.copy()
qemu_env["SDL_VIDEO_X11_DGAMOUSE"] = "0"
qemu_env["QEMU_AUDIO_DRV"] = "pa"
qemu_env["QEMU_PA_SERVER"] = pulseaudio_socket

def subprocess_qemu():
	qemu_sp = subprocess.Popen(qemu_cmd, env=qemu_env, cwd=vm_dir)
	#print("QEMU Running at PID: "+ str(qemu_sp.pid))
	#print("Telnet monitor port: " + cfg["MonitorPort"])
	
	if os.path.exists(cfg["SharedFolder"]):
		env_cpy = os.environ.copy()
		fix_smb_sp = subprocess.Popen(["bash", "/home/lucie/.conf_files/scripts/qemu_fix_smb.sh"], env=env_cpy)
		qemu_sp.wait()

print_cmd = False

if len(sys.argv) == 3:
	if sys.argv[2] == "--print-cmd":
		print_cmd = True

if print_cmd:
	#print(' '.join(qemu_cmd))
	print(*qemu_cmd)
else:
	spawn_daemon(subprocess_qemu)
