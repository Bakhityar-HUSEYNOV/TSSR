#Importe le module ActiveDirectory pour utiliser les cmdlets AD
Import-Module ActiveDirectory
#Importe le fichier CSV
$Users = Import-Csv -Delimiter ";" -Path ".\New-ADUser-Import.csv"
#Boucle sur chaque utilisateur du fichier CSV
foreach ($User in $Users)
{
    #Récupère les informations de l'utilisateur
#--------------------------------------------------------
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
#--------------------------------------------------------
    #Récupère les informations de l'utilisateur dans AD
    $AdUser = Get-ADUser -Filter {SamAccountName -eq $AccountName}
    #Récupère les informations du groupe dans AD
    $AdGroup = Get-ADGroup -Filter {DistinguishedName -eq $Group}
    $AdOrganisationalUnit = Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $OrganisationalUnit}
#--------------------------------------------------------
    #Récupère les informations de l'OU
    $AdOrganisationalUnitArray = $OrganisationalUnit -split ","
    $AdOrganisationalUnitName = $AdOrganisationalUnitArray[0] -replace "OU=", ""
    $AdOrganisationalUnitPath = $AdOrganisationalUnitArray[1] + "," + $AdOrganisationalUnitArray[2]
#--------------------------------------------------------
    #Récupère les informations du groupe
    $GroupArray = $Group -split ","
    $GroupName = $GroupArray[0] -replace "cn=", ""
    $GroupPath = $GroupArray[1] +","+ $GroupArray[2] + "," + $GroupArray[3]
#--------------------------------------------------------
    #Récupère les informations du AD pour créer le groupe
    $AdOrganisationalUnitGroup = Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $GroupPath}
    $AdGroupName = $GroupArray[1] -replace "OU=", ""
    $AdGroupPath = $GroupArray[2] + "," + $GroupArray[3]
#--------------------------------------------------------
    #Création de l'OU si elle n'existe pas
    if ($AdOrganisationalUnit -eq $null) {
        Write-Warning "Impossible de trouver l'OU, création $AdOrganisationalUnitName ..."
        New-ADOrganizationalUnit -Name $AdOrganisationalUnitName -Path $AdOrganisationalUnitPath -ProtectedFromAccidentalDeletion $false
    }
    else {
        Write-Output "OU $AdOrganisationalUnitName trouvé"
    }
#--------------------------------------------------------
    #Création de l'OU pour le groupe si elle n'existe pas
    if ($AdOrganisationalUnitGroup -eq $null) {
        Write-Warning "Impossible de trouver l'OU pour le groupe, création $AdGroupName ..."
        New-ADOrganizationalUnit -Name $AdGroupName -Path $AdGroupPath -ProtectedFromAccidentalDeletion $false
    }
    else {
        Write-Output "OU $AdGroupName trouvé"
    }
#--------------------------------------------------------
    #Write-Output $GroupPath
    #Write-Output $GroupName
    #Création du groupe si il n'existe pas
    if( $AdGroup -eq $null) {
        Write-Warning "Impossible de trouver le groupe, création $GroupName ..."
        New-ADGroup -Name $GroupName -GroupScope Global -path $GroupPath
    }
    else {
        Write-Output "Groupe $GroupName trouvé"
    }
    #Création de l'utilisateur si il n'existe pas
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
         #lol xd
    write-output "lol xd"
}
	
