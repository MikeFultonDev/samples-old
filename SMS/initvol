export UNITS="0a98 0a99 0a9a 0a9b"
export VOLS="USER01 USER02 TOOLS1 TOOLS2"
output="/tmp/initvol.${RANDOM}.out"

for u in ${UNITS}; do
	opercmd "v ${u},offline" >${output}
	if [ $? -gt 0 ]; then
		echo "Unable to bring unit ${u} offline"
		echo "See ${output} for details"
		exit 16
	fi
	#cat ${output}
	rm -f ${output}
done

export U="${UNITS}"
for v in ${VOLS}; do
	u=${U%% *}
	U=${U#* }
	mvscmdauth --pgm=ickdsf --args='NOREPLYU,FORCE' --sysprint=* >${output} --sysin=stdin <<zzz
 INIT UNIT(${u}) VOLID(${v}) NOVERIFY STORAGEGROUP -
 VTOC(2,1,10) INDEX(2,11,5)
zzz
   	if [ $? -gt 0 ]; then
		echo "Unable to format unit:${u}, volume:${v}"
		echo "See ${output} for details"
		exit 16
	fi
	#cat ${output}
	rm -f ${output}
done

for u in ${UNITS}; do
	opercmd "v ${u},online" >${output}
	if [ $? -gt 0 ]; then
		echo "Unable to bring unit ${u} online"
		echo "See ${output} for details"
		exit 16
	fi
	#cat ${output}
	rm -f ${output}
done
