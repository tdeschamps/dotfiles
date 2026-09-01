function serve -d "Serve the current directory over HTTP (default port 8000)"
    set -l port 8000
    test (count $argv) -gt 0; and set port $argv[1]
    echo "Serving "(pwd)" on http://localhost:$port"
    python3 -m http.server $port
end
