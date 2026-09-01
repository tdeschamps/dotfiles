function stt -d "Open Neovim in the current (or given) directory"
    if test (count $argv) -eq 0
        nvim .
    else
        nvim $argv
    end
end
