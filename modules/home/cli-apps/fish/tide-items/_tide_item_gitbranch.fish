function _tide_item_gitbranch
    # Only run in git repos
    if not command git rev-parse --is-inside-work-tree 2>/dev/null | string match -q true
        return
    end

    # Get branch name or short SHA if detached
    set -l branch (command git branch --show-current 2>/dev/null)
    if test -z "$branch"
        # Detached HEAD - show short SHA
        set branch (command git rev-parse --short HEAD 2>/dev/null)
        if test -z "$branch"
            return
        end
    end

    # Truncate if needed
    set -l max_length (set -q tide_gitbranch_truncation_length; and echo $tide_gitbranch_truncation_length; or echo 24)
    if test (string length "$branch") -gt $max_length
        set branch (string sub -l $max_length "$branch")"…"
    end

    # Determine background color based on repo state
    set -l bg_color $tide_gitbranch_bg_color

    # Check for conflicts
    if command git diff --name-only --diff-filter=U 2>/dev/null | string length -q
        set bg_color $tide_gitbranch_bg_color_urgent
    end

    _tide_print_item gitbranch $tide_gitbranch_icon" " $branch
end
