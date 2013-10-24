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
extpath = path.abspath(path.join(abspath, '../ext/*.jar')) 
titanJarsAndDires = glob.glob(joinpath) + glob.glob(extpath)
hadoopJarsAndDires = subprocess.Popen(["hadoop", "classpath"], stdout=subprocess.PIPE).communicate()[0].strip().split(':')
#hadoopJars = subprocess.check_output(['hadoop', 'classpath']).strip().split(':')
#hbaseJars = subprocess.check_output(['hbase', 'classpath']).strip().split(':')
hbaseJarsAndDires = subprocess.Popen(["hbase", "classpath"], stdout=subprocess.PIPE).communicate()[0].strip().split(':')

totalJars = [ jar for jar in titanJarsAndDires if (path.isfile(jar))]
totalDires = [ dire for dire in titanJarsAndDires if path.isdir(dire) ]
hadoopJars = [ jar for jar in hadoopJarsAndDires if path.isfile(jar) ]
hadoopDires = [ dire for dire in hadoopJarsAndDires if path.isdir(dire) ]
hbaseJars = [ jar for jar in hbaseJarsAndDires if path.isfile(jar) ]
hbaseDires = [ dire for dire in hbaseJarsAndDires if path.isdir(dire) ]
totalJarNames = [ path.split(jar)[1] for jar in totalJars if getNameOnly(path.split(jar)[1]) != "hadoop-core" ]
totalJarPaths = [ path.split(jar)[0] for jar in totalJars if getNameOnly(path.split(jar)[1]) != "hadoop-core" ]
totalJarNamesOnly = [ getNameOnly(jarname) for jarname in totalJarNames ]
totalJarVersionsOnly = [ getVersionOnly(jarname) for jarname in totalJarNames ]
hadoopJarNames = [ path.split(path.abspath(jar))[1] for jar in hadoopJars ]
hadoopJarPaths = [ path.split(path.abspath(jar))[0] for jar in hadoopJars ]
hadoopJarNamesOnly = [ getNameOnly(jarname) for jarname in hadoopJarNames ]
hadoopJarVersionsOnly = [ getVersionOnly(jarname) for jarname in hadoopJarNames ]
hbaseJarNames = [ path.split(path.abspath(jar))[1] for jar in hbaseJars ]
hbaseJarPaths = [ path.split(path.abspath(jar))[0] for jar in hbaseJars ]
hbaseJarNamesOnly = [ getNameOnly(jarname) for jarname in hbaseJarNames ]
hbaseJarVersionsOnly = [ getVersionOnly(jarname) for jarname in hbaseJarNames ]

for i, name in enumerate(totalJarNamesOnly):
    if name in hadoopJarNamesOnly:
        #print 'replacing ', name, ' with one from hadoop'
        replaceIndex = hadoopJarNamesOnly.index(name)
        totalJarPaths[i] = hadoopJarPaths[replaceIndex]
        totalJarNames[i] = '-'.join((hadoopJarNamesOnly[replaceIndex], hadoopJarVersionsOnly[replaceIndex]))
    if name in hbaseJarNamesOnly:
        #print 'replacing ', name, ' with one from hbase'
        replaceIndex = hbaseJarNamesOnly.index(name)
        totalJarPaths[i] = hbaseJarPaths[replaceIndex]
        totalJarNames[i] = '-'.join((hbaseJarNamesOnly[replaceIndex], hbaseJarVersionsOnly[replaceIndex]))
for i, name in enumerate(hadoopJarNamesOnly):
    if name not in totalJarNamesOnly:
        #print 'adding ', name, ' from hadoop'
        totalJarNames.append(hadoopJarNames[i])
        totalJarPaths.append(hadoopJarPaths[i])
for i, name in enumerate(hbaseJarNamesOnly):
    if name not in totalJarNamesOnly:
        #print 'adding ', name, ' from hbase'
        totalJarNames.append(hbaseJarNames[i])
        totalJarPaths.append(hbaseJarPaths[i])

totalDireNames = [ path.split(dire)[1] for dire in totalDires ]
totalDirePaths = [ path.split(dire)[0] for dire in totalDires ]
totalDireNamesOnly = [ getNameOnly(direname) for direname in totalDireNames ]
totalDireVersionsOnly = [ getVersionOnly(direname) for direname in totalDireNames ]
hadoopDireNames = [ path.split(path.abspath(dire))[1] for dire in hadoopDires ]
hadoopDirePaths = [ path.split(path.abspath(dire))[0] for dire in hadoopDires ]
hadoopDireNamesOnly = [ getNameOnly(direname) for direname in hadoopDireNames ]
hadoopDireVersionsOnly = [ getVersionOnly(direname) for direname in hadoopDireNames ]
hbaseDireNames = [ path.split(path.abspath(dire))[1] for dire in hbaseDires ]
hbaseDirePaths = [ path.split(path.abspath(dire))[0] for dire in hbaseDires ]
hbaseDireNamesOnly = [ getNameOnly(direname) for direname in hbaseDireNames ]
hbaseDireVersionsOnly = [ getVersionOnly(direname) for direname in hbaseDireNames ]

for i, name in enumerate(totalDireNamesOnly):
    if name in hadoopDireNamesOnly:
        #print 'replacing ', name, ' with one from hadoop'
        replaceIndex = hadoopDireNamesOnly.index(name)
        totalDirePaths[i] = hadoopDirePaths[replaceIndex]
        totalDireNames[i] = '-'.join((hadoopDireNamesOnly[replaceIndex], hadoopDireVersionsOnly[replaceIndex]))
    if name in hbaseDireNamesOnly:
        #print 'replacing ', name, ' with one from hbase'
        replaceIndex = hbaseDireNamesOnly.index(name)
        totalDirePaths[i] = hbaseDirePaths[replaceIndex]
        totalDireNames[i] = '-'.join((hbaseDireNamesOnly[replaceIndex], hbaseDireVersionsOnly[replaceIndex]))
for i, name in enumerate(hadoopDireNamesOnly):
    if name not in totalDireNamesOnly:
        #print 'adding ', name, ' from hadoop'
        totalDireNames.append(hadoopDireNames[i])
        totalDirePaths.append(hadoopDirePaths[i])
for i, name in enumerate(hbaseDireNamesOnly):
    if name not in totalDireNamesOnly:
        #print 'adding ', name, ' from hbase'
        totalDireNames.append(hbaseDireNames[i])
        totalDirePaths.append(hbaseDirePaths[i])
        
newclasspath = [ path.join(totalJarPaths[i], name) for i, name in enumerate(totalJarNames) ]
newclasspath += [ path.join(totalDirePaths[i], name) for i, name in enumerate(totalDireNames) ]

print ':'.join(newclasspath)

#for filepath in newclasspath:
#    try:
#        with open(filepath): pass
#    except IOError:
#        print filepath, ' does not exist!'
