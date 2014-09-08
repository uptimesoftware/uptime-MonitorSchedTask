':: ******************************************
':: * CheckSched.vbs
':: * Monitor all "scheduled tasks" from a single machine
':: * Returns success status and last run time. 
':: * by Jonathan Best
':: * INPUTS: the name of the scheduled task.  In 7/2008 the name is the foldername+task name.  
':: * for example, \Microsoft\Windows\Autochk\Proxy
':: * OUTPUTS:  
':: * 			Exit Statuses:  0 for OK, 1 for WARNING, 2 for CRITICAL, 3 for UNKNOWN
':: * 			Name, Status, Last run time, Last run result.
':: * NOTES: 
':: * To run, call with "cscript checksched <task to check>"
':: ******************************************
'OPTION EXPLICIT
'Declare variables
Dim objShell
Dim TSKcmd
Dim TASKlines
Dim arrayTasks
Dim Arraysize
Dim TASKline
Dim ArrayCounter
Dim Dict
Dim stdout
Dim stderr

'Make sure we're passing through some command line arguemnts
If WScript.Arguments.Count = 0 Then
	WScript.echo("No command lines passed")
	WScript.Quit(2)
End if
'Initialize Variables
ArrayCounter = 0
Set Dict = CreateObject("Scripting.Dictionary") 
Set fso = CreateObject ("Scripting.FileSystemObject")
Set stdout = fso.GetStandardStream (1)
Set stderr = fso.GetStandardStream (2)

'Build the command.
TSKcmd = "Schtasks  /query /V /FO CSV "

'Create the shell
set objShell = createobject("WScript.shell")

'Run the command.
set TASKlines = objShell.exec("%ComSpec% /c  " & TSKcmd )  

'Break into an array
arrayTasks = Split(TASKlines.StdOut.readall, vbNewLine)
Arraysize = UBOUND(arrayTasks)
'WScript.echo Arraysize

Dim TwoDArray(1000,28)
Dim temparray
'First thing first, break the csv list into separate lines, then break each line down to an array.
for each TASKline in arrayTasks
	'If the line starts with "HOSTNAME" than do nothing.  This removes the column headers
	IF LCase(mid(TASKline,2,8)) = "hostname" THEN
		'do nothing
	ELSE ' Column headers are gone.  Now we have to play with the data.
	
		'WScript.echo "ArrayCounter "& ArrayCounter
		'Strip out the "," sections, replace with ^ due to MS being fucking stupid.  2003 places a , in the
		'date/time area.
		TASKline = Replace(TASKline,""",""","^")
		'WScript.echo "TASKline = " & TASKline
		'stdout.WriteLine ("TASKline = " & TASKline)
		IF TASKline = "" THEN
			Exit For
		End if
		'add to the dictionary
		temparray = Split(TASKline,"^")
		'temparray = Split(TASKline,",")
		'WScript.echo temparray(1)
		If Dict.Exists(temparray(1)) then
		'do nothing, this is a repeat key.  This happens due to each schedule or trigger for a task causes
		'it to show up in the list again.
		Else
			Dict.Add temparray(1), Split(TASKline,"^")
		End if
		'ok, we have all the info we need to do the lookup.
	ArrayCounter = Arraycounter + 1
	END IF
	
next

'Take the command line arguments and do stuff with it.
'There should only be one argument
'WScript.echo WScript.Arguments(0)'
'WScript.echo Dict.Item(WScript.Arguments(0))(2)

'Lets return the selected scheduled task
IF Dict.exists(WScript.Arguments(0)) THEN
	stdout.WriteLine ("Selected Task Name: ") & Dict.Item(WScript.Arguments(0))(1)
	stdout.WriteLine ("TaskStatus ")  & Dict.Item(WScript.Arguments(0))(3)
	stdout.WriteLine ("TaskLastRunTime ") & Dict.Item(WScript.Arguments(0))(5)
	stdout.WriteLine ("TaskLastResult ") & Dict.Item(WScript.Arguments(0))(6)
ELSE
	stdout.WriteLine ("Unable to find """) & WScript.Arguments(0) & (""" as a scheduled task")
	WScript.Quit(3)
END IF

'lets close out what we used
set TASKlines=NOTHING
set objShell=NOTHING
set fso=NOTHING

'Lets send our reply back to uptime
'If Selected Task Last Result is a 1, send back a critical status.
'If Selected Task Last Result is a 0, send back a OK status.
'If Selected Task Last Result is a N/A, send back a OK status (We can add in other checks like if
'next run is in the next 15 minutes or so, do something, else send back an unknown.  For now, this.
'If Selected Task Last Result is anything else, send back a UNKNOWN status.
IF Dict.Item(WScript.Arguments(0))(6) = "1" THEN
	WScript.Quit(2)
ELSEIF Dict.Item(WScript.Arguments(0))(6) = "0" THEN
	WScript.Quit(0)
ELSEIF Dict.Item(WScript.Arguments(0))(6) = "N/A" THEN
	WScript.Quit(0)
ELSE
	WScript.Quit(3)
END IF
