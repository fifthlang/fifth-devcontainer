#!/bin/bash
set -e

echo "=== Fifth Language Development Container Setup ==="

# Verify Fifth compiler is available
if command -v fifth &> /dev/null; then
    echo "✓ Fifth compiler version: $(fifth --version 2>/dev/null || echo 'installed')"
else
    echo "✗ Fifth compiler not found in PATH"
    exit 1
fi

# Verify build tools
echo "✓ Make version: $(make --version | head -n1)"
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
echo "  fifth <source.5th>           # Compile a Fifth program"
echo "  make                         # If using a Makefile"
echo ""