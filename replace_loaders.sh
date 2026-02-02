#!/bin/bash

# Script to replace all CircularProgressIndicator with BouncingDotsLoader

cd "/Users/Gracegold/Desktop/Ace App/ace_mall_app"

# Find all .dart files with CircularProgressIndicator
files=$(find lib -name "*.dart" -type f -exec grep -l "CircularProgressIndicator" {} \;)

for file in $files; do
    echo "Processing: $file"
    
    # Check if bouncing_dots_loader import already exists
    if ! grep -q "import '../widgets/bouncing_dots_loader.dart';" "$file" && \
       ! grep -q "import 'package:ace_mall_app/widgets/bouncing_dots_loader.dart';" "$file"; then
        
        # Add import after other imports (look for first import statement)
        if grep -q "^import 'package:flutter/material.dart';" "$file"; then
            # Add after material.dart import
            sed -i '' "/^import 'package:flutter\/material.dart';/a\\
import '../widgets/bouncing_dots_loader.dart';
" "$file"
        fi
    fi
    
    # Replace simple CircularProgressIndicator() with BouncingDotsLoader()
    sed -i '' 's/CircularProgressIndicator()/BouncingDotsLoader()/g' "$file"
    
    # Replace CircularProgressIndicator with BouncingDotsLoader (but keep properties for manual review)
    sed -i '' 's/CircularProgressIndicator(/BouncingDotsLoader(/g' "$file"
    
    echo "  ✓ Replaced loaders in $file"
done

echo ""
echo "✅ Completed! Replaced loaders in $(echo "$files" | wc -l | xargs) files"
echo ""
echo "⚠️  Note: Some files may have invalid BouncingDotsLoader properties (strokeWidth, valueColor)"
echo "   These need manual cleanup. Common fixes:"
echo "   - Remove: strokeWidth, valueColor parameters"
echo "   - Use: color and size parameters instead"
