#!/bin/bash

set -x 

# Function to reset HTML index base64 in settings.json with multiple input files
# Usage: reset_html_index "settings_file_path" "file1.html:no_server" "file2.html:conf_mismatch" "file3.html:no_rule"
reset_html_index() {
    local settings_file="$1"
    shift
    local file_mappings=("$@")
    
    # Pass the file mappings as arguments to Python
    python3 - "${file_mappings[@]}" << RESET_EOF
import sys
import json
import base64
import os

settings_file = "${settings_file}"

def reset_html_index_base64(settings_file, file_mappings):
    """
    Reset nginx.default fields in a settings JSON file by encoding HTML files to base64
    
    Args:
        settings_file: Path to the settings JSON file to update
        file_mappings: List of strings in format "filepath:field_name"
                       e.g., ["html/index.html:no_server", "html/prod.html:conf_mismatch"]
    """
    try:
        # Check if settings file exists
        if not os.path.exists(settings_file):
            print(f"✗ Error: Settings file not found - {settings_file}")
            sys.exit(1)
            
        # Read settings.json
        with open(settings_file, 'r') as f:
            settings = json.load(f)
        
        # Verify nginx.default structure exists
        if 'nginx' not in settings or 'default' not in settings['nginx']:
            print("✗ Error: nginx.default structure not found in settings.json")
            sys.exit(1)
        
        # Process each file mapping
        updates_made = []
        for mapping in file_mappings:
            if not mapping.strip():
                continue
                
            parts = mapping.strip().split(':')
            if len(parts) != 2:
                print(f"⚠ Warning: Invalid mapping format '{mapping}'. Expected 'filepath:field_name'")
                continue
            
            file_path, field_name = parts
            
            # Check if file exists
            if not os.path.exists(file_path):
                print(f"✗ Error: File not found - {file_path}")
                sys.exit(1)
            
            # Read the HTML file and encode to base64
            with open(file_path, 'r') as html_file:
                html_content = html_file.read()
                base64_content = base64.b64encode(html_content.encode('utf-8')).decode('utf-8')
            
            # Update the specified field
            settings['nginx']['default'][field_name] = base64_content
            updates_made.append(f"{field_name} ← {file_path}")
            print(f"✓ Updated nginx.default.{field_name} with base64 from {file_path}")
        
        if not updates_made:
            print("⚠ Warning: No updates were made")
            return False
        
        # Write back to settings.json
        with open(settings_file, 'w') as f:
            json.dump(settings, f, indent=4)
        
        print(f"\n✓ Successfully updated {settings_file}")
        print(f"  Updated {len(updates_made)} field(s):")
        for update in updates_made:
            print(f"  - {update}")
        return True
        
    except FileNotFoundError as e:
        print(f"✗ Error: File not found - {e}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"✗ Error: Invalid JSON in settings file - {e}")
        sys.exit(1)
    except Exception as e:
        print(f"✗ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    # Get file mappings from command line arguments (skip first arg which is '-')
    mappings = sys.argv[1:]
    if not mappings:
        print("✗ Error: No file mappings provided")
        print("Usage: Provide settings file path and mappings in format 'filepath:field_name'")
        sys.exit(1)
    
    reset_html_index_base64(settings_file, mappings)
RESET_EOF
}

# Example usage based on environment
if [ -z "$ENV_REF" ]; then
    ENV_REF="dev"
fi

# Default settings file (can be overridden)
if [ -z "$SETTINGS_FILE" ]; then
    SETTINGS_FILE="data/settings.json"
fi

echo "Environment: $ENV_REF"
echo "Settings file: $SETTINGS_FILE"
echo "Resetting HTML index in settings file..."

case "$ENV_REF" in
    prod)
        echo "Processing production environment files..."
        reset_html_index \
            "$SETTINGS_FILE" \
            "html/index.html:no_server" \
            "html/index.html:conf_mismatch" \
            "html/index.html:no_rule"
        ;;
    acc)
        echo "Processing acceptance environment files..."
        reset_html_index \
            "$SETTINGS_FILE" \
            "html/index.html:no_server" \
            "html/index.html:conf_mismatch" \
            "html/index.html:no_rule"
        ;;
    dev)
        echo "Processing development environment files..."
        reset_html_index \
            "$SETTINGS_FILE" \
            "html/index.html:no_server" \
            "html/index.html:conf_mismatch" \
            "html/index.html:no_rule"
        ;;
    *)
        echo "Processing default environment files..."
        reset_html_index \
            "$SETTINGS_FILE" \
            "html/index.html:no_server" \
            "html/index.html:conf_mismatch" \
            "html/index.html:no_rule"
        ;;
esac

# Direct function call for testing
echo ""
echo "============================================"
echo "Testing direct function call..."
echo "============================================"
reset_html_index "data/settings.json" "html/index.html:no_server" "html/index.html:conf_mismatch" "html/index.html:no_rule"
reset_html_index "data/sample-settings.json" "html/index.html:no_server" "html/index.html:conf_mismatch" "html/index.html:no_rule"