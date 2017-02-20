#!/bin/bash -e

export CONTEXT=$1
export RES_TAG=$2
export CURR_JOB=$3
export IMAGE_NAME=$CONTEXT
export RES_REPO=$CONTEXT"_repo"
export RES_IMAGE_OUT=$CONTEXT"_img"
export HUB_ORG="drydock"

export RES_TAG_UP=$(echo $RES_TAG | awk '{print toupper($0)}')
export RES_TAG_VER_NAME=$(eval echo "$"$RES_TAG_UP"_VERSIONNAME")

export RES_REPO_UP=$(echo $RES_REPO | awk '{print toupper($0)}')
export RES_REPO_STATE=$(eval echo "$"$RES_REPO_UP"_STATE")
export RES_REPO_COMMIT=$(eval echo "$"$RES_REPO_UP"_COMMIT")

set_context() {
  export BLD_IMG=$HUB_ORG/$IMAGE_NAME:$RES_TAG_VER_NAME

  echo "CONTEXT=$CONTEXT"
  echo "RES_TAG=$RES_TAG"
  echo "CURR_JOB=$CURR_JOB"
  echo "IMAGE_NAME=$IMAGE_NAME"
  echo "RES_REPO=$RES_REPO"
  echo "RES_IMAGE_OUT=$RES_IMAGE_OUT"
  echo "HUB_ORG=$HUB_ORG"

  echo "RES_TAG_UP=$RES_TAG_UP"
  echo "RES_TAG_VER_NAME=$RES_TAG_VER_NAME"
  echo "RES_REPO_UP=$RES_REPO_UP"
  echo "RES_REPO_STATE=$RES_REPO_STATE"
  echo "BLD_IMG=$BLD_IMG"
}

create_image() {
  pushd $RES_REPO_STATE

  echo "Replacing Dockerfile with $BLD_IMG"
  sed -i "s/{{%TAG%}}/$RES_TAG_VER_NAME/g" Dockerfile

  echo "Starting Docker build & push for $BLD_IMG"
  sudo docker build -t=$BLD_IMG .
  echo "Pushing $BLD_IMG"
  sudo docker push $BLD_IMG
  echo "Completed Docker build &  push for $BLD_IMG"

  popd
}

create_out_state() {
  echo "Creating a state file for $RES_IMAGE_OUT"
  echo versionName=$BLD_IMG > "$JOB_STATE/$RES_IMAGE_OUT.env"
  echo commitSHA=$RES_REPO_COMMIT >> "$JOB_STATE/$RES_IMAGE_OUT.env"

  echo "Creating a state file for $CURR_JOB"
  echo versionName=$BLD_IMG > "$JOB_STATE/$CURR_JOB.env"
  echo commitSHA=$RES_REPO_COMMIT >> "$JOB_STATE/$CURR_JOB.env"
}

main() {
  set_context
  create_image
  create_out_state
}

main
