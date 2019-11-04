# AWS_AZURE_CLIENT

This repository was created to allow the AXC F 2152 connection to AWS or Azure. (Write only)

REQUIRED HARDWARE:
===============================================================================
-AXC F 2152 (Firmware MUST be 2019.6 or newer)

-Minimum 2GB Memory stick for AXC F 2152 (Part# 1043501 or 1061701)

For this repositiory, ensure a root user has been created.

For this repository, ensure that the AXC F 2152 has an internet connection.

Download this repository to your PC, and using WINSCP copy AzureAwsSetup.sh to the /opt/plcnext/ folder of the PLCNext.

Below explains the additional files needed for the shell script to function properly.
============================================================================
AWS:
-----------------------------------------------------------------------------
A folder with the AWS certificates on the AXC F 2152 in the opt/plcnext/ directory. 
The folder name MUST be named AWSCerts. It is case sensitive. 

There must be at least 3 files within this folder. 
1: <filename>.pem file 
2: <security certname>-certificate.pem 
3: <security certname>-private.pem.key

Azure:
------------------------------------------------------------------------------
No additional files needed.

Download:
==============================================================================
After all necessary files have been added to the /opt/plcnext/ directory of the controller:

Log into root user, execute chmod -c 755 AzureAwsSetup.sh and bash AzureAwsSetup.sh (./AzureAwsSetup.sh), and follow the commands in the command line. 

After script completion:
==============================================================================
Import the PLCnext Engineer library into a PLCnext Engineer project (or use test projects given in PLCnext file folder).

Read the help file attached to the library for additional guidance. 

