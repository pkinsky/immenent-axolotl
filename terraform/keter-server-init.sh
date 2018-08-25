#!/bin/sh

set -e



cd /home/admin

# todo: figure out how not to need all this stuff just to grab a thing from s3
sudo apt-get -y update
sudo apt-get -y install ruby
sudo apt-get -y install wget
wget https://aws-codedeploy-us-west-2.s3.amazonaws.com/latest/install
chmod +x install
sudo ./install auto
rm install

# grab keter deb file off of my s3 bucket and install
# TODO: there's gotta be a better way of doing this
aws s3 cp s3://imminent-axolotl/keter.deb .
sudo dpkg -i keter.deb
rm keter.deb
sudo systemctl enable keter
sudo systemctl start keter
