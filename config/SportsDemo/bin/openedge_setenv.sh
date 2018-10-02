#!/bin/sh
# Catalina environment setup specific to the OpenEdge product set.
# This scripts adds in the Java system properties (-Dpsc.oe.<name>=<val>)
# that are global and used by OpenEdge web applications and catalina
# extensions

# Make it easy for the OpenEdge installer to tailor the DLC and WRKDIR
# locations so that they can be easily preserved when creating 
# AppServer instances and/or clones
if [ "${DLC}" = "" ] ; then
    DLC=""
    export DLC
fi
if [ "${WRKDIR}" = "" ] ; then
    WRKDIR="${CATALINA_BASE}/work"
    export WRKDIR
fi

# Load environment variables from OpenEdge's WRKDIR/proset.env, if it exists
if [ "${WRKDIR}" != "" -a -f "${WRKDIR}"/proset.env ]
then
    . "${WRKDIR}"/proset.env
fi

# Now add those as Java system properties to JAVA_OPTS environment variable
_oeopts="-Dpsc.as.oe.dlc=${DLC}"
_oeopts="${_oeopts} -Dpsc.as.oe.wrkdir=${WRKDIR}"
_oeopts="${_oeopts} -Dlogback.ContextSelector=JNDI"
_oeopts="${_oeopts} -Dlogback.configurationFile=file:///${CATALINA_BASE}/conf/logging.xml"
#_oeopts="${_oeopts} -Dpsc.as.uid=`id -u`" -- YK: Doesn't work on Solaris
#_oeopts="${_oeopts} -Dpsc.as.whoami=`id -un`" -- YK:  Doesn't work on Solaris
uidstr=`exec id`
_oeopts="${_oeopts} -Dpsc.as.uid=`echo $uidstr | sed 's/uid=//' | sed 's/(.*//'`"
_oeopts="${_oeopts} -Dpsc.as.whoami=`echo $uidstr | sed 's/uid=[0-9]*(//'  | sed 's/).*//'`"

# set network buffer size to 60K
_oeopts="${_oeopts} -DPROGRESS.Session.NetworkBufferSize=60000"

# Optional system property to enable instrumentation
# _oeopts="${_oeopts} -Dpsc.as.oe.instrument=true"

JAVA_OPTS="${JAVA_OPTS} ${_oeopts}" ; export JAVA_OPTS
