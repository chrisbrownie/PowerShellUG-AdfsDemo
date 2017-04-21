<#
.SYNOPSIS
Rebrands AD FS on Windows Server 2012 R2 and greater.

.DESCRIPTION
This script rebrands the Active Directory Federation Services web themes on
Windows Server 2012 R2 and greater. It downloads and updates CSS and JavaScript
content, as well as uploading image assets where appropriate.

Configuration for the script is maintained in the "$params" hashtable at the 
top of the script. 

.EXAMPLE
.\Invoke-AdfsBranding.ps1

.LINK
https://github.com/chrisbrownie/Invoke-AdfsBranding

.NOTES
Written by Chris Brown

License:

The MIT License (MIT)

Copyright (c) 2016 Chris Brown

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the "Software"), to deal 
in the Software without restriction, including without limitation the rights 
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
DEALINGS IN THE SOFTWARE.


#>

[CmdletBinding()]
#requires -version 4
#requires -Modules Adfs
#requires -RunAsAdministrator

$params = @{
    # Script Settings
    "AdfsCustomThemeName" = "CustomTheme1"
    "AdfsAssetsBaseDirectory" = "C:\adfs\assets"
    "AdfsCustomThemeBaseDirectory" = "C:\adfs\themes-working"

    # Global Web Content
    "CertificatePageDescriptionText"                    = $null
    "CompanyName"                                       = "Flaming Keys Lab"
    "ErrorPageAuthorizationErrorMessage"                = $null
    "ErrorPageDescriptionText"                          = "An error occurred."
    "ErrorPageDeviceAuthenticationErrorMessage"         = $null
    "ErrorPageGenericErrorMessage"                      = "An error occurred. Contact your administrator for more information."
    "ErrorPageSupportEmail"                             = "support@lab.flamingkeys.com"
    "HelpDeskLink"                                      = "https://helpdesk.lab.flamingkeys.com/"
    "HelpDeskLinkText"                                  = $null
    "HomeLink"                                          = $null
    "HomeLinkText"                                      = $null
    "PrivacyLink"                                       = "https://lab.flamingkeys.com/privacy-statement"
    "PrivacyLinkText"                                   = "Privacy Statement"
    "SignInPageAdditionalAuthenticationDescriptionText" = $null
    "SignInPageDescriptionText"                         = '<p>Having trouble? Contact the Flaming Keys Lab IT Support Office:</p><p>1800 555 555<br /><a href="mailto:itsupport@lab.flamingkeys.com">itsupport@lab.flamingkeys.com</a>.</p>'
    "SignOutPageDescriptionText"                        = $null
    "UpdatePasswordPageDescriptionText"                 = $null

    "SignInPromptText"                                  = 'Sign in with your Flaming Keys Lab email address and password.'
    "LoginFormatPrompt"                                 = 'Invalid username. Enter your user ID in the format \u0026quot;someone@lab.flamingkeys.com\u0026quot;'
    "UsernamePlaceholder"                               = "someone@lab.flamingkeys.com"
    "HideCopyright"                                     = $true

    # Colours
    "ButtonBackgroundColour"                            = "#008dcb"
    "ButtonForegroundColour"                            = "#ffffff"
    "InputOutlineColour"                                = "#008dcb"
    "LinkColour"                                        = "#008dcb"

    # Images
    "Logo"                                              = "C:\adfs\assets\logo.png"
    "Illustration"                                      = "C:\adfs\assets\illustration.jpg"
    "Favicon"                                           = $null

    }

#region HelperFunctions

function AddOrUpdateTextInFile() {
Param(
    $File,
    [string]$StartString,
    [string]$EndString,
    [string]$ReplacementString
    )
    
    # Source: https://gist.github.com/chrisbrownie/dccdd150e683718d682a0bbbb7e93952

    $fileContent = Get-Content $File -ReadCount 512
    
    if ($fileContent -match [System.Text.RegularExpressions.Regex]::Escape($StartString)) {
        $numberOflines = $fileContent.Length
        
        $startLineNumber = $null
        $endLineNumber = $null

        for ($i=0; $i -lt $numberOflines; $i++) {
            if (-not ($startLineNumber) -and ($fileContent[$i].ToString().Trim() -eq $StartString)) {
                $startLineNumber = $i
            } elseif (-not ($endLineNumber) -and ($fileContent[$i].ToString().Trim() -eq $EndString)) {
                $endLineNumber = $i
            }   
        }

        $FileStartPart = $fileContent[0..($startLineNumber-1)]
        $FileEndPart = $fileContent[($endLineNumber+1)..$numberOflines]
        
        $NewContent = ($FileStartPart +  $ReplacementString + $FileEndPart) -join "`r`n"

        $NewContent | Out-File $File -Encoding ascii

    } else {
        # Could not find the start string, append to the end
        Add-Content -Path $File -Value "`r`n" -Encoding ascii
        Add-Content -Path $File -Value "$StartString`r`n" -Encoding ascii
        Add-Content -Path $file -Value $ReplacementString -Encoding ascii
        Add-Content -Path $File -Value "`r`n$EndString" -Encoding ascii

    }

}

