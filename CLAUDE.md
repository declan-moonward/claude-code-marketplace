# Team Coding Standards

These conventions apply to all projects. They are deployed globally via the Claude Code Marketplace.

## Naming Conventions

- **Files & directories**: kebab-case (`user-profile.ts`, `api-utils/`)
- **Variables & functions**: camelCase (`getUserProfile`, `isActive`)
- **React components & TypeScript types/interfaces**: PascalCase (`UserProfile`, `ApiResponse`)
- **CSS classes**: kebab-case (`nav-header`, `btn-primary`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_RETRIES`, `API_BASE_URL`)
- **Environment variables**: UPPER_SNAKE_CASE prefixed by context (`NEXT_PUBLIC_`, `EXPO_PUBLIC_`)

## Code Style

- Prefer named exports over default exports
- Prefer `const` over `let`; never use `var`
- Prefer early returns over deeply nested conditionals
- Keep functions under 50 lines; extract helpers when complexity grows
- Use TypeScript strict mode; avoid `any` — use `unknown` and narrow

## Project Structure

- Group by feature, not by type (e.g., `features/auth/` not `components/`, `hooks/`, `utils/` at top level)
- Co-locate tests next to source files (`user-profile.test.ts` beside `user-profile.ts`)
- Keep shared utilities in a `lib/` or `shared/` directory

## Git & PRs

- Branch names: `<type>/<ticket>-<short-description>` (e.g., `feat/PROJ-123-add-login`)
- Commit messages: imperative mood, under 72 characters (e.g., "Add login form validation")
- One logical change per commit
