#!/bin/bash
# Godot C# Code Organization Tools - Setup Script
# This script helps set up the code organization tools in your Godot project

echo "🚀 Godot C# Code Organization Tools - Setup"
echo "============================================"
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check for Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    echo "✅ $PYTHON_VERSION"
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version 2>&1)
    # Check if it's Python 3
    if [[ "$PYTHON_VERSION" == *"Python 3"* ]]; then
        echo "✅ $PYTHON_VERSION"
        PYTHON_CMD="python"
    else
        echo "❌ Python 3 is required, but found: $PYTHON_VERSION"
        echo "   Please install Python 3.6+ from https://python.org"
        exit 1
    fi
else
    echo "❌ Python not found in PATH"
    echo "   Please install Python 3.6+ from https://python.org"
    echo "   Make sure it's available in your system PATH"
    exit 1
fi

# Check for bash (should be available since we're running in bash)
BASH_VERSION=$(bash --version 2>&1 | head -n 1)
echo "✅ $BASH_VERSION"

echo ""

# Check if we're in a Godot project
if [[ ! -f "project.godot" ]]; then
    echo "⚠️  Warning: project.godot not found in current directory."
    echo "   Make sure you're running this from your Godot project root."
    echo ""
    read -p "Continue anyway? (y/N): " continue_anyway
    if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled."
        exit 1
    fi
fi

# Get the current directory
CURRENT_DIR="$(pwd)"
TOOLS_DIR="$CURRENT_DIR"

echo "📁 Project Directory: $CURRENT_DIR"
echo ""

# Option to create a tools subdirectory
read -p "📂 Create a 'tools/' subdirectory for organization scripts? (y/N): " create_tools_dir
if [[ "$create_tools_dir" =~ ^[Yy]$ ]]; then
    TOOLS_DIR="$CURRENT_DIR/tools"
    mkdir -p "$TOOLS_DIR"
    echo "✅ Created tools/ directory"
fi

echo "📁 Tools will be installed in: $TOOLS_DIR"
echo ""

# Check if files already exist
if [[ -f "$TOOLS_DIR/organization-helper.sh" ]]; then
    echo "⚠️  Files already exist in target directory:"
    ls -la "$TOOLS_DIR"/*.{sh,py,md} 2>/dev/null | head -5
    echo ""
    read -p "Overwrite existing files? (y/N): " overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled."
        exit 1
    fi
fi

# Function to update PROJECT_ROOT in shell script
update_project_root() {
    local script_path="$1"
    local project_path="$2"
    
    if [[ "$TOOLS_DIR" != "$CURRENT_DIR" ]]; then
        # If tools are in subdirectory, use relative path to project root
        project_path="../"
    else
        # If tools are in project root, use current directory
        project_path="\$(pwd)"
    fi
    
    # Update the PROJECT_ROOT line
    sed -i.bak "s|PROJECT_ROOT=\".*\"|PROJECT_ROOT=\"$project_path\"|" "$script_path"
    rm "$script_path.bak" 2>/dev/null
    
    echo "✅ Updated PROJECT_ROOT to: $project_path"
}

# Copy files (this would normally copy from the source, but for demo we'll create placeholders)
echo "📋 Setting up organization files..."

# Note: In a real deployment, you would copy the actual files here
# For this example, we'll assume the files are already present in the current directory

if [[ -f "organization-helper.sh" ]]; then
    cp "organization-helper.sh" "$TOOLS_DIR/"
    chmod +x "$TOOLS_DIR/organization-helper.sh"
    update_project_root "$TOOLS_DIR/organization-helper.sh" "$CURRENT_DIR"
    echo "✅ Installed organization-helper.sh"
else
    echo "❌ organization-helper.sh not found in current directory"
fi

if [[ -f "code-organization-tool.py" ]]; then
    cp "code-organization-tool.py" "$TOOLS_DIR/"
    echo "✅ Installed code-organization-tool.py"
else
    echo "❌ code-organization-tool.py not found in current directory"
fi

if [[ -f "CODE_ORGANISATION.md" ]]; then
    cp "CODE_ORGANISATION.md" "$TOOLS_DIR/"
    echo "✅ Installed CODE_ORGANISATION.md"
else
    echo "❌ CODE_ORGANISATION.md not found in current directory"
fi

if [[ -f "README.md" ]]; then
    cp "README.md" "$TOOLS_DIR/TOOLS_README.md"
    echo "✅ Installed TOOLS_README.md"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Review the configuration in $TOOLS_DIR/organization-helper.sh"
echo "2. Run your first scan:"
if [[ "$TOOLS_DIR" != "$CURRENT_DIR" ]]; then
    echo "   cd tools && ./organization-helper.sh"
else
    echo "   ./organization-helper.sh"
fi
echo "3. Select option 2 to scan your project"
echo "4. Read $TOOLS_DIR/CODE_ORGANISATION.md for detailed usage"
echo ""
echo "🛠️  Quick Commands:"
if [[ "$TOOLS_DIR" != "$CURRENT_DIR" ]]; then
    echo "   cd tools"
fi
echo "   ./organization-helper.sh              # Interactive menu"
echo "   $PYTHON_CMD code-organization-tool.py --scan  # Quick scan"
echo ""
echo "📖 Documentation: $TOOLS_DIR/CODE_ORGANISATION.md"
echo ""
echo "Happy organizing! 🎮✨"
