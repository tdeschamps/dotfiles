function localips -d "Print this machine's local IPv4 addresses"
    if command -q ip
        command ip -4 -oneline addr show | string replace -rf '.*inet (\S+)/.*' '$1'
    else if command -q ifconfig
        command ifconfig | string match -rg 'inet (\d+\.\d+\.\d+\.\d+)'
    else
        echo "localips: neither ip nor ifconfig is available" >&2
        return 1
    end
end
