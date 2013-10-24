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

TITANVERSION=0.3.2
REXSTERVERSION=2.3.0

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR
cd ../../
basedir=$(pwd)

if [ ! -f rexster-server-$REXSTERVERSION.zip ]; then
	wget http://tinkerpop.com/downloads/rexster/rexster-server-$REXSTERVERSION.zip
fi
if [ -d rexster-server-$REXSTERVERSION ]; then
	rm -r rexster-server-$REXSTERVERSION
fi
unzip rexster-server-$REXSTERVERSION.zip

if [ ! -d rexster-console-$REXSTERVERSION ]; then
	if [ ! -f rexster-console-$REXSTERVERSION.zip ]; then
		wget http://tinkerpop.com/downloads/rexster/rexster-console-$REXSTERVERSION.zip
	fi
	unzip rexster-console-$REXSTERVERSION.zip
fi
# download titan-hbase
if [ ! -f titan-hbase-$TITANVERSION.zip ]; then
	wget http://s3.thinkaurelius.com/downloads/titan/titan-hbase-$TITANVERSION.zip
fi
if [ -d titan-hbase-$TITANVERSION ]; then
	rm -r titan-hbase-$TITANVERSION
fi
unzip titan-hbase-$TITANVERSION.zip

# copy over scripts
cp titan-mapr-patch/bin/gremlin.sh titan-hbase-$TITANVERSION/bin/
cp titan-mapr-patch/bin/make-classpath.py titan-hbase-$TITANVERSION/bin/
cp titan-mapr-patch/bin/rexster.sh rexster-server-$REXSTERVERSION/bin/
cp titan-mapr-patch/bin/make-classpath.py rexster-server-$REXSTERVERSION/bin/

# copy config
if [ "$REXSTERVERSION" = "2.4.0" ]; then
	REXSTERCONFIGDIR=config/
else
	REXSTERCONFIGDIR=
fi
cp titan-mapr-patch/config/rexster.xml rexster-server-$REXSTERVERSION/$REXSTERCONFIGDIR

#python titan-mapr-patch/bin/fix-jars.py titan-hbase-$TITANVERSION/lib

mkdir rexster-server-$REXSTERVERSION/ext/titan
cp titan-hbase-$TITANVERSION/lib/* rexster-server-$REXSTERVERSION/ext/titan/
# fix metrics issue
#rm rexster-server-$REXSTERVERSION/ext/titan/metrics*


# avoid conflict with elasticsearch
rm rexster-server-$REXSTERVERSION/lib/lucene-core-*.jar




# customize hostames
zklist=$(maprcli node listzookeepers | xargs) # xargs removes trailing whitespace
sed -i.bak "s|REPLACEME|$zklist|" titan-mapr-patch/bin/make-hbase-graph.groovy
sed -i.bak "s|REPLACEME|$zklist|" titan-mapr-patch/config/rexster.xml

cat <<EOF
The titan-hbase-$TITANVERSION distribution has been downloaded to
$basedir/titan-hbase-$TITANVERSION
and has been "patched," in the sense that the classpath has been
fixed in the launch scripts.

You have to now run gremlin.sh and create an HBase-backed graph. See
$DIR/make-hbase-graph.groovy for the example commands to run in the
gremlin shell. (TODO: run this script automatically?)

Once the graph is created, you can configure Rexster to run with it.
The Rexster server distribution has been downloaded to
$basedir/rexster-server-$REXSTERVERSION
Rexster has been patched too, by adding a titan subfolder to the ext
folder in the Rexster dist and adding all the Titan jars to that, and
in the sense that the classpath has been fixed in the rexster.sh script.
The Rexster console distribution has also been downloaded to
$basedir/rexster-console-$REXSTERVERSION

To start rexster, go to the rexster directory and run:
bin/rexster.sh -s -c ${REXSTERCONFIGDIR}rexster.xml &
Then go to the rexster console directory and run:
bin/rexster-console.sh

EOF