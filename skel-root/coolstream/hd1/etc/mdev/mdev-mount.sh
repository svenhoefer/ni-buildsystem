#!/bin/sh
LOG="logger -p user.info -t mdev-mount"
WARN="logger -p user.warn -t mdev-mount"

MOUNTBASE=/media
MOUNTPOINT="$MOUNTBASE/$MDEV"
ROOTDEV=$(readlink /dev/root)

# do not add or remove root device again...
[ "$ROOTDEV" = "$MDEV" ] && exit 0
if [ -e /tmp/.nomdevmount ]; then
	$LOG "no action on $MDEV -- /tmp/.nomdevmount exists"
	exit 0
fi

create_symlinks() {
	DEVBASE=${MDEV:0:3} # first 3 characters
	PARTNUM=${MDEV:3}   # characters 4-
	if [ -e /sys/block/$DEVBASE/device/model ]; then # don't read if blockdevice not present
		read MODEL < /sys/block/$DEVBASE/device/model
	fi
	MODEL=${MODEL// /_} # replace ' ' with '_'
	OLDPWD=$PWD
	cd $MOUNTBASE
	if which blkid > /dev/null; then
		BLKID=$(blkid /dev/$MDEV)
		eval ${BLKID#*:}
	fi
	if [ -n "$LABEL" ]; then
		LABEL=${LABEL// /_} # replace ' ' with '_'
		rm -f "$LABEL"
		ln -s $MDEV "$LABEL"
	fi
	if [ -n "$UUID" ]; then
		LINK="${TYPE}${TYPE:+-}${UUID}"
		rm -f "${LINK}"
		ln -s $MDEV "${LINK}"
	fi
	if [ -n "$MODEL" ]; then
		LINK="${MODEL}${PARTNUM:+-}${PARTNUM}"
		rm -f "${LINK}"
		ln -s $MDEV "${LINK}"
	fi
	cd $OLDPWD
}

remove_symlinks() {
	OLDPWD=$PWD
	cd $MOUNTBASE
	for i in *; do
		[ -L "$i" ] || continue
		TARGET=$(readlink "$i")
		if [ "$TARGET" = "$MDEV" ]; then
			rm "$i"
		fi
	done
	cd $OLDPWD
}

case "$ACTION" in
	add|"")
		if [ ${#MDEV} = 3 ]; then # sda, sdb, sdc => whole drive
			PARTS=$(sed -n "/ ${MDEV}[0-9]$/{s/ *[0-9]* *[0-9]* * [0-9]* //;p}" /proc/partitions)
			if [ -n "$PARTS" ]; then
				$LOG "drive has partitions $PARTS, not trying to mount $MDEV"
				exit 0
			fi
		fi
		if grep -q "/dev/$MDEV" /proc/mounts; then
			$LOG "/dev/$MDEV already mounted - not mounting again"
			exit 0
		fi
		$LOG "[$ACTION] mounting /dev/$MDEV to $MOUNTPOINT"
		# remove old mountpoint symlinks we might have for this device
		rm -f $MOUNTPOINT
		mkdir -p $MOUNTPOINT
		for i in 1 2 3 4 5 6 7 8 9; do # retry 9 times for slow devices
			# $LOG "mounting /dev/$MDEV to $MOUNTPOINT try $i"
			OUT1=$(mount -t auto /dev/$MDEV $MOUNTPOINT 2>&1 >/dev/null)
			RET1=$?
			[ $RET1 = 0 ] && break
			sleep 1
		done
		if [ $RET1 = 0 ]; then
			create_symlinks
		else
			$WARN "mount   /dev/$MDEV $MOUNTPOINT failed with $RET1"
			$WARN "        $OUT1"
			rmdir $MOUNTPOINT
		fi
		;;
	remove)
		$LOG "[$ACTION] unmounting /dev/$MDEV"
		grep -q "^/dev/$MDEV " /proc/mounts || exit 0 # not mounted...
		umount -lf /dev/$MDEV
		RET=$?
		if [ $RET = 0 ]; then
			rmdir $MOUNTPOINT
			remove_symlinks
		else
			$WARN "umount /dev/$MDEV failed with $RET"
		fi
		;;
esac
