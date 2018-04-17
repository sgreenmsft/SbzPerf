$LoopIterations = 5

Write-Host "=================== Preparing Prerequisites ==================="
&docker pull microsoft/aspnetcore:2.0
&docker pull microsoft/aspnetcore-build:2.0
&docker build -t runforever:dev .
if (-Not (Test-Path('C:\sbz')))
{
    Write-Host("Ensure that the required scripts are installed to C:\sbz");
    return;
}

$stopwatch = [system.diagnostics.stopwatch]::StartNew();

Write-Host "=================== Running SeaBreeze Application ==================="
$stopwatch.Reset();
for ($i = 0; $i -lt $LoopIterations; $i++)
{
    Write-Host "Removing previous version..."
    $startTime = $stopwatch.Elapsed.TotalSeconds
    $stopwatch.Start();
    & powershell -Command "Import-Module C:\sbz\PSModule\ServiceFabricHttpPSModule.dll; Connect-SFCluster -Endpoint http://localhost:19080; C:\sbz\Delete-ServiceFabricApplicationResource.ps1 -ApplicationResourcename 'ABCD'"
    $stopwatch.Stop();
    Write-Host "Deploying application..."
    $stopwatch.Start()
    & powershell -Command "Import-Module C:\sbz\PSModule\ServiceFabricHttpPSModule.dll; Connect-SFCluster -Endpoint http://localhost:19080; C:\sbz\Deploy-ServiceFabricApplicationResource.ps1 -ApplicationResourcename 'ABCD' -ResourceDescriptionFile .\app.json"
    while ($true)
    {
        $exists = (docker ps -a --filter status=running -q) | Out-String
        if ($exists)
        {
            break;
        }
        else
        {
            Start-Sleep -Milliseconds 100
        }
    }
    $stopwatch.Stop();
    $elapsedSeconds = $stopwatch.Elapsed.TotalSeconds - $startTime
    Write-Host "Operation completed in $elapsedSeconds seconds"
}

$totalSFSeconds = $stopwatch.Elapsed.TotalSeconds
$averageSFSeconds = $totalSFSeconds / $LoopIterations

Write-Host "==========================================="
Write-Host "TOTAL SF SECONDS: $totalSFSeconds"
Write-Host "AVERAGE SF SECONDS: $averageSFSeconds"
Write-Host "==========================================="

Write-Host "=================== Docker Run ==================="
$stopwatch.Reset();
for ($i = 0; $i -lt $LoopIterations; $i++)
{
    Write-Host "Removing previous version..."
    $startTime = $stopwatch.Elapsed.TotalSeconds
    $stopwatch.Start();
    $containerId = (docker ps -a --filter status=running -q) | Out-String
    $containerId = $containerId.Trim()
    docker rm -f $containerId
    $stopwatch.Stop();
    Write-Host "Running container..."
    $stopwatch.Start();
    docker run -d runforever:dev
    while ($true)
    {
        $exists = (docker ps -a --filter status=running -q) | Out-String
        $exists = $exists.Trim()
        if ($exists)
        {
            break;
        }
        else
        {
            Start-Sleep -Milliseconds 100
        }
    }
    $stopwatch.Stop();
    $elapsedSeconds = $stopwatch.Elapsed.TotalSeconds - $startTime
    Write-Host "Operation completed in $elapsedSeconds seconds"
}

$totalDockerSeconds = $stopwatch.Elapsed.TotalSeconds
$averageDockerSeconds = $totalDockerSeconds / $LoopIterations

Write-Host "==========================================="
Write-Host "TOTAL DOCKER SECONDS: $totalDockerSeconds"
Write-Host "AVERAGE DOCKER SECONDS: $averageDockerSeconds"
Write-Host "==========================================="