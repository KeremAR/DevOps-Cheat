# Bash Notes

A collection of Bash shell concepts, commands, and techniques organized for learning.

## Script Execution and Setup

### Creating and Running Scripts

**Creating a script:**
```bash
# Create a new script file
touch my_script.sh

# Add execute permission
chmod +x my_script.sh
```

**Script execution methods:**
There are two main ways to run a script:

1. **Direct execution** (`./script.sh`): Uses the shebang line to determine which interpreter to use
2. **Shell interpretation** (`sh script.sh`): Forces the script to run with the specified shell

```bash
# With shebang (#!/bin/bash)
./my_script.sh     # Uses bash interpreter

# Force different shell
sh my_script.sh    # Uses sh interpreter regardless of shebang
bash my_script.sh  # Uses bash interpreter
```

The **shebang** (`#!/bin/bash`) tells the system which interpreter to use when executing the script directly.

### Debugging Options

Use `set` commands to help debug your scripts:

```bash
#!/bin/bash

# Exit immediately if any command fails
set -e

# Print each command before executing it
set -x

# Both options together (recommended for debugging)
set -ex

echo "This command will be printed before execution"
ls /some/directory
echo "Script continues only if ls succeeds"
```

**Individual debugging:**
- `set -e`: Exit on error - script stops if any command returns non-zero
- `set -x`: Debug mode - prints each command before executing
- `set +x`: Turn off debug mode
- `set +e`: Turn off exit-on-error mode

## User Input

### Reading User Input

The `read` command accepts various flags for different input scenarios:

```bash
# Basic usage with prompt
read -p "Enter your name: " name
echo "Hello, $name"

# Read multiple variables
read -p "Enter command and argument: " cmd arg
echo "Command: $cmd, Argument: $arg"

# Common read flags:
read -s password          # Silent input (for passwords)
read -t 5 response       # Timeout after 5 seconds
read -n 1 key            # Read only 1 character
read -r line             # Raw input (don't interpret backslashes)
```

## Variables

Variables are used to store data. Think of them as a labeled box where you put a piece of information that you can use later by calling its name.

### Defining a Variable
There are no spaces around the equals sign. By convention, variable names are in uppercase.

```bash
# Variable name is GREETING, its value is "Hello World"
GREETING="Hello World"
```

### Using a Variable
Put a `$` in front of the variable name to get its value.

```bash
echo $GREETING
# Output: Hello World
```

### Variable Syntax: $VAR vs ${VAR}

Both `$VAR` and `${VAR}` access the variable's value, but `${VAR}` is more explicit and safer:

```bash
NAME="John"

# Both work the same for simple cases
echo $NAME        # Output: John
echo ${NAME}      # Output: John

# But ${} is required for complex cases
echo "$NAMEs"     # Error: looks for variable NAMEs
echo "${NAME}s"   # Output: Johns

# Required for arrays and special expansions
echo ${ARRAY[0]}  # Array element access
echo ${#NAME}     # String length
```

**Best practice:** Always use `${VAR}` for consistency and safety.

### Variable Quoting Rules

**Always quote variables that contain file paths, user input, or spaces:**

```bash
# WRONG - Can break with spaces in filenames
FILE=my file.txt
cat $FILE              # Error: cat tries to read "my" and "file.txt"

# CORRECT - Always quote variables
FILE="my file.txt"
cat "$FILE"            # Works correctly

# Examples of when to quote
USERNAME="$1"          # User input
cp "$SOURCE" "$DEST"   # File paths
echo "Hello $NAME"     # String interpolation
```

### Variable "Types"
Technically, all Bash variables are strings (text). However, Bash is smart. If a variable's value contains only digits, it can be used in mathematical operations.

- **String**: `MESSAGE="This is a test"`
- **Integer-like**: `COUNT=100`

### Arrays
An array is a special variable that holds a list of values.

```bash
# Create an array
USERS=("Alice" "Bob" "Charlie")

# Get the second element (indexing starts at 0)
echo ${USERS[1]}
# Output: Bob

# Get all elements
echo ${USERS[@]}
# Output: Alice Bob Charlie
```

### Indirect Variable Expansion

Use `${!VAR}` to use a variable's value as another variable name:

```bash
ARG_COUNT=3
ARG3="hello world"

# Get the value of ARG3 using ARG_COUNT
VALUE=${!ARG_COUNT}    # Same as: VALUE=${ARG3}
echo "$VALUE"          # Output: hello world

# Practical example
LAST_ARG_NUM=$#
LAST_ARG=${!LAST_ARG_NUM}  # Gets the last argument
echo "Last argument: $LAST_ARG"
```

