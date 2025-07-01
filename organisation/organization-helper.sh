#!/bin/bash
# Godot C# Code Organization Helper Script
# This script helps apply the standardized organization pattern to C# files in Godot projects

# ✅ COMMENT PRESERVATION: The Python organization tool preserves ALL comments:
#    - XML documentation comments (/// <summary>, /// <param>, etc.)
#    - Regular comments (//)
#    - Multi-line comments (/* */)
#    - All comments are kept with their associated members

echo "🚀 Godot C# Code Organization Helper"
echo "===================================="

# Set project root 
# Update this path to your actual project root
PROJECT_ROOT="$(pwd)"
# You can also set an absolute path like:
# PROJECT_ROOT="/path/to/your/godot/project"
# Windows: "C:/path/to/your/godot/project"
# macOS/Linux: "/Users/username/path/to/your/godot/project"

# Counter for statistics
TOTAL_FILES=0
ORGANIZED_FILES=0

# Check for Python availability and set the command
check_python() {
    if command -v py &> /dev/null; then
        PYTHON_CMD="py"
    elif command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &> /dev/null; then
        PYTHON_CMD="python"
    else
        echo "❌ Python not found in PATH"
        echo "   Please install Python 3.6+ from https://python.org"
        echo "   Make sure it's available in your system PATH"
        echo "   Then restart your terminal and try again."
        return 1
    fi
    
    # Verify it's Python 3
    if ! $PYTHON_CMD --version 2>&1 | grep -q "Python 3"; then
        echo "❌ Python 3 is required, but found: $($PYTHON_CMD --version 2>&1)"
        echo "   Please install Python 3.6+ from https://python.org"
        return 1
    fi
    
    return 0
}

# Function to get relative path (cross-platform)
get_relative_path() {
    local file="$1"
    local base="$2"
    # Remove the base directory and leading slash
    echo "${file#$base/}"
}

# Function to count C# files
count_cs_files() {
    find "$PROJECT_ROOT" -name "*.cs" | wc -l
}

# Function to list unorganized files (files that don't have the standardized comments)
list_unorganized_files() {
    echo "📋 Scanning for files that need organization..."
    echo ""

    while IFS= read -r -d '' file; do
        # Skip auto-generated files and temp files
        if [[ "$file" == *"/.godot/"* ]] || [[ "$file" == *"/temp/"* ]] || [[ "$file" == *"/obj/"* ]] || [[ "$file" == *"/bin/"* ]]; then
            continue
        fi

        # Skip files with .generated. in the name
        if [[ "$(basename "$file")" == *".generated."* ]]; then
            continue
        fi        # Skip AssemblyInfo.cs files
        if [[ "$(basename "$file")" == "AssemblyInfo.cs" ]] || [[ "$(basename "$file")" == *".AssemblyInfo.cs" ]]; then
            continue
        fi

        # Check if file contains any class, struct, record, or enum declarations (not just interfaces)
        if ! grep -E "^\s*(public|private|protected|internal|abstract|partial|static|sealed).*\s+(class|struct|record|enum)\s+" "$file" >/dev/null; then
            continue
        fi

        # Skip files that only contain interfaces
        class_count=$(grep -cE "^\s*(public|private|protected|internal|abstract|partial|static|sealed).*\s+(class|struct|record|enum)\s+" "$file")
        interface_count=$(grep -cE "^\s*(public|private|protected|internal).*\s+interface\s+" "$file")

        if [ "$class_count" -eq 0 ] && [ "$interface_count" -gt 0 ]; then
            continue
        fi

        # Skip enum-only files
        enum_count=$(grep -cE "^\s*(public|private|protected|internal).*\s+enum\s+" "$file")
        non_enum_count=$(grep -cE "^\s*(public|private|protected|internal|abstract|partial|static|sealed).*\s+(class|struct|record)\s+" "$file")

        if [ "$enum_count" -gt 0 ] && [ "$non_enum_count" -eq 0 ]; then
            continue
        fi

        TOTAL_FILES=$((TOTAL_FILES + 1))

        # Check if this is a static-only class
        static_class_count=$(grep -cE "^\s*public\s+static\s+class\s+" "$file")
        if [ "$static_class_count" -gt 0 ]; then
            # Static classes typically don't need standard organization
            ORGANIZED_FILES=$((ORGANIZED_FILES + 1))
            echo "✅ $(basename "$file") - Already organized (static class)"
            continue
        fi

        # Check if file actually has content that needs organizing
        has_fields=$(grep -c "^\s*\(private\|protected\|public\|internal\).*\s\+\w\+\s*;" "$file")
        has_properties=$(grep -c "{\s*get\|set" "$file")
        has_methods=$(grep -c "^\s*\(public\|protected\|private\|internal\).*\s\+\w\+\s*(" "$file")
        has_exports=$(grep -c "\[Export\]" "$file")
        has_signals=$(grep -c "\[Signal\]" "$file")

        # If file has no organizable content, consider it organized
        total_organizable=$((has_fields + has_properties + has_methods + has_exports + has_signals))

        if [ "$total_organizable" -eq 0 ]; then
            ORGANIZED_FILES=$((ORGANIZED_FILES + 1))
            echo "✅ $(basename "$file") - Already organized (no organizable content)"
        else
            # Check if file has the standardized organization comments (both // and #region styles)
            if grep -q "// Fields\|// Properties\|// Public Methods\|// Protected Methods\|// Private Methods\|#region.*Fields\|#region.*Properties\|#region.*Methods" "$file"; then
                ORGANIZED_FILES=$((ORGANIZED_FILES + 1))
                echo "✅ $(basename "$file") - Already organized"
            else
                echo "❓ $(basename "$file") - Needs organization"
                echo "   📂 $(dirname "$file")"
            fi
        fi
    done < <(find "$PROJECT_ROOT" -name "*.cs" -print0)

    echo ""
    echo "📊 Organization Status:"
    echo "   📁 Total C# files: $TOTAL_FILES"
    echo "   ✅ Already organized: $ORGANIZED_FILES"
    echo "   ❓ Need organization: $((TOTAL_FILES - ORGANIZED_FILES))"
}

