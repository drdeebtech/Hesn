```markdown
# Hesn Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill covers the core development patterns and conventions used in the Hesn TypeScript codebase. It documents file naming, import/export styles, commit message conventions, and testing patterns. By following these guidelines, contributors can ensure consistency and maintainability throughout the project.

## Coding Conventions

### File Naming
- **Style:** Snake case  
- **Example:**  
  ```plaintext
  user_profile.ts
  data_manager.test.ts
  ```

### Imports
- **Style:** Relative imports  
- **Example:**  
  ```typescript
  import { fetchData } from './data_manager';
  ```

### Exports
- **Style:** Named exports  
- **Example:**  
  ```typescript
  // In data_manager.ts
  export function fetchData() { ... }
  ```

### Commit Messages
- **Style:** Conventional commits  
- **Prefix:** `feat`  
- **Example:**  
  ```plaintext
  feat: add user authentication middleware
  ```

## Workflows

### Adding a New Feature
**Trigger:** When implementing new functionality  
**Command:** `/add-feature`

1. Create a new TypeScript file using snake_case naming.
2. Implement the feature using named exports.
3. Import dependencies using relative paths.
4. Write corresponding test files with the `.test.ts` suffix.
5. Commit changes using the `feat:` prefix and a clear, concise message.

### Writing Tests
**Trigger:** When adding or updating code that requires validation  
**Command:** `/write-test`

1. Create a test file named `<module>.test.ts` in the same directory as the module.
2. Write test cases using the project's preferred (unknown) testing framework.
3. Use relative imports to bring in the module under test.
4. Run tests to ensure correctness.

### Refactoring Code
**Trigger:** When improving or reorganizing existing code  
**Command:** `/refactor`

1. Rename files using snake_case if necessary.
2. Update imports to use relative paths.
3. Ensure all exports are named.
4. Update or add tests as needed.
5. Commit with a clear message (e.g., `feat: refactor data_manager for clarity`).

## Testing Patterns

- **Test File Naming:** Use the `.test.ts` suffix for test files.
  - Example: `user_profile.test.ts`
- **Location:** Place test files alongside the modules they test.
- **Framework:** The specific testing framework is not detected; follow project standards.
- **Imports:** Use relative imports in test files.

## Commands
| Command        | Purpose                                      |
|----------------|----------------------------------------------|
| /add-feature   | Steps for adding a new feature               |
| /write-test    | Steps for writing and organizing tests       |
| /refactor      | Steps for refactoring code                   |
```