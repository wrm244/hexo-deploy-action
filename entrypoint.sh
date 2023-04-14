#!/bin/sh

set -e

echo "setup ssh-private-key"
# setup ssh-private-key
mkdir -p /root/.ssh/
echo "$INPUT_DEPLOY_KEY" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

# setup deploy git account
git config --global user.name "$INPUT_USER_NAME"
git config --global user.email "$INPUT_USER_EMAIL"

echo ">>>install hexo env....."
# install hexo env
npm install hexo-cli -g

echo ">>>install node dependency....."
npm ci
npm install hexo-deployer-git --save

echo ">>>clone history git repositories......"
echo ">>>Please check whether the deployment configuration is set up in _config.yml......"
NODE_PATH=$NODE_PATH:$(pwd)/node_modules node /sync_deploy_history.js

echo ">>> Clean cache files ..."
npx hexo clean

echo ">>> Generate file ..."
npx hexo g

echo ">>>deploying......"
npx hexo d

echo ">>> Deployment successful!"
