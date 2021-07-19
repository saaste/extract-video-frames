<#
.Description
A script for extracting geo-tagged images from a video based on a GPX track
#>
param (
    [Parameter(Mandatory = $True)]
    [String]
    $VideoFile,

    [Parameter(Mandatory = $False)]
    [int16]
    $FrameRate = 2
)

$VideoFiles = Get-ChildItem -Filter $VideoFile
$VideoFilesCount = ($VideoFiles | Measure-Object).Count
if ($VideoFilesCount -eq 0) {
    Write-Output "No files matching '${VideoFile}'"
    exit
}

Write-Output "Found ${VideoFilesCount} matching files!"
Write-Output "Press Esc to cancel or any other key to continue"
$Key = [Console]::ReadKey($true)
if ($Key.Key -eq [ConsoleKey]::Escape) {
    exit
}

$VideoFiles |
ForEach-Object {
    $File = $_
    $VideoFileBaseName = [io.path]::GetFileNameWithoutExtension($File)
    $Path = "${VideoFileBaseName}-${FrameRate}fps"

    if (Test-Path $Path) {
        Write-Output "Deleting existing frames directory"
        Remove-Item -Confirm:$False -Recurse -Path $Path 
    }

    Write-Output "Creating a new frames directory"
    New-Item -Path ${Path} -ItemType Directory > $null


    Write-Output "Extracting frames from '$File' at $FrameRate frames/sec"
    .\ffmpeg\bin\ffmpeg.exe -hwaccel auto -i $File -y -ss 1 -an -q:v 0 -f image2 -r $FrameRate ${Path}\pic%05d.jpg

    Write-Output "Setting initial date"
    $StartDate = .\exiftool\exiftool.exe -CreateDate -S $File | % { $_ -replace "CreateDate: ", "" }
    ./exiftool/exiftool.exe -overwrite_original_in_place -AllDates="$StartDate" ${Path}\pic*.jpg

    $hour = 0
    $min = 0
    $sec = 1
    $millisec = 0

    $delta_ms = 1000 / $FrameRate

    Get-ChildItem $Path -Filter *.jpg |
    ForEach-Object {
        $Filename = "${Path}\${_}"
        Write-Output "Update ${Filename} at ${hour}:${min}:${sec}.${millisec}"
        ./exiv2/bin/exiv2.exe -a +${hour}:${min}:${sec} ${Filename}
        if ($millisec -ne 0) {
            ./exiv2/bin/exiv2.exe -M"set Exif.Photo.SubSecTimeOriginal ${millisec}" $Filename
        }

        $millisec = $millisec + $delta_ms;

        if ($millisec -gt 999) {
            $millisec = $millisec - 1000;
            $sec = $sec + 1
            if ($sec -gt 59) {
                $sec = 0
                $min = $min + 1
                if ($min -gt 59) {
                    $min = 0
                    $hour = $hour + 1
                }
            }
        }

    }
}
