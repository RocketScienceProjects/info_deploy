# info_deploy

Repository host all the required shell scripts and configurations needed to perform a deployment
orchestration on an Informatica Powercenter.

# To use it via jenkins, there are 2 ways:
1. install the Command line utility on the jenkins agents
2. Perform remote invokation of the scripts from the Informatica server

I am using the option #1.

The script 'Deployment.sh' is a simple shell script that invokes a series of commands based on the Action selected. Before any action is executed the 'pmrep connect' command is invoked. This is just the way how the pmrep/Informatica Powercenter works.

# Some available Actions in the 'Deployment.sh' script:

- DG_DELETE  -- Delete deployment group
- DG_CLEAR   -- Clear content of a deployment group
- DG_CREATE  -- Create deployment group
- DG_C_A_D   -- This is a series of actions. Deployment group Create, Add objects and Deplo DG
- DG_ADD     -- Add objects to a deployment group
- DG_DEPLOY  -- Deploy a deployment group
- LB_CREATE  -- Create a Label
- LB_ADD     -- Add a Label
- LB_DELETE  -- Delete a Label

# Each file plays an important part:
Deployment.sh  --> The main shell script
deploymentGroupsList.txt  --> The file that should be entered with the list of DG names to be deleted at once
DeployOptions.xml  --> This is more or less the control file for the deployment process
environmental_variables.env  --> The file which should have all the valuable information for the pmrep command to be executed successfully by the user used to invoke this scripts
Groups_Lst.txt   --> This file will have the list of Groups and the permissions that we will be set to the DG's
Mig_Inventory_list.csv  --> This CSV file will have the objects that will be deployed
