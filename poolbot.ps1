#################
################################################################
#Init
################################################################
#################

$defaultpath = "C:\users\$($env:username)\Downloads\"
$baseurl = "https://bloodcat.com/osu/s/"
$apiKey ="85e468b92a36c2af9f597ff862c4f91593e21164"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -Assembly System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

#################
################################################################
#Function
################################################################
#################
function bulkLoad( #Function that gets all the inserted id from the table and starts the download on each of them to the selected path
){
    $rows = $bulktable.rows

    if($rows -eq $null){
        write-error "Paste something first!"
        return
    }
    foreach($r in $rows){
        $item = $r.databounditem.items
        singleDL $item.trim() $defaultpath
    }
}

function singleDL( #Main function to download a sigle map via mapid or osu/bloodcat link (link not implemented yet)
    [string]$mapid,
    [string]$path
){
write-host $mapid


        $response = (Invoke-WebRequest "https://bloodcat.com/osu/?q=$mapid")
        write-host $response.statuscode
        $links = $response.links
        $id = ($links|?{$_.href -like "*beatmapsets*"}).innerhtml
    
    <#$htm = $response.content
    $div = $htm.IndexOf('class="set')
    $a = $htm.IndexOf('<a',$div)
    $start = $htm.IndexOf('s/',$a)
    $end = $htm.IndexOf('"',$start)
    $id = $htm.substring($start+2,$end - $start -2)#>

    write-host $id

    $output = $path + "$id.osz"
    $output
    $url = $baseurl + $id

    $wc = New-Object System.Net.WebClient

    $wc.UseDefaultCredentials = $true

    #$wc.DownloadString($url) | Out-File -FilePath c:\scripts\poolbot\test.txt -Encoding utf8

    write-host $url
    $statusT.Text += "downloading mappack $id based on mapID $mapid
    "
   # $ret =  $wc.DownloadFile($url, $output)
    return $ret

}

Function Get-Folder($initialDirectory="")

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

#################
################################################################
#GUI-Elements
################################################################
#################

$form                     = New-Object system.Windows.Forms.Form
$form.ClientSize          = New-Object System.Drawing.Size(628,548)
$form.text                = "Beatmap downloader"
$form.TopMost             = $false
$form.BackColor         = [System.Drawing.ColorTranslator]::FromHtml("#202020")
$form.Location.Y          = 2

$PasteB                = New-Object system.Windows.Forms.button
$PasteB.width          = 170
$PasteB.height         = 40
$PasteB.location       = New-Object System.Drawing.Point(425,123)
$PasteB.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',20)
$PasteB.Text = "PASTE"
$PasteB.BackColor         = [System.Drawing.ColorTranslator]::FromHtml("#404040")
$PasteB.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")
$PasteB.add_Click({
 
    $cb = [System.Windows.Forms.Clipboard]::GetData('text')
 
    try{
        $rdr = New-Object System.IO.StreamReader($cb)
    }catch{
        Write-error "Wrong Input-format"
        return
    }
    $csv = $rdr.ReadToEnd() | ConvertFrom-Csv -Header "Items"
 
    $Bulktable.DataSource=[collections.arraylist]$csv
    $Bulktable.Columns[0].AutoSizeMode = [Windows.Forms.DataGridViewAutoSizeColumnMode]::AllCells
})


$Bulktable                = New-Object system.Windows.Forms.DataGridView
$Bulktable.width          = 170
$Bulktable.height         = 305
$Bulktable.location       = New-Object System.Drawing.Point(425,162)

$bulkDlB                = New-Object system.Windows.Forms.button
$bulkDlB.width          = 170
$bulkDlB.height         = 40
$bulkDlB.location       = New-Object System.Drawing.Point(425,482)
$bulkDlB.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',12)
$bulkDlB.Text = "Download from table"
$bulkDlB.BackColor              = [System.Drawing.ColorTranslator]::FromHtml("#404040")
$bulkDlB.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")
$bulkDlB.Add_Click({
    bulkload
})


$pathL                          = New-Object system.Windows.Forms.Label
$pathL.text                     = "Pick a path to save your maps in by pressing the button next to the textbox"
$pathL.AutoSize                 = $true
$pathL.width                    = 300
$pathL.height                   = 10
$pathL.location                 = New-Object System.Drawing.Point(51,36)
$pathL.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$pathL.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")

$pathI                        = New-Object system.Windows.Forms.TextBox
$pathI.multiline              = $false
$pathI.width                  = 475
$pathI.height                 = 20
$pathI.location               = New-Object System.Drawing.Point(70,55)
$pathI.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$pickPathB                = New-Object system.Windows.Forms.button
$pickPathB.width          = 25
$pickPathB.height         = 25
$pickPathB.location       = New-Object System.Drawing.Point(45,55)
$pickPathB.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',12)
$pickPathB.Text = ""
$pickPathB.BackColor              = [System.Drawing.ColorTranslator]::FromHtml("#c78530")
$pickPathB.Add_Click({
    $pathI.text= get-folder
})

$statusl                          = New-Object system.Windows.Forms.Label
$statusl.text                     = "Status"
$statusl.AutoSize                 = $true
$statusl.width                    = 25
$statusl.height                   = 10
$statusl.location                 = New-Object System.Drawing.Point(49,101)
$statusl.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$statusl.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")

$StatusT                          = New-Object system.Windows.Forms.Textbox
$StatusT.multiline              = $true
$StatusT.readonly                = $true
$StatusT.height                   = 413
$StatusT.width                    = 359
$StatusT.BorderStyle = "Fixed3D"
$StatusT.BackColor         = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")
$StatusT.location                 = New-Object System.Drawing.Point(45,117)

$form.controls.AddRange(@($PasteB, $Bulktable, $bulkDlB,$pathI, $pickPathB, $StatusT,$pathL,$statusl))

[void] $form.ShowDialog()


