#region documentation
#execute queries on a sql server
#endregion

#region scriptheader
#requires -version 3.0
#endregion

#region code
function Invoke-Sql {
    param(
        #DataSource in format ServerName\InstanceName
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $dataSource,
        [Parameter(Mandatory = $true)]  
        [ValidateNotNullOrEmpty()]      
        [string]
        $databaseName,
        [Parameter(Mandatory = $true, ValueFromPipeLine=$true)]     
        [ValidateNotNullOrEmpty()]   
        [string]
        $sqlQuery,
        #Parameters as hashtable e.g. "@{ContactNo="4711";AccountNo="0815"}". Parameters can be used in the query, e.g. "select * from table where AccountNumber = @AccountNo"
        [Hashtable]
        $parameters = @{}
    )
    
    $databaseName = $databaseName -replace '\[', '' -replace '\]', ''
    $connectionString = "Data Source=$dataSource; " +
    "Integrated Security=SSPI; " +
    "Initial Catalog=$database"

    $Connection = New-Object System.Data.SQLClient.SQLConnection
    $Connection.ConnectionString = $ConnectionString
    $Connection.Open()
    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.Connection = $Connection
    $Command.CommandText = $sqlQuery
    $Command.CommandTimeout = 0
    foreach ($p in $Parameters.Keys) {
        [Void] $Command.Parameters.AddWithValue("@$p", $parameters[$p])
    }
    $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
    $dataset = New-Object System.Data.DataSet
    write-output $adapter.Fill($dataSet) | Out-Null
    $connection.Close()
    return $dataSet.Tables
}
#endregion