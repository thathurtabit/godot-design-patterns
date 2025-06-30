# Godot C# Code Organization Tools

A comprehensive set of tools to standardize and organize C# code in Godot projects. These tools help maintain consistent, readable, and maintainable code across your entire Godot C# project.

### NOTE!

Remember to have a clean working directory before running these tools, as they will modify your C# files and create backups.

If something goes wrong, you can always discard the changes and restore from the backups created by the tools - or use version control to revert changes.

## 🎯 What This Does

This system automatically organizes your C# classes according to a standardized pattern:

1. **Fields** (including `[Export]` decorated fields)
2. **Properties**
3. **Virtual Properties** (for dependency injection)
4. **Constants**
5. **Enums**
6. **Signals** (Godot `[Signal]` declarations)
7. **Public Methods**
8. **Protected Methods**
9. **Private Methods**

## � Requirements

Before using these tools, ensure you have:

- **Python 3.6+** installed and available in your system PATH
  - Windows: Download from [python.org](https://python.org) or install via Microsoft Store
  - macOS: `brew install python3` or download from python.org
  - Linux: `sudo apt install python3` (Ubuntu/Debian) or equivalent for your distro
- **Bash shell** (for the interactive helper script)
  - Windows: Use Git Bash, WSL, or PowerShell with bash compatibility
  - macOS/Linux: Built-in bash shell
- **A Godot C# project** with .cs files to organize

### Verify Installation

```bash
# Check Python is installed
python3 --version
# or on some systems:
python --version

# Check bash is available
bash --version
```

## �🚀 Quick Start

1. **Download** the files to your project:

   - `organization-helper.sh` (interactive menu system)
   - `code-organization-tool.py` (automation engine)
   - `CODE_ORGANISATION.md` (detailed documentation)

2. **Place them** in your project root or create a `tools/` folder

3. **Update the project path** in `organization-helper.sh`:

   ```bash
   # Edit this line to point to your project
   PROJECT_ROOT="$(pwd)"  # Uses current directory
   # Or set absolute path:
   # PROJECT_ROOT="/path/to/your/godot/project"
   ```

4. **Make executable and run**:

   ```bash
   chmod +x organization-helper.sh
   ./organization-helper.sh
   ```

5. **Select option 2** to scan your project and see current status

## 🛠️ Tools Overview

### Interactive Shell Script (`organization-helper.sh`)

- **Purpose**: User-friendly menu system for project management
- **Features**: Status checking, selective organization, bulk operations
- **Best for**: Daily workflow, reviewing project status

### Python Automation Tool (`code-organization-tool.py`)

- **Purpose**: Performs the actual file reorganization
- **Features**: Safety backups, Godot-specific handling, batch processing
- **Best for**: Automation, integration with build systems

## 📋 Organization Example

### Before:

```csharp
public partial class Player : CharacterBody2D
{
    public void Jump() { }

    [Export] private float _speed = 100f;

    public float Health { get; set; }

    private void UpdateMovement() { }

    [Signal] public delegate void HealthChangedEventHandler(float newHealth);

    protected virtual void Die() { }
}
```

### After:

```csharp
public partial class Player : CharacterBody2D
{
    // Fields
    [Export] private float _speed = 100f;

    // Properties
    public float Health { get; set; }

    // Signals
    [Signal] public delegate void HealthChangedEventHandler(float newHealth);

    // Public Methods
    public void Jump()
    {
        // Implementation
    }

    // Protected Methods
    protected virtual void Die()
    {
        // Implementation
    }

    // Private Methods
    private void UpdateMovement()
    {
        // Implementation
    }
}
```

## 🔧 Command Examples

### Check Project Status

```bash
# Interactive menu
./organization-helper.sh

# Direct scan
python code-organization-tool.py --scan
```

### Organize Specific File

```bash
python code-organization-tool.py --file "scripts/Player.cs"
```

### Organize All Files

```bash
# With interactive batching
python code-organization-tool.py

# All files without pausing
python code-organization-tool.py --no-pause

# Using #region blocks instead of comments
python code-organization-tool.py --regions
```

## 💡 Customization

### Update Priority Files

Edit the `priority_patterns` array in `organization-helper.sh`:

```bash
priority_patterns=(
    "**/YourGameManager.cs"
    "**/YourPlayerController.cs"
    "**/YourCustomSystem.cs"
)
```

### Update File Categories

Edit the `categories` array to match your project structure:

```bash
categories=(
    "Player Scripts:player"
    "Enemy Scripts:enemies"
    "UI Scripts:ui"
    # Add your own patterns
)
```

## ⚠️ Safety Features

- **Automatic backups** created before any changes
- **Godot attribute preservation** (`[Export]`, `[Signal]`, etc.)
- **File validation** before and after organization
- **Smart filtering** (skips auto-generated files, interfaces-only, etc.)
- **Build compatibility** (backups stored outside project to avoid build issues)

## 🎮 Godot-Specific Features

### Preserved Godot Attributes

- `[Export]` property declarations
- `[Signal]` delegate declarations
- `[Rpc]` method attributes
- Node-specific overrides (`_Ready()`, `_Process()`, etc.)

### Smart File Detection

- Automatically skips `.godot/` generated files
- Ignores `obj/` and `bin/` build artifacts
- Handles partial classes correctly
- Preserves scene file associations

## 📁 Supported Project Structures

The tools automatically detect common Godot project patterns:

- `scripts/` (most common)
- `Scripts/` (capitalized)
- `src/` (source folder)
- Root-level C# files
- Nested folder structures

## 🔄 Workflow Integration

### Daily Development

1. Write code normally
2. Run quick status check: `./organization-helper.sh` → option 2
3. Organize new files as needed: option 5

### Before Commits

1. Organize all unorganized files: `./organization-helper.sh` → option 7
2. Review changes before committing
3. Build and test to ensure everything works

### Team Usage

- All team members use the same tools
- Include organization check in code reviews
- Consider adding to CI/CD pipeline

## 🆘 Troubleshooting

### Build Errors After Organization

```bash
# Check what was changed
dotnet build

# If needed, restore from backup
cp -r /path/to/backup/* ./
```

### Tool Not Finding Files

1. Verify `PROJECT_ROOT` path in shell script
2. Check that your project has `.cs` files
3. Ensure you're running from correct directory

### False Organization Status

- Static-only classes are correctly marked as "organized"
- Interface-only files are skipped (expected behavior)
- Empty classes show as "organized (no organizable content)"

## 📄 License

These tools are provided as-is for use in Godot C# projects. Feel free to modify and adapt them to your specific needs.

## 🤝 Contributing

Found an issue or have an improvement? These tools are designed to be easily customizable for different project needs. Common modifications include:

- Adding new file type patterns
- Customizing organization sections
- Adding project-specific validations
- Integrating with build systems

## 🔗 Related Files

- `CODE_ORGANISATION.md` - Comprehensive documentation
- `organization-helper.sh` - Interactive menu system
- `code-organization-tool.py` - Automation engine

---

_Happy coding! 🎮✨_
