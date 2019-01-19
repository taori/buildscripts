# AppVeyor utilities by Andreas Müller
[cmdletbinding()]
param()


function Custom-Nuget-PushOrAdd {
    [cmdletbinding()]
    param (
        [Parameter(Position=0, Mandatory=0,ValueFromPipeline=$true)]
        [string]$nupkg,
        [string]$packageName,
        [string]$apiKey,
        [string]$source
    )
    process {
        $statusCode = Custom-GetHttpStatusCode("https://www.nuget.org/packages/$packageName/")
        
        if($statusCode -eq 200){
            nuget push $nupkg -ApiKey $apiKey -Source $source
        } elseif($statusCode -eq 404) {
            nuget add $nupkg -ApiKey $apiKey -Source $source
        } else {
            Write-Host -ForegroundColor Red "Destination unavailable"
        }
    }
}

function Custom-GetHttpStatusCode {
    [cmdletbinding()]
    param (
        [Parameter(Position=0, Mandatory=1,ValueFromPipeline=$true)]
        [string]$url
    )
    
    $req = [system.Net.WebRequest]::Create($url)

    try {
        $res = $req.GetResponse()
    } 
    catch [System.Net.WebException] {
        $res = $_.Exception.Response
    }

    return [int]$res.StatusCode
}

function CsProj-GetVersionPrefix {
    [cmdletbinding()]
    param (
        [Parameter(Position=0, Mandatory=1,ValueFromPipeline=$true)]
        [string] $file,
        [Parameter(Position=1, Mandatory=0)]
        [switch] $isFile = $true
    )

    if($isFile){
        return Select-Xml -Path $file -XPath //Project/PropertyGroup/VersionPrefix | Select -ExpandProperty Node | Select -Expand '#text'
    }
    else{
        return Select-Xml -Content $file -XPath //Project/PropertyGroup/VersionPrefix | Select -ExpandProperty Node | Select -Expand '#text'
    }

}

function CsProj-GetVersionSuffix {
    [cmdletbinding()]
    param (
        [Parameter(Position=0, Mandatory=1,ValueFromPipeline=$true)]
        [string] $file,
        [Parameter(Position=1, Mandatory=0)]
        [switch] $isFile = $true
    )
    
    if($isFile){
        return Select-Xml -Path $file -XPath //Project/PropertyGroup/VersionSuffix | Select -ExpandProperty Node | Select -Expand '#text'
    }
    else{
        return Select-Xml -Content $file -XPath //Project/PropertyGroup/VersionSuffix | Select -ExpandProperty Node | Select -Expand '#text'
    }
}

function CsProj-GetVersion {
    [cmdletbinding()]
    param (
        [Parameter(Position=0, Mandatory=1,ValueFromPipeline=$true)]
        [string] $file,
        [Parameter(Position=1, Mandatory=0)]
        [switch] $isFile = $true
    )

    if($isFile){
        return Select-Xml -Path $file -XPath //Project/PropertyGroup/Version | Select -ExpandProperty Node | Select -Expand '#text'
    }
    else{
        return Select-Xml -Content $file -XPath //Project/PropertyGroup/Version | Select -ExpandProperty Node | Select -Expand '#text'
    }    
}

function Custom-GetPaddedBuildNumber {
    [cmdletbinding()]
    param (
        [Parameter(Position=0, Mandatory=0,ValueFromPipeline=$true)]
        [int] $length = 5
    )
    
    if($length -eq 0){
        return ([int]$env:appveyor_build_number)
    }
    if($length -eq 1){
        return ([int]$env:appveyor_build_number).ToString("0")
    }
    if($length -eq 2){
        return ([int]$env:appveyor_build_number).ToString("00")
    }
    if($length -eq 3){
        return ([int]$env:appveyor_build_number).ToString("000")
    }
    if($length -eq 4){
        return ([int]$env:appveyor_build_number).ToString("0000")
    }
    if($length -eq 5){
        return ([int]$env:appveyor_build_number).ToString("00000")
    }
    if($length -eq 6){
        return ([int]$env:appveyor_build_number).ToString("000000")
    }
    if($length -eq 7){
        return ([int]$env:appveyor_build_number).ToString("0000000")
    }
    if($length -eq 8){
        return ([int]$env:appveyor_build_number).ToString("00000000")
    }
}