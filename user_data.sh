#!/bin/bash
apt update -y
apt upgrade -y
apt install -y nginx
systemctl start nginx
systemctl enable nginx