# Function to show the standardized pattern
show_pattern() {
    echo "📋 Standardized C# Class Organization Pattern:"
    echo "=============================================="
    echo ""
    echo "Style 1: Traditional // Comments"
    echo "--------------------------------"
    cat << 'EOF'

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

EOF

    echo ""
    echo "Style 2: #region Blocks"
    echo "----------------------"
    cat << 'EOF'

public partial class ClassName : BaseClass
{
    #region Fields
    [Export] private ExportType _exportField;
    private PrivateType _privateField;
    protected ProtectedType _protectedField;
    #endregion

    #region Properties
    protected PropertyType ProtectedProperty { get; private set; }
    public PropertyType PublicProperty { get; private set; }
    #endregion

    #region Virtual Properties
    protected virtual DependencyType VirtualDependency => DependencyType.Instance;
    #endregion

    #region Constants
    private const Type ConstantName = value;
    #endregion

    #region Enums
    public enum EnumName
    {
        Value1,
        Value2
    }
    #endregion

    #region Public Methods
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
    #endregion

    #region Protected Methods
    protected virtual void ProtectedMethod()
    {
        // Implementation
    }
    #endregion

    #region Private Methods
    private void PrivateMethod()
    {
        // Implementation
    }
    #endregion
}

EOF
}

# Function to show priority files for manual organization
show_priority_files() {
    echo "🎯 Priority Files for Organization (High Impact):"
    echo "================================================"

    # Define common priority file patterns (update these for your project)
    priority_patterns=(
        "**/SceneManager.cs"
        "**/GameManager.cs"
        "**/PlayerController.cs"
        "**/GlobalSettings.cs"
        "**/AudioManager.cs"
        "**/SaveSystem.cs"
    )

    echo ""
    echo "Looking for common high-impact files..."
    
    for pattern in "${priority_patterns[@]}"; do
        # Use find to locate files matching the pattern
        while IFS= read -r -d '' file; do
            if [[ -f "$file" ]]; then
                relative_path=$(get_relative_path "$file" "$PROJECT_ROOT")
                # Check if file needs organization
                if grep -q "// Fields\|#region.*Fields" "$file" && grep -q "// Public Methods\|#region.*Methods" "$file"; then
                    echo "✅ $relative_path - Already organized"
                else
                    echo "❗ $relative_path - HIGH PRIORITY - Needs organization"
                fi
            fi
        done < <(find "$PROJECT_ROOT" -name "${pattern##*/}" -print0 2>/dev/null)
    done
    
    echo ""
    echo "💡 Tip: Update the priority_patterns array in this script to match your project's important files."
}

