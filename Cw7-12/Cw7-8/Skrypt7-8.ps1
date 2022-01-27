# Automatyzacja przetwarzania danych
# autor Karol Pastuszka 
# pwsh skrypt

$DIR = "C:\Users\User\Desktop\StudiaSemestr5\b_d_p\cw7-8\"
$ZIPDOWNLOAD = "https://home.agh.edu.pl/~wsarlej/Customers_Nov2021.zip"
$INDEX = "402500"
$LOGFILE = "${DIR}PROCESSED\skrypt_${INDEX}.log"
$TIMESTAMP = Get-Date -Format "MM/dd/yyyy"
$CUSTOMERSTABLEN = "CUSTOMERS_${INDEX}"
$bestCUSTOMERSTABLEN = "BEST_CUSTOMERS_${INDEX}"

$USER = "postgres"
$PASSWORD = "1234"
$HOSTNAME = "localhost"
$PORT = "5432"
$DATABASE = "Cw7_8"
$PSQL = "postgresql://${USER}:${PASSWORD}@${HOSTNAME}:${PORT}/${DATABASE}"
Set-Location $DIR


#dane do maila
$CPASSWORD = 'c6e97558c11e67'
$SPASSWORD = ConvertTo-SecureString $CPASSWORD -AsPlainText -Force
$CUSER = 'a6cade97073653'
$CRED = New-Object System.Management.Automation.PSCREDential ($CUSER, $SPASSWORD)


#pobieranie i rozpakowywanie ( w 7-zip )
Invoke-WebRequest -Uri $ZIPDOWNLOAD -OutFile "${DIR}Customers_Nov2021.zip"

$7zip = '"C:\Program Files\7-Zip\7z.exe"'
$zipPass = "agh"
$zipFile = '"${DIR}Customers_Nov2021.zip"'

$command = "& $7zip e -o${DIR} -y -tzip -p$zipPass $zipFile"
iex $command

if($?){
    Add-Content $LOGFILE -Value "${TIMESTAMP} Unzip successful"
} else {
    Add-Content $LOGFILE -Value "${TIMESTAMP} Unzip failed"
}



#pobieranie csv i sprawdzanie
$customers = ImPORT-Csv -Path "${DIR}Customers_Nov2021.csv"
$customersOld = ImPORT-Csv -Path "${DIR}Customers_old.csv"

if($?){
    Add-Content $LOGFILE -Value "${TIMESTAMP} CSV imPORT successful"
} else {
    Add-Content $LOGFILE -Value "${TIMESTAMP} CSV imPORT failed"
}

$ARRAY = @()
$DUPLICATES = 0
$TMP = 0

foreach($i in $customers){
    foreach($j in $customersOld){
        if($i.email -eq $j.email){
            $TMP = 1
            $DUPLICATES += 1
            Add-Content "${DIR}Customers_Nov2021.bad_${TIMESTAMP}.txt" $i

        }
    }
    if($TMP -eq 0){
        $ARRAY += $i
    }
    $TMP = 0
}

if($?){
    Add-Content $LOGFILE -Value "${TIMESTAMP} Validation successful"
} else {
    Add-Content $LOGFILE -Value "${TIMESTAMP} Validation failed"
}


#eksportowanie
$ARRAY | ExPORT-Csv -Path "${DIR}Customers_Nov2021.csv" -NoTypeInformation
Move-Item -Path "${DIR}Customers_Nov2021.csv" -Destination "${DIR}PROCESSED\${TIMESTAMP}_Customers_Nov2021.csv" -Force

if($?){
    Add-Content $LOGFILE -Value "${TIMESTAMP} Validated data exPORT successful"
} else {
    Add-Content $LOGFILE -Value "${TIMESTAMP} Validated data exPORT failed"
}

#konfigurowanie bazy ( tworzenie rozszerzeń i tabeli)
"CREATE EXTENSION IF NOT EXISTS POSTGIS;" | psql $PSQL

if($?){
    Add-Content $LOGFILE -Value "${TIMESTAMP} Postgis extension successful"
} else {
    Add-Content $LOGFILE -Value "${TIMESTAMP} Postgis extension failed"
}

"DROP TABLE IF EXISTS $CUSTOMERSTABLEN; DROP TABLE IF EXISTS $bestCUSTOMERSTABLEN;" | psql $PSQL

