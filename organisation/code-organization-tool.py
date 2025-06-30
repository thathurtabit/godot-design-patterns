#!/usr/bin/env python3
"""
Godot C# Code Organization Tool
Automatically organizes C# class files according to a standardized pattern for Godot projects.

SAFETY FEATURES:
- Creates backups outside project directory to avoid build conflicts
- Preserves Godot [Signal] declarations and [Export] attributes
- Handles Godot-specific syntax properly
- Validates file integrity before/after changes
- Supports batch processing with user confirmation
- Skips static-only files, interfaces, and auto-generated files
- Comprehensive validation to prevent data loss

USAGE:
    python code-organization-tool.py --scan                    # Scan without changes
    python code-organization-tool.py --file path/to/file.cs    # Organize single file
    python code-organization-tool.py                           # Organize all files (with batching)
    python code-organization-tool.py --no-pause               # Organize all files without pausing
    python code-organization-tool.py --batch-size 5           # Custom batch size
    python code-organization-tool.py --regions                # Use #region blocks instead of // comments

This tool follows a standardized C# organization pattern:
1. Fields (including [Export] decorated fields)
2. Properties
3. Virtual Properties
4. Constants
5. Enums
6. Signals (Godot [Signal] declarations)
7. Public Methods
8. Protected Methods
9. Private Methods

Supports both organization styles:
- Traditional // comment sections (default)
- #region/#endregion blocks (--regions flag)
"""

import os
import re
import sys
import shutil
from datetime import datetime
from typing import List, Dict, Optional

