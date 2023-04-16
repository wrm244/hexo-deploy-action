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

mkdir -p ./public/slides
for f in ./source/_posts/slides/*.md; do
    # 从 argument.txt 文件中读取对应的参数
    args=$(grep "$(basename "$f")" ./source/_posts/slides/argument.txt | cut -d' ' -f2-)
    # 调用 pandoc 命令并传递参数
    pandoc "$f" -o "./public/slides/$(basename "$f" .md).html" -t revealjs -s $args
done

# 如果 index.md 文件不存在，就创建一个空的
if [ ! -f ./source/slide/index.md ]; then
    touch ./source/slide/index.md
fi

# 遍历 ./public/slides 文件夹中的文件
for f in ./public/slides/*.html; do
    # 获取文件名（不含扩展名）
    name=$(basename "$f" .html)
    # 获取文件的创建时间（格式为 YYYY-MM-DD HH:MM:SS）
    time=$(stat -c %w "$f")
    # 检查 index.md 文件中是否已经有了相同的文件名
    if ! grep -q "${name}" ./source/slide/index.md; then
        # 如果没有，就追加一行到 index.md 文件中
        echo "| [${name}](https://wrm244.github.io/slides/${name}.html) | ${time} |" >> ./source/slide/index.md
    fi
done

echo ">>> Generate file again..."
npx hexo g

if [ $? -eq 0 ]; then
  echo "deploy to slide success"
else
  echo "deploy to slide failure"
fi

echo ">>>deploying......"
npx hexo d

echo ">>> Deployment successful!"
