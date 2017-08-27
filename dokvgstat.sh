#!/bin/sh

# using linux pvs, lvs, vgs command

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
to=`vgs | grep docker-vg | awk '{print $6}' | sed 's/g/ g/;s/m/ m/;s/t/ t/'`
fr=`vgs | grep docker-vg | awk '{print $7}' | sed 's/g/ g/;s/m/ m/;s/t/ t/'`
echo $to | awk '{if($2 == "t") {a = ($1*1000*1000*1000); print "DOC_VG_Total " a;}}'
echo $to | awk '{if($2 == "g") {a = ($1*1000*1000); print "DOC_VG_Total " a;}}'
echo $to | awk '{if($2 == "m") {a = ($1*1000); print "DOC_VG_Total " a;}}'
echo $fr | awk '{if($2 == "t") {b = ($1*1000*1000*1000); print "DOC_VG_Free " b;}}'
echo $fr | awk '{if($2 == "g") {b = ($1*1000*1000); print "DOC_VG_Free " b;}}'
echo $fr | awk '{if($2 == "m") {b = ($1*1000); print "DOC_VG_Free " b;}}'

# Using dockerinfo command

(docker info | grep "Space" | sed 's/ //;s/ /_/;s/ /_/; s/://') 2>/dev/null > /tmp/docinfop
while IFS= read -r line; do
  echo $line | awk '{if($3 == "TB") {c = ($2*1000*1000*1000); print $1 " " c;}}'
  echo $line | awk '{if($3 == "GB") {c = ($2*1000*1000); print $1 " " c;}}'
  echo $line | awk '{if($3 == "MB") {c = ($2*1000); print $1 " " c;}}'
  echo $line | awk '{if($3 == "kB") {c = ($2 - 0); print $1 " " c;}}'
done < /tmp/docinfop
