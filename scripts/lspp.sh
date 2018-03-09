#!/usr/bin/env bash

# Documentation
# https://docs.gitlab.com/ce/api/projects.html#list-projects
# NAMESPACE can be: tas, ntas, pmod, bb, lawful-interception and nsre

NAMESPACE=$1
BASE_PATH="https://gitlabe1.ext.net.nokia.com/"
PROJECT_SEARCH_PARAM=""
PROJECT_PROJECTION="{ "path": .path, "git": .ssh_url_to_repo }"
PROJECT_SELECTION="select(.namespace.name == \"$NAMESPACE\")"

#HERE is your access token got from setting->access token
GITLAB_PRIVATE_TOKEN="cMQ7v72TuEQqKLwyzDU9"
#GITLAB_PRIVATE_TOKEN="X5B7yhon95DYZu7zTz6W"
FILENAME="$NAMESPACE-repos.json"

#trap "{ rm -f $FILENAME; }" EXIT

#curl -s "${BASE_PATH}api/v4/projects?private_token=$GITLAB_PRIVATE_TOKEN&search=$PROJECT_SEARCH_PARAM&per_page=999" \
#    | jq --raw-output --compact-output ".[] | $PROJECT_SELECTION |  $PROJECT_PROJECTION" > "$FILENAME"

PAGE_COUNTER=1
while true; do
    echo "Reading page $PAGE_COUNTER"

    CURL_OUT=$(curl -s "${BASE_PATH}api/v3/projects?private_token=$GITLAB_PRIVATE_TOKEN&search=$PROJECT_SEARCH_PARAM&per_page=100&page=$PAGE_COUNTER")
    if [ "$CURL_OUT" == "[]" ]; then break; fi

    echo $CURL_OUT | jq --raw-output --compact-output ".[] | $PROJECT_SELECTION | $PROJECT_PROJECTION" >> "$FILENAME"
    let PAGE_COUNTER++
done

while read repo; do
    THEPATH=$(echo "$repo" | jq -r ".path")
    GIT=$(echo "$repo" | jq -r ".git")

    echo "Cloning --- $GIT [$THEPATH]"

    if [ ! -d "$THEPATH" ]; then
        echo "Cloning $THEPATH ( $GIT )"
        git clone "$GIT" --quiet &
    else
        echo "Pulling $THEPATH"
        (cd "$THEPATH" && git pull --quiet) &
    fi
done < "$FILENAME"
