
<#PSScriptInfo

.VERSION 1.0

.GUID 57ee66e4-3ac2-4bae-87de-a85e13d7f53e

.AUTHOR barbos@inbox.ru

.COMPANYNAME Hothing Ltd

.COPYRIGHT GPL v3

.TAGS 

.LICENSEURI https://www.gnu.org/licenses/gpl-3.0.txt

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 
.SYNOPSIS
The script downloads the audio-books from a site 'Kniga v uhe'(https://knigavuhe.org/) 

.DESCRIPTION 

How to use
1. Open the desired book on the site and copy the URL (for example, https://knigavuhe.org/book/prikljuchenija-kota-akakija-1/)
2. Cover Windows Powershell
3. Go to the download directory, for example
     `cd 'D: \ My Books'`
4. Run the script
     `PS> <path-to-script> \ kniga-v-uhe-dl.ps1 -Uri <Uri>`
    where instead of \ <Uri \> you need to paste the copied URL

During the execution of the skit, he will do:
* Directory 'Author - Title'
* Copy all mp3 files from this site to this directory
* At the end of the download, it will create one file 'Author - Title'.mp3 with the entire book if the switch 'WithOneFile' is set

.PARAMETER uri
the URL (for example, https://knigavuhe.org/book/prikljuchenija-kota-akakija-1/)

.PARAMETER WithOneFile
At the end of the download, it will create one file 'Author - Title'.mp3 with the entire book

#> 
param (
    [Parameter(Mandatory = $true,
            HelpMessage = 'Enter full URI of "Kniga V Uhe" site',
            Position = 0)][String]$uri = "https://knigavuhe.org/book/unknown/",
    [Parameter(HelpMessage = 'Keep the original file name',
            Position = 1)][switch]$KeepFilename = $false, 
    [Parameter(HelpMessage = 'Keep the original files',
            Position = 1)][switch]$KeepInputFiles = $false, 
    [Parameter(HelpMessage = 'Concat all parts to one file',
            Position = 2)][switch]$WithOneFile = $false 
)

# TODO Make a request via GUI when the script has been started from Windows Explorer 
#If ($PSBoundParameters.Count -lt 1) {
#	$uri = Read-Host -Prompt 'Input a URL for a book on the "Kniga v uhe" site'
#}

If (-not (Get-Module -ErrorAction Ignore -ListAvailable PowerHTML)) {
  Write-Verbose "Installing PowerHTML module for the current user..."
  Install-Module PowerHTML -ErrorAction Stop
}
Import-Module -ErrorAction Stop PowerHTML

try {
	$wp = Invoke-WebRequest -Uri $uri
    $doc = ConvertFrom-Html -Content $wp.Content
} catch {
	Write-Host "$uri is not reachable"
	Exit
}

# Get the title of book
try {
    $tc = $doc.SelectNodes("/html/body/div[6]/div/div/div[2]/div[1]/div[2]/h1/span[1]").InnerHtml
    $tc = $tc.Trim()
} catch {
    $tc = "Unknown book"
}

Write-Information "Book title : $tc"

# Get the Author
try {
    $author = $doc.SelectNodes("/html/body/div[6]/div/div/div[2]/div[1]/div[2]/h1/span[2]/span[2]/a").InnerHtml
    #fixme: IT CAN BE AN ARRAY WITH THE AUTHORS 

    if ($author.GetType() -eq [Object[]])
    {
       $author = $author[0]
    }
    $author = $author.Trim()
    
    #$author = $wp.Links[6].outerText
} catch {
    $author = "Unknown Author"
}

Write-Information "Book author : $author"

# Extract a list of mp3 files

$script = $doc.SelectNodes("/html/body/script[1]")

$content = @()
if($script -ne $null)
{
   $script.InnerText -split "\n" | Select-String -Pattern "BookPlayer\(" | foreach { $_ -match "BookPlayer\((\d+), (\[.*?\]),"; $content = ConvertFrom-Json $Matches[2] }
   Write-Verbose "List of files: $content"
}

$bookid = "{0} - {1}" -f ($author, $tc)
$out = "{0}.mp3" -f $bookid

if (! (Test-Path $out -IsValid)) {
    $out = "kniga-v-uhe-book.mp3"
}

if (!(Test-Path $bookid)) {
    if ((Get-Item -Path ".").BaseName -ne $bookid) {
        New-Item -Path $bookid -ItemType Directory
        Push-Location -Path $bookid
    }
} else {
    Push-Location -Path $bookid
}

$i = 1
$fileList = @()
$content | foreach {
    $uri = "{0}?f=1" -f $_.url
    if ($KeepFilename -and -not $WithOneFile) {
        $uri = $_.url
        $fn = $uri.Substring($uri.LastIndexOf("/") + 1)
    } else {
        $fn = "{0:d3}.mp3" -f $i
    }
    try {
        Write-Host "Download a file $uri"
	    $r = Invoke-WebRequest -Uri "$uri" -OutFile "$fn"
        Write-Host "Done $fn"
        $fileList += $fn
        $i++
    } catch {
    }
}


if ($WithOneFile) {
    $solidName = $out -replace '[^\w]+', '-'
    $outFileName = "$solidName.mp3"
	$tempFileName = "{0}/{1}.mp3" -f ($env:TMP, $solidName)
	$argOut = "--sout=`"#gather:transcode{acodec=mp3,ab=128}:std{access=file,mux=mp3,dst=$tempFileName}`" --sout-keep"
    Write-Host "Merging..."
    cvlc ( $fileList | sort ) $argOut "vlc://quit"
    Write-Host "Save to $outFileName"
    Rename-Item $tempFileName $outFileName
}

Pop-Location
