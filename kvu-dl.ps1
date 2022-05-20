
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
            Position = 0)][String]$Uri = "https://knigavuhe.org/book/unknown/",
    [Parameter(HelpMessage = 'Keep the original file name',
            Position = 1)][switch]$KeepFilename = $false, 
    [Parameter(HelpMessage = 'Continue downloading after restart',
            Position = 2)][switch]$DlContinue = $false, 
    [Parameter(HelpMessage = 'Merge all parts to one file',
            Position = 3)][switch]$Merge = $false
)

If (-not (Get-Module -ErrorAction Ignore -ListAvailable PowerHTML)) {
  Write-Verbose "Installing PowerHTML module for the current user..."
  Install-Module PowerHTML -ErrorAction Stop
}
Import-Module -ErrorAction Stop PowerHTML

# Try to use TagLib-Sharp library for the media file tagging

$pkgTagLib = Get-Package TaglibSharp -ErrorAction Ignore

$canUseTaglib = $null -ne $pkgTagLib

if ($canUseTaglib) {
    Add-Type -Path ((Split-Path $pkgTagLib.Source) + "/lib/netstandard2.0/TagLibSharp.dll")
} else {
    Install-Package TagLibSharp -Scope CurrentUser
    $pkgTagLib = Get-Package TaglibSharp -ErrorAction Ignore
    $canUseTaglib = $null -ne $pkgTagLib
    if ($canUseTaglib) {
        Add-Type -Path ((Split-Path $pkgTagLib.Source) + "/lib/netstandard2.0/TagLibSharp.dll")
    }
}

function Set-Mp3Tags ($mediaFile, $Author, $Title, $Performers, $Genre)
{
	# Invoke TagLibSharp library to set MP3 metadata tags
    # WARNING! $mediaFile must be an _absolute_ file name
    try {        
        $Tags = [TagLib.File]::Create($mediaFile)

        $Tags.Tag.AlbumArtists = $Author
        $Tags.Tag.Performers   = $Performers
        $Tags.Tag.Title = $Title
        $Tags.Tag.Genres = $Genre
        
        # Commit the MP3 metadata tag changes to the file
        $Tags.Save()
    } catch {
        Write-Host -ForegroundColor DarkYellow "Error setting MP3 tags for file [$($mediaFile)]"
        continue
    }
}

#######################################
## Download and pase a book document ##
#######################################

try {
	$wp = Invoke-WebRequest -Uri $Uri
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

# Get a reader/performer
try {
    # /html/body/div[6]/div/div/div[2]/div[1]/div[2]/h1/span[3]/span[2]/a[1]
    # /html/body/div[6]/div/div/div[2]/div[1]/div[2]/h1/span[3]/a
    $perfBlock = $doc.SelectNodes("/html/body/div[6]/div/div/div[2]/div[1]/div[2]/h1/span[3]")  
} catch {
    
}
# try a variant A
$performer = $perfBlock.SelectNodes("a")
if ($null -ne $performer) {
    $performer = $performer.InnerHtml    
} else {
    # try a variant B
    $performer = $perfBlock.SelectNodes("span[2]/a[1]")
    if ($null -ne $performer) {
        $performer = $performer.InnerHtml    
    } else {
        $performer = "---"
    }
}
$performer = $performer.Trim()

# Get another reader #1 => /html/body/div[6]/div/div/div[2]/div[2]/div[2]/div[1]/div[2]
#div.book_blue_block:nth-child(1)
#div.book_serie_block_item:nth-child(2)
#try {
#    $i = 1
#    $book_reader = @()    
#    #$book_reader += $doc.SelectNodes("/html/body/div[6]/div/div/div[2]/div[2]/div[2]/div[1]/div[2]")
#} catch {
#
#}


# Extract a genre
try {
    $genre = $doc.SelectNodes("/html/body/div[6]/div/div/div[2]/div[1]/div[1]/a").InnerHtml
} catch {
    $genre = ""
}

Write-Host "== Book summary =="
Write-Host "Book title : $tc"
Write-Host "Book author : $author"
Write-Host "Audio performer : $performer"
Write-Host "Book genre : $genre"
Write-Host "=================="

##################################
## Extract a list of mp3 files  ##
##################################

$script = $doc.SelectNodes("/html/body/script[1]")

$content = @()
if($null -ne $script)
{
   $script.InnerText -split "\n" | Select-String -Pattern "BookPlayer\(" | ForEach-Object { $_ -match "BookPlayer\((\d+), (\[.*?\]),"; $content = ConvertFrom-Json $Matches[2] }
   Write-Verbose "List of files: $content"
}

$bookid = "{0} - {1}" -f ($author, $tc)

if (!(Test-Path $bookid)) {
    if ((Get-Item -Path ".").BaseName -ne $bookid) {
        New-Item -Path $bookid -ItemType Directory
        Push-Location -Path $bookid
    }
} else {
    Push-Location -Path $bookid
}

# Extract a book cover(image)
# /html/body/div[6]/div/div/div[2]/div[2]/div[1]/div[1]/img
try {
    $coverNode = $doc.SelectNodes("/html/body/div[6]/div/div/div[2]/div[2]/div[1]/div[1]/img")
    $coverUrl = $coverNode.GetAttributeValue("src","")
    $cu = [uri]$coverUrl
    $picExt = Split-Path $cu.LocalPath -Extension
    $r = Invoke-WebRequest -Uri $coverUrl -OutFile ("book-cover{0}" -f $picExt)
} catch {
    $coverUrl = ""
}

$i = 1
$fileList = @()
$content | ForEach-Object {
    $muri = "{0}?f=1" -f $_.url
    if ($KeepFilename -and -not $WithOneFile) {
        $muri = $_.url
        $fn = $muri.Substring($muri.LastIndexOf("/") + 1)
    } else {
        $fn = "{0:d3}.mp3" -f $i
    }
    if ($DlContinue -and (Test-Path $fn)) {
        Write-Host "Audio file already exists"
    } else{
        try {
            Write-Host "Download a file $muri"
            $r = Invoke-WebRequest -Uri "$muri" -OutFile "$fn"
            Write-Host "Done $fn"
            $fileList += $fn
            $i++
        } catch {
        }
    }    
}

if ($Merge) {
    $solidName = $out -replace '[^\w]+', '-'
    $outFileName = "$solidName.mp3"
	$tempFileName = "{0}/{1}.mp3" -f ($env:TMP, $solidName)
	$argOut = "--sout=`"#gather:transcode{acodec=mp3,ab=128}:std{access=file,mux=mp3,dst=$tempFileName}`" --sout-keep"
    Write-Host "Merging..."
    cvlc ( $fileList | sort ) $argOut "vlc://quit"
    Write-Host "Save to $outFileName"
    Rename-Item $tempFileName $outFileName
    if ($canUseTaglib) { Set-Mp3Tags (Resolve-Path $outFileName) $author $tc $performer $genre }
} else { 
    if ($canUseTaglib) {
        Write-Host "Media file(s) tags updating"
        $fileList | ForEach-Object {
            $fullName = Resolve-Path $_ # FIXME: must convert to absolute file name 
            Set-Mp3Tags $fullName $author $tc $performer $genre
        }
    }
}

$description = @"
Url : {1}
== Book summary ====
Book title      : {2}
Book author     : {3}
Audio performer : {4}
Book genre      : {5}
=====================
{0}

"@ -f (Get-Date), $Uri, $tc, $author, $performer, $genre 
Set-Content -Path .\descript.ion -Value $description

Pop-Location