### Sourcing Variables
You can load variables from a file into your current script using the `source` command (or its shorthand, a single dot `.`). This is useful for configuration files.

**Example:**

Create a file named `config.vars`:
```bash
# config.vars
ADMIN_USER="admin"
```

Create a script `my_script.sh` to use it:
```bash
#!/bin/bash
# my_script.sh

# Load variables from the file
source ./config.vars

echo "The admin user is: $ADMIN_USER"
```

Run the script: `./my_script.sh` will output `The admin user is: admin`.

### Variable Deletion

Use the `unset` command to delete a variable from memory. Once unset, the variable becomes undefined and will return an empty value.

```bash
# Create a variable
MY_VAR="Hello World"
echo "$MY_VAR"        # Output: Hello World

# Delete the variable
unset MY_VAR
echo "$MY_VAR"        # Output: (empty/nothing)

# Check if variable is set using conditional
if [[ -n "$MY_VAR" ]]; then
    echo "Variable is set"
else
    echo "Variable is not set"  # This will be output
fi
```

**Important notes:**
- `unset` removes the variable completely from the shell's memory
- Unsetting a variable is different from setting it to an empty string (`VAR=""`)
- You can unset multiple variables at once: `unset VAR1 VAR2 VAR3`
- Cannot unset readonly variables or special variables (like `$1`, `$@`, etc.)

```bash
# Example: Cleanup temporary variables
TEMP_FILE="/tmp/myfile"
TEMP_DIR="/tmp/mydir"

# Use the variables...
echo "Working with $TEMP_FILE"

# Clean up when done
unset TEMP_FILE TEMP_DIR
```

## Environment Variables ⚙️

These are special, system-wide variables available to all programs and scripts. They define your shell's environment.

### Creating Environment Variables (export)
The `export` command makes a variable an environment variable, so it can be used by any child processes or sub-shells.

```bash
# Create a local variable
MY_SURNAME="Smith"

# Export it to make it an environment variable
export MY_SURNAME

# Or do it in one line
export API_KEY="a1b2-c3d4-e5f6"
```

### Viewing Environment Variables
Use `env` or `printenv` to see all environment variables.

```bash
# This command will list all environment variables
env

# To check a specific variable
env | grep MY_SURNAME
# Output: MY_SURNAME=Smith
```

### The PATH Variable
`PATH` is a crucial environment variable that holds a colon-separated list of directories. When you type a command, the shell looks for it in these directories.

**Example:** Add homework folder to PATH permanently.

```bash
# Add homework folder to PATH permanently
echo 'export PATH="$HOME/homework:$PATH"' >> ~/.bashrc
```

This command:
- Adds `~/homework` directory to PATH
- Writes it to `.bashrc` file (makes it permanent)
- Now you can run scripts from homework folder by just typing their name

## Special Variables

Bash has special, reserved variables that are automatically set and provide useful information.

- **$0**: The name of the script itself.
- **$1, $2, ... $n**: The arguments passed to the script. `$1` is the first, `$2` is the second, and so on.
- **$#**: The total number of arguments passed to the script.
- **$@**: All arguments passed to the script, treated as separate, quoted items. This is the safest way to use all arguments in a loop.
- **$***: All arguments passed to the script, treated as a single string.
- **$?**: The exit code of the last command that finished. This is extremely important.
  - `0` means success.
  - Any non-zero number (1-255) means failure/error.
- **$$**: The Process ID (PID) of the current script.

### Example Script (my_script.sh):

```bash
#!/bin/bash
# my_script.sh

echo "Script name: $0"
echo "All arguments: $@"
echo "Number of arguments: $#"
echo "The second argument is: $2"

# Run a command and check its exit code
ls non_existent_file
echo "The exit code of the 'ls' command was: $?" # Will print a non-zero number

ls /
echo "The exit code of the second 'ls' was: $?" # Will print 0
```

**Running the example:**
```bash
./my_script.sh hello world "bash script"
# Script name: ./my_script.sh
# All arguments: hello world bash script
# Number of arguments: 3
# The second argument is: world
# ls: cannot access 'non_existent_file': No such file or directory
# The exit code of the 'ls' command was: 1 (or another non-zero value)
# ... (output of ls /)
# The exit code of the second 'ls' was: 0
```

## Conditional Operators

These operators are used inside if statements to test conditions. They return an exit code: `0` for true and `1` for false.

### Test Constructs: [ vs [[ ]] vs (( ))

