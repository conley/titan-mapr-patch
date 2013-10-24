import glob
#import argparse
from optparse import OptionParser
import subprocess
from os import path

def splitVersion(jarname):
    """Split a jarname into the name and the version.

    For example, 'hbase-0.94.5-mapr.jar' gets split into
    ('hbase', '0.94.5-mapr.jar')"""
    splitIndex = -1
    prevDash = False
    for i, char in enumerate(jarname):
        if prevDash:
            if char.isdigit():
                splitIndex = i - 1
                break
        if char == '-':
            prevDash = True
        else:
            prevDash = False
    if splitIndex > 0:
        return (jarname[0:splitIndex], jarname[splitIndex+1:])
    else:
        return (jarname, "")

def getNameOnly(jarname):
    return splitVersion(jarname)[0]

def getVersionOnly(jarname):
    return splitVersion(jarname)[1]

parser = OptionParser()
#parser = argparse.ArgumentParser(description='Make the correct classpath for Titan.')
#parser.add_argument('tpath', help='Path of the gremlin.sh script, so correct Titan jars can be found.')
(options, args) = parser.parse_args()
if len(args) != 1:
    parser.error("incorrect number of arguments")
tpath = args[0]
abspath = path.abspath(tpath)
joinpath = path.abspath(path.join(abspath, '../lib/*.jar'))
copypath = path.abspath(path.join(abspath, '../lib/'))
#extpath = path.abspath(path.join(abspath, '../ext/*.jar')) 
titanJarsAndDires = glob.glob(joinpath) #+ glob.glob(extpath)
hadoopJarsAndDires = subprocess.Popen(["hadoop", "classpath"], stdout=subprocess.PIPE).communicate()[0].strip().split(':')
#hadoopJars = subprocess.check_output(['hadoop', 'classpath']).strip().split(':')
#hbaseJars = subprocess.check_output(['hbase', 'classpath']).strip().split(':')
hbaseJarsAndDires = subprocess.Popen(["hbase", "classpath"], stdout=subprocess.PIPE).communicate()[0].strip().split(':')

totalJars = [ jar for jar in titanJarsAndDires if (path.isfile(jar))]
#totalDires = [ dire for dire in titanJarsAndDires if path.isdir(dire) ]
hadoopJars = [ jar for jar in hadoopJarsAndDires if path.isfile(jar) ]
#hadoopDires = [ dire for dire in hadoopJarsAndDires if path.isdir(dire) ]
hbaseJars = [ jar for jar in hbaseJarsAndDires if path.isfile(jar) ]
#hbaseDires = [ dire for dire in hbaseJarsAndDires if path.isdir(dire) ]
totalJarNames = [ path.split(jar)[1] for jar in totalJars if getNameOnly(path.split(jar)[1]) != "hadoop-core" ]
totalJarNamesOnly = [ getNameOnly(jarname) for jarname in totalJarNames ]
hadoopJarNames = [ path.split(path.abspath(jar))[1] for jar in hadoopJars ]
hadoopJarNamesOnly = [ getNameOnly(jarname) for jarname in hadoopJarNames ]
hbaseJarNames = [ path.split(path.abspath(jar))[1] for jar in hbaseJars ]
hbaseJarNamesOnly = [ getNameOnly(jarname) for jarname in hbaseJarNames ]

# loop over Titan jars
for i, name in enumerate(totalJarNamesOnly):
    # if in the hadoop Jars, copy over the one from the hadoop jar
    if name in hadoopJarNamesOnly:
        replaceIndex = hadoopJarNamesOnly.index(name)
        subprocess.check_call(["cp", hadoopJars[replaceIndex], copypath])
        subprocess.check_call(["rm", totalJars[i]])
    if name in hbaseJarNamesOnly:
        #print 'replacing ', name, ' with one from hbase'
        replaceIndex = hbaseJarNamesOnly.index(name)
        subprocess.check_call(["cp", hbaseJars[replaceIndex], copypath])
        subprocess.check_call(["rm", totalJars[i]])
# add all other jars from hadoop and hbase classpaths?
for i, name in enumerate(hadoopJarNamesOnly):
    if name not in totalJarNamesOnly:
        #print 'adding ', name, ' from hadoop'
        subprocess.check_call(["cp", hadoopJars[i], copypath])
for i, name in enumerate(hbaseJarNamesOnly):
    if name not in totalJarNamesOnly:
        #print 'adding ', name, ' from hbase'
        subprocess.check_call(["cp", hbaseJars[i], copypath])
