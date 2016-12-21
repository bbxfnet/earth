#!/bin/sh
cycle="18"
currentdate="20161220"
currentdatestamp=$(date +%s -d "${currentdate}")
dir=${currentdate}${cycle}
echo "$dir"
if [ ! -d "${dir}" ]; then
    mkdir "${dir}"
fi

for(( i=0;i<60;i+=3 )); do
    index=${i};
    if [ "${index}" -lt 10 ]; then
        index=0${i};
    fi
    filename=gfs.t${cycle}z.pgrb2.1p00.f0$index;
    url="http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_1p00.pl?file=${filename}&lev_1000_mb=on&var_TMP=on&var_UGRD=on&var_VGRD=on&leftlon=0&rightlon=360&toplat=90&bottomlat=-90&dir=%2Fgfs.${dir}";
    path=${dir}/${filename}
    echo $url;
    curl "$url" -o "$path"
    
    hours=$((${cycle}+0+${i}))
    hour=$((${hours}%24));
    if [ "${hour}" -lt 10 ]; then
        hour=0${hour};
    fi
    echo $hour
    day=$((${hours}/24));
    timeadd=$((${day}*24*3600))
    echo $timeadd
    newdate=$(($currentdatestamp+$timeadd))
    echo $newdate
    newdir=$(date +%Y/%m/%d -d "1970-01-01 UTC $newdate seconds")
    echo $newdir
    if [ ! -d "${newdir}" ]; then
       mkdir -p "${newdir}"
    fi
    
    ./grib2json/bin/grib2json --fd 0 --fc 2 -n -d -o  ${newdir}/${hour}00-wind-isobaric-1000hPa-gfs-1.0.json  "$path"
    ./grib2json/bin/grib2json --fd 0 --fc 0 -n -d -o  ${newdir}/${hour}00-temp-isobaric-1000hPa-gfs-1.0.json  "$path"
    
    if [ "${i}" -eq 0 ]; then
        if [ ! -d "current" ]; then
            mkdir "current"
        fi
        cp ${newdir}/${hour}00-wind-isobaric-1000hPa-gfs-1.0.json "current/current-wind-isobaric-1000hPa-gfs-1.0.json"
        cp ${newdir}/${hour}00-temp-isobaric-1000hPa-gfs-1.0.json "current/current-temp-isobaric-1000hPa-gfs-1.0.json"
    fi
done