- **[[ ... ]]** (Recommended): A modern Bash keyword. It's safer and more powerful, handling strings and comparisons better.
- **[ ... ]**: An alias for the test command. It's more portable to older shells but is more error-prone.
- **(( ... ))**: Used specifically for arithmetic (math) tests.

### String Comparisons (use with [[ ]])

- `[[ "$STR1" == "$STR2" ]]`: True if strings are equal.
- `[[ "$STR1" != "$STR2" ]]`: True if strings are not equal.
- `[[ -z "$STR" ]]`: True if the string is empty (zero length).
- `[[ -n "$STR" ]]`: True if the string is not empty (non-zero length).

### Integer Comparisons (use with [[ ]] or (( )))
These use "flag-style" operators.

- `-eq`: equal (`==` inside `(( ))`).
- `-ne`: not equal (`!=` inside `(( ))`).
- `-gt`: greater than (`>` inside `(( ))`).
- `-lt`: less than (`<` inside `(( ))`).
- `-ge`: greater than or equal to (`>=` inside `(( ))`).
- `-le`: less than or equal to (`<=` inside `(( ))`).

**Example:**
```bash
export TEST=123

#!/bin/bash

# 1. String karşılaştırma (eşit mi)
[[ "$1" == "$2" ]]
echo $?

# 2. String uzunluk karşılaştırması
[[ ${#1} -gt ${#2} ]]
echo $?

# 3. TEST environment değişkeni tanımlı mı (boş değil mi)
[[ -n "$TEST" ]]
echo $?

# 4. Sayısal karşılaştırma (eşit değil mi)
[[ $3 -ne $4 ]]
echo $?

# 5. Sayısal karşılaştırma (büyük veya eşit mi)
[[ $3 -ge $4 ]]
echo $?

# Usage: my_conditions.sh hi world 7 9
```

## The if Statement 🚦

The `if` statement lets your script make decisions by running commands only if a condition is true.

### Basic Syntax

```bash
if [[ <some_test> ]]; then
    # commands to run if the test is true
fi
```

### if-else
Provides an alternative path if the condition is false.

**Example:** Check if a number is even or odd.

```bash
# odd_even.sh
NUM=$1
if (( NUM % 2 == 0 )); then # Using (( )) for math 
    echo "Even"
else
    echo "Odd"
fi
```

```bash
./odd_even.sh 10 # -> Even
./odd_even.sh 7  # -> Odd
```

### if-elif-else
Used to check a series of different conditions. `elif` is short for "else if".

**Example:** Check the number of arguments.

```bash
#!/bin/bash
# my_script.sh

if [[ $# -lt 2 ]]; then # fewer than 2 arguments
    echo "You provided one or zero arguments: $@"
elif [[ $# -lt 4 ]]; then # fewer than 4 (so 2 or 3)
    echo "The last argument was: ${!#}" # ${!#} is a trick for last arg
else
    echo "Invalid number of arguments"
fi
```

```bash
./my_script.sh hello                 # -> You provided one or zero arguments: hello
./my_script.sh hello world pie       # -> The last argument was: pie
./my_script.sh a b c d               # -> Invalid number of arguments
```

## case Statement 🚦

When you have a long `if-elif-else` chain checking a single variable, the `case` statement is often a cleaner and more readable alternative. It compares a variable against a series of patterns and executes the commands for the first match it finds.

### Syntax

- The block starts with `case $VARIABLE in` and ends with `esac`.
- Each pattern ends with a `)`.
- The commands for each pattern are terminated with `;;`.
- The `*)` pattern is a wildcard that acts as a default "catch-all" if no other patterns match.

### Example
A service management script that demonstrates background processes and process finding:

```bash
#!/bin/bash

case "$1" in
  start)
    echo "Service is started"
    sleep 9999
    ;;
  stop)
    # my_service.sh process PID'sini al ve öldür
    PID=$(pgrep -f "my_service.sh start")
    if [[ -n "$PID" ]]; then
      kill "$PID"
      echo "Service is stopped"
    else
      echo "Service is not running"
    fi
    ;;
  restart)
    # restart = stop + start
    "$0" stop
    "$0" start &
    ;;
  *)
    echo "usage: my_service.sh [start|stop|restart]"
    ;;
esac

# Usage: my_service.sh start &
```

**Key concepts in this example:**
- `pgrep -f`: Searches the full command line (command + arguments) to find processes
- `&`: Runs the command in the background, allowing the script to exit while the process continues
- `"$0"`: References the script name itself for recursive calls

