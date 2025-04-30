#!/bin/sh
# Pre-processor used by fz and ripgrep to search pdf's and zsd files
case "$1" in
  *.pdf)
    # The -s flag ensures that the file is non-empty.
    if [ -s "$1" ]; then
      exec pdftotext "$1" -
    else
      exec cat
    fi
    ;;
  *)
    case $(file "$1") in
      *Zstandard*)
        exec pzstd -cdq "$1"
        ;;
      *)
        exec cat
        ;;
    esac
    ;;
esac
