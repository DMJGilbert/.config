---
paths:
  - "**/*.html"
  - "**/*.css"
  - "**/*.scss"
  - "**/*.tsx"
  - "**/*.jsx"
---

# UI Rules

## HTML

- Use semantic elements (`nav`, `main`, `article`)
- Add proper heading hierarchy
- Include alt text for images
- Use labels for form inputs

## CSS/Tailwind

- Mobile-first responsive design
- Use CSS variables for theming
- Prefer Tailwind utilities
- Extract components for reuse

## Accessibility (WCAG)

- Ensure keyboard navigation
- Provide focus indicators
- Use ARIA labels where needed
- Maintain color contrast (4.5:1)

## Security

- Set `Content-Security-Policy` headers to restrict script and resource origins; avoid `unsafe-inline`
- Add `rel="noopener noreferrer"` to all external links to prevent window reference hijacking
- Never interpolate user data into HTML strings — use DOM APIs or a sanitisation library
- Prevent clickjacking with `X-Frame-Options: DENY` or CSP `frame-ancestors 'none'`
- Validate file uploads server-side: check MIME type, enforce size limits, reject executable extensions

## Performance

- Optimize images (WebP, lazy load)
- Minimize layout shifts (CLS)
- Use CSS containment

## Validation

1. Inspect in a real browser; CSS-only changes rarely fail tests
2. Run an accessibility audit (axe DevTools, Lighthouse, or `pa11y`) before claiming a11y compliance
3. Test keyboard navigation (Tab, Enter, Esc) on interactive components
4. Verify contrast ratios against WCAG AA (4.5:1 for text, 3:1 for UI components) with a contrast tool
5. Check responsive layouts at common breakpoints (375px, 768px, 1280px)
