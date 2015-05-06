<#
PowerSurfer 0.1a
The cheesy web browsing script
Now using IE!!!

PARAMS
------
[1] URL
[2] links deep
[3] delay (in sec) - recommend nothing less than 15.

@khr0x40sh - http://khr0x40sh.wordpress.com
#>
Param(
$url = "https://help.github.com/",
$links=100,
$pause=0
);
function ConvertTo-UnixTimestamp {
	$epoch = Get-Date -Year 1970 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0	
 	$input | % {		
		$milliSeconds = [math]::truncate($_.ToUniversalTime().Subtract($epoch).TotalSeconds)
		Write-Output $milliSeconds
	}	
}

$ie = New-Object -com internetexplorer.application; 
try
{
$ie1 = (New-Object -COM "Shell.Application").Windows() `
        | ? { $_.Name -eq "Windows Internet Explorer" }
if ($ie1)
{
    if ($ie1.GetType().ToString() -eq "System.__ComObject")
    {
        $ie = $ie1;
    }
    else
    {
        $ie = $ie1[0];
    }
}
}
catch [Exception]
{
    Write-host "Error"+ $_.Exception.Message
}

$tick = 0;
$timeout = 60;
$cont1 = $true
$count = $links
$ie.visible = $true; 
$ie.navigate($url); 
while ($ie.Busy -eq $true) 
{ 
    Start-Sleep -Milliseconds 1000; 
} 
while ($cont1 -and $count -gt 0)
{
    $ieHTML = $ie.Document.url
    
   if ($ieHTML.Contains("invalid"))
   {
        $A = $ie.Document.getElementsByTagName("a")
        foreach ($aa in $A)
        {
            if ($aa.innerText.toLower().Contains("continue to this website"))
            {
                $aa.Click();
                break;
            }
        }
   }
   else
   {
        $a2 =@()
        $A = $ie.Document.getElementsByTagName("a")
        $seed = Get-Date | ConvertTo-UnixTimestamp
        $size = $ie.Document.Body.InnerHTML.Length
        Write-Host $size
        $adjusted = ($size / 10000)
        Write-Host $adjusted
        if ($pause -ne 0)
        {
            if ($adjusted -lt 11)
            {
                $delay = [int]$pause * [int]$adjusted
            }
            else
            {
                $delay = [int]$pause * [int]11
            }
        }
        else
        {
            $delay = 15
        }
        #$a2 = New-Object -TypeName System.Collections.Generic.List[mshtml.IHTMLAnchorElement]
        foreach ($aa in $A)
        {
            $temp = [mshtml.HTMLAnchorElement]$aa
            $a2 += $temp
           # if($temp.href)
            #{
             #   if ($temp.href.toLower().Contains(".swf") -or $temp.href.toLower().Contains(".mp4") -or $temp.href.toLower().Contains(".wmv"))
              #  {
               #     Write-Host "vidya found"
                #}
            #}
        }
        while ($ie.Busy -eq $true -and $tick -lt 60) { Start-Sleep -Milliseconds 1000; $tick++;} 
        #$a2 = [mshtml.HTMLElementCollection]$A
        $rand = new-object System.Random $seed
        $r2 = $rand.Next(0, $a2.Count)
        Write-Host $a2.Count
        if ($a2[$r2].href.Contains("mailto"))
        {
            Write-Host $a2[$r2].href
            #should I do nothing?
        }
        else
        {
        $a2[$r2].Click();
        $tick = 0 

        while ($ie.Busy -eq $true -and $tick -lt 60) { Start-Sleep -Milliseconds 1000; $tick++;} 
        if ($ie.Document.title -eq "HTTP 404 Not Found")
        {
            $ie.History.Back()
            $count++
        }
        Write-host $ie.Document.url
        Start-sleep $delay
        
        $count--
        }
    }
    }
        