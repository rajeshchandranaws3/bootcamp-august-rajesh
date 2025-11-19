
# install clamav in your device (mac, linux, windows, ec2 machine )
# or run it as docker container

mkdir -p /d/devops/Akhilesh/bootcamp-august-rajesh/class17-python-argparse-clamav/clamav-project/{db,logs}

/opt/homebrew/etc/clamav/freshclam.conf (mac)

C:\Program Files\ClamAV\freshclam.conf (windows)

# Custom paths

```
DatabaseDirectory /d/devops/Akhilesh/bootcamp-august-rajesh/class17-python-argparse-clamav/clamav-project/db
UpdateLogFile /d/devops/Akhilesh/bootcamp-august-rajesh/class17-python-argparse-clamav/clamav-project/logs/freshclam.log
PidFile /d/devops/Akhilesh/bootcamp-august-rajesh/class17-python-argparse-clamav/clamav-project/freshclam.pid

# Database mirror
DatabaseMirror database.clamav.net

# Checks per day
Checks 24

```

## Update the db (windows)
"C:\Program Files\ClamAV\freshclam.exe" --config-file="C:\Program Files\ClamAV\freshclam.conf"

## Run the scan (windows)
"C:\Program Files\ClamAV\clamscan.exe" "clean.txt"

## Update the db (mac)
freshclam

## Run the scan (mac)
clamscan clean.txt