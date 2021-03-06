#!/bin/bash
common() {
    string1=$pathFile
    string2=${arrayPom[$i]}
    first_diff_char=$(cmp <(echo "$string1") <(
        echo "$string2"
    ) | cut -d " " -f 5 | tr -d ",")
    ris=${string1:0:$((first_diff_char - 1))}
    echo "$ris"
}
getclassName() {
    local stringPath=$testName
    IFS='.'                        # hyphen (-) is set as delimiter
    read -ra ADDR <<<"$stringPath" # str is read into an
    array as tokens separated by IFS
    sizeArray=${#ADDR[@]}
    className=${ADDR[sizeArray - 2]}
    echo "$className"
}
getNameMethod() {
    local stringPath=$testName
    IFS='.'
    read -ra ADDR <<<"$stringPath"
    sizeArray=${#ADDR[@]}
    nameMethod=${ADDR[sizeArray - 1]}
    echo "$nameMethod"
}
cloneAndCheckRepo() {
    local link=$linkRepo
    local sha=$shaCommit
    local baseDir=$BASEDIR
    local repoFolder=$REPOFOLDER
    cd $baseDir
    cd $repoFolder
    git clone $linkRepo
    basename=$(basename $link)
    nameRepo=${basename%.*}
    cd $nameRepo
    echo "git checkout " $sha
    git checkout $sha
}
BASEDIR=$1
REPOFOLDER=$2
fileOutput=$BASEDIR"outIDFlakies.csv"
maxLength=-1
path=$BASEDIR"input.csv"
while IFS= read -r line; do
    IFS=',' read -r -a array <<<"$line"
    linkRepo=${array[0]}
    shaCommit=${array[1]}
    testName=${array[3]}
    cloneAndCheckRepo "$linkRepo" "$shaCommit" "$BASEDIR"
    "$REPOFOLDER"
    className="$(getclassName)"
    nameMethod="$(getNameMethod)"
    pathFile=$(find -name "$className".java)
    readarray -d '' arrayPom < <(find . -name pom.xml -print0)
    lengthArray=${#arrayPom[@]}
    var=$((lengthArray - 1))
    for i in $(seq 0 $var); do
        common $pathFile ${arrayPom[$i]}
        length=${#ris}
        if [ $length -gt $maxLength ]; then
            maxLength=$length
            moduleName=$ris
        fi
    done
    echo
    $nameRepo,$linkRepo,$shaCommit,$moduleName,$className,$nameMe
    thod >>$fileOutput
    cd $BASEDIR
    longPath=""
    length=-1
    maxLength=-1
    ris=""
done <"$path"
