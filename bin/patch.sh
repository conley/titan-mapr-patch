#!/bin/bash

usage(){
    cat <<EOF
$0

Downloads the Rexster server distribution and the Titan HBase
distribution. 

Runs fix-jars.py to replace all the jars in the lib directory
of the Titan distribution that need replacing by MapR jars.

Replaces config/rexster.xml in the Rexster server distribution 
with the one we've modified to use the Titan-HBase graph that
you should create. Also copies all the jars over from the lib
directory of Titan, after the MapR ones have been copied in.

EOF
    exit 1
}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR
cd ../../
basedir=$(pwd)

wget http://tinkerpop.com/downloads/rexster/rexster-server-2.4.0.zip
unzip rexster-server-2.4.0.zip

# download titan-hbase
wget http://s3.thinkaurelius.com/downloads/titan/titan-hbase-0.4.0.zip
unzip titan-hbase-0.4.0.zip

# copy over scripts
#cp titan-mapr-patch/bin/gremlin.sh titan-hbase-0.4.0/bin/
#cp titan-mapr-patch/bin/titan.sh titan-hbase-0.3.2/bin/
#cp titan-mapr-patch/bin/make-classpath.py titan-hbase-0.4.0/bin/
python titan-mapr-patch/bin/fix-jars.py titan-hbase-0.4.0/lib

mkdir rexster-server-2.4.0/ext/titan
cp titan-hbase-0.4.0/lib/* rexster-server-2.4.0/ext/titan/

# avoid conflict with elasticsearch
rm rexster-server-2.4.0/lib/lucene-core-3.5.0.jar

cat <<EOF
The titan-hbase-0.4.0 distribution has been downloaded to
$basedir/titan-hbase-0.4.0
and has been "patched," in the sense that the MapR-specific jars have
been copied to the lib directory.

You have to now run gremlin.sh and create an HBase-backed graph. See
$DIR/make-hbase-graph.groovy for an example script.

Once the graph is created, you can configure Rexster to run with it.
Rexster has been patched too, by adding a titan subfolder to the ext
folder in the Rexster dist and adding all the (patched) Titan jars to 
that subfolder.

EOF