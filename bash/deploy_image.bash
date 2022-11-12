#!/usr/bin/env bash

BLUE=$'\033[1;34m'
RED=$'\033[1;31m'
GREEN=$'\033[1;32m'
YELLOW=$'\033[1;33m'
BOLD_BLUE=$'\033[1;34m'
PURPLE=$'\033[1;35m'
CYAN=$'\033[1;36m'
GRAY=$'\033[1;37m'
NO_COLOUR=$'\033[0m'

AWS_PROFILE_PREFIX="DS"
ENV="dev"
DOCKER_TAG="latest"
AWS_REGION="eu-central-1"
BUILD_IMAGE=1
PUSH_IMAGE=1

error() {
  echo "${RED}Wrong parameter: ${NO_COLOUR} $1"
  usage
  exit $2
} >&2

usage() {
  echo "${YELLOW}Usage:${NO_COLOUR}"
  echo "   ./deploy_image [-aret]"
  echo
  echo "${YELLOW}Available options are:${NO_COLOUR}"
  echo "    -a | --account     AWS account prefix (default: ${AWS_PROFILE_PREFIX})"
  echo "    -r | --region      AWS region (default: ${AWS_REGION})"
  echo "    -e | --env         AWS account environment, either <dev|test|prod> (default: ${ENV})"
  echo "    -t | --tag         Value to use as the docker image tag  (default: ${DOCKER_TAG})"
  echo "    -p | --push-only   Push a already built docker image if it exists."
  echo "    -d | --dry-run     Only build the docker image and do not push to ECR"
  echo
  echo "  ${YELLOW}Example:${NO_COLOUR}"
  echo "    ./deploy_image.bash -a dss -e test --tag latest"
  echo
}

if [[ $1 == '--help' || "$1" == "-h" ]]; then
  usage
  exit 0
fi

# Parse parameters
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
  -a | --account)
    AWS_PROFILE_PREFIX="$2"
    shift
    ;;
  -e | --env)
    ENV="$2"
    shift
    ;;
  -t | --tag)
    DOCKER_TAG=$2
    shift
    ;;
  -r | --region)
    AWS_REGION=$2
    shift
    ;;
  -d | --dry-run)
    BUILD_IMAGE=1
    PUSH_IMAGE=0
    shift
    ;;
  -p | --push-only)
    BUILD_IMAGE=0
    shift
    ;;
  *)
    error "$1" 3
    ;;
  esac
  shift
done

# set other necessary variables
AWS_PROFILE="${AWS_PROFILE_PREFIX}-${ENV}"

case $ENV in
"dev") AWS_ACCOUNT="<add the ID of your DEV account>" ;;
"test") AWS_ACCOUNT="<add the ID of your TEST account>" ;;
"prod") AWS_ACCOUNT="<add the ID of your PROD account>" ;;
esac

DOCKER_REPO="<name your docker image repo in the AWS ECR>"
AWS_URI="$AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com"
DOCKER_IMAGE_NAME_TAG="$DOCKER_REPO:$DOCKER_TAG"
DOCKER_AWS_URI="$AWS_URI/$DOCKER_IMAGE_NAME_TAG"

aws --profile=$AWS_PROFILE ecr get-login-password --region $AWS_REGION |
  docker login --username AWS --password-stdin $AWS_URI

if [[ $BUILD_IMAGE -eq 1 ]]; then
  echo "${YELLOW}Building & tagging${NO_COLOUR} docker image."
  docker buildx build --platform linux/amd64 --load -t $DOCKER_IMAGE_NAME_TAG .
fi

if [[ $PUSH_IMAGE -eq 1 ]]; then
  echo "${YELLOW}Publishing${NO_COLOUR} docker image to AWS ECR."
  docker tag $DOCKER_IMAGE_NAME_TAG $DOCKER_AWS_URI
  docker push $DOCKER_AWS_URI
fi

echo "---------------------------------------------------"
echo "${GREEN}Done${NO_COLOUR}."
echo "${YELLOW}local${NO_COLOUR} image: $DOCKER_IMAGE_NAME_TAG"
echo "${YELLOW}to publish${NO_COLOUR} image: $DOCKER_AWS_URI"
echo "---------------------------------------------------"
