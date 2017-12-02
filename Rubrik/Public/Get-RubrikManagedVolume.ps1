﻿#requires -Version 3
function Get-RubrikManagedVolume
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more managed volumes known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikManagedVolume cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of managed volumes

      .NOTES
      Written by Jason Burrell for community usage
      Twitter: @jasonburrell2

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Get-RubrikManagedVolume -Name 'oracle'
      This will return details on all managed volumes named "oracle".

      .EXAMPLE
      Get-RubrikManagedVolume -Name 'oracle' -SLA Gold
      This will return details on all managed volumes named "oracle" that are protected by the Gold SLA Domain.

      .EXAMPLE
      Get-RubrikManagedVolume -Relic
      This will return all removed managed volumes that were formerly protected by Rubrik.
  #>

  [CmdletBinding()]
  Param(
    # Name of the managed volume
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('managed_volume')]
    [String]$Name,
    # Filter results to include only relic (removed) managed volumes
    [Alias('is_relic')]    
    [Switch]$Relic,
    # SLA Domain policy assigned to the managed volume
    [String]$SLA, 
    # Filter by SLA Domain assignment type
    [ValidateSet('Derived', 'Direct','Unassigned')]
    [String]$SLAAssignment,     
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,        
    # Virtual machine id
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # SLA id value
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,    
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

    #region One-off
    $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
