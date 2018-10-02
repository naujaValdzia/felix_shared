#!/bin/sh
# A monitoring tool. Uses jmx services to access Tomcat beans:
#  - generates a list of bean operations and attributes exposed to jmx
#  - invokes bean operations and reads bean attributes.
# Accepts four optional attributes
# -C - signales to generate a list of bean operations/attributes 
# -Q <file name> - file name (with path) having a set of bean opertion/attribute requests. 
#    This parameter is ignored if -C attribute present. Default value: <PASOE Base Dir>/bin/queries/queries.txt. 
#    Users have to pouplate this file with queries.
# -O <file name> - output file name (with path). 
#    The file name may include timestamp template: {TIMESTAMP} or {TIMESTAMP:<java type datetime format>}
#    Default values:
#      If -C argumet presents: <PASOE Temp Dir>/beanInfo{TIMESTAMP:yyMMdd-HHmm}.txt
#      If no -C argumet:  <PASOE Temp Dir>/queries-out-{TIMESTAMP:yyMMdd-HHmmss}.txt
# -R - signals write into output file results only. Oterhwise output file also includes queriy texts. 
#      It ignored if -C argumet presents
# Get the script directory
if [ -z "$CATALINA_HOME" ]
then
    # Allow an install tailored CATALINA_HOME to be used if the user
    # has not already defined their own private location
    CATALINA_HOME=""
    export CATALINA_HOME
    if [ -z "$CATALINA_HOME" ]
    then
        echo "CATALINA_HOME is not defined or points to an invalid server installation"
        exit 1
    fi
fi

PRGDIR="$CATALINA_HOME"/bin

# Allow an tcman create command tailor CATALINA_HOME
CATALINA_BASE=""
export CATALINA_BASE

# Allow tailoring of where temp files are accessed, but
# allow the individual's environment to supercede tailoring
if [ -z "$CATALINA_TMPDIR" ] ; then
CATALINA_TMPDIR="$CATALINA_BASE/temp"
export CATALINA_TMPDIR
fi

# Define a place where the JAVA_HOME and/or JRE_HOME process environment
# variables can be customized before executing JAVA related operations.
# This script will call out to the javacfg.sh script in the CATALINA_HOME
# directory to do the work so that it is in sync with the tcmanager utility
# version.
if [ -f "$CATALINA_HOME/bin/javacfg.sh" ] ; then
    . "$CATALINA_HOME/bin/javacfg.sh"
fi

dbg=""
javahome=$JAVA_HOME
tmpdir=$CATALINA_TMPDIR
pasoepid=""
pasoehome=$CATALINA_HOME
pasoebase=$CATALINA_BASE
beanInfo=""
resultOnly=""
resultOnlyArg=""
queriesArg=""
jacksoncore=""
jacksonmapper=""
oejmx=""
qResults=""
queries=""
scriptPath=$pasoebase/bin
instName=`basename $pasoebase`
pasoepidfile=$pasoebase/temp/catalina-$instName.pid

# echo "pasoepidfile: $pasoepidfile"

#get the pasoepid value from the pid file
if [ -f $pasoepidfile ]
then
  pidEmpty=`cat $pasoepidfile`
  if [ "$pidEmpty" != "" ]
  then
    pasoepid=`cat $pasoepidfile`
    export pasoepid
  else
    echo "No PID found in file, verify PASOE instance is running..."
    exit 1
  fi
else
    echo "No PID file found, verify PASOE instances is running..."
    exit 2
fi
  
if [ ! "$dbg" = "" ]; then
        echo "javahome:   $javahome"
        echo "tmpdir:     $tmpdir"
        echo "pasoepid:   $pasoepid"
        echo "pasoehome:  $pasoehome"
        echo "pasoebase:  $pasoebase"
fi

# Get parameters

while [ $# -gt 0 ]
do
  if [ $1 = "-R" ]; then  resultOnlyArg="-R";  fi
  if [ $1 = "-C" ]; then  beanInfo="-C";  fi
  if [ $1 = "-Q" ]; then  shift; if [ $# -gt 0 ]; then queriesArg=$1; fi  fi
  if [ $1 = "-O" ]; then  shift; if [ $# -gt 0 ]; then qResults=$1;	fi  fi
  shift
done
if [ ! "$dbg" = "" ]; then
	echo "beanInfo:   $beanInfo"
	echo "resultOnlyArg: $resultOnlyArg"
	echo "queriesArg:    $queriesArg"
	echo "qResults:   $qResults"
fi

# validate jar file presents 
# tools.jar
tools="$javahome/lib/tools.jar"
if [ ! -f "$tools" ]; then 	echo "Error! can not find jar $tools"; exit 1; fi

# jconsole.jar
jconsole="$javahome/lib/jconsole.jar"
if [ ! -f "$jconsole" ]; then echo "Error! can not find  $jconsole"; exit  1; fi

commonLib="$pasoehome/common/lib"
jacksonJars=`ls $commonLib/jackson-*-asl-[0-9\.]*\.jar`
jacksonJars=`echo "$jacksonJars" |  tr "\n" " "`

for ff in  $jacksonJars; do
  nn=`expr match "$ff" ".*jackson-core-asl.*"` 
  if [ ! "$nn" = "0" ]; then jacksoncore=$ff; else
  nn=`expr match "$ff" ".*jackson-mapper-asl.*"` 
  if [ ! "$nn" = "0" ]; then jacksonmapper=$ff; 
  fi fi
done 

if [ "$jacksoncore" = "" ] ; then
	echo "Error! Can't find jackson-core-asl*.jar in directory $commonLib";
	exit 1
fi
if [ "$jacksonmapper" = "" ] ; then
	echo "Error! Can't find jackson-mapper-asl*.jar in directory $commonLib";
	exit 1
fi


# find oejmx jar
binDir="$pasoehome/bin"
oejmxJars=`ls $binDir/oejmx[0-9\.]*\.jar`
oejmxJars=`echo "$oejmxJars" |  tr "\n" " "`

for ff in  $oejmxJars; do
  oejmx=$ff 
done 

if [ "$oejmx" = "" ] ; then
	echo "Error! Can't find oejmx*.jar in directory $binDir";
	exit 1
fi

# check queries file
if [ "$beanInfo" = "" ]; then
if [ "$queriesArg" = "" ]; then 
	queries="$scriptPath/jmxqueries/default.qry"
else
	queries="$queriesArg"
	
fi
resultOnly="$resultOnlyArg"
if [ ! -f "$queries" ]; then
     echo "Error! can not find queries file  '$queries'"
     exit 1 
fi
fi

# check output file directory
if [ "$qResults" = "" ]; then 
	if [ "$beanInfo" = "" ]; then
		qResults="$tmpdir"
	else
		qResults="$tmpdir/beanInfo-{TIMESTAMP:yyyyMMdd-HHmm}.txt"
	fi
fi
resultsDir=`dirname $qResults`
if [ ! -d "$resultsDir" ]; then
     echo "Error! can not access queries reslut file directory '$resultsDir'"
     exit 1 
fi

pasoeJmxCall="$javahome/bin/java" 
pasoeJmxCallCp="-cp $jacksoncore:$jacksonmapper:$tools:$jconsole:$oejmx"
pasoeJmxCallClass="com.progress.appserv.util.jmx.PASOEWatch" 

command="$pasoeJmxCall $pasoeJmxCallCp $pasoeJmxCallClass $pasoepid $queries $qResults $resultOnly $beanInfo"

if [ ! "$dbg" = "" ]; then
	echo "COMMAND: $command"
fi

eval "$command"
