#!/bin/ksh
#####################################################
# Created By: Bastin
# Created Date: Nov 28 2014
# Version: 1.0
# Description: Performs the below list of activities
# 1. Create DG 
# 2. Delete DG
# 3. Add objects to DG 
# 4. Deploy DG 
# 5. Clear DG 
# 6. Create Label 
# 7. Apply Label 
# 8. Delete Label
#####################################################

. /path/Informatica_Migration/Infa_environmental_variables.env

InfaMigPath=$HOME/Scripts/Informatica_Migration
LogFileDir=$InfaMigPath/Logs
date=`date +'%Y-%m-%d %H%M%S'`
LogFileName=Infa_DG_LB_$date.log
export USERNAME=$1
export PASSWORD=$2
export SRC_REP=$3
export TGT_REP=$4
export NAME=$5
export ACTION=$6

##### Nullifying the log file
cat /dev/null>$LogFileDir/$LogFileName

##### Connecting to the Source repository
$PMSERVERDIR/pmrep connect -r $SRC_REP -d $DOMAIN -n $USERNAME -x $PASSWORD -s $USERSECURITYDOMAIN 2>>$LogFileDir/$LogFileName 1>>$LogFileDir/$LogFileName	
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE  >>$LogFileDir/$LogFileName

	if [ $RETURN_CODE == 0 ]
	then 
	echo "Connected to the Repository "$SRC_REP
	echo  
	echo "Connected to the Repository "$SRC_REP >>$LogFileDir/$LogFileName
	else
	echo "Failed to Connect to the Repository "$SRC_REP
	echo "Failed to Connect to the Repository "$SRC_REP >>$LogFileDir/$LogFileName
	echo "Check the log file "$LogFileDir/$LogFileName
	echo 
	exit 1
	fi

##### Delete the existing deployment group 
if [ "$ACTION" == DG_DELETE ]
then

$PMSERVERDIR/pmrep deletedeploymentgroup -p $NAME -f 2>>$LogFileDir/$LogFileName 1>>$LogFileDir/$LogFileName	
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE  >>$LogFileDir/$LogFileName

	if [ $RETURN_CODE == 0 ]
	then 
	echo "Deleted the Deployment Group "$NAME
	echo  
	echo "Deleted the Deployment Group "$NAME >>$LogFileDir/$LogFileName
	else
	echo "Deployment Group "$NAME " is not present / invalid credentials."
	echo "Deployment Group "$NAME " is not present." >>$LogFileDir/$LogFileName
	echo "Check the log file "$LogFileDir/$LogFileName
	echo 
	exit 1
	fi

fi

##### Clear the objects in the deployment group 
if [ "$ACTION" == DG_CLEAR ]
then

$PMSERVERDIR/pmrep cleardeploymentgroup -p $NAME -f 2>>$LogFileDir/$LogFileName 1>>$LogFileDir/$LogFileName	
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE  >>$LogFileDir/$LogFileName

	if [ $RETURN_CODE == 0 ]
	then 
	echo "Cleared the Deployment Group "$NAME
	echo  
	echo "Cleared the Deployment Group "$NAME >>$LogFileDir/$LogFileName
	else
	echo "Deployment Group "$NAME " is not present / invalid credentials."
	echo "Deployment Group "$NAME " is not present." >>$LogFileDir/$LogFileName
	echo "Check the log file "$LogFileDir/$LogFileName
	echo 
	exit 1
	fi

fi


##### Create a new Depolyment Group 
if [ "$ACTION" == DG_CREATE -o "$ACTION" == DG_C_A_D ]
then

$PMSERVERDIR/pmrep createdeploymentgroup -p $NAME -t static -q DUMMY -u shared 2>>$LogFileDir/$LogFileName 1>>$LogFileDir/$LogFileName	
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE  >>$LogFileDir/$LogFileName

	if [ $RETURN_CODE == 0 ]
	then 
	echo "Created the Deployment Group "$NAME
	echo  
	echo "Created the Deployment Group "$NAME >>$LogFileDir/$LogFileName
	else
	echo "Deployment Group "$NAME " is already available / invalid credentials."
	echo "Deployment Group "$NAME " is already available / invalid credentials." >>$LogFileDir/$LogFileName
	echo "Check the log file "$LogFileDir/$LogFileName
	echo
	exit 1
	fi

##### Assigning permission to different informatica groups. 
echo Assigning permission for $NAME to below list of informatica groups if available.

LST_CNT=`wc -l $InfaMigPath/Informatica_Groups_Lst.txt|awk '{print $1}'`

