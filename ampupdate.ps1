# Execute the command and store the output in a variable
$ampOutput = & ampinstmgr -l

if ($null -eq $ampOutput) {
    Write-Host "No output from ampinstmgr -l command"
    break
}

# Print the ampOutput variable
#Write-Host "ampOutput: $ampOutput"

# Split the output into lines
$lines = $ampOutput -split "\r?\n"

# Create empty arrays to store instance names
$instanceNames = @()
$adsInstanceName = ""

# Initialize state variables
$currentInstanceName = ""
$isAdsInstance = $false

# Parse each line
foreach ($line in $lines) {
    # Print each line
    # Write-Host "Line: $line"

    # Split the line into key and value
    $parts = $line -split '│'

    if ($parts.Count -lt 2) {
        #Write-Host "Skipping line due to insufficient parts: $line"
        
        # When encountering a blank or invalid line, if we have an instance name, store it appropriately
        if ($currentInstanceName -ne "") {
            if ($isAdsInstance) {
                $adsInstanceName = $currentInstanceName
            } else {
                $instanceNames += $currentInstanceName
            }
        }

        # Reset state variables for next instance
        $currentInstanceName = ""
        $isAdsInstance = $false
        continue
    }

    # Trim whitespace from key and value
    $key = $parts[0].Trim()
    $value = $parts[1].Trim()

    # If the key is "Module" and value is "ADS", mark this as the ADSInstance
    if ($key -eq "Module" -and $value -eq "ADS") {
        $isAdsInstance = $true
    } elseif ($key -eq "Instance Name") {
        $currentInstanceName = $value
    }
}

# Handle the last instance
if ($currentInstanceName -ne "") {
    if ($isAdsInstance) {
        $adsInstanceName = $currentInstanceName
    } else {
        $instanceNames += $currentInstanceName
    }
}

# Print the adsInstanceName variable
#Write-Host "adsInstanceName: $adsInstanceName"

# Print the instanceNames array
#Write-Host "instanceNames: $($instanceNames -join ', ')"

# Stop all other instances
foreach ($instanceName in $instanceNames) {
    #Write-Host "Stopping instance: $instanceName"
    if ($null -ne $instanceName) {
        & ampinstmgr -o $instanceName
    }
}

# Stop the ADS instance
Write-Host "Stopping ADS instance: $adsInstanceName"
if ($null -ne $adsInstanceName) {
    & ampinstmgr -o $adsInstanceName
}



Write-Host "Downloading latest AMP installer..."
Invoke-WebRequest -Uri https://cubecoders.com/Downloads/AMPSetup.msi -OutFile AMPSetup.msi

Write-Host "Running AMP installer..."
./AMPSetup.msi /qn

Write-Host "Sleeping for 5 seconds..."
Start-Sleep -Seconds 5

Write-Host "Updating all instances..."
ampinstmgr upgradeall

Write-Host "Sleeping for 5 seconds..."
Start-Sleep -Seconds 5

Write-Host "Starting AMP..."
ampinstmgr -b

