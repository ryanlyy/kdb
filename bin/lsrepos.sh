#!/usr/bin/env bash

# Documentation
# https://docs.gitlab.com/ce/api/projects.html#list-projects

GROUP_NAME="tas"
BASE_PATH="https://gitlabe1.ext.net.nokia.com/"
PROJECT_PROJECTION="{ "path": .path, "git": .ssh_url_to_repo }"

GITLAB_PRIVATE_TOKEN="T_kJPzFzFDxJBEBbyN2h"
FILENAME="repos.json"

[ -e $FILENAME  ] && rm $FILENAME

PAGE_COUNTER=1
while true; do
    CURL_OUT=$(curl -XGET "${BASE_PATH}api/v3/groups/$GROUP_NAME/projects?private_token=$GITLAB_PRIVATE_TOKEN&per_page=100&page=$PAGE_COUNTER")
    if [ "$CURL_OUT" == "[]" ]; then break; fi
    tofile=$(echo $CURL_OUT | jq --raw-output --compact-output ".[] | $PROJECT_PROJECTION" )
    echo $tofile >> $FILENAME
    let PAGE_COUNTER++
done

sed -e "s/ /\n/g" $FILENAME > new-$FILENAME
while read repo; do
    THEPATH=$(echo "$repo" | jq -r ".path")
    GIT=$(echo "$repo" | jq -r ".git")
    if [ ! -d "$THEPATH" ]; then
        echo "Cloning $THEPATH ( $GIT )"
        git clone "$GIT" --quiet &
    else
        echo "Pulling $THEPATH"
        (cd "$THEPATH" && git pull --quiet) &
    fi
done < new-"$FILENAME"

rm -rf new-$FILENAME $FILENAME