if [ $LST_CNT == 0 ]
then 
echo Informatica Group list is empty. Not assigning permission to any group. 
else 

while read EachLine
do
var=$(echo $EachLine| awk -F"," '{print $1,$2}')
set -- $var
GRP_NM=$1
ACCESS=$2

$PMSERVERDIR/pmrep AssignPermission -o deploymentgroup -n $NAME -g $GRP_NM -s $USERSECURITYDOMAIN -p $ACCESS 2>>$LogFileDir/$LogFileName 1>>$LogFileDir/$LogFileName	
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE  >>$LogFileDir/$LogFileName

	if [ $RETURN_CODE == 0 ]
	then 
	echo $GRP_NM " - " $ACCESS " permission is given to the Deployment Group "$NAME
	echo $GRP_NM " - " $ACCESS " permission is given to the Deployment Group "$NAME >>$LogFileDir/$LogFileName
	else
	echo "Informatica Group "$GRP_NM " is not available / invalid credentials."
	echo "Informatica Group "$GRP_NM " is not available / invalid credentials." >>$LogFileDir/$LogFileName
	echo "Check the log file "$LogFileDir/$LogFileName
	echo
	exit 1
	fi

done < $InfaMigPath/Informatica_Groups_Lst.txt
fi

fi

##### Add Informatica Objects to the Deployment group. 
if [ "$ACTION" == DG_ADD -o "$ACTION" == DG_C_A_D ]
then

echo Adding objects to the deployment group
date

while read EachLine
do
var=$(echo $EachLine| awk -F"," '{print $1,$2,$3,$4}')
set -- $var
REPO_NM=$1
FLDR_NM=$2
OBJ_TYPE=$3
OBJ_NM=$4

	##### Checking the connected repository and repository name in the inventory list. 	
	if [ "$REPO_NM" != "$SRC_REP" ]
	then
	echo "Connected repository "$SRC_REP" is not equal to the repository name in file "$REPO_NM
	echo "Connected repository "$SRC_REP" is not equal to the repository name in file "$REPO_NM >>$LogFileDir/$LogFileName
	echo 
	exit 1
	fi

$PMSERVERDIR/pmrep addtodeploymentgroup -p $NAME -n $OBJ_NM -o $OBJ_TYPE -f $FLDR_NM -d all 2>>$LogFileDir/$LogFileName 1>>$LogFileDir/$LogFileName
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE >>$LogFileDir/$LogFileName

	if [ $RETURN_CODE == 0 ]
	then 
	echo "Added "$OBJ_NM " to the Deployment Group "$NAME
	echo "Added "$OBJ_NM " to the Deployment Group "$NAME >>$LogFileDir/$LogFileName
	else
	echo "Object name "$OBJ_NM" is not available / invalid credentials."
	echo "Object name "$OBJ_NM" is not available / invalid credentials." >>$LogFileDir/$LogFileName
	echo "Check the log file "$LogFileDir/$LogFileName
	echo
	exit 1
	fi

done < $InfaMigPath/Mig_Inventory_list.csv

echo 
echo "All Objects are added to the deployment Group "$NAME.
date
echo 

fi

##### Deploy the deployment group to the target repository. 
if [ "$ACTION" == DG_DEPLOY -o "$ACTION" == DG_C_A_D ]
then

echo "Starting Deployment of "$NAME" to target Repository "$TGT_REP.
date
$PMSERVERDIR/pmrep deploydeploymentgroup -p $NAME -c $InfaMigPath/DeployOptions.xml -r $TGT_REP -n $USERNAME -s $USERSECURITYDOMAIN -x $PASSWORD -l $LogFileDir/$NAME.log 2>>$LogFileDir/$LogFileName 1>>$LogFileDir/$LogFileName	
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE  >>$LogFileDir/$LogFileName

	if [ $RETURN_CODE == 0 ]
	then 
	echo "Deployment of "$NAME" to target Repository "$TGT_REP" was successful."
	echo 
	echo "Deployment of "$NAME" to target Repository "$TGT_REP" was successful." >>$LogFileDir/$LogFileName
	date
	else
	echo "Deployment of "$NAME" failed."
	echo "Deployment of "$NAME" failed." >>$LogFileDir/$LogFileName
	echo "Check the log file "$LogFileDir/$LogFileName
	echo "Check the deployment log file "$LogFileDir/$NAME.log
	echo
	exit 1
	fi

fi

##### Create a Label 
if [ "$ACTION" == LB_CREATE -o "$ACTION" == LB_C_A ]
then

