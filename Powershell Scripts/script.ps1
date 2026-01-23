Import-Module ActiveDirectory

$Users = Import-Csv -Delimiter ";" -Path ".\New-ADUser-Import.csv"
foreach ($User in $Users)
{
	$DisplayName = $User.'FirstName' + " " + $User.'LastName'
	$UserFirstName = $User.'FirstName'
	$UserLastName = $User.'LastName'
    $Group = $User.'Group'
    $UserPrincipalName = $User.'PrincipalName'
	$OrganisationalUnit = $User.'OrganisationalUnit'
	$AccountName = $User.'AccountName'
	$PrincipalName = $User.'AccountName' + "@" + $User.'DomainName'
	$Description = $User.'Description'
	$Password = $User.'Password'
    $AdUser = Get-ADUser -Filter {SamAccountName -eq $AccountName}
    $AdGroup = Get-ADGroup -Filter {DistinguishedName -eq $Group}
    $AdOrganisationalUnit = Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $OrganisationalUnit}
    $AdOrganisationalUnitGroup = Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $GroupPath}
    $GroupArray = $Group -split ","
    $GroupName = $GroupArray[0] -replace "cn=", ""
    $GroupPath = $GroupArray[1] +","+ $GroupArray[2] + "," + $GroupArray[3]
    #Write-Output $GroupPath
    #Write-Output $GroupName
    if( $AdGroup -eq $null) {
        Write-Warning "Impossible de trouver le groupe, création $GroupName ..."
        New-ADGroup -Name $GroupName -GroupScope Global -path $GroupPath
    }
    else {
        Write-Output "Groupe $GroupName trouvé"
    }
    if ($AdUser -eq $null) {
    Write-Output "Ajout du utilisateur $AccountName"
	New-ADUser `
		-Name "$AccountName" `
		-DisplayName "$DisplayName" `
		-SamAccountName $AccountName `
		-UserPrincipalName $PrincipalName `
		-GivenName "$UserFirstName" `
		-Surname "$UserLastName" `
		-Description "$Description" `
		-AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
		-Enabled $true `
		-Path "$OrganisationalUnit" `
		-ChangePasswordAtLogon $true `
		-PasswordNeverExpires $false `
		-AllowReversiblePasswordEncryption $false
        Write-Output "Ajout du utilisateur $AccountName au groupe $GroupName"
        Add-ADPrincipalGroupMembership `
            -Identity $AccountName `
            -MemberOf $Group `
            }
    else {
    Write-Warning "no no no"
         }

}
	
