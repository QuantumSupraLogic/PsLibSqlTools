Set-StrictMode -Version 3.0

function Get-DatabaseDataPath {
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

    $query = New-GetDataPathQuery -databaseName $databaseName
    $queryResult = Invoke-SQLQuery -databaseName $databaseName -dataSource $dataSource -sqlQuery $query 
    $path = $queryResult[0].physical_name | Split-Path -Parent
    return $path
}