"CREATE TABLE IF NOT EXISTS $CUSTOMERSTABLEN (first_name VARCHAR(100), last_name VARCHAR(100), email VARCHAR(100), geom GEOMETRY(POINT));" | psql $PSQL

if($?){
    Add-Content $LOGFILE -Value "${TIMESTAMP} Table creation successful"
} else {
    Add-Content $LOGFILE -Value "${TIMESTAMP} Table creation failed"
}


# dodawanie do sql
foreach($customer in $ARRAY){
    $first_name = $customer.first_name
    $last_name = $customer.last_name
    $email = $customer.email
    $lat = $customer.lat
    $long = $customer.long

    "INSERT INTO $CUSTOMERSTABLEN VALUES ('${first_name}', '${last_name}', '${email}', ST_GeomFromText('POINT(${lat} ${long})',4326));" | psql $PSQL
}

if($?){
    Add-Content $LOGFILE -Value "${TIMESTAMP} Table insert successful"
} else {
    Add-Content $LOGFILE -Value "${TIMESTAMP} Table insert failed"
}


#https://mailtrap.io/blog/powershell-send-email/?fbclid=IwAR3HwVvxPQqcdtYkohKnv9D0QSOyKqRLXmR9_PiAf1YBsBStX9ukpezfFKQ
#notification email
$correctRows = $ARRAY.Count # poprawne wejscia
$rows = $customers.Count #wejscia z pobranego pliku
$tableInserts = $correctRows*4

$body = "Number of rows: ${rows} `nNumber of correct rows: ${correctRows} `nNumber of DUPLICATES: ${DUPLICATES} `nAmount of data inserted in the table: ${tableInserts}"
#$body1 ="12342"
Send-MailMessage -To "mail@mail.com" -From "liam@liam.net" -Subject "CUSTOMERS LOAD " -Body $body -CREDential ($CRED) -SmtpServer "smtp.mailtrap.io" -PORT 587

if($?){
    Add-Content $LOGFILE -Value "${TIMESTAMP} Mail sending successful"
} else {
    Add-Content $LOGFILE -Value "${TIMESTAMP} Mail sending failed"
}

#sql query
"CREATE TABLE $bestCUSTOMERSTABLEN AS SELECT first_name, last_name, email, geom FROM $CUSTOMERSTABLEN x `
WHERE ST_DistanceSpheroid(x.geom, ST_GeomFromText('POINT(41.39988501005976 -75.67329768604034)',4326), 'SPHEROID[`"WGS 84`",6378137,298.257223563]')<50000" | psql $PSQL

if($?){
    Add-Content $LOGFILE -Value "${TIMESTAMP} SQL query successful"
} else {
    Add-Content $LOGFILE -Value "${TIMESTAMP} SQL query failed"
}

#esportowanie do csv a nastepnie do zipa
"\copy $bestCUSTOMERSTABLEN to '$bestCUSTOMERSTABLEN.csv' csv header" | psql $PSQL

if($?){
    Add-Content $LOGFILE -Value "${TIMESTAMP} Csv exPORT successful"
} else {
    Add-Content $LOGFILE -Value "${TIMESTAMP} Csv exPORT failed"
}


$nCommand = "& $7zip a -mx=9 ${DIR}${bestCUSTOMERSTABLEN}.zip ${DIR}${bestCUSTOMERSTABLEN}.csv"
iex $nCommand


if($?){
    Add-Content $LOGFILE -Value "${TIMESTAMP} Csv zip successful"
} else {
    Add-Content $LOGFILE -Value "${TIMESTAMP} Csv zip failed"
}


#wysylanie maila
$LASTMOD = (Get-Item "${DIR}${bestCUSTOMERSTABLEN}.csv").LastWriteTime
$NROWS = (ImPORT-Csv "${DIR}${bestCUSTOMERSTABLEN}.csv" | Measure-Object).Count #wejscia
$NBODY = "Last modification: ${LASTMOD} `nNumber of rows: ${NROWS}"


Send-MailMessage -To "mail@mail.com" -From "liam@liam.net" -Subject "BEST CUSTOMERS RAPORT" -Body $NBODY -Attachments "${DIR}${bestCUSTOMERSTABLEN}.zip" -CREDential ($CRED) -SmtpServer "smtp.mailtrap.io" -PORT 587