# Function to show files by category
show_files_by_category() {
    echo "📂 Files by Category:"
    echo "===================="

    # Common Godot project directory patterns (update these for your project structure)
    categories=(
        "UI Components:ui"
        "UI Components:UI"
        "Player Scripts:player"
        "Player Scripts:Player"
        "Managers:managers"
        "Managers:Managers"
        "Systems:systems"
        "Systems:Systems"
        "Globals:globals"
        "Globals:Globals"
        "Scripts:scripts"
        "Scripts:Scripts"
        "Autoloads:autoloads"
        "Autoloads:Autoloads"
    )

    for category in "${categories[@]}"; do
        name="${category%%:*}"
        path="${category##*:}"

        echo ""
        echo "📁 $name"
        
        # Look for the directory in common locations
        possible_paths=(
            "$PROJECT_ROOT/$path"
            "$PROJECT_ROOT/scripts/$path"
            "$PROJECT_ROOT/Scripts/$path"
            "$PROJECT_ROOT/src/$path"
        )
        
        found_path=""
        for possible_path in "${possible_paths[@]}"; do
            if [[ -d "$possible_path" ]]; then
                found_path="$possible_path"
                break
            fi
        done

        if [[ -n "$found_path" ]]; then
            echo "   Path: $found_path"
            file_count=$(find "$found_path" -name "*.cs" | wc -l)
            organized_count=0

            while IFS= read -r -d '' file; do
                if grep -q "// Fields\|#region.*Fields" "$file" && grep -q "// Public Methods\|#region.*Methods" "$file"; then
                    organized_count=$((organized_count + 1))
                fi
            done < <(find "$found_path" -name "*.cs" -print0)

            echo "   📊 $organized_count/$file_count files organized"
        else
            echo "   ❓ Directory not found in common locations"
        fi
    done
    
    echo ""
    echo "💡 Tip: Update the categories array in this script to match your project's directory structure."
}

