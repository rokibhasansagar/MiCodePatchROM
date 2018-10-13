#!/bin/bash

DIR=$(pwd)

echo -e "ReEnable PATH and Set Repo & GHR"
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://github.com/akhilnarang/repo/raw/master/repo
sudo chmod a+x /usr/local/bin/repo
PATH=~/bin:/usr/local/bin:$PATH && echo $PATH

echo -e "Github Authorization"
git config --global user.email rokibhasansagar2014@outlook.com
git config --global user.name rokibhasansagar
git config --global color.ui true

# Main Function Starts Here

cd $DIR; mkdir MiCodePatchROM; cd MiCodePatchROM

echo -e "Initialize the repo data fetching"
repo init -q -u https://github.com/MiCode/patchrom.git -b marshmallow --depth 1

# Sync it up!
time repo sync -c -f -q --force-sync --no-clone-bundle --no-tags -j32

echo -e "SHALLOW Source Syncing done"

rm -rf .repo/

cd $DIR
mkdir upload/

echo -en "The total size of the checked-out files is ---  "
du -sh MiCodePatchROM
DDF=$(du -sh -BM MiCodePatchROM | awk '{print $1}' | sed 's/M//')
echo -en "Value of DDF is  --- " && echo $DDF

cd MiCodePatchROM

echo -e "Compressing files --- "
echo -e "Please be patient, this will take time"

export XZ_OPT=-9e

if [ $DDF -gt 8192 ]; then
  echo -e "Compressing and Making 1.75GB parts Because of Huge Data Amount \nBe Patient..."
  time tar -I pxz -cf - * | split -b 1792M - $DIR/upload/MiCodePatchROM-norepo-$(date +%Y%m%d).tar.xz.
  # Show Total Sizes of the compressed .repo
  echo -en "Final Compressed size of the consolidated checked-out files is ---  "
  du -sh $DIR/upload/
else
  time tar -I pxz -cf $DIR/upload/MiCodePatchROM-norepo-$(date +%Y%m%d).tar.xz *
  echo -en "Final Compressed size of the consolidated checked-out archive is ---  "
  du -sh $DIR/upload/MiCodePatchROM-norepo*.tar.xz
fi

echo -e "Compression Done"

cd $DIR/upload/

md5sum MiCodePatchROM-norepo* > MiCodePatchROM-norepo-$(date +%Y%m%d).md5sum
cat MiCodePatchROM-norepo-$(date +%Y%m%d).md5sum

echo -en "Final Compressed size of the checked-out files is ---  "
du -sh $DIR/upload/

echo -e " Source Compression Done "

echo -e " Begin to upload "
for file in MiCodePatchROM-norepo*; do wput $file ftp://fr3akyphantom:"$FTPPass"@uploads.androidfilehost.com//MiCodePatchROM-NoRepo/ ; done
echo -e " Done uploading to AFH"
for file in MiCodePatchROM-norepo*; do curl --upload-file $file https://transfer.sh/ ; done
echo -e " Done uploading to transfer.sh"


cd $DIR/MiCodePatchROM
echo -e "\nCongratulations! Job Done!"
echo -e " Everything done! "
