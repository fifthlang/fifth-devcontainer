#!/bin/bash
set -e

echo "=== Fifth Language Development Container Setup ==="

# Verify Fifth compiler is available
if command -v fifthc &> /dev/null; then
    echo "✓ Fifth compiler tool version: $(fifthc --version 2>/dev/null || echo 'installed')"
else
    echo "✗ Fifth compiler tool (fifthc) not found in PATH"
    exit 1
fi

# Verify build tools
echo "✓ GCC version: $(gcc --version | head -n1)"

# Verify .NET SDK (for SDK-style projects)
if command -v dotnet &> /dev/null; then
    echo "✓ .NET SDK version: $(dotnet --version)"
fi

# Verify Java (for ANTLR grammar work)
if command -v java &> /dev/null; then
    echo "✓ Java version: $(java -version 2>&1 | head -n1)"
fi

echo ""
echo "=== Setup Complete ==="
echo "You can now build Fifth programs using:"
echo "  dotnet tool restore          # Restore local fifthc tool"
echo "  dotnet build <project.5thproj>"
echo ""
