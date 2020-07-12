#!bin/bash
checkout() {
    #entra nella repo
    local sha=$SHACOMMIT
    git checkout $sha
}
cloneRepo() {
    local nameRepo=$NAMEREPO
    local linkRepo=$LINKREPO
    local shaCommit=$SHACOMMIT
    local baseDir=$BASEDIR
    local repoFolder=$REPOFOLDER
    cd $baseDir
    cd $repoFolder
    message=$(git clone $linkRepo 2>&1)
    TOSEARCH="fatal: destination path"
    toReturn=0
    cd $nameRepo
    if echo "$message" | grep -q "$TOSEARCH"; then
        actualSha=$(git rev-parse HEAD)
        if echo "$actualSha" | grep -q "$shaCommit"; then
            cd $baseDir
            toReturn=0
        else
            git checkout $shaCommit
            toReturn=1
        fi
    else
        git checkout $shaCommit
        toReturn=1
    fi
}
mvnStep() {
    local baseDir=$BASEDIR
    TOSEARCH="BUILD FAILURE"
    OUTPUTBUILD=""
    message=$(mvn install -DskipTests -fn -B)
    if echo "$message" | grep -q "$TOSEARCH"; then
        OUTPUTBUILD="BUILD FAILED"
    else
        OUTPUTBUILD="BUILD PASS"
    fi
    cd $baseDir
    echo "$OUTPUTBUILD"
}
CSVINPUTFIRSTSTEP=$1
REPOFOLDER=$2
BASEDIR=$3
CSVOUTPUTFIRSTSTEP=$4
while IFS= read -r line; do
    IFS=',' read -r -a array <<<"$line"
    NAMEREPO=${array[0]}
    LINKREPO=${array[1]}
    SHACOMMIT=${array[2]}
    MODULENAME=${array[3]}
    cloneRepo "$NAMEREPO" "$LINKREPO" "$SHACOMMIT"
    "$BASEDIR" "$REPOFOLDER"
    echo $toReturn
    if [ $toReturn -eq 1 ]; then
        mvnStep $BASEDIR
        echo
        "$NAMEREPO","$LINKREPO","$SHACOMMIT","$OUTPUTBUILD" >>"$CSVOUTPUTFIRSTSTEP"
    fi
done <"$CSVINPUTFIRSTSTEP"
