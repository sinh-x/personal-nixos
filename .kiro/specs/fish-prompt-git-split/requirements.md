# Fish Prompt Git Split Requirements

## 1. Introduction

This document specifies the requirements for splitting the Tide fish prompt git segment into separate branch and status components. The goal is to prevent long branch names from being truncated together with git status indicators.

**Architecture Overview**: Custom Tide prompt items will replace the default `git` item with two separate items: `gitbranch` (branch name only) and `gitstatus` (status indicators only). These will be managed via home-manager fish configuration.

## 2. User Stories

### Shell User
- **As a developer**, I want to see the full git branch name in my prompt, so that I can identify which feature branch I'm working on
- **As a developer**, I want git status indicators (+staged, !unstaged, ?untracked) displayed separately, so that they remain visible even with long branch names
- **As a developer**, I want the branch name to truncate independently from status, so that status information is never hidden

## 3. Acceptance Criteria

### Git Branch Display Requirements
- **WHEN** in a git repository, **THEN** the prompt **SHALL** display the current branch name
- **WHEN** the branch name exceeds the truncation length, **THEN** only the branch name **SHALL** be truncated (not the status)
- **WHEN** not in a git repository, **THEN** the gitbranch segment **SHALL NOT** appear

### Git Status Display Requirements
- **WHEN** there are staged changes, **THEN** the prompt **SHALL** display `+N` indicator (green)
- **WHEN** there are unstaged changes, **THEN** the prompt **SHALL** display `!N` indicator (yellow/unstable)
- **WHEN** there are untracked files, **THEN** the prompt **SHALL** display `?N` indicator
- **WHEN** there are stashed changes, **THEN** the prompt **SHALL** display stash indicator
- **WHEN** ahead/behind remote, **THEN** the prompt **SHALL** display upstream indicators
- **WHEN** there are no changes, **THEN** the gitstatus segment **SHALL NOT** appear (or show clean state)

### Visual Requirements
- **WHEN** displayed, gitbranch **SHALL** use the same color scheme as current git segment (green bg for clean)
- **WHEN** there are unstaged changes, gitstatus **SHALL** use yellow/unstable background color
- **WHEN** there are conflicts, gitstatus **SHALL** use red/urgent background color
- **WHEN** gitbranch and gitstatus are adjacent, **THEN** they **SHALL** visually connect with powerline separators

### Integration Requirements
- **WHEN** system is rebuilt, **THEN** custom tide items **SHALL** be automatically installed via home-manager
- **WHEN** tide is configured, **THEN** the prompt items **SHALL** replace the default `git` item

## 4. Technical Architecture

### Shell Configuration
- **Framework**: Fish shell with Tide prompt
- **Configuration Management**: NixOS home-manager
- **Custom Items Location**: `~/.config/fish/functions/_tide_item_*.fish`

### Key Dependencies
- **Tide**: Fish prompt framework (existing)
- **home-manager**: Declarative fish configuration
- **git**: Version control (existing)

## 5. Feature Specifications

### Core Features
1. **gitbranch item**: Display only branch name with configurable truncation
2. **gitstatus item**: Display only status indicators (staged, unstaged, untracked, stash, upstream)
3. **Color coordination**: Match existing tide git color scheme
4. **Powerline integration**: Proper segment separators between items

### Configuration Options
1. **Branch truncation length**: Configurable max length for branch name
2. **Status position**: Can be placed before or after branch in prompt items

## 6. Success Criteria

### User Experience
- **WHEN** viewing prompt with long branch name, **THEN** user **SHALL** always see status indicators
- **WHEN** branch is truncated, **THEN** truncation **SHALL** be indicated with ellipsis or similar

### Visual Consistency
- **WHEN** comparing to original git segment, **THEN** colors and icons **SHALL** be consistent
- **WHEN** prompt renders, **THEN** segments **SHALL** connect seamlessly

## 7. Assumptions and Dependencies

### Technical Assumptions
- Tide prompt is installed and configured
- Fish shell is the active shell
- home-manager manages fish configuration

### External Dependencies
- Tide prompt framework functions and variables
- Git command-line tool for repository detection

## 8. Constraints and Limitations

### Technical Constraints
- Must work within Tide's item system
- Must be compatible with existing tide configuration
- Performance should not noticeably impact prompt rendering

---

**Document Status**: Draft

**Last Updated**: 2026-01-30

**Version**: 1.0
