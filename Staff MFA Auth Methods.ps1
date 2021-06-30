$FilePath = "OutputFile.csv"                                           # Path to Results File 
$StaffAzureGroupName = "Group Name"                                    # Name of Azure AD Group

if(!(Get-Module -ListAvailable -Name MSOnline)){                       # Check if required PS Module is install and if not, install it. 
    Install-mMdule MSOnline   
}

#Connect-MsolService                                                     # Connect to Azure - Hash this out if you've run receetly to save logging in
$MFAAuthMethods = [System.Collections.ArrayList]::new()                 # List of all users Auth Methods
  
$StaffAzureGroup = Get-MsolGroup -SearchString $StaffAzureGroupName     #Get Staff Group
$AllStaff = Get-MsolGroupMember -GroupObjectId $StaffAzureGroup.ObjectId  -MemberObjectTypes User   # Get All memeber of Staff Group

$AllStaff.foreach{                                                  # For Each Staff Memeber
    $user = Get-MsolUser -UserPrincipalName $_.EmailAddress         # Get Each User 
    $entry = [PSCustomObject]@{                                     # Create an Object that will form each line of the Output CSV
        User = $user.UserPrincipalName                              # Default all AUth Methdos to "null". They will only get updated if the relevent method exists in the $User Object 
        PhoneAppNotification = "Null"
        PhoneAppOTP = "Null"
        OneWaySMS = "Null"
        TwoWayVoiceMobile = "Null"
        TwoWayVoiceAlternateMobile = "Null"
        TwoWayVoiceOffice = "Null"
    }
    if ($user.StrongAuthenticationMethods.count -gt 0){             # If the user has set up MFA (so more than 0 authMethds Exist)
        $AuthMthods = $user.StrongAuthenticationMethods             # Get their MFA Auth Methods
        for ($i=0; $i -lt $user.StrongAuthenticationMethods.count; $i++) {      # For Each Method
            $entry.($AuthMthods[$i].MethodType) = $AuthMthods[$i].IsDefault     # Update the method type with either True or False (i.e. is default method or not)                 
        }
    }
    $null = $MFAAuthMethods.Add($entry)                             # Add user object to list
}

$MFAAuthMethods | Export-Csv $FilePath -NoTypeInformation           # Export List of Auth Methds to Results File as a CSV
