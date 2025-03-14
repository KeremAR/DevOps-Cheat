# Bash Notes

A collection of Bash shell concepts, commands, and techniques organized for learning.

## Basic Shell Concepts

### Available Shells
`/etc/shells` - Provides an overview of known shells on a Linux system

### User-Specific Startup Files
Configuration files that are executed when a user logs in or starts a shell session. These files are located in the **user's home directory (~)** and control environment variables, aliases, and shell behaviors. Examples:

- **~/.profile** - This file is used to save modifications to the shell environment across sessions for login shells. It is executed when a user logs in and can contain environment variable exports, aliases, and other shell configurations.
- **~/.bashrc**

## Basic Commands and Syntax

### Command Substitution
```bash
echo "The date is: $(date)!"
```
This Bash script would produce output like: "The date is: Sun Mar 24 12:30:06 CST 2019!"

### Exit Status Variables
**$?** - Stores the exit status of the last executed command. If the value is 0, the command was successful; otherwise, a nonzero value indicates an error.

### For Loops
```bash
for i in $(ls); do ... done
```
- `$(ls)` executes the ls command, capturing the output as a list of filenames.
- The for loop iterates over each filename in the list.

## Input/Output and Redirection

### Pipe Operator
The pipe (`|`) takes the output of one command and passes it as input to another command.

### Redirection Operator
**> in the Bash Shell**

The > operator in Bash is used for **redirection**. It redirects the **standard output (stdout)** of a command to a file, overwriting its contents.

**Basic Usage**
```bash
command > filename
```
- Runs command
- Redirects output to filename
- **Overwrites** existing contents of filename
- If the filename is new, **> will create the file automatically** before writing to it.

## Control Flow and Logic

### Operator Precedence in Shell
`&&` (AND) has higher precedence than `||` (OR).

Example:
```bash
echo this || echo that && echo other
```

Step-by-Step Execution:
1. First Expression: `echo this`
   - `echo this` executes successfully (exit status 0).
   - Since `||` (OR) only runs the right side if the left fails, the entire OR condition is skipped.
   - This means `echo that && echo other` is never executed.
2. Final output is "this"

### Case Statements
`;;` marks the end of a pattern block in a case statement, telling Bash to stop processing that particular case and move to the next one

### Error Handling
`set -e` (also known as **"exit on error" mode**) is a Bash option that makes the script **terminate immediately** if any command **returns a nonzero exit status** (i.e., an error).

## Process Management

### Stopping Processes
To stop a process in a Unix-like system, you typically use one of the following commands:

**1. kill Command**
- **kill** sends a signal to a process, often to terminate it.

```bash
kill <PID>
```
- **PID**: Process ID of the process you want to terminate.
- By default, kill sends the **SIGTERM (signal 15)**, which asks the process to gracefully terminate.

If the process doesn't terminate, you can send a **SIGKILL** signal (signal 9), which forces the process to stop:
```bash
kill -9 <PID>
```

**2. killall Command**
- **killall** allows you to kill a process by name (rather than by PID).

```bash
killall <process_name>
```
- This will terminate all processes with the given name.

**3. pkill Command**
- **pkill** works similarly to killall, but with more flexible options. It allows you to stop processes based on a pattern (e.g., name, user, etc.).

```bash
pkill <process_name>
```
- It terminates processes that match the specified name.

## File Permissions

### umask Command
- The umask command sets default file permissions for newly created files in the current shell session.
- The **default permission for files** is 666 (read and write for everyone).
- The umask command **subtracts** permissions from the default, so you need to set it to 000 to give read and write permissions to everyone for every file created.

**Command to set rw permissions for all users:**
```bash
umask 000
```

**Explanation:**
- **Default file permissions**: 666 (rw-rw-rw-)
- **umask 000**: Subtracts no permissions, so files created will have rw-rw-rw- permissions for everyone.

## Troubleshooting

### Cross-Platform Line Ending Issues
```bash
sed -i 's/\r$//' filename.sh
```

This command (sed -i 's/\r$//' cond1.sh) solves line ending differences between Windows and Unix/Linux systems.

Windows uses line endings with CRLF (Carriage Return + Line Feed, \r\n) characters, while Unix/Linux systems use only LF (\n) characters.

If you created or edited a file in Windows and try to run it in WSL (Linux), the \r character can cause problems and your script might not run correctly.

The sed command fixes this issue:
- 's/\r$//': Removes the \r character at the end of each line
- -i: Saves changes directly to the file

You only need to run this command once. After running it, the file is converted to Unix format and you can run it directly:

```bash
./script.sh "1,2,3,4,5,6,7"
```

Alternatively, if you create files directly in WSL/Linux using a text editor (like nano or vim), they'll have the correct format and you won't need this conversion.
