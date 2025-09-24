# UsefulBashScripts

A small collection of bash utilities written for classes:

- backup.sh    Create tar backups of directories (uses /etc/backup.conf).
- restore.sh   Restore a backup tarball to its original location.
- dosutil.sh   DOS/Windows-style file management helper (interactive or CLI).
- scanScript.sh Multi-stage nmap scan with output files and screenshots.

## Requirements
- bash, tar, gunzip, bzip2
- nmap
- firefox (headless mode for screenshots)
- sudo (for backup/restore operations)

## Quick Setup
Clone the repo and make the scripts executable:
git clone <repo-url>
cd <repo-dir>
chmod +x *.sh


## Usage
Run scripts directly:
./backup.sh <backup_name>
./restore.sh <backup_file>
./dosutil.sh [command]
./scanScript.sh


## Notes
- backup.sh expects a config file at /etc/backup.conf, and is incomplete
- restore.sh overwrites files and should be run with sudo
- scanScript.sh performs active network scans; use only with permission
- dosutil.sh includes commands like copy, move, del, perms, etc.
