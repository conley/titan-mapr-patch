#!/bin/bash

TITANVERSION=0.3.2
FAUNUSVERSION=0.3.2
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
echo unzipping rexster-server-$REXSTERVERSION.zip ...
unzip rexster-server-$REXSTERVERSION.zip &> /dev/null

if [ ! -d rexster-console-$REXSTERVERSION ]; then
	if [ ! -f rexster-console-$REXSTERVERSION.zip ]; then
		wget http://tinkerpop.com/downloads/rexster/rexster-console-$REXSTERVERSION.zip
	fi
	echo unzipping rexster-console-$REXSTERVERSION.zip ...
	unzip rexster-console-$REXSTERVERSION.zip &> /dev/null
fi
# download titan-hbase
if [ ! -f titan-hbase-$TITANVERSION.zip ]; then
	wget http://s3.thinkaurelius.com/downloads/titan/titan-hbase-$TITANVERSION.zip
fi
if [ -d titan-hbase-$TITANVERSION ]; then
	rm -r titan-hbase-$TITANVERSION
fi
echo unzipping titan-hbase-$TITANVERSION.zip ...
unzip titan-hbase-$TITANVERSION.zip &> /dev/null

# download faunus
if [ ! -f faunus-$FAUNUSVERSION.zip ]; then
	wget http://s3.thinkaurelius.com/downloads/faunus/faunus-$FAUNUSVERSION.zip
fi
if [ -d faunus-$FAUNUSVERSION ]; then
	rm -r faunus-$FAUNUSVERSION
fi
echo unzipping faunus-$FAUNUSVERSION.zip ...
unzip faunus-$FAUNUSVERSION.zip &> /dev/null
export FAUNUS_HOME=$PWD/faunus-$FAUNUSVERSION

# copy over scripts
cp titan-mapr-patch/bin/titan-gremlin.sh titan-hbase-$TITANVERSION/bin/gremlin.sh
cp titan-mapr-patch/bin/make-classpath.py titan-hbase-$TITANVERSION/bin/
cp titan-mapr-patch/bin/rexster.sh rexster-server-$REXSTERVERSION/bin/
cp titan-mapr-patch/bin/make-classpath.py rexster-server-$REXSTERVERSION/bin/
cp titan-mapr-patch/bin/faunus-gremlin.sh faunus-$FAUNUSVERSION/bin/gremlin.sh
cp titan-mapr-patch/bin/make-classpath.py faunus-$FAUNUSVERSION/bin/


# copy config
if [ "$REXSTERVERSION" = "2.4.0" ]; then
	REXSTERCONFIGDIR=config/
else
	REXSTERCONFIGDIR=
fi
cp titan-mapr-patch/config/rexster-$REXSTERVERSION.xml rexster-server-$REXSTERVERSION/${REXSTERCONFIGDIR}rexster.xml

# customize hostames
zklist=$(maprcli node listzookeepers | xargs) # xargs removes trailing whitespace
cp titan-mapr-patch/bin/make-hbase-graph.groovy titan-hbase-$TITANVERSION/bin/
sed -i.bak "s|REPLACEME|$zklist|" titan-hbase-$TITANVERSION/bin/make-hbase-graph.groovy
sed -i.bak "s|REPLACEME|$zklist|" rexster-server-$REXSTERVERSION/${REXSTERCONFIGDIR}rexster.xml

# go ahead and create graph using gremlin?
#echo creating titan-hbase graph...
#titan-hbase-$TITANVERSION/bin/gremlin.sh -e titan-hbase-$TITANVERSION/bin/make-hbase-graph.groovy

#python titan-mapr-patch/bin/fix-jars.py titan-hbase-$TITANVERSION/lib

mkdir rexster-server-$REXSTERVERSION/ext/titan
cp titan-hbase-$TITANVERSION/lib/* rexster-server-$REXSTERVERSION/ext/titan/
# fix metrics issue
#rm rexster-server-$REXSTERVERSION/ext/titan/metrics*
# start rexster server?

# avoid conflict with elasticsearch
rm rexster-server-$REXSTERVERSION/lib/lucene-core-*.jar

cat <<EOF
The titan-hbase-$TITANVERSION distribution has been downloaded to
$basedir/titan-hbase-$TITANVERSION
and has been "patched," in the sense that the classpath has been
fixed in the launch scripts.

The script will run gremlin.sh and create an HBase-backed graph. See
titan-hbase-$TITANVERSION/bin/make-hbase-graph.groovy
for the commands that are run in the gremlin shell. 

Once the graph is created, you can configure Rexster to run with it.
The Rexster server distribution has been downloaded to
$basedir/rexster-server-$REXSTERVERSION
Rexster has been patched too, by adding a titan subfolder to the ext
folder in the Rexster dist and adding all the Titan jars to that, and
in the sense that the classpath has been fixed in the rexster.sh script.
The Rexster console distribution has also been downloaded to
$basedir/rexster-console-$REXSTERVERSION

To start rexster, the script goes to the rexster server directory and run:
bin/rexster.sh -s -c ${REXSTERCONFIGDIR}rexster.xml &
Then go to the rexster console directory and run:
bin/rexster-console.sh

EOF