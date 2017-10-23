#!/usr/bin/env bash

set -ex

cd /vagrant

SYNCED_FOLDER=$(grep "synced_folder:" ./site.yml | sed -e s/synced_folder://g | tr -d '\"\ ' | sed -n 1p)

VCCW_HOST_NAME=$(grep "hostname:" ./site.yml | sed -e s/hostname://g | tr -d '\"\ ' | sed -n 1p)

VCCW_SITE_URL=$(grep "wp_siteurl:" ./site.yml | sed -e "s/wp_siteurl://" | sed -e "s/\# Path to the WP_SITEURL like \"wp\"//g" | tr -d "\'\ ")

[ -z "${VCCW_SITE_URL}" ] && VCCW_SITE_URL='' || VCCW_SITE_URL="/${VCCW_SITE_URL}"

THEME_SLUG=$(grep "hostname:" ./site.yml | sed -e s/hostname://g | tr -d '\"\ ' | sed -n 1p | awk -F '.' '{print $1}')

if [ ! -e "${SYNCED_FOLDER}"/"${VCCW_HOST_NAME}""${VCCW_SITE_URL}"/wp-conteht/themes/"${THEME_SLUG}" ]; then

  if [ ! -e dist ]; then
    mkdir dist
  fi

  cd ./wordpress  && wp scaffold _s ${THEME_SLUG} --activate --theme_name=${THEME_SLUG} --sassify

  cd wp-content/themes/${THEME_SLUG}

  git clone https://github.com/marushu/package.git

  cp package/package.json .

  grep '\"serve"\' package.json | sed -i -e s/vccw.test/${VCCW_HOST_NAME}/g package.json

  rm -rf ./package/

  curl https://raw.githubusercontent.com/marushu/build-theme/master/mixin.txt | awk '{print $0}' >> ./sass/style.scss

else

  echo 'Your project semms to have same name theme. :P'

fi
