﻿#requires -Version 3
function Get-RubrikManagedVolumeExport
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more managed volume exports known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikManagedVolumeExport cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of managed volume exports

      .NOTES
      Written by Jason Burrell for community usage
      Twitter: @jasonburrell2

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Get-RubrikManagedVolumeExport -SourceName 'oracle'
      This will return details on all managed volume exports named "oracle".

  #>

  [CmdletBinding()]
  Param(
    # Name of the source managed volume
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('source_managed_volume_name')]
    [String]$SourceName,     
    # ID of the source managed volume
    [Alias('source_managed_volume_id')]
    [String]$SourceID,          
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
    
    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name
        
    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = (Get-RubrikAPIData -endpoint $function).$api
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
