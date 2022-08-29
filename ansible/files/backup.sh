#!/bin/bash
# Managed by Ansible
# Originally by FastLizard4, adapted by stwalkerster

if [ `id -u` != 0 ]; then
  >&2 echo 'Error: This script must be run as root.'
  exit 1
fi

mkdir -p /media/backup/daily
cd /media/backup/daily

FILENAME="`date -u +%Y%m%dT%H%M%SZ`.sql"

mysqldump --defaults-extra-file=/media/backup/backup.cnf --all-databases --complete-insert --disable-keys --hex-blob --quote-names --opt --single-transaction --tz-utc --flush-logs --flush-privileges --master-data=1 > "${FILENAME}"

if [ $? == 0 ]; then
  gzip -9f "${FILENAME}"
else
  rm "${FILENAME}"
fi

# Clean up old files
ls -tp *.sql.gz | grep -v '/$' | tail -n +6 | xargs -rd '\n' rm --