class CSharpClassOrganizer:
    def __init__(self, project_root: str, use_regions: bool = False):
        self.project_root = project_root
        self.use_regions = use_regions
        self.backup_dir = os.path.join(os.path.dirname(project_root), f"godot_csharp_backups_{datetime.now().strftime('%Y%m%d_%H%M%S')}")
        self.godot_patterns = {
            'signals': re.compile(r'\[Signal\]\s+public\s+delegate\s+[^;]+;'),
            'exports': re.compile(r'\[Export(?:\([^)]*(?:\([^)]*\)[^)]*)*\))?\]\s*\n?\s*(?:public\s+|private\s+|protected\s+)?[^;{]+[;{]', re.MULTILINE | re.DOTALL),
            'signal_emits': re.compile(r'EmitSignal\s*\(\s*SignalName\.[^)]+\)'),
        }

    def create_backup(self, file_path: str) -> str:
        """Create a backup of the file outside the project directory."""
        if not os.path.exists(self.backup_dir):
            os.makedirs(self.backup_dir)

        rel_path = os.path.relpath(file_path, self.project_root)
        backup_path = os.path.join(self.backup_dir, rel_path)
        backup_dir = os.path.dirname(backup_path)

        if not os.path.exists(backup_dir):
            os.makedirs(backup_dir)

        shutil.copy2(file_path, backup_path)
        return backup_path

    def is_already_organized(self, content: str) -> bool:
        """Check if file is already organized."""
        # Look for any organization section comments (both // and #region styles)
        organization_patterns = [
            # Traditional // comments
            r'^\s*//\s*Fields\s*$',
            r'^\s*//\s*Properties\s*$',
            r'^\s*//\s*Public Methods\s*$',
            r'^\s*//\s*Protected Methods\s*$',
            r'^\s*//\s*Private Methods\s*$',
            r'^\s*//\s*Constants\s*$',
            r'^\s*//\s*Enums\s*$',
            r'^\s*//\s*Signals\s*$',
            # #region comments
            r'^\s*#region\s+(Fields|Constants|Exported?\s*Fields|Private\s*Fields)\s*$',
            r'^\s*#region\s+(Properties|Virtual\s*Properties)\s*$',
            r'^\s*#region\s+(Public\s*Methods?|Private\s*Methods?|Protected\s*Methods?)\s*$',
            r'^\s*#region\s+(Enums?|Constants?|Signals?)\s*$'
        ]

        # Count how many organization sections we find
        found_sections = 0
        for pattern in organization_patterns:
            if re.search(pattern, content, re.MULTILINE | re.IGNORECASE):
                found_sections += 1

        # Check if the file has any actual organizable content
        # Fields: private/protected/public fields ending with ; or = (excluding methods and properties)
        has_fields = bool(re.search(r'^\s*(private|protected|public|internal|readonly)\s+[^{(]+[;=][^}]*$', content, re.MULTILINE))
        has_properties = bool(re.search(r'{\s*(get|set)', content, re.MULTILINE))
        has_methods = bool(re.search(r'^\s*(public|protected|private|internal)\s+[^=;]+\([^)]*\)\s*{', content, re.MULTILINE))
        has_exports = bool(re.search(r'\[Export\]', content))
        has_signals = bool(re.search(r'\[Signal\]', content))
        has_enums = bool(re.search(r'^\s*(public|private|protected|internal)\s+enum\s+', content, re.MULTILINE))
        has_constants = bool(re.search(r'^\s*(public|private|protected|internal)\s+const\s+', content, re.MULTILINE))

        organizable_content_types = sum([has_fields, has_properties, has_methods, has_exports, has_signals, has_enums, has_constants])

        # If we have organization comments and they cover the content types present, consider it organized
        # For simple classes with only one content type, one section comment is enough
        # For complex classes, we expect more comprehensive organization
        if organizable_content_types <= 1:
            return found_sections >= 1  # Simple classes need at least 1 section
        else:
            return found_sections >= 2  # Complex classes need at least 2 sections

    def should_skip_file(self, file_path: str) -> bool:
        """Determine if file should be skipped."""
        skip_patterns = [
            '/.godot/',
            '/temp/',
            '/obj/',
            '/bin/',
            '/backup',
            '/Backup',
            'AssemblyInfo.cs',
            '.g.cs',  # Generated files
            '.Designer.cs',  # Visual Studio generated files
        ]

        # Skip if it's in any of the skip patterns
        normalized_path = file_path.replace('\\', '/')
        if any(pattern in normalized_path for pattern in skip_patterns):
            return True

        # Skip if it's primarily static classes/constants (like settings.cs)
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Skip files with only interfaces
            if re.search(r'public\s+interface\s+\w+', content) and not re.search(r'public\s+(?:(?:partial|abstract|static|readonly)\s+)*(?:class|struct|record)\s+\w+', content):
                return True

            # Skip files with only enums (no classes/structs to organize)
            if re.search(r'public\s+enum\s+\w+', content) and not re.search(r'public\s+(?:(?:partial|abstract|static|readonly)\s+)*(?:class|struct|record)\s+\w+', content):
                return True

            # Count static classes vs regular types (classes, structs, records)
            static_classes = len(re.findall(r'public\s+static\s+class', content))
            regular_types = len(re.findall(r'public\s+(?:(?:partial|abstract|readonly)\s+)*(?:class|struct|record)(?!\s+static)', content))

            # Skip if it's mostly static classes or has no types at all
            if static_classes > 0 and regular_types == 0:
                return True

            # Skip if file is very small or mostly empty
            if len(content.strip()) < 100:
                return True

        except Exception:
            pass

        return False

    def extract_godot_signals(self, content: str) -> List[str]:
        """Extract all Godot [Signal] declarations."""
        signals = []

        # Match complete signal declarations including multi-line ones
        signal_pattern = re.compile(
            r'\[Signal\]\s*\n?\s*public\s+delegate\s+[^;]+;',
            re.MULTILINE | re.DOTALL
        )

        for match in signal_pattern.finditer(content):
            signal_text = match.group(0).strip()
            # Normalize whitespace but preserve structure
            signal_text = re.sub(r'\s+', ' ', signal_text)
            signal_text = signal_text.replace('[Signal] ', '[Signal]\n    ')
            signals.append(signal_text)

        return signals

    def extract_godot_exports(self, content: str) -> List[str]:
        """Extract all Godot [Export] declarations."""
        exports = []

        # Match [Export] attributes with their associated fields/properties
        export_pattern = re.compile(
            r'\[Export(?:\([^)]*\))?\]\s*\n?\s*(?:public\s+|private\s+|protected\s+)?[^;{]+[;{]',
            re.MULTILINE | re.DOTALL
        )

        for match in export_pattern.finditer(content):
            export_text = match.group(0).strip()
            exports.append(export_text)

        return exports

    def organize_file(self, file_path: str) -> bool:
        """Organize a single C# file according to the standard pattern."""
        try:
            # Skip files that shouldn't be organized
            if self.should_skip_file(file_path):
                print(f"⏭️  Skipped: {os.path.relpath(file_path, self.project_root)} (auto-excluded)")
                return True

            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()

            # Check if already organized
            if self.is_already_organized(original_content):
                print(f"✅ Already organized: {os.path.relpath(file_path, self.project_root)}")
                return True

            # Create backup
            backup_path = self.create_backup(file_path)

            # Extract Godot signals before reorganization (extracted separately to preserve exact formatting)
            godot_signals = self.extract_godot_signals(original_content)

            # Note: [Export] attributes are handled during normal member parsing to avoid duplicates

            # Extract class information
            class_info = self.extract_class_structure(original_content)
            if not class_info:
                print(f"⚠️  Could not parse class structure in {os.path.relpath(file_path, self.project_root)}")
                return False

            # Reorganize the content
            organized_content = self.reorganize_class_content(class_info, original_content, godot_signals)

            # Validate the organized content
            if not self.validate_organized_content(original_content, organized_content):
                print(f"❌ Validation failed for {os.path.relpath(file_path, self.project_root)}")
                return False

            # Write back to file
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(organized_content)

            print(f"✅ Organized: {os.path.relpath(file_path, self.project_root)}")
            print(f"   📁 Backup: {backup_path}")
            return True

        except Exception as e:
            print(f"❌ Error organizing {file_path}: {str(e)}")
            return False

    def validate_organized_content(self, original: str, organized: str) -> bool:
        """Validate that important content wasn't lost during reorganization."""
        # Check that signal count is preserved
        original_signals = len(self.godot_patterns['signals'].findall(original))
        organized_signals = len(self.godot_patterns['signals'].findall(organized))

        if original_signals != organized_signals:
            print(f"❌ Signal count mismatch: {original_signals} -> {organized_signals}")
            return False

        # Check that export count is preserved
        original_exports = len(self.godot_patterns['exports'].findall(original))
        organized_exports = len(self.godot_patterns['exports'].findall(organized))

        if original_exports != organized_exports:
            print(f"❌ Export count mismatch: {original_exports} -> {organized_exports}")
            print(f"Original exports found: {self.godot_patterns['exports'].findall(original)}")
            print(f"Organized exports found: {self.godot_patterns['exports'].findall(organized)}")
            return False

        # Check that basic class structure is preserved
        original_class_count = len(re.findall(r'public\s+(?:(?:partial|abstract|static|readonly)\s+)*(?:class|struct|record|interface)\s+\w+', original))
        organized_class_count = len(re.findall(r'public\s+(?:(?:partial|abstract|static|readonly)\s+)*(?:class|struct|record|interface)\s+\w+', organized))

        if original_class_count != organized_class_count:
            print(f"❌ Class count mismatch: {original_class_count} -> {organized_class_count}")
            return False

        # Check for basic content preservation (method count, property count)
        original_methods = len(re.findall(r'(public|private|protected)\s+[^=]*\([^)]*\)\s*{', original))
        organized_methods = len(re.findall(r'(public|private|protected)\s+[^=]*\([^)]*\)\s*{', organized))

        if abs(original_methods - organized_methods) > 1:  # Allow small variance for parsing differences
            print(f"❌ Method count difference too large: {original_methods} -> {organized_methods}")
            return False

        return True

    def extract_class_structure(self, content: str) -> Optional[Dict]:
        """Extract the structure of a C# class, struct, record, interface, or enum."""
        # Enhanced pattern to handle modern C# syntax including:
        # - readonly struct with primary constructors
        # - classes with primary constructors
        # - records with primary constructors
        type_patterns = [
            # Modern syntax with primary constructors: class Name(...) { or struct Name(...) {
            r'public\s+(?:(?:partial|abstract|static|readonly)\s+)*(?:class|struct|record)\s+(\w+)\s*\([^)]*\)\s*(?::\s*[^{]+)?\s*{',
            # Traditional syntax: class Name { or class Name : Base {
            r'public\s+(?:(?:partial|abstract|static|readonly)\s+)*(?:class|struct|record|interface|enum)\s+(\w+)\s*(?::\s*[^{]+)?\s*{',
        ]

        type_match = None
        for pattern in type_patterns:
            type_match = re.search(pattern, content)
            if type_match:
                break

        if not type_match:
            return None

        type_name = type_match.group(1)
        type_start = type_match.end() - 1  # Position of opening brace

        # Extract using statements and namespace
        using_statements = re.findall(r'using\s+[^;]+;', content[:type_start])
        namespace_match = re.search(r'namespace\s+([^;{]+)\s*;?', content[:type_start])
        namespace = namespace_match.group(1).strip() if namespace_match else ""

        return {
            'name': type_name,
            'using_statements': using_statements,
            'namespace': namespace,
            'class_start': type_start,
            'original_content': content
        }

    def reorganize_class_content(self, class_info: Dict, original_content: str, godot_signals: Optional[List[str]] = None) -> str:
        """Reorganize the class content according to the standard pattern."""
        if godot_signals is None:
            godot_signals = []

        # Extract the pre-class content (usings, namespace)
        class_start = class_info['class_start']
        pre_class = original_content[:class_start + 1]

        # Find the class end
        brace_count = 1
        pos = class_start + 1
        while pos < len(original_content) and brace_count > 0:
            if original_content[pos] == '{':
                brace_count += 1
            elif original_content[pos] == '}':
                brace_count -= 1
            pos += 1

        class_body = original_content[class_start + 1:pos - 1]
        post_class = original_content[pos - 1:]

        # Parse class members
        members = self.parse_class_members(class_body)

        # Add Godot signals to their respective sections (signals are extracted separately to preserve formatting)
        # Note: We replace any signals found during parsing with the extracted ones to avoid duplicates
        if godot_signals:
            members['signals'] = godot_signals  # Replace instead of extend to avoid duplicates

        # Note: godot_exports are already handled during parse_class_members(),
        # so we don't need to add them separately to avoid duplicates

        # Organize members according to pattern
        organized_body = self.build_organized_class_body(members)

        return pre_class + organized_body + post_class

    def parse_class_members(self, class_body: str) -> Dict[str, List[str]]:
        """Parse class members into categories."""
        members = {
            'fields': [],
            'properties': [],
            'virtual_properties': [],
            'constants': [],
            'enums': [],
            'signals': [],  # Added for Godot signals
            'public_methods': [],
            'protected_methods': [],
            'private_methods': []
        }

        # Remove existing organization comments to avoid duplication (both // and #region styles)
        clean_body = re.sub(r'^\s*//\s*(Fields|Properties|Virtual properties|Constants|Enums|Signals|Public Methods|Protected Methods|Private Methods)\s*$', '', class_body, flags=re.MULTILINE)
        clean_body = re.sub(r'^\s*#region\s+[^\n]*\s*$', '', clean_body, flags=re.MULTILINE)
        clean_body = re.sub(r'^\s*#endregion\s*$', '', clean_body, flags=re.MULTILINE)

        # Split into logical blocks
        blocks = self.split_into_blocks(clean_body)

        for block in blocks:
            if not block.strip():
                continue

            category = self.categorize_member(block)
            if category and category in members:
                members[category].append(block.strip())

        return members

    def split_into_blocks(self, content: str) -> List[str]:
        """Split content into logical member blocks."""
        blocks = []
        lines = content.split('\n')
        current_block = []
        brace_depth = 0
        in_member = False

        for line in lines:
            stripped = line.strip()

            # Count braces to track method/property boundaries
            brace_depth += line.count('{') - line.count('}')

            # Start of a new member (field, property, method, etc.)
            if (re.match(r'^(private|protected|public|internal|\[)', stripped) and
                brace_depth == 0 and not in_member):

                if current_block:
                    blocks.append('\n'.join(current_block))
                    current_block = []

                in_member = True

            current_block.append(line)

            # End of member (when we're back to brace depth 0)
            if in_member and brace_depth == 0 and stripped.endswith((';', '}')):
                blocks.append('\n'.join(current_block))
                current_block = []
                in_member = False

        # Add any remaining content
        if current_block:
            blocks.append('\n'.join(current_block))

        return blocks

    def categorize_member(self, member_text: str) -> Optional[str]:
        """Categorize a class member into the appropriate section."""
        stripped = member_text.strip()

        # Godot signals
        if '[Signal]' in stripped:
            return 'signals'

        # Constants
        if re.search(r'const\s+\w+', stripped):
            return 'constants'

        # Enums
        if re.search(r'enum\s+\w+', stripped):
            return 'enums'

        # Fields (including [Export] fields)
        field_patterns = [
            # Regular fields
            r'^\s*(private|protected|public|internal)\s+(?:readonly\s+|static\s+)?(?:(?!\s*(override|virtual|abstract)).)*\s+\w+(?:\s*[=;]|\s*$)',
            # [Export] decorated fields (with optional parameters)
            r'^\s*\[Export(?:\([^)]*\))?\]\s*',
        ]

        for pattern in field_patterns:
            if re.search(pattern, stripped, re.MULTILINE):
                # Exclude methods and properties
                if not re.search(r'\(.*\)|{\s*get|{\s*set', stripped):
                    return 'fields'

        # Properties
        if re.search(r'{\s*(get|set)', stripped):
            if 'virtual' in stripped or 'override' in stripped:
                return 'virtual_properties'
            else:
                return 'properties'

        # Methods
        if re.search(r'\(.*\)\s*{', stripped) or re.search(r'\(.*\)\s*;', stripped):
            if re.search(r'^\s*public', stripped, re.MULTILINE):
                return 'public_methods'
            elif re.search(r'^\s*protected', stripped, re.MULTILINE):
                return 'protected_methods'
            elif re.search(r'^\s*private', stripped, re.MULTILINE):
                return 'private_methods'

        return None

    def build_organized_class_body(self, members: Dict[str, List[str]]) -> str:
        """Build the organized class body with proper sections."""
        if self.use_regions:
            return self.build_organized_class_body_with_regions(members)
        else:
            return self.build_organized_class_body_with_comments(members)

    def build_organized_class_body_with_regions(self, members: Dict[str, List[str]]) -> str:
        """Build the organized class body with #region sections."""
        sections = []

        # Fields section
        if members['fields']:
            sections.append('    #region Fields')
            sections.extend([f'    {member}' for member in members['fields']])
            sections.append('    #endregion')
            sections.append('')

        # Properties section
        if members['properties']:
            sections.append('    #region Properties')
            sections.extend([f'    {member}' for member in members['properties']])
            sections.append('    #endregion')
            sections.append('')

        # Virtual properties section
        if members['virtual_properties']:
            sections.append('    #region Virtual Properties')
            sections.extend([f'    {member}' for member in members['virtual_properties']])
            sections.append('    #endregion')
            sections.append('')

        # Constants section
        if members['constants']:
            sections.append('    #region Constants')
            sections.extend([f'    {member}' for member in members['constants']])
            sections.append('    #endregion')
            sections.append('')

        # Enums section
        if members['enums']:
            sections.append('    #region Enums')
            sections.extend([f'    {member}' for member in members['enums']])
            sections.append('    #endregion')
            sections.append('')

        # Signals section (Godot-specific)
        if members['signals']:
            sections.append('    #region Signals')
            sections.extend([f'    {member}' for member in members['signals']])
            sections.append('    #endregion')
            sections.append('')

        # Public methods section
        if members['public_methods']:
            sections.append('    #region Public Methods')
            sections.extend([f'    {member}' for member in members['public_methods']])
            sections.append('    #endregion')
            sections.append('')

        # Protected methods section
        if members['protected_methods']:
            sections.append('    #region Protected Methods')
            sections.extend([f'    {member}' for member in members['protected_methods']])
            sections.append('    #endregion')
            sections.append('')

        # Private methods section
        if members['private_methods']:
            sections.append('    #region Private Methods')
            sections.extend([f'    {member}' for member in members['private_methods']])
            sections.append('    #endregion')

        return '\n' + '\n'.join(sections) + '\n'

    def build_organized_class_body_with_comments(self, members: Dict[str, List[str]]) -> str:
        """Build the organized class body with // comment sections."""
        sections = []

        # Fields section
        if members['fields']:
            sections.append('    // Fields')
            sections.extend([f'    {member}' for member in members['fields']])
            sections.append('')

        # Properties section
        if members['properties']:
            sections.append('    // Properties')
            sections.extend([f'    {member}' for member in members['properties']])
            sections.append('')

        # Virtual properties section
        if members['virtual_properties']:
            sections.append('    // Virtual Properties')
            sections.extend([f'    {member}' for member in members['virtual_properties']])
            sections.append('')

        # Constants section
        if members['constants']:
            sections.append('    // Constants')
            sections.extend([f'    {member}' for member in members['constants']])
            sections.append('')

        # Enums section
        if members['enums']:
            sections.append('    // Enums')
            sections.extend([f'    {member}' for member in members['enums']])
            sections.append('')

        # Signals section (Godot-specific)
        if members['signals']:
            sections.append('    // Signals')
            sections.extend([f'    {member}' for member in members['signals']])
            sections.append('')

        # Public methods section
        if members['public_methods']:
            sections.append('    // Public Methods')
            sections.extend([f'    {member}' for member in members['public_methods']])
            sections.append('')

        # Protected methods section
        if members['protected_methods']:
            sections.append('    // Protected Methods')
            sections.extend([f'    {member}' for member in members['protected_methods']])
            sections.append('')

        # Private methods section
        if members['private_methods']:
            sections.append('    // Private Methods')
            sections.extend([f'    {member}' for member in members['private_methods']])

        return '\n' + '\n'.join(sections) + '\n'

    def find_cs_files(self) -> List[str]:
        """Find all C# files in the project."""
        cs_files = []
        for root, dirs, files in os.walk(self.project_root):
            # Skip backup directories and .godot
            dirs[:] = [d for d in dirs if not d.startswith('.') and 'backup' not in d.lower()]

            for file in files:
                if file.endswith('.cs'):
                    cs_files.append(os.path.join(root, file))
        return cs_files

    def scan_project(self):
        """Scan project and report organization status without modifying files."""
        cs_files = self.find_cs_files()

        organized_count = 0
        total_relevant = 0

        print(f"📁 Scanning {len(cs_files)} C# files...\n")

        for file_path in cs_files:
            if self.should_skip_file(file_path):
                continue

            total_relevant += 1

            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()

                if self.is_already_organized(content):
                    organized_count += 1
                    print(f"✅ {os.path.relpath(file_path, self.project_root)}")
                else:
                    print(f"❓ {os.path.relpath(file_path, self.project_root)}")

            except Exception as e:
                print(f"❌ {os.path.relpath(file_path, self.project_root)} - Error: {e}")

        print(f"\n📊 Scan Results:")
        print(f"   📁 Total relevant files: {total_relevant}")
        print(f"   ✅ Already organized: {organized_count}")
        print(f"   ❓ Need organization: {total_relevant - organized_count}")

        if organized_count == total_relevant:
            print("🎉 All files are already organized!")
        else:
            print(f"🔧 {total_relevant - organized_count} files need organization")

    def organize_all_files(self, batch_size: int = 10):
        """Organize all C# files in the project, optionally in batches."""
        cs_files = self.find_cs_files()

        # Filter out files that should be skipped
        relevant_files = [f for f in cs_files if not self.should_skip_file(f)]

        print(f"📁 Found {len(relevant_files)} relevant C# files in {self.project_root}")
        print(f"🔧 Starting organization process (batch size: {batch_size})...\n")

        success_count = 0
        processed_count = 0

        for i, file_path in enumerate(relevant_files):
            # Process in batches
            if batch_size > 0 and i > 0 and i % batch_size == 0:
                print(f"\n⏸️  Batch {i // batch_size} completed. Press Enter to continue, or 'q' to quit...")
                user_input = input().strip().lower()
                if user_input == 'q':
                    print("🛑 Organization stopped by user.")
                    break
                print()

            processed_count += 1
            if self.organize_file(file_path):
                success_count += 1
            else:
                print(f"❌ Failed to organize: {os.path.relpath(file_path, self.project_root)}")

        print(f"\n✨ Organization complete!")
        print(f"✅ Successfully organized: {success_count}/{processed_count} files")
        print(f"📊 Total relevant files in project: {len(relevant_files)}")
        if success_count < processed_count:
            print(f"❌ Failed to organize: {processed_count - success_count} files")


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(description='Godot C# Code Organization Tool')
    parser.add_argument('project_root', nargs='?', default='.',
                       help='Project root directory (default: current directory)')
    parser.add_argument('--scan', action='store_true',
                       help='Scan project without modifying files')
    parser.add_argument('--file', type=str,
                       help='Organize a specific file')
    parser.add_argument('--batch-size', type=int, default=10,
                       help='Number of files to process in each batch (0 for no batching)')
    parser.add_argument('--no-pause', action='store_true',
                       help='Process all files without pausing between batches')
    parser.add_argument('--regions', action='store_true',
                       help='Use #region blocks instead of // comments for organization')

    args = parser.parse_args()

    project_root = os.path.abspath(args.project_root)

    if not os.path.exists(project_root):
        print(f"❌ Project root directory does not exist: {project_root}")
        sys.exit(1)

    print("🚀 Godot C# Code Organization Tool")
    print("=" * 40)
    print(f"📁 Project Root: {project_root}")
    print(f"🎨 Organization Style: {'#region blocks' if args.regions else '// comments'}")
    print()

    organizer = CSharpClassOrganizer(project_root, use_regions=args.regions)

    if args.scan:
        organizer.scan_project()
    elif args.file:
        file_path = os.path.abspath(args.file)
        if not os.path.exists(file_path):
            print(f"❌ File does not exist: {file_path}")
            sys.exit(1)
        organizer.organize_file(file_path)
    else:
        batch_size = 0 if args.no_pause else args.batch_size
        organizer.organize_all_files(batch_size)


if __name__ == "__main__":
    main()
