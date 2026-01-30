#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <new-project-name>"
    exit 1
fi

NEW_NAME="$1"
NEW_NAME_LOWER=$(echo "$NEW_NAME" | tr '[:upper:]' '[:lower:]' | tr '-' '_')
NEW_NAME_UPPER=$(echo "$NEW_NAME_LOWER" | tr '[:lower:]' '[:upper:]')
NEW_NAME_CAMEL=$(echo "$NEW_NAME" | sed -r 's/(^|[-_])([a-z])/\U\2/g' | tr -d '-' | tr -d '_')
NEW_NAME_HYPHEN=$(echo "$NEW_NAME" | tr '[:upper:]' '[:lower:]' | tr '_' '-')

echo "=========================================="
echo "Renaming project to: $NEW_NAME"
echo "=========================================="
echo "Lowercase:  $NEW_NAME_LOWER"
echo "Uppercase:  $NEW_NAME_UPPER"
echo "CamelCase:  $NEW_NAME_CAMEL"
echo "Hyphenated: $NEW_NAME_HYPHEN (for vcpkg)"
echo "=========================================="

# Function to replace in file
replace_in_file() {
  local file="$1"
  if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS (BSD sed requires '' for no backup)
      sed -i '' 's/\${PROJECT_NAME}/__CMAKEVAR_PROJNAME__/g' "$file"
      sed -i '' "s/PROJECT_NAME_LOWER/$NEW_NAME_LOWER/g" "$file"
      sed -i '' "s/PROJECT_NAME_UPPER/$NEW_NAME_UPPER/g" "$file"
      sed -i '' "s/PROJECT_NAME_CAMEL/$NEW_NAME_CAMEL/g" "$file"
      sed -i '' "s/project-name/$NEW_NAME_HYPHEN/g" "$file"
      sed -i '' "s/PROJECT_NAME/$NEW_NAME/g" "$file"
      sed -i '' 's/__CMAKEVAR_PROJNAME__/${PROJECT_NAME}/g' "$file"
  elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
      # Linux, Git Bash, MSYS2, Cygwin (GNU sed)
      sed -i 's/\${PROJECT_NAME}/__CMAKEVAR_PROJNAME__/g' "$file"
      sed -i "s/PROJECT_NAME_LOWER/$NEW_NAME_LOWER/g" "$file"
      sed -i "s/PROJECT_NAME_UPPER/$NEW_NAME_UPPER/g" "$file"
      sed -i "s/PROJECT_NAME_CAMEL/$NEW_NAME_CAMEL/g" "$file"
      sed -i "s/project-name/$NEW_NAME_HYPHEN/g" "$file"
      sed -i "s/PROJECT_NAME/$NEW_NAME/g" "$file"
      sed -i 's/__CMAKEVAR_PROJNAME__/${PROJECT_NAME}/g' "$file"
  else
      echo "Warning: Unsupported OS type: $OSTYPE"
      echo "Please run this script in Git Bash, WSL, or a Unix-like environment"
      exit 1
  fi
}

# Export function for find -exec
export -f replace_in_file
export NEW_NAME_LOWER NEW_NAME_UPPER NEW_NAME_CAMEL NEW_NAME NEW_NAME_HYPHEN

# Replace in CMakeLists.txt files
echo "Updating CMakeLists.txt files..."
find . -name "CMakeLists.txt" -type f -exec bash -c 'replace_in_file "$0"' {} \;

# Replace in source files
echo "Updating source files..."
find src include tests -type f \( -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \) -exec bash -c 'replace_in_file "$0"' {} \; 2>/dev/null || true

# Replace in vcpkg.json
if [ -f "vcpkg.json" ]; then
    echo "Updating vcpkg.json..."
    replace_in_file "vcpkg.json"
fi

# Replace in README.md
if [ -f "README.md" ]; then
    echo "Updating README.md..."
    replace_in_file "README.md"
fi

# Rename include directory
if [ -d "include/PROJECT_NAME_LOWER" ]; then
    echo "Renaming include directory..."
    mv "include/PROJECT_NAME_LOWER" "include/$NEW_NAME_LOWER"
fi

# Remove the rename workflow and script after execution
echo "Cleaning up rename artifacts..."
rm -f .github/workflows/rename-project.yml
rm -f scripts/rename_project.sh

echo ""
echo "=========================================="
echo "Project renamed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff"
echo "  2. Update README.md with project description"
echo "  3. Commit changes: git add . && git commit -m 'Initialize project from template'"
echo ""
