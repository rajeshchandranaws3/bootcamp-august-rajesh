#!/bin/bash

# File Permission Checker Script
# This script checks if a file/directory has correct permissions and ownership

# Check if user provided correct number of arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <file_path> <expected_permissions>"
    echo "Example: $0 /etc/passwd 644"
    echo "Example: $0 /home/user/script.sh 755"
    exit 3  # Exit code 3 for invalid arguments
fi

# Store command-line arguments in variables
FILE_PATH="$1"
EXPECTED_PERMS="$2"

# Validate permission format (should be 3 octal digits)
if ! [[ "$EXPECTED_PERMS" =~ ^[0-7]{3}$ ]]; then
    echo "Error: Invalid permission format '$EXPECTED_PERMS'. Use 3 octal digits (e.g., 644, 755)."
    exit 3
fi

# Check if the file/directory exists
if [ ! -e "$FILE_PATH" ]; then
    echo "❌ Error: File or directory '$FILE_PATH' does not exist."
    exit 2  # Exit code 2 for file not found
fi

# Get current user
CURRENT_USER=$(whoami)

# Get file information using stat
ACTUAL_PERMS=$(stat -c %a "$FILE_PATH" 2>/dev/null)
FILE_OWNER=$(stat -c %U "$FILE_PATH" 2>/dev/null)

# Check if stat command worked
if [ -z "$ACTUAL_PERMS" ] || [ -z "$FILE_OWNER" ]; then
    echo "❌ Error: Unable to retrieve file information for '$FILE_PATH'"
    exit 1
fi

# Initialize exit code
EXIT_CODE=0

echo "Checking permissions for: $FILE_PATH"
echo "----------------------------------------"

# Check if permissions match expected
if [ "$ACTUAL_PERMS" = "$EXPECTED_PERMS" ]; then
    echo "✅ $FILE_PATH has correct permissions ($ACTUAL_PERMS)"
else
    echo "❌ $FILE_PATH has permissions $ACTUAL_PERMS (expected $EXPECTED_PERMS)"
    EXIT_CODE=1
fi

# Check file ownership
if [ "$FILE_OWNER" = "$CURRENT_USER" ]; then
    echo "✅ File ownership is secure (owned by $CURRENT_USER)"
else
    echo "❌ File owned by different user ($FILE_OWNER, current user: $CURRENT_USER)"
    EXIT_CODE=1
fi

# Security checks - Check for dangerous permissions
echo "----------------------------------------"
echo "Security Analysis:"

# Check if file is world-writable (others have write permission)
OTHERS_PERMS=${ACTUAL_PERMS:2:1}  # Extract last digit (others permissions)
if [ $((OTHERS_PERMS & 2)) -ne 0 ]; then
    echo "⚠️  WARNING: File is world-writable! This is a security risk."
    EXIT_CODE=1
else
    echo "✅ File is not world-writable"
fi

# Check if file is world-readable for sensitive files
if [ $((OTHERS_PERMS & 4)) -ne 0 ]; then
    # Check if this might be a sensitive file based on path
    if [[ "$FILE_PATH" =~ /etc/(passwd|shadow|group|gshadow) ]] || 
       [[ "$FILE_PATH" =~ \.key$ ]] || 
       [[ "$FILE_PATH" =~ \.pem$ ]] || 
       [[ "$FILE_PATH" =~ /\.ssh/ ]]; then
        echo "⚠️  WARNING: Sensitive file is world-readable!"
        EXIT_CODE=1
    else
        echo "ℹ️  File is world-readable (may be intentional)"
    fi
else
    echo "✅ File is not world-readable"
fi

# Check if it's a directory and has appropriate permissions
if [ -d "$FILE_PATH" ]; then
    echo "ℹ️  This is a directory"
    # Directories typically need execute permission to be traversed
    USER_PERMS=${ACTUAL_PERMS:0:1}
    if [ $((USER_PERMS & 1)) -eq 0 ]; then
        echo "⚠️  WARNING: Directory is not executable by owner (cannot be traversed)"
        EXIT_CODE=1
    else
        echo "✅ Directory is executable by owner"
    fi
else
    echo "ℹ️  This is a regular file"
fi

# Check for setuid/setgid permissions (4-digit permissions)
FULL_PERMS=$(stat -c %04a "$FILE_PATH" 2>/dev/null)
if [ ${#FULL_PERMS} -eq 4 ]; then
    SPECIAL_PERMS=${FULL_PERMS:0:1}
    if [ "$SPECIAL_PERMS" != "0" ]; then
        echo "⚠️  WARNING: File has special permissions (setuid/setgid/sticky bit): $FULL_PERMS"
        if [ $((SPECIAL_PERMS & 4)) -ne 0 ]; then
            echo "    - Setuid bit is set (runs as file owner)"
        fi
        if [ $((SPECIAL_PERMS & 2)) -ne 0 ]; then
            echo "    - Setgid bit is set (runs as file group)"
        fi
        if [ $((SPECIAL_PERMS & 1)) -ne 0 ]; then
            echo "    - Sticky bit is set"
        fi
        # Don't automatically set exit code to 1 for special perms as they might be intentional
    fi
fi

# Additional file information
echo "----------------------------------------"
echo "File Details:"
echo "Full permissions: $(stat -c %A "$FILE_PATH")"
echo "Owner: $(stat -c %U "$FILE_PATH")"
echo "Group: $(stat -c %G "$FILE_PATH")"
echo "Size: $(stat -c %s "$FILE_PATH") bytes"
echo "Last modified: $(stat -c %y "$FILE_PATH")"

echo "----------------------------------------"
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ All permission checks passed!"
else
    echo "❌ Permission issues detected!"
fi

exit $EXIT_CODE