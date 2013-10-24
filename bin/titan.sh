#!/bin/bash

mydir=`dirname $0`

#case `uname` in
#  CYGWIN*)
#    CP=$( echo `dirname $0`/../lib/*.jar . | sed 's/ /;/g')
#    CP=$CP:$(find -L `dirname $0`/../ext/ -name "*.jar" | tr '\n' ';')
#    ;;
#  *)
#    CP=$( echo `dirname $0`/../lib/*.jar . | sed 's/ /:/g')
#    CP=$CP:$(find -L `dirname $0`/../ext/ -name "*.jar" | tr '\n' ':')
#esac
#echo $CP

#JAC NOTE: need to call make-classpath.py here and put this classpath into CP, like
CP=$(python $mydir/make-classpath.py $mydir)


# Find Java
if [ "$JAVA_HOME" = "" ] ; then
    JAVA="java -server"
else
    JAVA="$JAVA_HOME/bin/java -server"
fi

# Set Java options
if [ "$JAVA_OPTIONS" = "" ] ; then
    JAVA_OPTIONS="-Xms1G -Xmx1G"
fi

JAVA_OPTIONS="$JAVA_OPTIONS \
              -Dcom.sun.management.jmxremote.port=7199 \
              -Dcom.sun.management.jmxremote.ssl=false \
              -Dcom.sun.management.jmxremote.authenticate=false"

echo Java virtual machine options are $JAVA_OPTIONS

# Launch the application
$JAVA $JAVA_OPTIONS -cp $CP:$CLASSPATH com.thinkaurelius.titan.tinkerpop.rexster.RexsterTitanServer $@