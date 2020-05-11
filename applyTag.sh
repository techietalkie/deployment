#!/bin/sh

err()
{
    echo "ERROR: $*, exiting..."
    exit 1
}

--ROOT="/home/jenkins/backup"
project=""
repository=""
branch=""

while getopts "p:r:b:" opt
do
  case "$opt" in
    p ) project="$OPTARG" ;;
    r ) repository="$OPTARG" ;;
    b ) branch="$OPTARG" ;;
  esac
done

[ ! -z "$project" ] || err "Project/organization is not specified"
[ ! -z "$repository" ] || err "Repository is not specified"
[ ! -z "$branch" ] || err "Branch is not specified"

echo "GitHub project/organization $project"
echo "Repository: $repository"
echo "Branch: $branch"

echo "Applying new tag..."
timestamp=$(date +"%Y%m%d")
tagSample="t_$timestamp"
#echo $tagSample
nextSuffix="-1"

cd $ROOT
rm -rf applying_tag_${repository}
sleep 1
mkdir applying_tag_${repository}
cd applying_tag_${repository}

git init
git remote add -f origin https://techietalkie:pune_2020@github.com/${project}/${repository}
git checkout ${branch}

tagList=""
for item in $(git tag -l | grep "^$tagSample")
do
  tagList="$tagList$item,"
done

tagSuffix=""
for item in $(echo $tagList | tr ',' '\n')
do
  #echo $item
  tagSuffix=$(echo $item | cut -d'_' -f 3) # if non-numerical, will treat it as 0
  #echo $tagSuffix
  if [ -z "$tagSuffix" ]
  then
    tagSuffix="0"
  fi
  if (( $tagSuffix > $nextSuffix ))
  then
    #echo "New next suffix: $tagSuffix"
    nextSuffix=$tagSuffix
  fi
done
#echo "NEXT SUFFIX $nextSuffix"

newSuffix=""
newTag="$tagSample"
if [ "$nextSuffix" != "-1" ]
then
  newSuffix=$(($nextSuffix + 1))
  #echo "New Suffix:  $newSuffix"
  newTag+="_$newSuffix"
fi

echo "$newTag will be applied"

#exit

echo "Tagging locally..."
git tag $newTag ${branch}
echo "Pushing the tag to GIT ${repository}..."
git push origin $newTag

cd $ROOT
rm -rf applying_tag_${repository}_newTag
mkdir applying_tag_${repository}_newTag
cd applying_tag_${repository}_newTag
echo "$newTag" > newTag

