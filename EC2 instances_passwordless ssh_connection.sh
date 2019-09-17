#!/bin/bash
#Author: Sandip Saha
#This script will establish password-less SSH between EC2 instances.
#Please transfer .pem file to your HOME Directory same as this Script. It has been considered you have used same .pem file for all your instances 
#Please create Instance_IP_Details.txt in your HOME Directory, and list the IP-Details of your instances here. Note: 1st Instance IP-Address will be considered as host node.
#We will use ubuntu user for this purpose.
pem_file_path="`pwd`/`ls|grep -i *.pem`"
chmod 600 "$pem_file_path"
i=0
counter=1
while read -r instance_ip|| [[ -n $instance_ip ]];
do
	instance_ip_list[$i]="ubuntu@$instance_ip"
    i=`expr $i + 1`
done<Instance_IP_Details.txt
echo "Generating RSA Key pair in host node server if not already exists"
yes ~/.ssh/id_rsa | ssh-keygen -t rsa -N '' > /dev/null
i=0
for i in ${instance_ip_list[@]:1}
do
    echo "Checking SSH Password-less Login status for Instance-$counter..."
	ssh -o BatchMode=yes $i exit > /dev/null 2>&1 
	if [ $? == 0 ]
	then
		echo "Test Connection Successful..."
	else
		sleep 2
		echo "Creating SSH Password-less Login for Instance-$counter:"
		sleep 1		
		ssh-agent bash -c "ssh-add $pem_file_path; ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no $i" > /dev/null 2>&1
		sleep 1
		ssh -q $i exit > /dev/null 2>&1	
		if [ $? == 0 ]
        then 
				echo "Password-less connection has been established successfully."
		else     
				echo "Please try to set it up manually!"
				exit			
		fi
	fi
	counter=`expr $counter + 1`
done
