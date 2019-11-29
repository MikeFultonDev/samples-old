#!/bin/sh
crtzfs() {
#set -x
	ds=$1
	zfs=$2
	size=$3
	mkdir -p -m 755 $zfs
	rc=$?
	if [ $rc -gt 0 ]; then
		echo "Unable to create new ZFS directory: $zfs" >&2
		return $rc
	fi

	mvscmdauth --pgm=IDCAMS --sysprint='*' --sysin=stdin <<zzz
   DEFINE CLUSTER(NAME(${ds}) -
   LINEAR CYLINDERS(${size}) SHAREOPTIONS(3))
zzz
   	rc=$?
	if [ $rc -gt 0 ]; then
		echo "Unable to create new ZFS file system: $ds" >&2
		return $rc
	fi
	mvscmdauth --pgm=IOEAGFMT --args="-aggregate ${ds} -compat" --sysprint='*'
	rc=$?
	if [ $rc -gt 0 ]; then
		echo "Unable to initialize new ZFS file system: $ds" >&2
		return $rc
	fi
	/usr/sbin/mount -t zfs -f ${ds} ${zfs}
	if [ $rc -gt 0 ]; then
		echo "Unable to mount new ZFS file system: $ds at: $zfs" >&2
		return $rc
	fi
	return 0
}

if [ $# -ne 3 ]; then
	echo "Syntax: crtzfs <dataset> <zfs directory> <size in primary/secondary cylinders>" >&2
	exit 4
fi

crtzfs "$1" "$2" "$3"
exit $?
