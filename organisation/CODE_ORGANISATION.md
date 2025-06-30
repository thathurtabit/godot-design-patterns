# Godot C# Code Organization System

This document describes a standardized code organization system for Godot C# projects, including automation tools and usage guidelines. This system helps maintain consistent, readable, and maintainable code across your Godot C# project.

## 📋 Requirements

Before using these tools, ensure you have:

- **Python 3.6+** installed and available in your system PATH
- **Bash shell** (Git Bash on Windows, built-in on macOS/Linux)
- **A Godot C# project** with .cs files to organize

To verify your setup:

```bash
python3 --version  # Should show Python 3.6 or higher
bash --version     # Should show bash information
```

## 📋 Organization Standard

All C# classes in your Godot project should follow this standardized member organization pattern:

```csharp
public partial class ClassName : BaseClass
{
    // Fields
    [Export] private ExportType _exportField;
    private PrivateType _privateField;
    protected ProtectedType _protectedField;

    // Properties
    protected PropertyType ProtectedProperty { get; private set; }
    public PropertyType PublicProperty { get; private set; }

    // Virtual properties (for dependency injection)
    protected virtual DependencyType VirtualDependency => DependencyType.Instance;

    // Constants
    private const Type ConstantName = value;

    // Enums
    public enum EnumName
    {
        Value1,
        Value2
    }

    // Signals (Godot-specific)
    [Signal]
    public delegate void SomeEventEventHandler();

    // Public Methods
    public override void _Ready()
    {
        // Implementation
    }

    public override void _ExitTree()
    {
        // Implementation
    }

    public void PublicMethod()
    {
        // Implementation
    }

    // Protected Methods
    protected virtual void ProtectedMethod()
    {
        // Implementation
    }

    // Private Methods
    private void PrivateMethod()
    {
        // Implementation
    }
}
```

## 🛠️ Automation Tools

### 1. Organization Helper Script (Interactive)

**File:** `organization-helper.sh`
**Purpose:** Interactive menu system for project management and status checking

#### Quick Start

```bash
# Make executable (first time only)
chmod +x organization-helper.sh

# Run the interactive menu
./organization-helper.sh
```

#### Menu Options

1. **Show organization pattern** - Display the standardized pattern
2. **Scan project organization status** - Check which files are organized
3. **Show priority files** - View high-impact files for organization
4. **Show files by category** - Browse files by project area
5. **Auto-organize selected files** - Choose specific files to organize
6. **Auto-organize priority files only** - Focus on high-impact files
7. **Auto-organize ALL unorganized files** - Bulk organization with backup
8. **Exit**

### 2. Python Organization Tool (Automation)

**File:** `code-organization-tool.py`
**Purpose:** Performs the actual file reorganization with advanced safety features

#### Command Line Usage

```bash
# Scan project status only
py code-organization-tool.py --scan

# Organize a specific file
py code-organization-tool.py --file "path/to/file.cs"

# Batch organize with custom batch size
py code-organization-tool.py --batch-size 5

# Organize all files without pauses
py code-organization-tool.py --no-pause

# Organize specific project directory
py code-organization-tool.py /path/to/project
```

#### Safety Features

- **Automatic backups** created outside project directory
- **Godot [Signal] and [Export] preservation**
- **Build validation** after changes
- **Smart file filtering** (skips auto-generated, static-only, interface-only files)
- **Batch processing** with user confirmation
- **Error handling** with detailed logging

## 📊 Project Status Example

**Example from a completed project:**

- ✅ **67 relevant C# files** in project
- ✅ **67 properly organized** (100%)
- ✅ **0 files needing organization**
- ✅ **0 build errors or warnings**

> **Note:** Your project status will be displayed when you run the scanning tools.

## 🚀 Quick Commands Reference

### Daily Status Check

```bash
./organization-helper.sh
# Select option 2: "Scan project organization status"
```

### Organize New Files

```bash
# Interactive selection
./organization-helper.sh
# Select option 5: "Auto-organize selected files"

# Or directly with Python tool
py code-organization-tool.py --batch-size 3
```

### Bulk Organization (for major changes)

```bash
# With backup and confirmation
./organization-helper.sh
# Select option 7: "Auto-organize ALL unorganized files"
```

### Check Specific File

