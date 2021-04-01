#!/usr/bin/bash

#Usage:
#$0 <GROUP> <GIT Access Token> <GIT URL>

ROOT_DIR=$PWD

#GIT GROUP
GROUP_NAME=$1
#GIT SETTING "ACCESS TOKEN"
GIT_CLONE_TOKEN=$2
#GIT URL FORMAT LIKE: https://x.x.x.x/api/v4/groups
GIT_URL=$3
#PROJECT URL FORMAT
PROJECT_PROJECTION='{ path: .path, path_with_namespace: .path_with_namespace, ssh_url_to_repo: .ssh_url_to_repo }'
SUBGROUP_PROJECTION='{ path: .path, full_path: .full_path}'

#Multiple thread to git clone or pull repos
typeset -i THREAD_MAX=10
typeset -i THREAD_COUNT=0
#PAGE COUNTER of projects lists query
typeset -i PAGE_COUNTER=1
#TOTAL Repos Number
typeset -i TOTAL_REPOS_COUNT=0

FILENAME=/tmp/repos
NEW_FILENAME=/tmp/repos_new

git_list_projects_per_group() {
    GROUP_NAME=$1
    PAGE_COUNTER=1
    rm -rf $FILENAME.$GROUP_NAME.json
	GROUP_PATH_NAME=$(echo $GROUP_NAME | sed -e 's/\//_/g')
    while true; do
		echo -n "."
        FULL_PATH=$(echo $GROUP_NAME | sed -e 's/\//%2f/g')
        #echo "URL $FULL_PATH"
        CURL_OUT=$(curl -s -XGET "$GIT_URL/$FULL_PATH/projects?private_token=$GIT_CLONE_TOKEN&per_page=10&page=$PAGE_COUNTER")
        if [[ "$CURL_OUT" == "[]" ]]; then
			return 1
		else
            tofile=$(echo $CURL_OUT | jq --raw-output --compact-output ".[] | $PROJECT_PROJECTION" )
            echo $tofile >> $FILENAME.$GROUP_PATH_NAME.json
            let PAGE_COUNTER++
        fi
    done
	echo "\n"
	return 0
}

git_clone_pull_project() {
    REPO=$1
	let TOTAL_REPOS_COUNT++
    THEPATH=$(echo "$REPO" | jq -r ".path")
	THEFULLPATH=$(echo "$REPO" | jq -r ".path_with_namespace")
    REPO_URL=$(echo "$REPO" | jq -r ".ssh_url_to_repo")
	REPO_TARGET_DIR=$ROOT_DIR/$THEFULLPATH
	PARENT_DIR=${REPO_TARGET_DIR%\/*}
    if [ ! -d "$REPO_TARGET_DIR" ]; then		
		cd $PARENT_DIR
        echo "Cloning repository $REPO_URL in $PARENT_DIR ..."
        (git clone $REPO_URL) &
    else
        echo "Pulling repository $REPO_URL in $GIT_TARGET_DIR"
        (cd $REPO_TARGET_DIR && git pull) &
    fi
}

git_clone_group() {
    GROUP_NAME=$1
	echo "Cloning GROUP $GROUP_NAME ..."
	GROUP_DIR=$ROOT_DIR/$GROUP_NAME
    if [ ! -d $GROUP_DIR ]; then
        mkdir -p $GROUP_DIR
    fi
    cd $GROUP_DIR

    echo "Listing projects in group $GROUP_NAME ... "
    git_list_projects_per_group $GROUP_NAME
	GROUP_PATH_NAME=$(echo $GROUP_NAME | sed -e 's/\//_/g')
    if [[ ! -e $FILENAME.$GROUP_PATH_NAME.json ]]; then      
		echo "No Projects in group $GROUP_NAME"
        return 1
    fi
    sed -e "s/ /\n/g" $FILENAME.$GROUP_PATH_NAME.json > $NEW_FILENAME.$GROUP_PATH_NAME.json
	THREAD_COUNT=0
    while read repo; do
        git_clone_pull_project $repo
		let THREAD_COUNT++
		if [[ $THREAD_COUNT -eq $THREAD_MAX ]]; then
			wait
			THREAD_COUNT=0
		fi
    done < $NEW_FILENAME.$GROUP_PATH_NAME.json
    rm -rf $FILENAME.$GROUP_PATH_NAME.json
	rm -rf $NEW_FILENAME.$GROUP_PATH_NAME.json
    echo "Cloning all projects under group $GROUP_NAME... DONE "

	FULL_PATH=$(echo $GROUP_NAME | sed -e 's/\//%2f/g')
    CURL_OUT=$(curl -s -XGET $GIT_URL/$FULL_PATH/subgroups)
    if [[ $CURL_OUT == *"404 Not Found"* ]]; then
        echo "No subgroup under group $GROUP_NAME"
		return 1
    else
        echo "List all subgroups under group $GROUP_NAME..."
        tofile=$(echo $CURL_OUT | jq --raw-output --compact-output ".[] | $SUBGROUP_PROJECTION" )
        for subgrp in $tofile; do
				FULLPATH=$(echo "$subgrp" | jq -r ".full_path")               
                git_clone_group $FULLPATH
        done
        echo "List all subgroups under group $GROUP_NAME... Done"
    fi
}

git_clone_group "$GROUP_NAME"
wait
echo "#######################################################################"
echo "Finish clone or pull repositories under group $1"
echo "The total number of repository cloned or pulled is $TOTAL_REPOS_COUNT"
echo "#######################################################################"
