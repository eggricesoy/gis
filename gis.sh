#!/bin/bash
# Git Simplified/Sanitized prototype
# Author: Nocoto Day (notcoding.today)

MASTER="master main"

parent_branch() {
  echo $(git show-branch |
    sed "s/].*//" |
    grep "\*" |
    grep -v "$(git rev-parse --abbrev-ref HEAD)" |
    head -n1 |
    sed "s/^.*\[//")
}

remote_hash() {
  current="$(git branch --show-current)"
  git rev-parse "origin/$current"
}

local_hash() {
  current="$(git branch --show-current)"
  git rev-parse "$current"
}

commit_epoch() {
  git --no-pager show -s --format=%at "$1"
}

# TODO: delete
recursive_sync() {
  if [[ "$MASTER" =~ *"$1"* ]]; then
    echo "Syncing HEAD.."
    git pull origin "$1"
    git rebase "$1"
    return $?
  fi
  git checkout "$1"
  grandparent=$(parent_branch)
  recursive_sync "$grandparent" "$1"

  git checkout "$2"
  if [[ $? -eq 0 ]]; then
    echo "Sync $grandparent successful"
    git rebase "$1"
    return $?
  else
    return 1
  fi
}

exit_if_modified_files() {
  changes=$(git --no-pager diff --name-only)
  [[ ! -z "$changes" ]] && echo "There modified tracked files, save them or amend into existing change list" && exit 1
}

case "$1" in
"init")
  shift
  git init "$@"
  ;;

  #
  # Files
  #
"track" | "add" | "a" | "t")
  shift
  git add "$@"
  ;;
"untrack" | "unadd")
  shift
  git restore --staged "$@"
  ;;
"cp")
  shift
  git cp "$@"
  ;;
"mv")
  shift
  git mv "$@"
  ;;
"restore")
  shift
  git restore "$@"
  ;;

  #
  # Change list
  #
"cl" | "c")
  [[ -z "$2" ]] && echo "Usage: gis $1 <change list name>" && exit 1
  changes=$(git --no-pager diff --cached)
  [[ -z "$changes" ]] && echo "No tracked changes, try using: gis track <file>" && exit 1

  current="$(git branch --show-current)"

  git stash

  echo "New change list $2 will be based on $current"
  git checkout -b "$2" "$current"

  git stash pop
  git commit

  gis up
  ;;
"sync")
  exit_if_modified_files && exit 1
  echo "Fetching all CLs"
  git fetch --all
  echo "Syncing CLs"
  git pull --all
  # TODO: delete
  # current="$(git branch --show-current)"
  # parent="$(parent_branch)"
  # recursive_sync $parent $current
  # [[ $? -eq 0 ]] && echo "Successfully synced" || echo "Failed to sync, merge conflicts found"
  ;;
"amend" | "am")
  # Check if safe to amend
  lh="$(local_hash)"
  rh="$(remote_hash)"
  if [ "$lh" != "$rh" ] && [ ! -z "$rh" ]; then
    local_time="$(commit_epoch $lh)"
    remote_time="$(commit_epoch $rh)"
    if [[ "$remote_time" -gt "$local_time" ]]; then
      echo "Remote is not in sync, consider syncing first:"
      echo "  gis sync"
      exit 1
    fi
    echo "Amending more recent commit"
  fi

  git add -u
  git commit --amend
  ;;
"upload" | "p" | "up")
  current="$(git branch --show-current)"
  if [[ -z "$current" ]]; then
    echo "Currently at head, what is the feature name? "
    read current
    [[ -z "$current" ]] && exit 1
    current="HEAD:$current" 
  fi
  if [[ "$MASTER" =~ *"$current"* ]]; then
    echo "Cannot upload master"
    exit 1
  fi
  git push -f origin "$current"
  ;;
"cldelete")
  [[ -z "$2" ]] && echo "Usage: gis $1 <change list name>" && exit 1
  read -p "Deleting change list \"$2\", are you sure? [y/N] " -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    git branch -D "$2"
    echo "Deleting remote branch.."
    git push origin --delete "$2"
  else
    echo "Did not delete change list"
    exit 1
  fi
  ;;
"clget" | "cldownload")
  exit_if_modified_files && exit 1
  git fetch
  gis workon "$2"
  ;;
"workon" | "switch")
  exit_if_modified_files && exit 1
  git switch "$2"
  ;;

  #
  # Debug/Visualize
  #
"summary" | "s")
  gis status --short
  echo
  gis graph --max-count=10
  ;;
"history" | "hist")
  git --no-pager reflog
  ;;
"diff" | "d")
  current="$(git branch --show-current)"
  parent=$(parent_branch)
  echo "Diff of $current based on $parent"
  git --no-pager diff "$parent"..."$current"
  ;;
"status")
  shift
  git status "$@"
  ;;
"graph")
  shift
  git --no-pager log --all --decorate --abbrev-commit --graph --format=format:'%C(bold blue)%h%C(reset) - %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' "$@"
  ;;

  #
  # Remote
  #
"remote")
  git remote show origin
  ;;
"remoteset")
  [[ -z "$2" ]] && echo "Usage: gis $1 <remote url>" && exit 1
  git remote set-url origin "$2"
  ;;

"")
  gis summary
  ;;
*)
  echo "Gis not supported, running: git $@"
  git "$@"
  ;;
esac
