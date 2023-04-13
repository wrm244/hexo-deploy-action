#!/bin/sh

set -e

echo "setup ssh-private-key"
# setup ssh-private-key
mkdir -p /root/.ssh/
echo "$INPUT_DEPLOY_KEY" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

timedatectl set-timezone Asia/Shanghai

# setup deploy git account
git config --global user.name "$INPUT_USER_NAME"
git config --global user.email "$INPUT_USER_EMAIL"

echo "install hexo env..."
# install hexo env
npm install hexo-cli -g
npm ci
npm install hexo-deployer-git --save

echo "deploying......"
NODE_PATH=$NODE_PATH:$(pwd)/node_modules node /sync_deploy_history.js
hexo clean
hexo g
hexo d

echo "Deploy complate."
