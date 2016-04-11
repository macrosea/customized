#/bin/bash

usage()
{
    echo "$(basename $0) <32|64>"
}

if [ "$1" != "32" -a "$1" != "64" ]; then
    usage
    exit -1;
fi

if [ "$1" == "32" ]; then
    FROM="32bit\/ubuntu:14.04"
else
    FROM="ubuntu"
fi

DF="Dockerfile.$1"

sed "s/FROM.*/FROM $FROM/g" docker.file > $DF

grep "FROM" $DF

echo "start to build a $FROM image..."

docker build --force-rm  -t macrosea/u$1 -f $DF .
if [ $? -eq 0 ]; then 
    echo "build OK"
else
    echo "build failed"
    exit -2
fi
docker images

