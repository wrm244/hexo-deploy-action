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

# 定义一些常量
SLIDES_DIR="./source/_posts/slides"
PUBLIC_DIR="./public/slides"
INDEX_FILE="./source/slide/index.md"
ARG_FILE="$SLIDES_DIR/argument.md"

# 定义一个函数，用来转换 md 文件为 html 文件，并传递参数
convert_md_to_html() {
    # 获取文件名（不含扩展名）
    local name=$(basename "$1" .md)
    # 从 argument.txt 文件中读取对应的参数
    local args=$(grep "$name" "$ARG_FILE" | grep -v "^#" | cut -d' ' -f2-)
    # 调用 pandoc 命令并传递参数
    pandoc "$1" -o "$PUBLIC_DIR/$name.html" -t revealjs -s $args
}

# 定义一个函数，用来写入 index.md 文件
write_index_file() {
    # 获取文件名（不含扩展名）
    local name=$(basename "$1" .html)
    # 获取文件的创建时间（格式为 YYYY-MM-DD HH:MM）
    local time=$(grep -A 1 "$name" "$ARG_FILE" | grep "^#" | awk -F ' ' '{if ($3) print $3; else print "暂无时间"}')
    # 从 argument.txt 文件中读取对应的简介
    local desc=$(grep -A 1 "$name" "$ARG_FILE" | grep "^#" | awk -F ' ' '{if ($2) print $2; else print "暂无备注"}')
    # 检查 index.md 文件中是否已经有了相同的文件名
    if ! grep -q "$name" "$INDEX_FILE"; then
        # 如果没有，就追加一行到 index.md 文件中
        echo "| [$name](../slides/$name.html) | $desc | $time |" >> "$INDEX_FILE"
    fi
}

# 创建目录和文件（如果不存在）
mkdir -p "$PUBLIC_DIR"
touch "$INDEX_FILE"
touch "$ARG_FILE"

# 遍历 md 文件，并转换为 html 文件
for f in "$SLIDES_DIR"/*.md; do
    # 检查文件是否存在
    if [ -f "$f" ]; then
        convert_md_to_html "$f"
    else
        echo "File $f does not exist."
        exit 1
    fi
done

# 对 html 文件按照创建时间排序，并反转顺序
files=$(ls -t "$PUBLIC_DIR"/*.html | tac)
# 遍历排序后的文件，并写入 index.md 文件
for f in $files; do
    # 检查文件是否存在
    if [ -f "$f" ]; then
        write_index_file "$f"
    else
        echo "File $f does not exist."
        exit 1
    fi
done

echo "pandoc to slides Done."

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
