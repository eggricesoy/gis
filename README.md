# Git Simplified/Sanitized

Problems:

1. Git is pretty much the only version control option we have. Hence, developers tend to suffer from
Stockholm Syndrome with Git by giving it a 'free pass' as a developer tool without any consistent
attempts to improve it.

2. Git is like C++, there are may ways to get one thing done (not opinionated) and you can hold it
wrong. Unfortunately, there are many ways to hold it wrong.

Gis is a Git wrapper that covers 80-90% of use cases. Gis aims to:

- Make version control easier.
- Stay compatible with Git and allow users to take Git actions directly.
- Not be broken by unexpected Git changes.
- Not use existing git terminology if they mean different things.

## Workflow

In a repository, you create or modify files. When decide your set of changes satisfy a small goal,
you decide to create a change list. You add files to track in this change list and document this
change list.

You push this change list and merge into your main/master.

## Development status

This project is currently in very early stage. See features planned below and their implementation
status.

## Global commands

| Command     | Description | Aliases | Implemented |
| ----------- | ----------- | ------- | ----------- |
| init        | Initiate the current directory as git repository | | ✔️

## Repository commands

### Files

| Command     | Description | Aliases | Implemented |
| ----------- | ----------- | ------- | ----------- |
| track       | Start tracking file(s) in change list | add,a,t | ✔️
| untrack     | Undo track | unadd | ⚠️
| cp          | Copy a file and keep the copy tracked in change list | | ✔️
| mv          | Move a file and keep the move tracked in change list | | ✔️
| restore     | Restore the file to the CL | | ✔️

### Change list

| Command     | Description | Aliases | Implemented |
| ----------- | ----------- | ------- | ----------- |
| cl          | Create a change list using tracked files | c️ | ✔️
| uncl        | Undo commit |
| amend       | Amend (edit) the change list and its message using tracked files | am | ✔️
| unamend     | Undo amend |
| split       | Split a change list into two |
| merge       | Merge two change lists into one |
| upload      | Upload your change list | up,p | ✔️
| sync        | Sync your local CL to remote parent |
| clget       | Download remote cl | cldownload | ✔️
| cledit      | Interactive change list history editing |
| clmerge     | Attempt to merge your change list into master/main |
| cldelete    | Delete specified change list | ️| ⚠️
| workon      | Switch to working on specified change list | switch | ✔️

### Debug/Visualize

| Command     | Description | Aliases | Implemented |
| ----------- | ----------- | ------- | ----------- |
| summary     | Prints summary of your change list | s | ✔️
| history     | Prints history of all git actions | hist | ✔️
| diff        | Prints diff if your change list | d | ✔️
| status      | Prints status of your change list | | ✔️
| graph       | Prints change list graph | | ✔️

### Remote

| Command     | Description | Aliases | Implemented |
| ----------- | ----------- | ------- | ----------- |
| remote      | Prints remote origin URL | | ✔️
| remoteset   | Set remote origin URL | | ✔️

### Others

| Command     | Description | Aliases | Implemented |
| ----------- | ----------- | ------- | ----------- |
| undo        | Smart undo that undo-s whatever you did last |
| osmosis     | Attempt to automatically add your changes to current and ancestor change lists |
| stash       | Temporarily put away your changes |
| unstash     | Restore changes that were put away by stash |
