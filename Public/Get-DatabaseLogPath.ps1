Set-StrictMode -Version 3.0

function Get-DatabaseLogPath {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $dataSource,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $databaseName
    )
    if (!(Get-Module "PsLibSqlQueries")) {
        Import-Module PsLibSqlQueries
    }

    $query = New-GetLogPathQuery -databaseName $databaseName
    $queryResult = Invoke-SQLQuery -databaseName $databaseName -dataSource $dataSource -sqlQuery $query 
    $path = $queryResult[0].physical_name | Split-Path -Parent
    return $path
}