# returns $true if AD FS is running
# returns $false if AD FS is not running or is missing
function Get-AdfsServiceStatus {
    Param($ComputerName = $env:computername)
    
    try {
        if ((Get-Service -Name AdfsSrv -ComputerName $ComputerName).Status -eq "Running") {
            return $true
        } else {
            return $false 
        }
    } catch {
        return $false
    }

}

#endregion

#region Adfs Health Check Prereqs

# Make sure the AD FS services is running before we go any further
if (-not (Get-AdfsServiceStatus)) {
    throw "AD FS is not running or is not accessible on this computer"
}
#endregion Adfs Health Check Prereqs

Import-Module Adfs -Verbose:$false

#region Theme Setup

# Create custom theme
if (Get-AdfsWebTheme -name $params.AdfsCustomThemeName) {
    Write-Verbose "Using existing theme '$($params.AdfsCustomThemeName)'."
    $customTheme = Get-AdfsWebTheme -Name $Params.AdfsCustomThemeName
} else {
    Write-Verbose "Creating theme '$($params.AdfsCustomThemeName)'."
    New-AdfsWebTheme `
        -Name $params.AdfsCustomThemeName `
        -SourceName "Default" `
        | Out-Null

    $customTheme = Get-AdfsWebTheme -Name $Params.AdfsCustomThemeName
}

# Export custom theme to file system
$CustomThemePath = Join-Path $params.AdfsCustomThemeBaseDirectory $params.AdfsCustomThemeName
if (-not (Test-Path $CustomThemePath -ErrorAction SilentlyContinue)) {
    # $CustomThemePath does not exist
    New-Item -Path $CustomThemePath -ItemType Directory | Out-Null
}
Write-Verbose "Exporting theme to '$CustomThemePath'."
Export-AdfsWebTheme -WebTheme $customTheme -DirectoryPath $CustomThemePath

#endregion Theme Setup

#region AdfsGlobalWebContent
# These are the simple modifications that AD FS supports natively, outside of the web theme

Set-AdfsGlobalWebContent `
    -CertificatePageDescriptionText $params.CertificatePageDescriptionText `
    -CompanyName $params.CompanyName `
    -ErrorPageAuthorizationErrorMessage $params.ErrorPageAuthorizationErrorMessage `
    -ErrorPageDescriptionText $params.ErrorPageDescriptionText `
    -ErrorPageDeviceAuthenticationErrorMessage $params.ErrorPageDeviceAuthenticationErrorMessage `
    -ErrorPageGenericErrorMessage $params.ErrorPageGenericErrorMessage `
    -ErrorPageSupportEmail $params.ErrorPageSupportEmail `
    -HelpDeskLink $params.HelpDeskLink `
    -HelpDeskLinkText $params.HelpDeskLinkText `
    -HomeLink $params.HomeLink `
    -HomeLinkText $params.HomeLinkText `
    -PrivacyLink $params.PrivacyLink `
    -PrivacyLinkText $params.PrivacyLinkText `
    -SignInPageAdditionalAuthenticationDescriptionText $params.SignInPageAdditionalAuthenticationDescriptionText `
    -SignInPageDescriptionText $params.SignInPageDescriptionText `
    -SignOutPageDescriptionText $params.SignOutPageDescriptionText `
    -UpdatePasswordPageDescriptionText $params.UpdatePasswordPageDescriptionText

#endregion

# These are the simple modifications that AD FS supports natively, within the web theme
Write-Verbose "Setting AdfsWebTheme illustration and logo."
Set-AdfsWebTheme -TargetName $params.AdfsCustomThemeName `
    -Illustration @{Path=$params.Illustration} `
    -Logo @{Path=$params.Logo}

#region ChangeUsernamePlaceholder

Write-Verbose "Applying Username placeholder"
# Write this JS to the bottom of the CustomThemePath
$UsernamePlaceHolderJs = "var userNameInput = document.getElementById('userNameInput');`r`nif (userNameInput)`r`n{`r`nuserNameInput.placeholder = '$($params.UsernamePlaceholder)';`r`n}"

AddOrUpdateTextInFile -File $(Join-Path $CustomThemePath "script\onload.js") -StartString "//USERNAMEPLACEHOLDER" -EndString "//ENDUSERNAMEPLACEHOLDER" -ReplacementString $UsernamePlaceHolderJs

#endregion

#region ChangeSignInPromptText
Write-Verbose "Applying SignInPromptText"
# Write this JS to the bottom of the CustomThemePath
$SignInPromptTextJs = "var loginMessageDiv = document.getElementById('loginMessage');`r`nif (loginMessageDiv)`r`n{`r`n loginMessageDiv.innerHTML = '$($params.SignInPromptText)';`r`n}"

AddOrUpdateTextInFile -File $(Join-Path $CustomThemePath "script\onload.js") -StartString "//SignInPromptText" -EndString "//ENDSignInPromptText" -ReplacementString $SignInPromptTextJs

#endregion

#region ChangeLoginFormatPrompt
# We need to replace the built in LoginErrors() function with our own:
Write-Verbose "Overriding Login Format Prompt."
$LoginFormatPromptJs = "function LoginErrors(){this.userNameFormatError = '$($Params.LoginFormatPrompt)'; this.passwordEmpty = 'Enter your password.';}"
AddOrUpdateTextInFile -File $(Join-Path $CustomThemePath "script\onload.js") -StartString "//LOGINFORMATPROMPT" -EndString "//LOGINFORMATPROMPT" -ReplacementString $LoginFormatPromptJs
#endregion

#region setfavicon
if ($params.FavIcon) {
    Write-Verbose "Setting favicon"
    # Source: https://gist.github.com/mathiasbynens/428626
    $faviconJs = @"
    document.head || (document.head = document.getElementsByTagName('head')[0]);
    function changeFavicon(src) {
        var link = document.createElement('link'),
            oldLink = document.getElementById('dynamic-favicon');
        link.id = 'dynamic-favicon';
        link.rel = 'icon';
        link.href = src;
        if (oldLink) {
        document.head.removeChild(oldLink);
        }
        document.head.appendChild(link);
    }

    changeFavicon('/adfs/portal/logo/favicon.ico');
"@
    AddOrUpdateTextInFile -File $(Join-Path $CustomThemePath "script\onload.js") -StartString "//STARTfaviconJs" -EndString "//ENDfaviconJs" -ReplacementString $faviconJs
}
#endregion

#region ChangeSignInButtonColour
Write-Verbose "Changing Login button colour."

$buttonColourCss = @"
span.submit, input[type="submit"] {
    background-color: $($params.ButtonBackgroundColour) !important;
    color: @($params.ButtonForegroundColour) !important;
}
"@

AddOrUpdateTextInFile -File $(Join-Path $CustomThemePath "css\style.css") -StartString "/*STARTLOGINBUTTONCSSFIX*/" -EndString "/*ENDLOGINBUTTONCSSFIX*/" -ReplacementString $buttonColourCss

#endregion

#region ChangeInputOutlineColour
Write-Verbose "Changing Input outline colour."

$inputOutlineCss = @"
input {
    outline-color: $($params.InputOutlineColour) !important;
}
"@
AddOrUpdateTextInFile -File $(Join-Path $CustomThemePath "css\style.css") -StartString "/*STARTINPUTOUTLINECSSFIX*/" -EndString "/*ENDINPUTOUTLINECSSFIX*/" -ReplacementString $inputOutlineCss

Remove-Variable -Name buttonColourCss
#endregion

#region HideCopyright
if ($params.HideCopyright) {
    Write-Verbose "Hiding copyright."
    # Search for default copyright string
    $defaultCopyrightString = '#copyright {color:#696969;}'
    $cssPath = $(Join-Path $CustomThemePath "css\style.css")
    (Get-Content $cssPath) | ForEach-Object {
        if ($_.Trim() -eq $defaultCopyrightString) {
            '#copyright {display: none;}'
        } else {
            $_
        }
    } | Set-Content $cssPath


}
#endregion

#region Apply Changes

# Upload web theme
Write-Verbose "Uploading web theme."

$AdditionalFileResources = @{
        Uri = "/adfs/portal/script/onload.js"
        Path = (Join-Path $CustomThemePath "script\onload.js").ToString()
    }

if ($params.FavIcon) {
    # We need to upload the favicon, so add it to the list
     $AdditionalFileResources += @{
         Uri = "/adfs/portal/logo/favicon.ico"
         Path = (Join-Path $CustomThemePath "script\onload.js").ToString()
     }
}


Set-AdfsWebTheme -TargetName $customTheme.Name `
    -StyleSheet @{
        Locale=""
        Path="$(Join-Path $CustomThemePath "css\style.css")"
    } `
    -AdditionalFileResource $AdditionalFileResources

# Activate web theme
Write-Verbose "Activating theme '$($params.AdfsCustomThemeName)'."
Set-AdfsWebConfig -ActiveThemeName $params.AdfsCustomThemeName

#endregion Apply Changes

#region End of script cleanup
Write-Verbose "Cleaning up."
# Clean up the working directory for the theme
Get-Item $CustomThemePath | Remove-Item -Force -Recurse

#endregion

#TODO: Restart AD FS Service on all AD FS servers one after the other, 
# waiting for a resumption of service on previous server before restarting next 