if type -q arch >/dev/null
    # macOS check if we're running running arm64 vs rosetta
    if test (arch) = arm64
        test -f /opt/homebrew/bin/brew && eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        test -f /usr/local/bin/brew && eval "$(/usr/local/bin/brew shellenv)"
    end
else
    # User might not have rosetta installed, or might not be macos.
    set -l brew_paths /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew
    for brew_path in $brew_paths
        if test -f $brew_path
            eval "$($brew_path shellenv)"
            break
        end
    end
end

# Get `fish_user_paths` in reverse order to maintain order when re-adding
set -l user_paths (printf '%s\n' $fish_user_paths | tac)

# Move things in $fish_user_paths to the front of $PATH
# When we run `eval (brew shellenv)` it ends up putting things
# out of order.
# The assumption is that the user paths are the ones that we want
# as overrides, so it should be at the front of the path.
for user_path in $user_paths
    fish_add_path -m $user_path
end
