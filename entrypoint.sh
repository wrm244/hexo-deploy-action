#!/bin/sh -l

set -e

# check values

if [ -n "${PUBLISH_REPOSITORY}" ]; then
    TARGET_REPOSITORY=${PUBLISH_REPOSITORY}
else
    TARGET_REPOSITORY=${GITHUB_REPOSITORY}
fi

# if [ -n "${BRANCH}" ]; then
#     TARGET_BRANCH=${BRANCH}
# else
#     TARGET_BRANCH="gh-pages"
# fi

if [ -n "${PUBLISH_DIR}" ]; then
    TARGET_PUBLISH_DIR=${PUBLISH_DIR}
else
    TARGET_PUBLISH_DIR="./public"
fi

# if [ -z "$PERSONAL_TOKEN" ]
# then
#   echo "You must provide the action with either a Personal Access Token or the GitHub Token secret in order to deploy."
#   exit 1
# fi

#REPOSITORY_PATH="https://x-access-token:${PERSONAL_TOKEN}@github.com/${TARGET_REPOSITORY}.git"

# start deploy

echo ">>>>> Start deploy to ${TARGET_REPOSITORY} <<<<<"

# Installs Git.
echo ">>> Install Git ..."
apt-get update && \
apt-get install -y git && \

# Directs the action to the the Github workspace.
cd "${GITHUB_WORKSPACE}"

echo ">>> Install NPM dependencies ..."
npm install

echo ">>> Clean cache files ..."
npx hexo clean

echo ">>> Generate file ..."
npx hexo generate



# cd "${TARGET_PUBLISH_DIR}"

# Configures Git.

echo ">>> Config git ..."

CURRENT_DIR=$(pwd)

git config --global user.name "${PERSION_NAME}"
git config --global user.email "${PERSION_MAIL}"

# echo "user:${PERSION_NAME},mail:${PERSION_MAIL}"
# # git remote add origin "${REPOSITORY_PATH}"
# # git checkout --orphan "${TARGET_BRANCH}"

# echo "use PRIVATE_KEY"
# if [ -n "${SSH_PRIVATE_KEY}" ]
# then
#   mkdir -p /root/.ssh
#   echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
#   chmod 600 /root/.ssh/id_rsa
# fi

# # if [ -n "$SSH_KNOWN_HOSTS" ]
# # then
# #   mkdir -p /root/.ssh
# #   echo "StrictHostKeyChecking yes" >> /etc/ssh/ssh_config
# #   echo "$SSH_KNOWN_HOSTS" > /root/.ssh/known_hosts
# #   chmod 600 /root/.ssh/known_hosts
# # else
# #   echo "WARNING: StrictHostKeyChecking disabled"
# #   echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
# # fi

# mkdir -p ~/.ssh
# cp /root/.ssh/* ~/.ssh/ 2> /dev/null || true

# git config --global --add safe.directory '*'
# git remote -v
# git remote set-url origin git@github.com:"${TARGET_REPOSITORY}".git

echo ">>> deploy ..."
npx hexo d
# if [ -n "${CNAME}" ]; then
#     echo ${CNAME} > CNAME
# fi

# git add .

# echo '>>> Start Commit ...'
# git commit --allow-empty -m "Building and deploying Hexo project from Github Action"

# echo '>>> Start Push ...'
# git push -u origin "${TARGET_BRANCH}" --force

echo ">>> Deployment successful!"
