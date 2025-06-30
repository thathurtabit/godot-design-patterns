# Godot C# Code Organization - Configuration Examples

This file contains examples of how to customize the organization tools for your specific project needs.

## Project-Specific Customization

### 1. Update Priority Files (organization-helper.sh)

Edit the `priority_patterns` array to match your project's most important files:

```bash
# Example for a 2D platformer game
priority_patterns=(
    "**/GameManager.cs"
    "**/PlayerController.cs"
    "**/LevelManager.cs"
    "**/SceneTransition.cs"
    "**/SaveSystem.cs"
    "**/AudioManager.cs"
)

# Example for a 3D adventure game
priority_patterns=(
    "**/GameController.cs"
    "**/PlayerMovement.cs"
    "**/CameraController.cs"
    "**/InventorySystem.cs"
    "**/DialogueManager.cs"
    "**/QuestManager.cs"
)

# Example for a puzzle game
priority_patterns=(
    "**/PuzzleManager.cs"
    "**/GridSystem.cs"
    "**/ScoreManager.cs"
    "**/LevelLoader.cs"
    "**/HintSystem.cs"
)
```

### 2. Update Directory Categories (organization-helper.sh)

Customize the `categories` array to match your project structure:

```bash
# Standard Godot project structure
categories=(
    "Player Scripts:player"
    "Enemy Scripts:enemies"
    "UI Scripts:ui"
    "Managers:managers"
    "Systems:systems"
    "Autoloads:autoloads"
)

# Alternative structure with capitalized folders
categories=(
    "Player Scripts:Player"
    "Enemy Scripts:Enemies"
    "UI Scripts:UI"
    "Managers:Managers"
    "Utilities:Utils"
    "Data:Data"
)

# Nested script structure
categories=(
    "Core Systems:scripts/core"
    "Gameplay:scripts/gameplay"
    "UI Components:scripts/ui"
    "Audio:scripts/audio"
    "Effects:scripts/effects"
    "Tools:scripts/tools"
)
```

### 3. Project Root Path Configuration

```bash
# For tools in project root
PROJECT_ROOT="$(pwd)"

# For tools in subdirectory
PROJECT_ROOT="$(dirname "$(pwd)")"

# For specific project path (Windows)
PROJECT_ROOT="C:/Users/YourName/Projects/YourGodotGame"

# For specific project path (macOS/Linux)
PROJECT_ROOT="/Users/YourName/Projects/YourGodotGame"
PROJECT_ROOT="/home/YourName/Projects/YourGodotGame"
```

## Common Project Patterns

### Mobile Game Project

```bash
priority_patterns=(
    "**/GameController.cs"
    "**/TouchInput.cs"
    "**/AdManager.cs"
    "**/IAPManager.cs"
    "**/GameData.cs"
    "**/MenuManager.cs"
)

categories=(
    "Game Logic:game"
    "Input Handling:input"
    "UI Screens:ui/screens"
    "UI Components:ui/components"
    "Monetization:monetization"
    "Data:data"
)
```

### RPG Project

```bash
priority_patterns=(
    "**/PlayerCharacter.cs"
    "**/InventorySystem.cs"
    "**/BattleSystem.cs"
    "**/DialogueSystem.cs"
    "**/QuestManager.cs"
    "**/SaveLoadSystem.cs"
)

categories=(
    "Character System:characters"
    "Combat System:combat"
    "Inventory System:inventory"
    "Quest System:quests"
    "Dialogue System:dialogue"
    "World Systems:world"
)
```

### Multiplayer Game Project

```bash
priority_patterns=(
    "**/NetworkManager.cs"
    "**/PlayerSync.cs"
    "**/GameSession.cs"
    "**/ServerConnection.cs"
    "**/MultiplayerLobby.cs"
)

categories=(
    "Networking:network"
    "Player Systems:players"
    "Game Logic:game"
    "UI Multiplayer:ui/multiplayer"
    "Synchronization:sync"
)
```

## Integration Examples

### VS Code Tasks Configuration

Add to your `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Organize Code (Scan Only)",
      "type": "shell",
      "command": "python",
      "args": ["tools/code-organization-tool.py", "--scan"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    },
    {
      "label": "Organize Code (Interactive)",
      "type": "shell",
      "command": "./tools/organization-helper.sh",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": true,
        "panel": "shared"
      }
    },
    {
      "label": "Organize All Code (Auto)",
      "type": "shell",
      "command": "python",
      "args": ["tools/code-organization-tool.py", "--no-pause"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    }
  ]
}
```

### Git Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/sh
# Run code organization check before commit

echo "🔍 Checking code organization..."

# Run scan to check if any files need organization
if ! python tools/code-organization-tool.py --scan | grep -q "files need organization: 0"; then
    echo "❌ Some files need organization before commit."
    echo "Run: ./tools/organization-helper.sh"
    exit 1
fi

echo "✅ Code organization check passed."
```

### CI/CD Integration (GitHub Actions)

```yaml
name: Code Organization Check
on: [push, pull_request]

jobs:
  check-organization:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: "3.x"
      - name: Check code organization
        run: |
          python tools/code-organization-tool.py --scan
          # Fail if any files need organization
          if ! python tools/code-organization-tool.py --scan | grep -q "files need organization: 0"; then
            echo "Some files need organization"
            exit 1
          fi
```

## Advanced Customization

### Adding New Organization Sections

To add custom sections, modify the Python tool's organization pattern:

```python
# In code-organization-tool.py, find the build_organized_class_body method
# Add your custom sections to the organization order

def build_organized_class_body(self, members: Dict[str, List[str]]) -> str:
    if self.use_regions:
        return self.build_organized_class_body_with_regions(members)
    else:
        return self.build_organized_class_body_with_comments(members)

# Add custom sections like:
# - Static Fields
# - Events
# - Nested Classes
# - Operator Overloads
```

### Custom File Filtering

Add project-specific file filtering:

```python
def should_skip_file(self, file_path: str) -> bool:
    """Determine if file should be skipped."""
    skip_patterns = [
        # Standard patterns
        '/.godot/', '/temp/', '/obj/', '/bin/',

        # Add your custom patterns
        '/Generated/',          # Custom generated files
        '/ThirdParty/',        # Third-party code
        '/Legacy/',            # Legacy code to skip
        'Migration.cs',        # Database migrations
        '.Designer.cs',        # Designer files
    ]

    # Your custom logic here
    return any(pattern in file_path for pattern in skip_patterns)
```

This configuration guide helps you tailor the code organization tools to your specific Godot C# project structure and workflow needs.
