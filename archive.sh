#!/bin/bash

# Define the output ZIP file name
ARCHIVE_NAME="sandbox-sandbox"

# Find and zip all visible files and folders in the current directory
zip -r "$ARCHIVE_NAME" *

# Print completion message
echo "All visible files and folders have been zipped into: $ARCHIVE_NAME"
