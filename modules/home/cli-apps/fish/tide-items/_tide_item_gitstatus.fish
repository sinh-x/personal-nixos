function _tide_item_gitstatus
    # Only run in git repos
    if not command git rev-parse --is-inside-work-tree 2>/dev/null | string match -q true
        return
    end

    set -l status_parts

    # Count staged files
    set -l staged (command git diff --cached --numstat 2>/dev/null | wc -l | string trim)
    if test "$staged" -gt 0
        set -a status_parts "+$staged"
    end

    # Count unstaged/modified files
    set -l unstaged (command git diff --numstat 2>/dev/null | wc -l | string trim)
    if test "$unstaged" -gt 0
        set -a status_parts "!$unstaged"
    end

    # Count untracked files
    set -l untracked (command git ls-files --others --exclude-standard 2>/dev/null | wc -l | string trim)
    if test "$untracked" -gt 0
        set -a status_parts "?$untracked"
    end

    # Check for stash
    set -l stash_count (command git stash list 2>/dev/null | wc -l | string trim)
    if test "$stash_count" -gt 0
        set -a status_parts "≡$stash_count"
    end

    # Check ahead/behind upstream
    set -l upstream (command git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    if test -n "$upstream"
        set -l ahead (command git rev-list --count '@{upstream}..HEAD' 2>/dev/null | string trim)
        set -l behind (command git rev-list --count 'HEAD..@{upstream}' 2>/dev/null | string trim)
        if test "$ahead" -gt 0
            set -a status_parts "⇡$ahead"
        end
        if test "$behind" -gt 0
            set -a status_parts "⇣$behind"
        end
    end

    # Only display if there's something to show
    if test (count $status_parts) -eq 0
        return
    end

    set -l status_text (string join " " $status_parts)

    # Determine background color based on state
    set -l bg_color $tide_gitstatus_bg_color

    # Check for conflicts first (highest priority - red)
    if command git diff --name-only --diff-filter=U 2>/dev/null | string length -q
        set bg_color $tide_gitstatus_bg_color_urgent
    else if test "$unstaged" -gt 0 -o "$untracked" -gt 0
        # Unstaged or untracked changes - yellow
        set bg_color $tide_gitstatus_bg_color_unstable
    end

    _tide_print_item gitstatus '' $status_text
end
