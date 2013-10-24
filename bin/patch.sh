#!/bin/bash

usage(){
    cat <<EOF
$0

Downloads the Rexster server distribution and the Titan HBase
distribution. 

Copies make-classpath.py into the Rexster and Titan bin dirs,
as well as the patched rexster.sh and gremlin.sh, respectively.

Replaces config/rexster.xml in the Rexster server distribution 
with the one we've modified to use the Titan-HBase graph that
you should create. Also copies all the jars over from the lib
directory of Titan.

EOF
    exit 1
}

trim() {
    local var=$@
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR
cd ../../
basedir=$(pwd)

if [ ! -f rexster-server-2.4.0.zip ]; then
	wget http://tinkerpop.com/downloads/rexster/rexster-server-2.4.0.zip
fi
unzip rexster-server-2.4.0.zip

# download titan-hbase
if [ ! -f titan-hbase-0.4.0.zip ]; then
	wget http://s3.thinkaurelius.com/downloads/titan/titan-hbase-0.4.0.zip
fi
unzip titan-hbase-0.4.0.zip

# copy over scripts
cp titan-mapr-patch/bin/gremlin.sh titan-hbase-0.4.0/bin/
cp titan-mapr-patch/bin/make-classpath.py titan-hbase-0.4.0/bin/
cp titan-mapr-patch/bin/rexster.sh rexster-server-2.4.0/bin/
cp titan-mapr-patch/bin/make-classpath.py rexster-server-2.4.0/bin/


#python titan-mapr-patch/bin/fix-jars.py titan-hbase-0.4.0/lib

mkdir rexster-server-2.4.0/ext/titan
cp titan-hbase-0.4.0/lib/* rexster-server-2.4.0/ext/titan/

# avoid conflict with elasticsearch
rm rexster-server-2.4.0/lib/lucene-core-*.jar

# customize hostames
zklist=$(maprcli node listzookeepers | xargs) # xargs removes trailing whitespace
sed -i.bak "s|REPLACEME|$zklist|" titan-mapr-patch/bin/make-hbase-graph.groovy
sed -i.bak "s|REPLACEME|$zklist|" titan-mapr-patch/config/rexster.xml

cat <<EOF
The titan-hbase-0.4.0 distribution has been downloaded to
$basedir/titan-hbase-0.4.0
and has been "patched," in the sense that the classpath has been
fixed in the launch scripts.

You have to now run gremlin.sh and create an HBase-backed graph. See
$DIR/make-hbase-graph.groovy for an example script.

Once the graph is created, you can configure Rexster to run with it.
Rexster has been patched too, by adding a titan subfolder to the ext
folder in the Rexster dist and adding all the Titan jars to that, and
in the sense that the classpath has been fixed in the rexster.sh script.

EOF