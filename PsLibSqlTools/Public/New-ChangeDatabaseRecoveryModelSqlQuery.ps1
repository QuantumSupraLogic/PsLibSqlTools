function New-ChangeDatabaseRecoveryModelSqlQuery{
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string] 
        $databaseName,
        [Parameter(Mandatory=$true)]
        [ValidateSet('Full', 'Bulk-Logged', 'Simple')]
        [string]
        $recoveryModel
    )

    $sqlQuery = "
        USE [master]
        ALTER DATABASE $databaseName SET RECOVERY $recoveryModel"
        
    return $sqlQuery
}