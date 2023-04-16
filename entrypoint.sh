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

echo ">>>install hexo-deployer-git....."
npm install hexo-deployer-git --save

echo ">>>clone history git repositories......"
echo ">>>Please check whether the deployment configuration is set up in _config.yml......"
NODE_PATH=$NODE_PATH:$(pwd)/node_modules node /sync_deploy_history.js

echo ">>> Generate file ..."
npx hexo g

echo ">>> Clean cache files ..."
npx hexo clean

echo ">>> Generate file again..."
npx hexo g

#
echo ">>> deploy slides...."
apt-get install wget
wget https://github.com/jgm/pandoc/releases/download/3.1.2/pandoc-3.1.2-1-amd64.deb
dpkg -i pandoc-3.1.2-1-amd64.deb

# use pandoc to slides
echo ">>>pandoc -o pandoc ./public/slides/** -o "./public/slides/**" -t revealjs -s ${PANDOC_SLIDES}"
mkdir -p ./public/slides
if [-n "${PANDOC_SLIDES}"];them
    for f in ./source/_posts/slides/*.md; do
        pandoc "$f" -o "./public/slides/$(basename "$f" .md).html" -t revealjs -s ${PANDOC_SLIDES}
    done
else
    for f in ./source/_posts/slides/*.md; do
        pandoc "$f" -o "./public/slides/$(basename "$f" .md).html" -t revealjs -s
    done
if [ $? -eq 0 ]; then
  echo "deploy to slide success"
else
  echo "deploy to slide failure"
fi

echo ">>>deploying......"
npx hexo d

echo ">>> Deployment successful!"