# Function to organize selected files using Python script
organize_selected_files() {
    local style_flag="$1"
    local style_name="// comments"
    if [[ "$style_flag" == "--regions" ]]; then
        style_name="#region blocks"
    fi

    echo "🔧 Auto-Organize Selected Files ($style_name)"
    echo "================================"
    echo ""

    # Show unorganized files first
    echo "📋 Unorganized files available for auto-organization:"
    echo ""

    unorganized_files=()
    unorganized_files_full=()
    while IFS= read -r -d '' file; do
        # Skip auto-generated files and temp files
        if [[ "$file" == *"/.godot/"* ]] || [[ "$file" == *"/temp/"* ]] || [[ "$file" == *"/obj/"* ]] || [[ "$file" == *"/bin/"* ]]; then
            continue
        fi

        # Skip files with .generated. in the name
        if [[ "$(basename "$file")" == *".generated."* ]]; then
            continue
        fi

        # Skip AssemblyInfo.cs files
        if [[ "$(basename "$file")" == "AssemblyInfo.cs" ]] || [[ "$(basename "$file")" == *".AssemblyInfo.cs" ]]; then
            continue
        fi        # Check if file contains any class, struct, record, or enum declarations (not just interfaces)
        if ! grep -E "^\s*(public|private|protected|internal|abstract|partial|static|sealed).*\s+(class|struct|record|enum)\s+" "$file" >/dev/null; then
            continue
        fi

        # Skip files that only contain interfaces
        class_count=$(grep -cE "^\s*(public|private|protected|internal|abstract|partial|static|sealed).*\s+(class|struct|record|enum)\s+" "$file")
        interface_count=$(grep -cE "^\s*(public|private|protected|internal).*\s+interface\s+" "$file")

        if [ "$class_count" -eq 0 ] && [ "$interface_count" -gt 0 ]; then
            continue
        fi

        # Skip enum-only files
        enum_count=$(grep -cE "^\s*(public|private|protected|internal).*\s+enum\s+" "$file")
        non_enum_count=$(grep -cE "^\s*(public|private|protected|internal|abstract|partial|static|sealed).*\s+(class|struct|record)\s+" "$file")

        if [ "$enum_count" -gt 0 ] && [ "$non_enum_count" -eq 0 ]; then
            continue
        fi

        # Check if file has the standardized organization comments (both // and #region styles)
        if ! grep -q "// Fields\|#region.*Fields" "$file" || ! grep -q "// Public Methods\|#region.*Methods" "$file"; then
            relative_path=$(get_relative_path "$file" "$PROJECT_ROOT")
            unorganized_files+=("$relative_path")
            unorganized_files_full+=("$file")
            echo "${#unorganized_files[@]}. $relative_path"
        fi
    done < <(find "$PROJECT_ROOT" -name "*.cs" -print0)

    if [ ${#unorganized_files[@]} -eq 0 ]; then
        echo "✅ All files are already organized!"
        return
    fi

    echo ""
    echo "Enter file numbers to organize (e.g., 1,3,5 or 'all' for all files):"
    read -p "Selection: " selection

    if [[ "$selection" == "all" ]]; then
        echo ""
        echo "🚀 Running Python auto-organization tool on all unorganized files using $style_name..."
        if ! check_python; then
            return 1
        fi
        $PYTHON_CMD code-organization-tool.py "$PROJECT_ROOT" $style_flag
    else
        # Parse comma-separated numbers
        IFS=',' read -ra ADDR <<< "$selection"
        selected_files=()

        for i in "${ADDR[@]}"; do
            # Remove whitespace
            i=$(echo "$i" | xargs)
            if [[ "$i" =~ ^[0-9]+$ ]] && [ "$i" -ge 1 ] && [ "$i" -le ${#unorganized_files[@]} ]; then
                selected_files+=("${unorganized_files_full[$((i-1))]}")
            else
                echo "❌ Invalid selection: $i"
            fi
        done

        if [ ${#selected_files[@]} -gt 0 ]; then
            echo ""
            echo "🔧 Organizing selected files using $style_name..."
            if ! check_python; then
                return 1
            fi
            for file in "${selected_files[@]}"; do
                relative_path=$(get_relative_path "$file" "$PROJECT_ROOT")
                echo "⚙️  Processing: $relative_path"
                $PYTHON_CMD code-organization-tool.py "$PROJECT_ROOT" --file "$file" $style_flag
            done
            echo ""
            echo "✅ Selected files organized!"
        else
            echo "❌ No valid files selected."
        fi
    fi
}

# Function to organize priority files only
organize_priority_files() {
    local style_flag="$1"
    local style_name="// comments"
    if [[ "$style_flag" == "--regions" ]]; then
        style_name="#region blocks"
    fi

    echo "🎯 Auto-Organize Priority Files ($style_name)"
    echo "==============================="
    echo ""

    # Find priority files using the same patterns as show_priority_files
    priority_patterns=(
        "**/SceneManager.cs"
        "**/GameManager.cs"
        "**/PlayerController.cs"
        "**/GlobalSettings.cs"
        "**/AudioManager.cs"
        "**/SaveSystem.cs"
    )

    unorganized_priority=()

    echo "📋 Checking priority files..."
    echo ""
    
    for pattern in "${priority_patterns[@]}"; do
        while IFS= read -r -d '' file; do
            if [[ -f "$file" ]]; then
                relative_path=$(get_relative_path "$file" "$PROJECT_ROOT")
                if grep -q "// Fields\|#region.*Fields" "$file" && grep -q "// Public Methods\|#region.*Methods" "$file"; then
                    echo "✅ $relative_path - Already organized"
                else
                    echo "❗ $relative_path - Needs organization"
                    unorganized_priority+=("$file")
                fi
            fi
        done < <(find "$PROJECT_ROOT" -name "${pattern##*/}" -print0 2>/dev/null)
    done

    if [ ${#unorganized_priority[@]} -eq 0 ]; then
        echo ""
        echo "🎉 All priority files are already organized!"
        return
    fi

    echo ""
    echo "🔧 Found ${#unorganized_priority[@]} priority files that need organization."
    read -p "Organize them now? (y/N): " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo ""
        echo "🚀 Organizing priority files using $style_name..."
        if ! check_python; then
            return 1
        fi
        for file in "${unorganized_priority[@]}"; do
            echo "⚙️  Processing: $file"
            $PYTHON_CMD code-organization-tool.py "$PROJECT_ROOT" --file "$file" $style_flag
        done
        echo ""
        echo "✅ Priority files organized!"
    else
        echo "❌ Organization cancelled."
    fi
}

# Function to create backup before mass organization
create_backup() {
    echo "💾 Creating backup..."
    backup_dir="$PROJECT_ROOT/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    find "$PROJECT_ROOT" -name "*.cs" -not -path "*/.godot/*" -not -path "*/backup_*/*" | while read -r file; do
        relative_path=$(get_relative_path "$file" "$PROJECT_ROOT")
        backup_file="$backup_dir/$relative_path"
        mkdir -p "$(dirname "$backup_file")"
        cp "$file" "$backup_file"
    done

    echo "✅ Backup created at: $backup_dir"
}

# Main menu
main_menu() {
    echo ""
    echo "🛠️  What would you like to do?"
    echo "1. 📋 Show organization pattern"
    echo "2. 📊 Scan project organization status"
    echo "3. 🎯 Show priority files"
    echo "4. 📂 Show files by category"
    echo "5. 🔧 Auto-organize selected files (// comments)"
    echo "6. 🔧 Auto-organize selected files (#region blocks)"
    echo "7. 🎯 Auto-organize priority files only (// comments)"
    echo "8. 🎯 Auto-organize priority files only (#region blocks)"
    echo "9. 🚀 Auto-organize ALL unorganized files (// comments, with backup)"
    echo "10. 🚀 Auto-organize ALL unorganized files (#region blocks, with backup)"
    echo "11. ❌ Exit"
    echo ""
    read -p "Choose an option (1-11): " choice

    case $choice in
        1)
            show_pattern
            main_menu
            ;;
        2)
            list_unorganized_files
            main_menu
            ;;
        3)
            show_priority_files
            main_menu
            ;;
        4)
            show_files_by_category
            main_menu
            ;;
        5)
            organize_selected_files ""
            main_menu
            ;;
        6)
            organize_selected_files "--regions"
            main_menu
            ;;
        7)
            organize_priority_files ""
            main_menu
            ;;
        8)
            organize_priority_files "--regions"
            main_menu
            ;;
        9)
            echo ""
            echo "⚠️  WARNING: This will organize ALL unorganized C# files in the project using // comments!"
            read -p "Are you sure? This will modify many files (y/N): " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                create_backup
                echo ""
                echo "🚀 Running Python auto-organization tool on all files..."
                if ! check_python; then
                    main_menu
                    return
                fi
                $PYTHON_CMD code-organization-tool.py "$PROJECT_ROOT"
            else
                echo "❌ Mass organization cancelled."
            fi
            main_menu
            ;;
        10)
            echo ""
            echo "⚠️  WARNING: This will organize ALL unorganized C# files in the project using #region blocks!"
            read -p "Are you sure? This will modify many files (y/N): " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                create_backup
                echo ""
                echo "🚀 Running Python auto-organization tool on all files..."
                if ! check_python; then
                    main_menu
                    return
                fi
                $PYTHON_CMD code-organization-tool.py "$PROJECT_ROOT" --regions
            else
                echo "❌ Mass organization cancelled."
            fi
            main_menu
            ;;
        11)
            echo "👋 Goodbye! Happy coding!"
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Please choose 1-11."
            main_menu
            ;;
    esac
}

# Check if project directory exists
if [[ ! -d "$PROJECT_ROOT" ]]; then
    echo "❌ Project directory not found: $PROJECT_ROOT"
    echo "Please update the PROJECT_ROOT variable in this script."
    exit 1
fi

# Start the main menu
main_menu
