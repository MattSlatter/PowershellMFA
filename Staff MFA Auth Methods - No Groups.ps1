$FilePath = "c:\Temp\UserAuthMethods.csv"                              # Path to Results File 

if(!(Get-Module -ListAvailable -Name MSOnline)){                       # Check if required PS Module is install and if not, install it. 
    Install-mMdule MSOnline   
}


Connect-MsolService                                                     # Connect to Azure - Hash this out if you've run recently to save logging in every time
$MFAAuthMethods = [System.Collections.ArrayList]::new()                 # List of all users Auth Methods
  

$AllStaff = Get-MsolUser -all | Where-Object {$_.UserPrincipalName -notmatch("^\d")} # Get All users that don't start with a number

$AllStaff.foreach{                                                  # For Each Staff Memeber
    $entry = [PSCustomObject]@{                                     # Create an Object that will form each line of the Output CSV
        User = $_.UserPrincipalName                                 # Default all AUth Methdos to "null". They will only get updated if the relevent method exists in the $User Object 
        PhoneAppNotification = "Null"
        PhoneAppOTP = "Null"
        OneWaySMS = "Null"
        TwoWayVoiceMobile = "Null"
        TwoWayVoiceAlternateMobile = "Null"
        TwoWayVoiceOffice = "Null"
    }
    if ($_.StrongAuthenticationMethods.count -gt 0){             # If the user has set up MFA (so more than 0 authMethds Exist)
        $AuthMthods = $_.StrongAuthenticationMethods             # Get their MFA Auth Methods
        for ($i=0; $i -lt $_.StrongAuthenticationMethods.count; $i++) {      # For Each Method
            $entry.($AuthMthods[$i].MethodType) = $AuthMthods[$i].IsDefault     # Update the method type with either True or False (i.e. is default method or not)                 
        }
    }
    $null = $MFAAuthMethods.Add($entry)                             # Add user object to list
}

$MFAAuthMethods | Export-Csv $FilePath -NoTypeInformation           # Export List of Auth Methds to Results File as a CSV
