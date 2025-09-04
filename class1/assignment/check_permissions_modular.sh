#!/bin/bash

# File Permission Checker Script - Modular Version
# This script checks if a file/directory has correct permissions and ownership

# Global variables
EXIT_CODE=0
FILE_PATH=""
EXPECTED_PERMS=""
ACTUAL_PERMS=""
FILE_OWNER=""
CURRENT_USER=""

# Function to display usage information
show_usage() {
    echo "Usage: $0 <file_path> <expected_permissions>"
    echo "Example: $0 /etc/passwd 644"
    echo "Example: $0 /home/user/script.sh 755"
}

# Function to validate command-line arguments
validate_arguments() {
    local args=("$@")
    echo "Script arguments: ${args[@]}"
    echo "No of arguments: $#"
    
    # Check if user provided correct number of arguments
    if [ $# -ne 2 ]; then
        show_usage
        exit 3  # Exit code 3 for invalid arguments
    fi
    
    # Store arguments in global variables
    FILE_PATH="${args[0]}"
    EXPECTED_PERMS="${args[1]}"
}

# Function to check if file exists
validate_file_exists() {
    if [ ! -e "$FILE_PATH" ]; then
        echo "❌ Error: File Path '$FILE_PATH' does not exist."
        exit 2  # Exit code 2 for file not found
    fi
}

# Function to validate permission format
validate_permission_format() {
    # Use grep to check pattern (redirect output to avoid showing matches)
    if echo "$EXPECTED_PERMS" | grep -q '^[0-7][0-7][0-7]$' 2>/dev/null; then
        echo "Permission format is valid: $EXPECTED_PERMS"
    else
        echo "ERROR: Invalid permission format: '$EXPECTED_PERMS'"
        echo "Expected: 3-digit octal format (e.g., 755, 644)"
        exit 3 # Exit code 3 for invalid arguments
    fi
}

# Function to gather file information
gather_file_info() {
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
}

# Function to check permissions match
validate_permissions_match() {
    echo "----------------------------------------"
    echo "Checking permissions for: $FILE_PATH :-"
    
    # Check if permissions match expected
    if [ "$ACTUAL_PERMS" = "$EXPECTED_PERMS" ]; then
        echo "✅ $FILE_PATH has correct permissions ($ACTUAL_PERMS)"
    else
        echo "❌ $FILE_PATH has permissions $ACTUAL_PERMS (expected: $EXPECTED_PERMS)"
        EXIT_CODE=1
    fi
}

# Function to check file ownership
validate_file_ownership() {
    # Check file ownership
    if [ "$FILE_OWNER" = "$CURRENT_USER" ]; then
        echo "✅ File ownership is secure (owned by $CURRENT_USER)"
    else
        echo "❌ File owned by different user (actual owner: $FILE_OWNER, current user: $CURRENT_USER)"
        EXIT_CODE=1
    fi
}

# Function to perform security analysis
perform_security_analysis() {
    echo "----------------------------------------"
    echo "Security Analysis:"
    
    # Check if file is world-writable (others have write permission)
    local others_perms=${ACTUAL_PERMS:2:1}  # Extract last digit (others permissions)
    
    if [ $((others_perms & 2)) -ne 0 ]; then
        echo "⚠️  WARNING: File is world-writable! This is a security risk."
        EXIT_CODE=1
    else
        echo "✅ File is not world-writable"
    fi
    
    # Check if file is world-readable for sensitive files
    if [ $((others_perms & 4)) -ne 0 ]; then
        echo "ℹ️  File is world-readable (may be intentional)"
    else
        echo "✅ File is not world-readable"
    fi
}

# Function to check directory-specific permissions
validate_directory_permissions() {
    # Check if it's a directory and has appropriate permissions
    if [ -d "$FILE_PATH" ]; then
        echo "ℹ️  This is a directory"
        # Directories typically need execute permission to be traversed
        local user_perms=${ACTUAL_PERMS:0:1}
        if [ $((user_perms & 1)) -eq 0 ]; then
            echo "⚠️  WARNING: Directory is not executable by owner (cannot be traversed)"
            EXIT_CODE=1
        else
            echo "✅ Directory is executable by owner"
        fi
    else
        echo "ℹ️  This is a regular file"
    fi
}

# Function to display detailed file information
display_file_details() {
    echo "----------------------------------------"
    echo "File Details (Complete): $(ls -l "$FILE_PATH")"
    echo "File Permissions: $(stat -c %A "$FILE_PATH")"
    echo "Owner: $(stat -c %U "$FILE_PATH")"
    echo "Group: $(stat -c %G "$FILE_PATH")"
    echo "Size: $(stat -c %s "$FILE_PATH") bytes"
    echo "Last modified: $(stat -c %y "$FILE_PATH")"
    echo "----------------------------------------"
}

# Main function that orchestrates all operations
main() {
    
    # Step 1: Validate arguments
    validate_arguments "$@"
    
    # Step 2: Check if file exists
    validate_file_exists
    
    # Step 3: Validate permission format
    validate_permission_format
    
    # Step 4: Gather file information
    gather_file_info
    
    # Step 5: Check if permissions match expected
    validate_permissions_match
    
    # Step 6: Check file ownership
    validate_file_ownership
    
    # Step 7: Perform security analysis
    perform_security_analysis
    
    # Step 8: Check directory-specific permissions
    validate_directory_permissions
    
    # Step 9: Display detailed file information
    display_file_details
    
    # Exit with appropriate code
    exit $EXIT_CODE
}

# Call main function with all command-line arguments
main "$@"