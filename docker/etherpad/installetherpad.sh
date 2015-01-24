#!/bin/bash

mkdir /usr/local/etherpad
cd /usr/local/etherpad
git clone git://github.com/ether/etherpad-lite.git
cd etherpad-lite 
npm install ep_codepad
npm instal ep_padlist
npm install ep_expiration
