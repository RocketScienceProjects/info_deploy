#!/bin/bash

#Sourcing the env variable for the user executing the script
source ./environmental_variables.env

#Defining VARIABLES to be used in the script
InfaMigPath=$(pwd)
echo "$InfaMigPath"


#Setting the parameters passed in the script as env variables for the session
export USERNAME=$1
export PASSWORD=$2
export SRC_REP=$3
export TGT_REP=$4
export NAME=$5
export ACTION=$6


##### Connecting to the Source repository, $DOMAIN defined in the env file
echo "Connecting to the Repository "$SRC_REP
pmrep connect -r $SRC_REP -d $DOMAIN -n $USERNAME -x $PASSWORD -s $USERSECURITYDOMAIN
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE

	if [ $RETURN_CODE == 0 ]
	then
	echo "Connected to the Repository "$SRC_REP
	echo
	echo "Connected to the Repository "$SRC_REP
	else
	echo "Failed to Connect to the Repository "$SRC_REP
	echo
	exit 1
	fi


##### Delete the existing deployment group,
##### the list should be provided via the file deploymentGroupsList.txt
if [ "$ACTION" == DG_DELETE ]
then

while read EachLine
	do
		var=$(echo $EachLine| awk -F"," '{print $1}')
		set -- $var
		DG_NAME=$1


echo "Deleting the Deployment Group "$DG_NAME
pmrep deletedeploymentgroup -p $DG_NAME -f
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE

	if [ $RETURN_CODE == 0 ]
	then
	echo "Deleted the Deployment Group "$DG_NAME
	echo
	echo "Deleted the Deployment Group "$DG_NAME
	else
	echo "Deployment Group "$DG_NAME " is not present / invalid credentials."
	echo "Deployment Group "$DG_NAME " is not present."
	echo
	exit 1
	fi

done < $InfaMigPath/deploymentGroupsList.txt

fi

##### Clear the objects in the deployment group
if [ "$ACTION" == DG_CLEAR ]
then

pmrep cleardeploymentgroup -p $NAME -f
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE

	if [ $RETURN_CODE == 0 ]
	then
	echo "Cleared the Deployment Group "$NAME
	echo
	echo "Cleared the Deployment Group "$NAME
	else
	echo "Deployment Group "$NAME " is not present / invalid credentials."
	echo "Deployment Group "$NAME " is not present."
	echo
	exit 1
	fi

fi


##### Create a new Depolyment Group
if [ "$ACTION" == DG_CREATE -o "$ACTION" == DG_C_A_D ]
then

pmrep createdeploymentgroup -p $NAME -t static -q DUMMY -u shared
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE

	if [ $RETURN_CODE == 0 ]
	then
	echo "Created the Deployment Group "$NAME
	echo
	else
	echo "Deployment Group "$NAME " is already available / invalid credentials."
	echo
	exit 1
	fi

##### Assigning permission to different informatica groups.
echo Assigning permission for $NAME to below list of informatica groups if available.

LST_CNT=`wc -l $InfaMigPath/Groups_Lst.txt|awk '{print $1}'`

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

pmrep AssignPermission -o deploymentgroup -n $NAME -g $GRP_NM -s $USERSECURITYDOMAIN -p $ACCESS
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE

	if [ $RETURN_CODE == 0 ]
	then
	echo $GRP_NM " - " $ACCESS " permission is given to the Deployment Group "$NAME
	else
	echo "Informatica Group "$GRP_NM " is not available / invalid credentials."
	echo "Check the log file "$LogFileDir/$LogFileName
	echo
	exit 1
	fi

done < $InfaMigPath/Groups_Lst.txt
fi

fi

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

	if [ "$REPO_NM" != "$SRC_REP" ]
	then
	echo "Connected repository "$SRC_REP" is not equal to the repository name in file "$REPO_NM
	echo
	exit 1
	fi

pmrep addtodeploymentgroup -p $NAME -n $OBJ_NM -o $OBJ_TYPE -f $FLDR_NM -d all
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE

	if [ $RETURN_CODE == 0 ]
	then
	echo "Added "$OBJ_NM " to the Deployment Group "$NAME
	else
	echo "Object name "$OBJ_NM" is not available / invalid credentials."
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
pmrep deploydeploymentgroup -p $NAME -c $InfaMigPath/DeployOptions.xml -r $TGT_REP -n $USERNAME -s $USERSECURITYDOMAIN -x $PASSWORD
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE
	if [ $RETURN_CODE == 0 ]
	then
	echo "Deployment of "$NAME" to target Repository "$TGT_REP" was successful."
	echo
	date
	else
	echo "Deployment of "$NAME" failed."
	echo
	exit 1
	fi

fi

##### Create a Label
if [ "$ACTION" == LB_CREATE -o "$ACTION" == LB_C_A ]
then

pmrep createlabel -a $NAME
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE

	if [ $RETURN_CODE == 0 ]
	then
	echo "Created the Label "$NAME
	echo
	echo "Created the Label "$NAME >>$LogFileDir/$LogFileName
	else
	echo "Label "$NAME " is already available / invalid credentials."
	echo "Check the log file "$LogFileDir/$LogFileName
	echo
	exit 1
	fi

##### Assigning permission to different informatica groups.
echo Assigning permission for $NAME to below list of informatica groups.

LST_CNT=`wc -l $InfaMigPath/Groups_Lst.txt|awk '{print $1}'`

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

pmrep AssignPermission -o label -n $NAME -g $GRP_NM -s $USERSECURITYDOMAIN -p $ACCESS
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE

	if [ $RETURN_CODE == 0 ]
	then
	echo $GRP_NM " - " $ACCESS " permission is given to the Label "$NAME
	else
	echo "Informatica Group "$GRP_NM " is not available / invalid credentials."
	echo "Check the log file "$LogFileDir/$LogFileName
	echo
	exit 1
	fi

done < $InfaMigPath/Groups_Lst.txt

fi

fi

##### Delete a Label
if [ "$ACTION" == LB_DELETE ]
then

pmrep deletelabel -a $NAME -f
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE

	if [ $RETURN_CODE == 0 ]
	then
	echo "Deleted the Label "$NAME
	echo
	echo "Deleted the Label "$NAME
	else
	echo "Label "$NAME " is not available / invalid credentials."
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
	echo
	exit 1
	fi

pmrep applylabel -a $NAME -n $OBJ_NM -o $OBJ_TYPE -f $FLDR_NM -p children
RETURN_CODE=$?
echo "RETURN_CODE: "$RETURN_CODE


	if [ $RETURN_CODE == 0 ]
	then
	echo "Applied label "$NAME " to the Infa Object "$OBJ_NM
	else
	echo "Object name "$OBJ_NM" is not available / invalid credentials."
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
