# Object-Oriented Design Patterns Checklist

**Remember**: Patterns are tools, not goals. Use them when they solve real problems, not because they're "good practice."

- [Object-Oriented Design Patterns Checklist](#object-oriented-design-patterns-checklist)
  - [Quick Reference for Better OO Design](#quick-reference-for-better-oo-design)
    - [🎯 SOLID Principles Check](#-solid-principles-check)
    - [🏗️ Common Design Patterns](#️-common-design-patterns)
      - [Creational Patterns](#creational-patterns)
      - [Structural Patterns](#structural-patterns)
      - [Behavioral Patterns](#behavioral-patterns)
    - [🔍 Code Smell Detection](#-code-smell-detection)
      - [Class Design](#class-design)
      - [Method Design](#method-design)
      - [General Structure](#general-structure)
    - [🎮 Godot-Specific OO Considerations](#-godot-specific-oo-considerations)
      - [Node Architecture](#node-architecture)
      - [Resource Management](#resource-management)
    - [💡 Design Questions to Ask](#-design-questions-to-ask)
      - [Before Writing a Class](#before-writing-a-class)
      - [Before Writing a Method](#before-writing-a-method)
      - [When Adding Features](#when-adding-features)
    - [📋 Refactoring Checklist](#-refactoring-checklist)
      - [Extract Method When:](#extract-method-when)
      - [Extract Class When:](#extract-class-when)
      - [Use Inheritance When:](#use-inheritance-when)
      - [Use Composition When:](#use-composition-when)
    - [🔧 Practical Tips](#-practical-tips)
      - [Naming Conventions](#naming-conventions)
      - [Interface Design](#interface-design)
      - [Error Handling](#error-handling)
    - [📚 Pattern Selection Guide](#-pattern-selection-guide)
    - [🚀 Quick Wins](#-quick-wins)

## Quick Reference for Better OO Design

### 🎯 SOLID Principles Check

- [ ] **Single Responsibility**: Does this class have only one reason to change?
- [ ] **Open/Closed**: Can I extend behavior without modifying existing code?
- [ ] **Liskov Substitution**: Can subclasses replace their parent without breaking functionality?
- [ ] **Interface Segregation**: Are my interfaces focused and not forcing unnecessary dependencies?
- [ ] **Dependency Inversion**: Am I depending on abstractions, not concrete implementations?

### 🏗️ Common Design Patterns

#### Creational Patterns

- [ ] **Singleton**: Do I need exactly one instance? (Use sparingly - consider static classes or dependency injection)
- [ ] **Factory Method**: Am I creating objects based on conditions? Consider extracting creation logic.
- [ ] **Builder**: Do I have complex object construction? Consider a builder for clarity.
- [ ] **Object Pool**: Am I creating/destroying expensive objects frequently?

#### Structural Patterns

- [ ] **Adapter**: Do I need to make incompatible interfaces work together?
- [ ] **Decorator**: Am I adding behavior dynamically? Consider composition over inheritance.
- [ ] **Facade**: Can I simplify complex subsystem interactions?
- [ ] **Composite**: Am I dealing with tree-like structures or part-whole hierarchies?

#### Behavioral Patterns

- [ ] **Observer**: Do objects need to be notified of state changes? (Great for events/signals in Godot)
- [ ] **Strategy**: Do I have multiple algorithms for the same task?
- [ ] **Command**: Am I performing operations that need to be undone, queued, or logged?
- [ ] **State**: Does object behavior change based on internal state?
- [ ] **Template Method**: Do I have algorithms with similar steps but different implementations?

### 🔍 Code Smell Detection

#### Class Design

- [ ] **God Class**: Is this class doing too much? (>200 lines often indicates issues)
- [ ] **Feature Envy**: Is this method using more data from another class than its own?
- [ ] **Data Class**: Does this class only hold data without behavior?
- [ ] **Refused Bequest**: Is the subclass not using most of its parent's interface?

#### Method Design

- [ ] **Long Method**: Is this method doing too much? (>20 lines often needs refactoring)
- [ ] **Long Parameter List**: Do I have >3-4 parameters? Consider parameter objects.
- [ ] **Switch/If Statement Smell**: Can polymorphism replace conditional logic?

#### General Structure

- [ ] **Duplicate Code**: Am I repeating logic? Extract to methods/classes.
- [ ] **Dead Code**: Are there unused methods/classes I can remove?
- [ ] **Speculative Generality**: Am I over-engineering for future needs?

### 🎮 Godot-Specific OO Considerations

#### Node Architecture

- [ ] **Component Composition**: Am I using nodes as components rather than deep inheritance?
- [ ] **Scene Organization**: Are my scenes focused on single responsibilities?
- [ ] **Signal Usage**: Am I using signals for loose coupling between nodes?

#### Resource Management

- [ ] **Autoload Singletons**: Am I overusing autoloads? Consider dependency injection.
- [ ] **Resource Loading**: Am I caching expensive resources appropriately?
- [ ] **Memory Management**: Am I properly managing object lifecycles?

### 💡 Design Questions to Ask

#### Before Writing a Class

1. What is the single responsibility of this class?
2. What data does it encapsulate and why?
3. What behavior does it provide?
4. How will other classes interact with it?
5. Is this class testable in isolation?

#### Before Writing a Method

1. What is this method's single purpose?
2. What data does it need and where should it come from?
3. What should it return and why?
4. Are there side effects I should minimize?
5. Can this be made pure/stateless?

#### When Adding Features

1. Does this belong in the existing class or a new one?
2. Am I modifying existing code or extending it?
3. Will this change break existing functionality?
4. How will I test this new behavior?
5. Is there a pattern that fits this scenario?

### 📋 Refactoring Checklist

#### Extract Method When:

- [ ] Method is longer than 20 lines
- [ ] Logic is repeated in multiple places
- [ ] Method has multiple levels of abstraction
- [ ] Comments are needed to explain sections

#### Extract Class When:

- [ ] Class has multiple responsibilities
- [ ] Groups of methods operate on the same data
- [ ] Class is becoming too large (>200-300 lines)
- [ ] You find yourself saying "and" when describing the class

#### Use Inheritance When:

- [ ] There's a clear "is-a" relationship
- [ ] Subclasses need most of the parent's behavior
- [ ] You're extending behavior, not replacing it
- [ ] The hierarchy is shallow (prefer composition for deep hierarchies)

#### Use Composition When:

- [ ] There's a "has-a" or "uses-a" relationship
- [ ] You need multiple inheritance-like behavior
- [ ] Behavior might change at runtime
- [ ] You want to combine different capabilities

### 🔧 Practical Tips

#### Naming Conventions

- [ ] Classes: Nouns representing concepts (TrainingProgressManager ✓)
- [ ] Methods: Verbs representing actions (MarkTrainingCompleted ✓)
- [ ] Properties: Descriptive nouns (CurrentTrainingKey ✓)
- [ ] Booleans: Questions or states (IsComplete, CanAdvance, HasPermission)

#### Interface Design

- [ ] Keep interfaces small and focused
- [ ] Use dependency injection over static dependencies
- [ ] Return interfaces/abstractions when possible
- [ ] Make invalid states unrepresentable

#### Error Handling

- [ ] Use exceptions for exceptional circumstances
- [ ] Return null/optional types for expected "not found" cases
- [ ] Validate inputs at boundaries
- [ ] Fail fast and provide clear error messages

### 📚 Pattern Selection Guide

| Problem                              | Consider These Patterns    |
| ------------------------------------ | -------------------------- |
| Object creation is complex           | Factory, Builder           |
| Need to notify multiple objects      | Observer, Event System     |
| Algorithm varies by context          | Strategy                   |
| Object behavior changes with state   | State                      |
| Need to add behavior dynamically     | Decorator, Component       |
| Working with tree structures         | Composite                  |
| Need to simplify complex interfaces  | Facade                     |
| Need to make incompatible types work | Adapter                    |
| Need exactly one instance            | Singleton (use cautiously) |
| Need to execute operations later     | Command                    |

### 🚀 Quick Wins

1. **Start with SOLID**: Focus on Single Responsibility first
2. **Favor Composition**: Use composition over inheritance by default
3. **Program to Interfaces**: Depend on abstractions, not concrete classes
4. **Keep Methods Small**: Aim for methods that do one thing well
5. **Use Meaningful Names**: Code should read like well-written prose
6. **Write Tests First**: TDD helps drive better design
7. **Refactor Regularly**: Don't let technical debt accumulate
