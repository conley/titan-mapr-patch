#!/bin/bash

#CP=$( echo `dirname $0`/../lib/*.jar . | sed 's/ /:/g')
#CP=$CP:$(find -L `dirname $0`/../ext/ -name "*.jar" | tr '\n' ':')

mydir=`dirname $0`

#JAC NOTE: need to call make-classpath.py here and put this classpath into CP, like
CP=$(python $mydir/make-classpath.py $mydir)

REXSTER_EXT=../ext

PUBLIC=`dirname $0`/../public/
EXTRA=

if [ $1 = "-s" ] ; then
    EXTRA="-wr $PUBLIC"
fi

# Find Java
if [ "$JAVA_HOME" = "" ] ; then
    JAVA="java -server"
else
    JAVA="$JAVA_HOME/bin/java -server"
fi

# Set Java options
if [ "$JAVA_OPTIONS" = "" ] ; then
    JAVA_OPTIONS="-Xms32m -Xmx512m"
fi

# Launch the application
$JAVA $JAVA_OPTIONS -cp $CP com.tinkerpop.rexster.Application $@ $EXTRA

# Return the program's exit code
exit $?