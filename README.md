# nmapGen
Ruby script for automated portscanning with nmap. 

### Features ###
* Reading target IP addresses via .txt file
* Reading target ports via .txt file
* Writing outputs of the scan in .txt file

### Installing ###
Get source code with 

`git clone https://github.com/pr0f3ss/nmapGen`

### Using nmapGen ###
To print all option parameters for nmapGen type `ruby nmapGen.rb --help`. 

    ruby nmapGen.rb --help
    Usage: ruby nmapGen.rb [options]
    -o, --os                         set flag to scan OS
    -t, --target TARGET              scan target IP address
    -w, --writeFile NAME             write output to file specified by NAME
    -r, --readFile NAME              read input target from file specified by NAME line per line
    -p, --ports PORT                 searches specified ports given by comma separated input
    -l, --listports FILE             use file to specify portlist, line per line. -l has higher presedence than the -p paramater
    -h, --help                       prints this help menu

### Examples ###

`ruby nmapGen.rb -t 192.168.1.1 -p 80,8080 -o`

scans the target IP 192.168.1.1 on ports 80 and 8080. It also tries to find the OS of the system referenced by 192.168.1.1.

`ruby nmapGen.rb -r targetIPs.txt -w portscanOutput.txt -l portlist.txt`

scans all IP addresses in targetIPs.txt on the ports specified in portscanOutput.txt. It writes the results into portscanOutput.txt. Note that the IP addresses and ports must be separated line per line.