$PMSERVERDIR/pmrep createlabel -a $NAME 2>>$LogFileDir/$LogFileName 1>>$LogFileDir/$LogFileName	
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE  >>$LogFileDir/$LogFileName

	if [ $RETURN_CODE == 0 ]
	then 
	echo "Created the Label "$NAME
	echo  
	echo "Created the Label "$NAME >>$LogFileDir/$LogFileName
	else
	echo "Label "$NAME " is already available / invalid credentials."
	echo "Label "$NAME " is already available / invalid credentials." >>$LogFileDir/$LogFileName
	echo "Check the log file "$LogFileDir/$LogFileName
	echo
	exit 1
	fi

##### Assigning permission to different informatica groups. 
echo Assigning permission for $NAME to below list of informatica groups.

LST_CNT=`wc -l $InfaMigPath/Informatica_Groups_Lst.txt|awk '{print $1}'`

if [ $LST_CNT == 0 ]
then 
echo Informatica Group list is empty. Not assigning permission to any group. 
else

while read EachLine
do
var=$(echo $EachLine| awk -F"," '{print $1,$2}')
set -- $var
GRP_NM=$1
ACCESS=$2

$PMSERVERDIR/pmrep AssignPermission -o label -n $NAME -g $GRP_NM -s $USERSECURITYDOMAIN -p $ACCESS 2>>$LogFileDir/$LogFileName 1>>$LogFileDir/$LogFileName	
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE  >>$LogFileDir/$LogFileName

	if [ $RETURN_CODE == 0 ]
	then 
	echo $GRP_NM " - " $ACCESS " permission is given to the Label "$NAME
	echo $GRP_NM " - " $ACCESS " permission is given to the Label  "$NAME >>$LogFileDir/$LogFileName
	else
	echo "Informatica Group "$GRP_NM " is not available / invalid credentials."
	echo "Informatica Group "$GRP_NM " is not available / invalid credentials." >>$LogFileDir/$LogFileName
	echo "Check the log file "$LogFileDir/$LogFileName
	echo
	exit 1
	fi

done < $InfaMigPath/Informatica_Groups_Lst.txt

fi

fi

##### Delete a Label 
if [ "$ACTION" == LB_DELETE ]
then

$PMSERVERDIR/pmrep deletelabel -a $NAME -f 2>>$LogFileDir/$LogFileName 1>>$LogFileDir/$LogFileName	
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE  >>$LogFileDir/$LogFileName

	if [ $RETURN_CODE == 0 ]
	then 
	echo "Deleted the Label "$NAME
	echo  
	echo "Deleted the Label "$NAME >>$LogFileDir/$LogFileName
	else
	echo "Label "$NAME " is not available / invalid credentials."
	echo "Label "$NAME " is not available / invalid credentials." >>$LogFileDir/$LogFileName
	echo "Check the log file "$LogFileDir/$LogFileName
	echo
	exit 1
	fi

fi

##### Apply Label to Informatica Objects. 
if [ "$ACTION" == LB_ADD -o "$ACTION" == LB_C_A ]
then

echo Applying label to informatica objects.
date

while read EachLine
do
var=$(echo $EachLine| awk -F"," '{print $1,$2,$3,$4}')
set -- $var
REPO_NM=$1
FLDR_NM=$2
OBJ_TYPE=$3
OBJ_NM=$4

	##### Checking the connected repository and repository name in the inventory list. 	
	if [ "$REPO_NM" != "$SRC_REP" ]
	then
	echo "Connected repository "$SRC_REP" is not equal to the repository name in file "$REPO_NM
	echo "Connected repository "$SRC_REP" is not equal to the repository name in file "$REPO_NM >>$LogFileDir/$LogFileName
	echo 
	exit 1
	fi

$PMSERVERDIR/pmrep applylabel -a $NAME -n $OBJ_NM -o $OBJ_TYPE -f $FLDR_NM -p children 2>>$LogFileDir/$LogFileName 1>>$LogFileDir/$LogFileName
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE >>$LogFileDir/$LogFileName


	if [ $RETURN_CODE == 0 ]
	then 
	echo "Applied label "$NAME " to the Infa Object "$OBJ_NM
	echo "Applied label "$NAME " to the Infa Object "$OBJ_NM >>$LogFileDir/$LogFileName
	else
	echo "Object name "$OBJ_NM" is not available / invalid credentials."
	echo "Object name "$OBJ_NM" is not available / invalid credentials." >>$LogFileDir/$LogFileName
	echo "Check the log file "$LogFileDir/$LogFileName
	echo
	exit 1
	fi

done < $InfaMigPath/Mig_Inventory_list.csv

echo 
echo "Label is applied to all available Informatica Objects"
date
echo 

fi

exit 0

