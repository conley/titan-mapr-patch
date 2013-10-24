#!/bin/bash

usage(){
    cat <<EOF
$0

Downloads the Rexster server distribution and the Titan HBase
distribution. Replaces bin/gremlin.sh in the Titan distribution
with the one that we've patched to use the classpath generated
by make-classpath.py (which is also copied into the the Titan
bin directory).

EOF
    exit 1
}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR
cd ..
basedir=$(pwd)

wget http://tinkerpop.com/downloads/rexster/rexster-server-2.4.0.zip

# download titan-hbase
wget http://s3.thinkaurelius.com/downloads/titan/titan-hbase-0.4.0.zip
unzip titan-hbase-0.4.0.zip

# copy over scripts
cp titan-mapr-patch/bin/gremlin.sh titan-hbase-0.4.0/bin/
#cp titan-mapr-patch/bin/titan.sh titan-hbase-0.3.2/bin/
cp titan-mapr-patch/bin/make-classpath.py titan-hbase-0.4.0/bin/

cat <<EOF
The titan-hbase-0.4.0 distribution has been downloaded to
$basedir/titan-hbase-0.4.0
and has been "patched," in the sense that the MapR-specific script
bin/gremlin.sh has been copied to the bin directory
in the titan-hbase distribution. 

EOF