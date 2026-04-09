---
name: nextjs-standards
description: Apply Moonward Next.js (App Router) frontend coding standards to the current task. Enforces component patterns, naming conventions, server/client boundaries, and security rules.
argument-hint: [component or file to review/apply standards to]
---

Apply the following Next.js (App Router) coding standards to all code generated, reviewed, or modified in this session. These are the Moonward team's canonical frontend rules.

---

## General Principles

- Keep changes minimal — do not refactor unrelated code.
- Follow existing patterns in the repo.
- Ask before introducing new libraries.
- Prefer editing over rewriting.
- Explain non-obvious changes.
- Preserve comments and TODOs.

## React Core Rules

- Use **Functional Components** only — no class components.
- Use **named exports** for components.
- **File Naming**: kebab-case for all files (e.g., `app-text.tsx`, `utils-helper.ts`).
- **Component Naming**: PascalCase (e.g., `AppText`).
- **Variables/Functions**: camelCase.
- Always define a TypeScript type/interface for component props.

## Hooks

- Call hooks at the top level only.
- Extract logic into custom hooks or services, not inside JSX.
- Place all custom hooks in the `hooks/` folder.

## State Management

- Use React Provider-Context pattern to avoid prop drilling > 4 levels deep.

## Next.js Framework

- Follow **Next.js App Router** patterns.
- Correctly distinguish between Server and Client Components.
- Use `"use client"` directive only when needed — prefer Server Components by default.

## Styling

- Use **Tailwind CSS** for styling.
- Use **Radix UI** for creating accessible, unstyled components.

## Routing

- Use Next.js App Router file-based routing.
- Use `next/link` for navigation.
- Use `next/image` for optimized images.

## SEO & Meta

- Use Next.js Metadata API for SEO.
- Ensure proper `<title>` and `<meta>` tags.

## Performance

- Componentize UI blocks to ensure minimal re-renders.
- Modularize components into smaller, reusable pieces.

## File Organization

- Split long files into multiple smaller component files.
- If a component exceeds ~200 lines, extract sub-components.
- Each file should have a single responsibility.
- Extract reusable UI pieces into `components/`.

## Data Fetching

- Use TanStack Query (`useQuery` / `useMutation`) for server state.
- Refer to `/backend-sdk/schema.d.ts` for Open API fetcher types.

## Forms & Validation

- Use `react-hook-form` for all form handling.
- Use `zod` for schema validation.

## Code Style

- Follow **AirBnB style guide**.
- Optimize for **readability** over premature optimization.

## Security

- Do not log secrets, tokens, or API keys.
- Do not hardcode environment values — use `.env`.
- Do not weaken authentication or validation logic.
- Be cautious when modifying payment or auth flows.

---

If `$ARGUMENTS` is provided, apply these standards specifically when working on that component or file. Otherwise, apply them to all code in the current task.
