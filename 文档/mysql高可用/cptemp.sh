#! /bin/bash  
# check args  
if [ $# -ne 1 ]  
then echo "Usage:$0 PROJECT_NAME" exit  
fi  
PROJ=$1  
# init path  
CURRPATH=`pwd`  
LIBDIR="$CURRPATH/$PROJ/WebRoot/WEB-INF/lib"    
SOURCEDIR="$CURRPATH/$PROJ/src"  
DISTDIR="$CURRPATH/$PROJ/WebRoot/WEB-INF/classes"  
# classpath  
CLASSPATH="$CLASSPATH"  
TMP=$(find $LIBDIR -name "*.jar" | awk '{var=$0":"var;}END{print var;}')  
CLASSPATH="$TMP$CLASSPATH"   
# cleanup  
rm -fr $DISTDIR/*  
# javac  
# CMD="javac -sourcepath $SOURCEDIR -classpath $CLASSPATH -d $DISTDIR `find $SOURCEDIR -name "*.java"` 
# echo "cmd="$CMD  
javac -sourcepath $SOURCEDIR -classpath $CLASSPATH -d $DISTDIR `find $SOURCEDIR -name "*.java"`  
# copy resources  
# mkdir  
cd $SOURCEDIR  
echo "#! /bin/bash" > $CURRPATH/.cptemp  
echo "`find . -type d | awk 'BEGIN{OFS=" "}{dir=substr($0,3);distdir="'"$DISTDIR/"'"dir;print "mkdir -p",distdir;}'`" >> $CURRPATH/.cptemp 
# copy file  
echo "`find . -type f | grep -v '.java' | awk 'BEGIN{OFS=" "}{dir=substr($0,3);sourcedir="'"$SOURCEDIR/"'"dir;distdir="'"$DISTDIR/"'"dir;print "cp",sourcedir,distdir;}'`" >> $CURRPATH/.cptemp 
chmod u+x $CURRPATH/.cptemp  
# execute  
$CURRPATH/.cptemp  
# remove  
rm -f $CURRPATH/.cptemp