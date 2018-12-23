#!/bin/bash
DIR_ROOT=$(pwd)
THEME_ROOT=${DIR_ROOT}/src/themes

THEME=$1

[[ ! -d ${DIR_ROOT}/http ]] && mkdir ${DIR_ROOT}/http

if ! which npm; then
    sudo yum install npm -y
fi

folder="$THEME_ROOT/$THEME"
echo ${folder}
THEME_NAME=$( echo $folder | rev | cut -d'/' -f1 | rev )
cd ${folder}
rm -rf ./dist/${THEME}
npm install
npm start
rm -rf ${DIR_ROOT}/http/${THEME_NAME}
cp -r dist ${DIR_ROOT}/http/${THEME_NAME}
cd ${THEME_ROOT}
