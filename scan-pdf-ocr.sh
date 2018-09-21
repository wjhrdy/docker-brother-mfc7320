#!/bin/bash

# This script will :
# scan an image and convert it to pdf-A format with jpeg in front and OCR test in the background

# Path to temporary files (will be deleted later)
name=`date +%F-%Hh%Mm%S`
tmpFolder=/tmp/scan2pdf-ocr
tmpFile=$tmpFolder/scan2pdf-tmp
destFolder="/volume/scans/"
resolution=$1
scanOptions="--resolution $resolution --format=pnm"
ocrLanguage="fra"
LOCKFILE=$tmpFolder/lock.txt

## Script Init
if [ ! -d $tmpFolder ]; then ## Create tmpFolder including subfolders if necessary
        mkdir -p $tmpFolder
fi

## Make sure only one instance of this script is running at any point in time
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "Script already running ($(basename $0))... Exiting."
    exit
fi
# Make sure the lockfile is removed when we exit and then claim it
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}


## Scanning
scanimage $scanOptions > ${tmpFile}.pnm

## Convert to jpg
convert ${tmpFile}.pnm ${tmpFile}.jpg

## Send the jpg version to it's destination
mv ${tmpFile}.jpg ${tmpFolder}/${name}.jpg
chmod ugo+rw ${tmpFolder}/${name}.jpg
chown 1026:users ${tmpFolder}/${name}.jpg
cp ${tmpFolder}/${name}.jpg $destFolder

## Release the Lock : we are ready for the next scan to run in parallel of the OCR
rm -f ${LOCKFILE}

## run OCR and save as pdf
tesseract -l $ocrLanguage ${tmpFolder}/${name}.jpg ${tmpFolder}/${name} pdf

## Send the pdf with ocr to it's destination
chmod ugo+rw ${tmpFolder}/${name}.pdf
chown 1026:users ${tmpFolder}/${name}.pdf
cp ${tmpFolder}/${name}.pdf $destFolder

## Cleanup
rm ${tmpFolder}/${name}.jpg
rm ${tmpFolder}/${name}.pdf
rm ${tmpFile}.pnm


