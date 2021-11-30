param($DomainControler,$TableName)


$SQLInstance = "S-SEBN2611"
$SQLDatabase = "DBActiveDirectory"

#Set-Location C:

 $SQLQueryDelete = "USE $SQLDatabase
    TRUNCATE TABLE [AD].["+$TableName+"]"

$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQueryDelete -ServerInstance $SQLInstance

$Iniciais = 'a*','b*','c*','d*','e*','g*','h*',
'i0*','i1*','i2*','i3*','i4*',
'i505003*','i505004*','i505005*','i505006*','i505007*','i505008*','i505009*',
'i50501*','i50502*','i50503*','i50504*','i50505*','i50506*','i50507*','i50508*','i50509*',
'i5051*','i5052*','i5053*','i5054*','i5055*','i5056*','i5057*','i5058*','i5059*',
'i506*','i507*','i508*','i509*',
'i501*','i502*','i503*','i504*',
'i500*',
'i51*','i52*','i53*','i54*','i55*','i56*','i57*','i58*','i59*',
'i6*','i7*','i8*','i9*',
'j*','k*','l*','m*','n*','o*','p*','q*','r*','s*','t*','u*','x*','z*','w*',
'1*','2*','3*','4*','5*','6*','7*','8*','9*','0*'

$HostName = $DomainControler

ForEach($Inicial in $Iniciais){
        try{
        $Usrs = Get-ADUser -server $HostName -f {SamAccountName -like $Inicial }  -Properties * | SELECT SamAccountName,
                    @{Name='PasswordLastSet';Expression={$_.PasswordLastSet.ToString("yyyy\/MM\/dd HH:mm:ss")}},
                    @{Name='LastLogonDate';Expression={$_.LastLogonDate.ToString("yyyy\/MM\/dd HH:mm:ss")}}
            }catch{
                Write-Output $Inicial
                throw $_
                break
            } 
 ForEach($Usr in $Usrs){
 
 	$SamAccountName = $Usr.SamAccountName
	$PasswordLastSet = $Usr.PasswordLastSet
	$LastLogonDate = $Usr.LastLogonDate

$SQLQuery = "USE $SQLDatabase
INSERT INTO [AD].["+$TableName+"]
       ( [SamAccountName], [PasswordLastSet], [LastLogonDate])
VALUES ('$SamAccountName','$PasswordLastSet','$LastLogonDate');"

try{
    $SQLQuery1Output = Invoke-Sqlcmd -query $SQLQuery -ServerInstance $SQLInstance -ErrorAction stop
}catch{
Write-Output $SQLQuery
throw $_
break
}
}
$Usrs.clear
}

