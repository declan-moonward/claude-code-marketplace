# Moonward AI Coding Standards

## General Behavior

- Keep changes minimal — do not refactor unrelated code.
- Follow existing patterns in the repo.
- Ask before introducing new libraries.
- Prefer editing over rewriting.
- Explain non-obvious changes.
- Preserve comments and TODOs.

## Code Style & Naming

- Follow the AirBnB style guide.
- Optimize for readability over premature optimization.
- **React files**: kebab-case (e.g. `app-text.tsx`)
- **React components**: PascalCase (e.g. `AppText`)
- **Non-React files**: kebab-case (e.g. `utils-helper.ts`)
- **Variables/functions**: camelCase

## Security

- Do not log secrets, tokens, or API keys.
- Do not hardcode environment values — use `.env`.
- Do not weaken authentication or validation logic.
- Be cautious when modifying payment or auth flows.

## React (All Platforms)

### Core

- Use functional components only — no class components.
- Use named exports for components.
- Always define a TypeScript type/interface for component props.

### Hooks

- Call hooks at the top level only.
- Extract logic into custom hooks or services, not inside JSX.
- Place all custom hooks in a `hooks/` folder.

### State Management

- Use React Provider-Context pattern to avoid prop drilling more than 4 levels deep.

### File Organization

- Split files exceeding ~200 lines into smaller component files.
- Each component file should have a single responsibility.
- Extract reusable UI pieces into `components/`.

### Performance

- Componentize UI blocks to ensure minimal re-renders.
- Modularize components into smaller, reusable pieces.

### Data Fetching

- Use TanStack Query (`useQuery` / `useMutation`) for server state.
- Refer to `/backend-sdk/schema.d.ts` for OpenAPI fetcher types.

### Forms & Validation

- Use `react-hook-form` for all form handling.
- Use `zod` for schema validation.
