@echo off
..\..\apache\php\php.exe rcs.php -h=%UPTIME_HOSTNAME% -p=%UPTIME_AGENT_PORT% -s=%UPTIME_PASSWORD% -c="CheckSchedTask" -a=%UPTIME_TASKNAME%
