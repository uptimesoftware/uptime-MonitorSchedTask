-----------------------
Windows Scheduled Task Monitor
-----------------------
This monitor will allow you to check the Current Status of a Windows Scheduled Task, along with the time & status of it's last run.
-----------------------

This monitor relies on an agent side vbs script to check the status of the Scheduled Task via the windows Schtasks /query command. 

The monitor requires the following input values:

up.time Agent Password
Task Name (Note on Win7/2k8 the task name is foldername + task name. ie. \Microsoft\Windows\Autochk\Proxy)

The monitor return the following output:

Selected: Task Name: \TestTask
Task Status: Ready
Task Last Run time: 3/29/2013 8:31:18 AM
Task Last Run Status: 0

Possible outcomes for the 'Task Last Run Status' field are:
'If Selected Task Last Result is a 1, send back a critical status.
'If Selected Task Last Result is a 0, send back a OK status.
'If Selected Task Last Result is a N/A, send back a OK status (We can add in other checks like if
'next run is in the next 15 minutes or so, do something, else send back an unknown.  For now, this.
'If Selected Task Last Result is anything else, send back a UNKNOWN status.



Steps for deploying the agent side script:
1. Place the CheckSched.vbs in the scripts directory where your up.time agent is installed (ie. C:\Program Files (x86)\uptime software\up.time agent\scripts\)
2. Open the up.time Agent Console (Start > up.time Agent).
3. Set a Password for the agent and click on the Save button (restart the agent for the change to take effect). It should only take about a second for the agent to restart and there should be no outage during this period.
4. Click on Advanced > Custom Scripts, and add a new custom script with the following values(you may need to change the path depending on where you placed the .vbs script during step 1)

Command: CheckSchedTask
Script: cscript //nologo "C:\Program Files (x86)\uptime software\up.time agent\scripts\CheckSched.vbs"

5. After adding the custom script(s) to the list, click on the Close button and it will ask to restart the agent, click Yes. Changes only go into effect once the agent is restarted.