```bash
py code-organization-tool.py --file "scripts/path/to/YourFile.cs"
```

### Project-wide Scan

```bash
py code-organization-tool.py --scan
```

## 📁 File Categories

The system recognizes and handles these file types:

### ✅ Standard Classes

- Instance classes with fields, properties, and methods
- Partial classes
- Classes with inheritance
- **Requires:** Standard organization pattern

### ✅ Static Classes

- Classes marked with `public static class`
- Utility classes with only static members
- **Handling:** Auto-recognized as organized (no standard pattern needed)

### ✅ Data Types

- Structs, records, enums
- Simple data containers
- **Handling:** Minimal organization based on content

### ✅ Godot-Specific

- Classes with `[Export]` attributes
- Classes with `[Signal]` declarations
- Node-derived classes
- **Handling:** Special preservation of Godot attributes

### ❌ Auto-Excluded

- Interface-only files
- Enum-only files
- Auto-generated files (`/.godot/`, `/obj/`, `/bin/`)
- AssemblyInfo.cs files
- Files with `.generated.` in name

## 🔧 Maintenance

### Adding New Files

1. Write your C# class normally
2. Run `./organization-helper.sh` → option 2 to check status
3. If needed, run option 5 to organize new files

### After Major Refactoring

1. Run `./organization-helper.sh` → option 7 for bulk organization
2. Review backup directory if needed
3. Test build: `dotnet build`

### Troubleshooting

#### Build Errors After Organization

```bash
# Check for missing signals/exports
dotnet build

# If errors, restore from backup:
cp -r /path/to/backup/* ./
```

#### False Positives in Status Check

- Static classes are correctly marked as "organized (static class)"
- Empty classes are marked as "organized (no organizable content)"
- This is expected behavior

#### Tool Synchronization Issues

Both tools should report the same status. If not:

1. Update both tools to latest version
2. Check for new file types that need special handling

## 📝 VS Code Integration

### Tasks Configuration

Add this to your project's `.vscode/tasks.json` file (create the file and directory if they don't exist):

**File:** `.vscode/tasks.json`

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Check Code Organization",
      "type": "shell",
      "command": "py",
      "args": ["code-organization-tool.py", "--scan"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      },
      "problemMatcher": []
    },
    {
      "label": "Organize Code (Interactive)",
      "type": "shell",
      "command": "./organization-helper.sh",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": true,
        "panel": "shared"
      },
      "problemMatcher": []
    }
  ]
}
```

### Running Tasks

- **Ctrl+Shift+P** → "Tasks: Run Task"
- Select "Check Code Organization" or "Organize Code (Interactive)"

## 🎯 Best Practices

### When to Organize

- **After adding new classes**
- **Before major commits**
- **During code reviews**
- **When onboarding new team members**

### Workflow Integration

1. Write code normally
2. Organize before committing
3. Review organization in PRs
4. Maintain consistency across team

### Team Usage

- All team members should use the same tools
- Include organization check in CI/CD pipeline
- Document any project-specific modifications

## 🏆 Benefits Achieved

✅ **Consistency** - All files follow same pattern
✅ **Readability** - Easy to find class members
✅ **Maintainability** - Predictable code structure
✅ **Automation** - Minimal manual effort required
✅ **Safety** - Backups and validation built-in
✅ **Godot Compatibility** - Preserves engine-specific attributes

## 📞 Support

If you encounter issues:

1. **Check this README** for common solutions
2. **Run status check** to verify current state
3. **Check backup directories** if files need restoration
4. **Validate build** with `dotnet build` after changes

---

_This code organization system helps improve code consistency, readability, and maintainability across Godot C# projects. The automation tools ensure minimal overhead while maintaining high standards._

## 🚀 Getting Started

1. **Download** the organization tools (`organization-helper.sh` and `code-organization-tool.py`)
2. **Place them** in your project's root directory or a dedicated `tools/` folder
3. **Update** the `PROJECT_ROOT` variable in `organization-helper.sh` to point to your project
4. **Make executable:** `chmod +x organization-helper.sh`
5. **Run:** `./organization-helper.sh` and select option 2 to scan your project

## 📄 License

This code organization system is provided as-is for use in Godot C# projects. Feel free to modify and adapt it to your specific needs.
