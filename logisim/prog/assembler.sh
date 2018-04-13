#!/bin/bash

LABELFILE=$( mktemp )
TMPFILE=$( mktemp )

awk -v lfile=$LABELFILE >$TMPFILE '
BEGIN {
    addr=0;
    ass["INBOX"]="00";   i["INBOX"]=1;
    ass["OUTBOX"]="10";  i["OUTBOX"]=1;
    ass["COPYFROM"]="20";i["COPYFROM"]=2;
    ass["COPYTO"]="30";  i["COPYTO"]=2;
    ass["ADD"]="40";     i["ADD"]=2;
    ass["SUB"]="50";     i["SUB"]=2;
    ass["BUMP+"]="60";   i["BUMP+"]=2;
    ass["BUMP-"]="70";   i["BUMP-"]=2;
    ass["JUMP"]="80";    i["JUMP"]=2;
    ass["JUMPZ"]="90";   i["JUMPZ"]=2;
    ass["JUMPN"]="A0";   i["JUMPN"]=2;
    ass["SET"]="E0";     i["SET"]=2;
    ass["HALT"]="F0";    i["HALT"]=1;
}

{
    if( $0 ~ /:/ ) { 
        sub( ":", "", $0 );
        labelAddr[$0]=addr;
        printf("%s:\n",$0);
    }
    else {
        printf("  %02x: %s %-2s ; %s\n",addr,ass[$1],$2,$0);
        addr+=i[$1];
    }
}

END { 
    for (label in labelAddr)
       { printf("%s %02x\n", label, labelAddr[label]) >> lfile } ; 
}

'

echo "labels:"
cat $LABELFILE
echo

cat $LABELFILE | while read LABEL ADDR 
do
   sed -i -e "s/ $LABEL / $ADDR /" $TMPFILE
done

cat $TMPFILE

echo $LABELFILE $TMPFILE

