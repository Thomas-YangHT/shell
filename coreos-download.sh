wget https://stable.release.core-os.net/amd64-usr/current/coreos_production_iso_image.iso
BASEURL="https://stable.release.core-os.net/amd64-usr/current/"
FILES="version.txt\
coreos_production_image.bin.bz2 \
coreos_production_image.bin.bz2.DIGESTS \
coreos_production_image.bin.bz2.DIGESTS.asc \
coreos_production_image.bin.bz2.DIGESTS.sig \
coreos_production_image.bin.bz2.sig "
for FILE in $FILES
do
wget $BASEURL$FILE
done
source version.txt
mkdir $COREOS_VERSION
mv coreos_production* $COREOS_VERSION