md5dir() {
  if [ -d "$1" ]; then  # Check if directory exists
    md5sum "$1"/**/* 2>/dev/null | cut -d ' ' -f1 | md5sum | cut -d ' ' -f1
  else
    echo "Error: Directory '$1' not found." >&2  # Print to standard error
  fi
}
