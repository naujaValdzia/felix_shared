#!/bin/sh
#
# Shell wrapper to execute the PAS watcher utility
#
WATCHERCONF=""

# the oewatcher utility runs from the main PAS server installation directory
if [ "$CATALINA_HOME" = "" ] ; then
    # Install tailoring will fill in this location of CATALINA_HOME
    CATALINA_HOME=""
    # If install tailoring did not run, then stop here
    if [ "$CATALINA_HOME" = "" ] ; then
        echo "CATALINA_HOME is not defined"
        exit 1
    fi
    export CATALINA_HOME
fi

# the oewatcher utility needs to know the instance being modified
if [ "$CATALINA_BASE" = "" ] ; then
    # tcman create will fill in the location of CATALINA_BASE
    CATALINA_BASE=""
    # If tcman create did not run, then stop here
    if [ "$CATALINA_BASE" = "" ] ; then
        echo "CATALINA_BASE is not defined"
        exit 1
    fi
    export CATALINA_BASE
fi

# the oewatcher utility needs tcman
TCDIR="$CATALINA_BASE"/bin
TCMAN=tcman.sh
if [ ! -x "$TCDIR/$TCMAN" ]; then
    echo "Cannot find $TCDIR/$TCMAN needed to run this program"
    exit 1
fi
PASOEPID=`exec sh $TCDIR/tcman.sh env pid`
if [ "$PASOEPID" = "" ]; then
    echo "Cannot find PASOE pid value"
    exit 1
fi

# get variables from config files into JAVA_OPTS
if [ -r "$CATALINA_BASE/bin/setenv.sh" ]; then
  . "$CATALINA_BASE/bin/setenv.sh"
elif [ -r "$CATALINA_HOME/bin/setenv.sh" ]; then
  . "$CATALINA_HOME/bin/setenv.sh"
fi

# Define a place where the JAVA_HOME and/or JRE_HOME process environment
# variables can be customized before executing JAVA related operations.
# This script will call out to the javacfg.sh script in the CATALINA_HOME
# directory to do the work so that it is in sync with the expand utility version.
if [ -f "$CATALINA_HOME/bin/javacfg.sh" ] ; then
    . "$CATALINA_HOME/bin/javacfg.sh"
fi

# A version of JAVA is required
if [ "$JAVA_HOME" = "" ] ; then
    echo "JAVA_HOME is not defined"
    exit 1
fi

OEJARSPATH=${OEJARSPATH-$CATALINA_HOME/common/lib}
OEBINPATH=${OEBINPATH-$CATALINA_HOME/bin}

# Where Main is located
if [ "$OEWATCHER_JAR" = "" ] ; then
    # Fill in a default if the location was not already set
    # in the environment
    OEWATCHER_JAR="$CATALINA_HOME"/bin/oewatcher.11.7.3.jar
fi

_watcherjar=`find $OEJARSPATH -name "oewatcher*.jar"`
_logbackcorejar=`find $OEJARSPATH -name "logback-core-*.jar"`
_logbackclassicjar=`find $OEJARSPATH -name "logback-classic-*.jar"`
_jacksoncorejar=`find $OEJARSPATH -name "jackson-core-asl-*.jar"`
_jacksonmapjar=`find $OEJARSPATH -name "jackson-mapper-asl-*.jar"`
_slfjar=`find $OEJARSPATH -name "slf4j-api-*.jar"`
_oejmxjar=`find $OEBINPATH -name "oejmx.*.jar"`
_oepropjar=`find $OEBINPATH -name "oeprop.*.jar"`
_toolsjar=`find "$JAVA_HOME/lib" -name tools.jar`
_jconsolejar=`find "$JAVA_HOME/lib" -name jconsole.jar`
OECP="${_slfjar}:${_logbackclassicjar}:${_logbackcorejar}:${_watcherjar}:${_jacksoncorejar}:${_jacksonmapjar}:${_oepropjar}:${_oejmxjar}:${_toolsjar}:${_jconsolejar}"


JAVAPATH=$JAVA_HOME/bin/java
if [ ! -f $JAVAPATH ]; then
    echo "Error. Can't find java. Path: $JAVAPATH "
    exit 1
fi
WATCHERPID=$CATALINA_BASE/temp/oewatcher.pid
#WATCHERCONF=${WATCHERCONF-$CATALINA_BASE/conf/oewatcher.conf}
WATCHERLOG=${WATCHERLOG-$CATALINA_BASE/logs/oewatcher.err}
case $1 in
    start)
        echo "Starting OeWatcher ..."
        if [ $# -ge 2 ]; then 
            WATCHERCONF=$2
        else 
            WATCHERCONF="$CATALINA_BASE/conf/oewatcher.conf"
        fi

        if [ ! -f $WATCHERCONF ]; then 
            echo "Error. Can not find oewatcher script: $WATCHERCONF"
            exit 1
        fi
        
        #echo  "WATCHERCONF=$WATCHERCONF"
        if [ -f $WATCHERPID ]; then
            PID=`exec cat $WATCHERPID`
            #echo "found PID: $PID"
            #is it running?
            WATCHERPS=`exec ps -p $PID -F | grep com.progress.appserv.util.oewatcher.OEWatcherUtil`
            #echo "Watcher process: $WATCHERPS"
            if [ "$WATCHERPS" != "" ]; then 
                echo "OeWatcher is already running. Check PID in $WATCHERPID"
                exit 1
            fi
        fi
            # Execute it now
        nohup $JAVAPATH -Dcatalina.base=$CATALINA_BASE -cp $OECP -Dlogback.configurationFile=$CATALINA_BASE/conf/watcher-logging.xml com.progress.appserv.util.oewatcher.OEWatcherUtil $WATCHERCONF $PASOEPID > $WATCHERLOG 2>&1 &
        WPID=$!
        #echo "WPID: $WPID"
        sleep 3
        ps -p $WPID > /dev/null
        if [ $? == 1 ]; then
            echo "Error. OeWatcher did not start"
            exit 1
        fi
        echo "${WPID}" > $WATCHERPID
        echo "OeWatcher started with PID $WPID. Script: $WATCHERCONF" 
    ;;
    stop)
        if [ -f $WATCHERPID ]; then
            PID=`exec cat $WATCHERPID`;
            WATCHERPS=`exec ps -p $PID -F | grep com.progress.appserv.util.oewatcher.OEWatcherUtil`
            #echo "Watcher process: $WATCHERPS"
            if [ "$WATCHERPS" == "" ]; then 
                echo "Error. Can not find process for pid $PID. Check file $WATCHERPID"
                exit 1
            fi
            # echo "Stopping oewatcher ..."
            kill -9 $PID;
            # echo "oewatcher stopped"
            rm $WATCHERPID
        else
            echo "Error. Can not find OeWatcher pid file: $WATCHERPID"
            exit 1
        fi
    ;;
    *)
    if [ "$1" == "" ]; then
        echo "Error. No command found. Possible commands: start, stop"
    else 
        echo "Error. Illeagal command found: '$1'. Possible commands: start, stop"
    fi  
    

esac 
