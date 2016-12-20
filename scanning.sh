#!/bin/bash

declare DEC_TCP
declare DEC_UDP

SCAN_NAME=`ls | grep UP | cut -d "_" -f 1`

echo "Do you want a TOP1000 or a full TCP port scan? [t/f]"
read DEC_TCP

if [[ $DEC_TCP == f ]]; then
    	nmap -v -Pn -sC -sV -sS -O --osscan-guess -p0-65535 --reason --open -iL ${SCAN_NAME}_UP -oA ${SCAN_NAME}_TCPscan  

elif [[ $DEC_TCP == t ]]; then
	nmap -v -Pn -sC -sV -sS -O --osscan-guess --reason --open -iL ${SCAN_NAME}_UP -oA ${SCAN_NAME}_TCPscan

fi

cat ${SCAN_NAME}_TCPscan.gnmap | grep 21 | awk -F " " '{print $2}' > 21_ftp_${SCAN_NAME}_host
cat ${SCAN_NAME}_TCPscan.gnmap | grep 22 | awk -F " " '{print $2}' > 22_ssh__${SCAN_NAME}_host
cat ${SCAN_NAME}_TCPscan.gnmap | grep 53 | awk -F " " '{print $2}' > 53_dns_${SCAN_NAME}_host
cat ${SCAN_NAME}_TCPscan.gnmap | grep 80 | awk -F " " '{print $2}' > 80_http_${SCAN_NAME}_host
cat ${SCAN_NAME}_TCPscan.gnmap | grep 443 | awk -F " " '{print $2}' > 443_ssl_${SCAN_NAME}_host


echo "The host(s) were regrupped according to the running services"



echo "Do you want a TOP1000 or a full UDP port scan? [t/f]"
read DEC_UDP

if [[ $DEC_UDP == f ]]; then
	nmap -v -Pn -sC -sV -sU -O --osscan-guess -p0-65535 --reason --open -iL ${SCAN_NAME}_UP -oA ${SCAN_NAME}_UDPscan  
elif [[ $DEC_UDP == t ]]; then
	nmap -v -Pn -sC -sV -sU -O --osscan-guess --reason --open -iL ${SCAN_NAME}_UP -oA ${SCAN_NAME}_UDPscan

fi

cat ${SCAN_NAME}_UDPscan.gnmap | grep 21 | awk -F " " '{print $2}' >> 21_ftp_${SCAN_NAME}_host
cat ${SCAN_NAME}_UDPscan.gnmap | grep 22 | awk -F " " '{print $2}' >> 22_ssh__${SCAN_NAME}_host
cat ${SCAN_NAME}_UDPscan.gnmap | grep 53 | awk -F " " '{print $2}' >> 53_dns_${SCAN_NAME}_host
cat ${SCAN_NAME}_UDPscan.gnmap | grep 80 | awk -F " " '{print $2}' >> 80_http_${SCAN_NAME}_host
cat ${SCAN_NAME}_UDPscan.gnmap | grep 443 | awk -F " " '{print $2}' >> 443_ssl_${SCAN_NAME}_host


echo "The host(s) were regrupped according to the running services"



ls -al | grep $SCAN_NAME




##################################################
# https://nmap.org/book/man-nse.html
# https://nmap.org/nsedoc/index.html


nmap --script-updatedb

# FTP scripts
nmap -g 53 -Pn -n -sS --open -p21 iL 21_ftp_${SCAN_NAME}_host --script=banner,ftp-anon,ftp-bounce,ftp-proftpd-backdoor,ftp-vsftpd-backdoor,ftp-vuln-cve2010-4221,tftp-enum

# SSH scripts
nmap -g 53 -Pn -n -sS --open -p22 iL 22_ssh_${SCAN_NAME}_host --script=banner,ssh-hostkey,ssh2-enum-algos,sshv1

#DNS scripts
nmap -g 53 -Pn -n -sS --open -p53 iL 53_dns_${SCAN_NAME}_host --script=banner,dns-brute,dns-cache-snoop,dns-check-zone,dns-client-subnet-scan,dns-ip6-arpa-scan,dns-nsec-enum,dns-nsec3-enum,dns-nsid,dns-random-srcport,dns-random-txid,dns-srv-enum,dns-zone-transfer
### >> nmap -sU -p 53 --script=dns-update --script-args=dns-update.hostname=foo.example.com,dns-update.ip=192.0.2.1 <target> ...

# HTTP scripts
nmap -g 53 -Pn -n -sS --open -p80 iL 80_http_${SCAN_NAME}_host --script=banner,"(not default and not brute) and http-*"
### >> http-apache-negotiation,http-apache-server-status,http-aspnet-debug,http-auth,http-auth-finder,http-backup-finder,http-cakephp-version,http-comments-displayer,http-config-backup,http-cors,http-cross-domain-policy,http-csrf,http-default-accounts,http-enum,http-errors,http-git,http-internal-ip-disclosure,http-methods,http-mobileversion-checker,http-ntlm-info,http-open-proxy,http-open-redirect,http-passwd,http-php-version,http-phpmyadmin-dir-traversal 
### >> nmap --script http-brute -p 80 <host> **Performs brute force password auditing against http basic, digest and ntlm authentication. **

# SSL scripts
nmap -g 53 -Pn -n -sS --open -p443 iL 443_ssl_${SCAN_NAME}_host --script=banner,ssl-ccs-injection,ssl-cert,ssl-date,ssl-dh-params,ssl-enum-ciphers,ssl-google-cert-catalog,ssl-heartbleed,ssl-known-key,ssl-poodle,sslv2,sslv2-drown,sstp-discover  

