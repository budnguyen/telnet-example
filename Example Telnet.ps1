
Function Get-Telnet
{   
    Param (
        [Parameter(ValueFromPipeline=$true)]
        [String[]]$Commands = @(),
        [string]$RemoteHost = "",
        [string]$Port = "23",
        [int]$WaitTime = 1000,
        [string]$OutputPath = "D:\"
    )
    

    #Attach to the remote device, setup streaming requirements
    $Socket = New-Object System.Net.Sockets.TcpClient($RemoteHost, $Port)
    If ($Socket)
    {   $Stream = $Socket.GetStream()
        $Writer = New-Object System.IO.StreamWriter($Stream)
        $Buffer = New-Object System.Byte[] 1024 
        $Encoding = New-Object System.Text.UTF8Encoding

        
        #Now start issuing the commands
        ForEach ($Command in $Commands)
        {   $Writer.WriteLine($Command) 
            $Writer.Flush()
            Start-Sleep -Milliseconds $WaitTime
        }
        #All commands issued, but since the last command is usually going to be the longest let's wait a little longer for it to finish
        Start-Sleep -Milliseconds ($WaitTime * 4)
        $Result = ""
        
        
        #Save all the results
        While($Stream.DataAvailable) 
        {   $Read = $Stream.Read($Buffer, 0, 1024) 
            $Result += ($Encoding.GetString($Buffer, 0, $Read))
        }
            
        }
    Else     
    {   $Result = "Unable to connect to host: $($RemoteHost):$Port"
    }
    #Done, now save the results to a file
    #Match Hostname in "Result"
    $Result -match "hostname (?<content>.*)"
    #Get Hostname
    $devicename = $matches['content']
    #Get present Date
    $getdate = Get-Date
    #remember to trim when get string from file
    $OutputPath += $devicename.trim() + "_" + $getdate.ToString("ddMMyyyy") + ".txt"

    #Output the result to the string path which defined above
    $Result | Out-File $OutputPath
    
}
Get-Telnet -RemoteHost "IP" -Commands "usr","Pwd", "terminal length 0","sh run","sh star","sh vlan br"
