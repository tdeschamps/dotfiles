function git_main_branch -d "Print this repo's main branch (main, master, trunk, ...)"
    # Prefer what the remote says its HEAD is.
    set -l head (command git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
    if test -n "$head"
        string replace -r '^origin/' '' -- $head
        return 0
    end

    for branch in main master trunk develop
        if command git show-ref --quiet --verify refs/heads/$branch 2>/dev/null
            echo $branch
            return 0
        end
    end

    echo main
end