## Pipelines & Logical Operators 🔗

These are powerful tools for chaining commands together conditionally and efficiently.

### Pipelines (|)
A pipeline connects the standard output (STDOUT) of one command directly to the standard input (STDIN) of another. Think of it as an assembly line: the result of one command becomes the material for the next one, letting you build complex one-liners.

**Example:** List files, filter for those ending in .log, and then sort the results alphabetically.

```bash
ls | grep ".log$" | sort
```

### Logical AND (&&)
This operator runs the command on its right **only if** the command on its left was successful (returned an exit code of 0). It means: "Do this, **and if it works**, do that."

**Example:** Create a directory, and only if that succeeds, create a file inside it.

```bash
mkdir my_app && touch my_app/config.txt
```

### Logical OR (||)
This operator runs the command on its right **only if** the command on its left failed (returned a non-zero exit code). It means: "Try to do this, **or if it fails**, do this instead."

**Example:** Try to remove a file, and if that fails (e.g., the file doesn't exist), print an error message.

```bash
rm important_file.txt || echo "Error: Could not remove the file."
```

### Background Processes

Use `&` to run commands in the background:

```bash
# Run command in background
long_running_command &

# Get the PID of the background process
BG_PID=$!
echo "Background process PID: $BG_PID"

# Continue with other commands while it runs
echo "This runs immediately"

# Wait for background process to finish
wait $BG_PID
```

## for Loop 🔁

A `for` loop is used to execute a block of code for each item in a given list or sequence.

### List-Based for Loop
This is the most common type, iterating over a list of items like an array.

### Brace Expansion {}
You can use brace expansion to quickly generate a sequence of strings or numbers for the loop.

```bash
# Prints numbers from 1 to 3
for i in {1..3}; do
    echo "Count: $i"
done
```

### C-Style for Loop
This style is useful for looping a specific number of times and is common in other programming languages. It uses an initializer, a condition, and a step calculation.

**Example:**

```bash
for (( i=0; i<5; i++ )); do
    echo "Iteration number $i"
done
```

### Loop Control
You can control the flow of a loop from within it.

- **continue**: Immediately stops the current iteration and jumps to the next one.
- **break**: Immediately stops the loop entirely.

```bash
for i in {1..10}; do
  if [[ $i -eq 3 ]]; then
    continue # Skip printing 3
  fi
  if [[ $i -eq 7 ]]; then
    break # Exit the loop when i is 7
  fi
  echo $i
done
# Output: 1 2 4 5 6
```

## while Loop 🔄

A `while` loop executes a block of code repeatedly as long as its control condition remains true. The condition is checked before each iteration begins.

### Syntax

```bash
while <condition>; do
  # commands to execute
done
```

**Example:** A simple counter that runs as long as a variable is less than 3.

```bash
COUNTER=0
while [[ "$COUNTER" -lt 3 ]]; do
  echo "Counter is at $COUNTER"
  ((COUNTER++)) # Increment the counter
done
```

### Common Use Cases

**Infinite Loops:** By using a condition that is always true (like `true` or the `:` command), you can create a loop that runs forever, which is useful for services or scripts that continuously monitor something.

```bash
# This will run until you stop it with Ctrl+C
while true; do
    echo "Checking system status... Press <CTRL+C> to exit."
    sleep 10
done
```

**Reading a File Line by Line:** A while loop is the standard way to process a file one line at a time. The loop runs as long as the `read` command is able to read a new line from the file.

```bash
FILENAME="users.txt"
while read -r line; do
  echo "Processing user: $line"
done < "$FILENAME"
```

## until Loop ⏳

The `until` loop is the logical opposite of the `while` loop. It executes a block of code repeatedly as long as its control condition remains false. The loop stops once the condition becomes true.

### Syntax

```bash
until <condition>; do
  # commands to execute
done
```

Think of it as saying, "Keep doing this until this thing is true."

**Example:** Wait for a service (like a website) to come online. The loop continues as long as the curl command fails.

```bash
# This script will keep trying to connect until it gets a successful response
until curl -s --head --fail http://localhost:8080 > /dev/null; do
    echo "Waiting for the service to be up..."
    sleep 2 # Wait for 2 seconds before trying again
done

echo "Service is now online!"
```

## Positional Arguments 👉

These are the arguments (or parameters) passed to your script from the command line. They are accessed using special variables.

### Accessing Arguments

- **$1, $2, $3, ...**: The first, second, third argument, and so on.
- **$0**: The name of the script itself.
- **$#**: The total number of arguments provided.
- **$@**: All arguments as a list of separate, quoted strings. This is the safest and most recommended way to iterate over all arguments.
- **$***: All arguments as a single string.

**Example:** A script that processes all its arguments.

```bash
#!/bin/bash
# arg_printer.sh

echo "This script is called: $0"
echo "You provided $# arguments."

# Loop through all arguments safely
for arg in "$@"; do
    echo "Argument processed: $arg"
done
```

**Running it:** `./arg_printer.sh hello "my friend" 123`

**Output:**
```
This script is called: ./arg_printer.sh
You provided 3 arguments.
Argument processed: hello
Argument processed: my friend
Argument processed: 123
```

## Input/Output (I/O) Redirection ↔️

In Linux, everything is treated like a file, including the data streams for a program. You can redirect these streams.

### The Three Standard Streams

- **STDIN (Standard Input - File Descriptor 0)**: Where a program gets its input. Default is the keyboard.
- **STDOUT (Standard Output - File Descriptor 1)**: Where a program sends its normal output. Default is the terminal screen.
- **STDERR (Standard Error - File Descriptor 2)**: Where a program sends its error messages. Default is also the terminal screen.

### Redirection Operators

- **>**: Redirects STDOUT to a file, overwriting the file if it exists.
  ```bash
  ls -l > file_list.txt
  ```

- **>>**: Redirects STDOUT to a file, appending to the end of the file.
  ```bash
  echo "New log entry" >> app.log
  ```

- **<**: Sends the content of a file to a command's STDIN.
  ```bash
  read_file.sh < data.txt
  ```

- **2>**: Redirects STDERR to a file.
  ```bash
  find / -name "secret" 2> find_errors.log
  ```

- **&>**: Redirects both STDOUT and STDERR to the same place.
  ```bash
  ./run_all.sh &> full_output.log
  ```

### Heredoc (<<)
Used to pass a multi-line string as input (STDIN) to a command. It's useful for embedding text blocks directly in a script.

```bash
cat << EOF
This is line 1.
This is line 2.
The variable USER is $USER.
EOF
```

## Functions 📦

Functions are reusable blocks of code within a script. They help organize your code, reduce repetition, and make scripts easier to read and maintain.

### Declaration and Calling
You must declare a function before you can call it.

```bash
# Declare the function
function greet() {
  echo "Hello, world!"
}

# Call the function
greet
```

### Arguments and Return Values

- Functions receive arguments just like a script does (`$1`, `$2`, `$@`).
- The `return` command exits the function with a numeric exit code (0-255), which can be checked with `$?`. This is for signaling success/failure, not for returning data.
- To "return" data (like a string or number), use `echo` inside the function and capture the output with command substitution `$(...)`.

### Variable Scope (local)
By default, all variables in a script are global. If you change a variable inside a function, it changes everywhere. To create a variable that only exists inside a function, use the `local` keyword. This is highly recommended to avoid side effects.

**Example:**

```bash
#!/bin/bash

# This function squares a number
function square() {
  local num=$1
  local result=$((num * num))
  echo $result # "Return" the result by printing it
}

# Main part of the script
SQUARED_VALUE=$(square 5) # Capture the function's output

echo "5 squared is $SQUARED_VALUE"
# Output: 5 squared is 25
```

## Process Management

### Finding Processes

**pgrep - Find Process IDs by Name:**

```bash
# Find PID of processes named "nginx"
pgrep nginx

# Use -f to search the full command line (command + arguments)
pgrep -f "python my_script.py"

# Combine with other commands
if pgrep -f "my_service" > /dev/null; then
    echo "Service is running"
else
    echo "Service is not running"
fi
```

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

## Troubleshooting

### Cross-Platform Line Ending Issues
```bash
sed -i 's/\r$//' filename.sh
```

This command (`sed -i 's/\r$//' cond1.sh`) solves line ending differences between Windows and Unix/Linux systems.

Windows uses line endings with CRLF (Carriage Return + Line Feed, \r\n) characters, while Unix/Linux systems use only LF (\n) characters.

If you created or edited a file in Windows and try to run it in WSL (Linux), the \r character can cause problems and your script might not run correctly.

The sed command fixes this issue:
- `s/\r$//`: Removes the \r character at the end of each line
- `-i`: Saves changes directly to the file

You only need to run this command once. After running it, the file is converted to Unix format and you can run it directly:

```bash
./script.sh "1,2,3,4,5,6,7"
```

Alternatively, if you create files directly in WSL/Linux using a text editor (like nano or vim), they'll have the correct format and you won't need this conversion.
