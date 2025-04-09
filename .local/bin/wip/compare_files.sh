#!/bin/bash

# Automator saves workflows such as Quick Actions in ~/Library/Services/

if [[ "$#" -ne 2 ]]; then
    osascript -e 'display dialog "Select exactly two files to compare." buttons {"OK"} default button "OK"'
    exit 1
fi

# Function to compare PDF files
compare_pdfs() {
    if ! command -v diff-pdf >/dev/null; then
        osascript -e 'display dialog "diff-pdf is not installed. Please install it with Homebrew and try again." buttons {"OK"} default button "OK"'
        exit 1
    fi

    # Compare PDFs visually with diff-pdf
    diff-pdf --view "$1" "$2"

    # Uncomment to generate a difference PDF
    # diff-pdf --output-diff="/path/to/output_diff.pdf" "$file1" "$file2"
}

# Function to compare binary files
compare_binary_files() {
    # # Use `xxd` for binary comparison
    # diff_output=$(diff <(xxd "$file1") <(xxd "$file2"))
    # if [[ -n "$diff_output" ]]; then
    #     echo "$diff_output" | open -f -a TextEdit
    # else
    #     osascript -e 'display dialog "Binary files have differences!" buttons {"OK"} default button "OK"'
    # fi

    if ! open -Ra "Hex Fiend"; then
        osascript -e 'display dialog "Hex Fiend is not installed. Please install it and try again." buttons {"OK"} default button "OK"'
        exit 1
    fi

    open -a "Hex Fiend" --args --compare "$1" "$2"
}

compare_text_files() {
    ## Use `diff` for text comparison
    #diff "$file1" "$file2" | open -f -a TextEdit

    # Use Xcode FileMerge
    opendiff "$1" "$2"
}

# Compare file hashes
hash1=$(shasum -a 256 "$1" | awk '{print $1}')
hash2=$(shasum -a 256 "$2" | awk '{print $1}')

if [[ "$hash1" == "$hash2" ]]; then
    osascript -e 'display dialog "Files are identical (content-wise)!" buttons {"OK"} default button "OK"'
else
    # Detect file types
    file1_type=$(file --mime-type -b "$1")
    file2_type=$(file --mime-type -b "$2")

    # Determine if files are binary or text
    if [[ "$file1_type" == "text/plain" && "$file2_type" == "text/plain" ]]; then
        compare_text_files "$1" "$2"
    elif [[ "$file1_type" == "application/pdf" && "$file2_type" == "application/pdf" ]]; then
        compare_pdfs "$1" "$2"
    else
        compare_binary_files "$1" "$2"
    fi
fi
