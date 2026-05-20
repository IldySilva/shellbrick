# Shellbrick — Design Specification (MVP)

# 1. Design Vision

Shellbrick is not just an SSH client.

It is a calm, modern, native workspace for infrastructure engineers.

The product should feel:

- minimal
- fast
- premium
- focused
- native
- elegant
- trustworthy

The experience must reduce cognitive load and make infrastructure management feel enjoyable instead of chaotic.

---

# 2. Design Philosophy

# 2.1 Minimalism First

Everything unnecessary must be removed.

Avoid:
- visual clutter
- noisy borders
- excessive colors
- dense interfaces
- overly decorative UI

Prioritize:
- whitespace
- hierarchy
- typography
- simplicity
- clarity

---

# 2.2 Typography-Driven Interface

Typography is the primary design element.

The UI should rely more on:
- spacing
- weight
- alignment
- contrast

instead of:
- excessive containers
- unnecessary dividers
- visual effects

---

# 2.3 Native Desktop Feel

Shellbrick must feel like a real desktop application.

Not:
- a web app
- a mobile app on desktop
- an Electron clone

Behavior should respect:
- macOS conventions
- Linux desktop expectations
- keyboard-first workflows

---

# 2.4 Calm Infrastructure UX

Infrastructure tools are often:
- visually noisy
- intimidating
- overloaded

Shellbrick should feel:
- quiet
- stable
- controlled
- readable

The interface must reduce operational stress.

---

# 2.5 Keyboard-First Experience

The UI should optimize for:
- shortcuts
- command palette workflows
- fast switching
- low mouse dependency

Power users should feel fast.

---

# 3. Visual Identity

# 3.1 Core Style

Style direction:

- Swiss-inspired minimalism
- developer-focused desktop UX
- typography-first
- terminal-native aesthetics

Inspired by:
- Linear
- Raycast
- Ghostty
- Warp
- Arc Browser
- VSCode
- Apple HIG

---

# 3.2 Interface Characteristics

The interface should feel:

- spacious
- balanced
- lightweight
- intentional
- clean

Avoid:
- crowded layouts
- heavy shadows
- glassmorphism abuse
- excessive gradients
- flashy animations

---

# 4. Layout System

# 4.1 Main Layout Structure

```txt
┌──────────────────────────────────────┐
│ Top Bar                             │
├──────────────┬──────────────────────┤
│ Sidebar      │ Main Content         │
│              │                      │
│ Hosts        │ Terminal             │
│ Favorites    │                      │
│ Tags         │                      │
│ Recent       │                      │
│              │                      │
└──────────────┴──────────────────────┘
```

---

# 4.2 Sidebar

Purpose:
- navigation
- host organization
- quick switching

Characteristics:
- fixed width
- compact
- typography-focused
- minimal icons

Avoid:
- large visual weight
- colorful backgrounds
- oversized buttons

---

# 4.3 Main Terminal Area

The terminal is the hero of the application.

It must:
- dominate the layout visually
- maximize readable space
- feel immersive

The terminal should feel:
- distraction-free
- focused
- professional

---

# 5. Color System

# 5.1 Theme Strategy

Dark-first design.

Light mode optional later.

---

# 5.2 Base Colors

Use neutral dark tones.

Avoid:
- pure black
- oversaturated colors

Recommended palette style:

```txt
Background: #0F1115
Surface:    #151922
Border:     #232734
Text:       #E6EAF2
Muted Text: #9AA4B2
```

---

# 5.3 Accent Colors

Only one primary accent color active at a time.

Examples:
- blue
- green
- orange

Accent color usage should be minimal.

Use accent color only for:
- active items
- focus states
- selected elements
- primary actions

Never overload the UI with accent colors.

---

# 5.4 Semantic Colors

Success:
- muted green

Warning:
- muted yellow/orange

Error:
- muted red

Colors should feel professional and restrained.

---

# 6. Typography

# 6.1 Philosophy

Typography is the foundation of the interface.

The product should communicate hierarchy mostly through:
- size
- weight
- spacing

not through:
- boxes
- borders
- decorations

---

# 6.2 Font Stack

# UI Font

Recommended:
- Inter

Alternative:
- SF Pro on macOS

---

# Terminal Font

Recommended:
- JetBrains Mono

Alternatives:
- Geist Mono
- Fira Code

---

# 6.3 Typography Scale

## Sidebar Labels

- 13px
- medium weight

## Main Headers

- 20px–28px
- semibold

## Body Text

- 14px–15px

## Terminal

- 13px–14px monospace

---

# 7. Spacing System

# 7.1 Philosophy

Whitespace is a feature.

Never compress the UI unnecessarily.

---

# 7.2 Base Spacing Scale

```txt
4
8
12
16
24
32
48
64
```

Most layouts should use:
- 16px
- 24px
- 32px

Avoid inconsistent spacing.

---

# 8. Components

# 8.1 Buttons

Buttons should feel:
- lightweight
- modern
- subtle

Avoid:
- huge rounded buttons
- excessive shadows
- gradients

Preferred:
- low-radius corners
- subtle hover states

---

# 8.2 Inputs

Inputs should:
- blend into the UI
- avoid excessive borders
- prioritize readability

States:
- idle
- hover
- focus
- error

Focus states should use accent color subtly.

---

# 8.3 Cards

Use cards sparingly.

Avoid:
- dashboard-style clutter

Prefer:
- flat surfaces
- grouped layouts
- section spacing

---

# 8.4 Modals

Modals should:
- feel lightweight
- avoid excessive size
- maintain focus

Animations should be subtle and fast.

---

# 9. Animations

# 9.1 Philosophy

Animations should:
- support clarity
- never distract

---

# 9.2 Motion Style

Preferred:
- fade
- scale
- slide

Avoid:
- bounce
- exaggerated easing
- flashy motion

---

# 9.3 Duration

Recommended:
- 120ms
- 180ms
- 240ms

Animations should feel fast and responsive.

---

# 10. Icons

# 10.1 Style

Use:
- thin outline icons
- minimal iconography

Avoid:
- colorful icons
- skeuomorphic styles

---

# 10.2 Recommended Icon Set

- Lucide-style icons
- Cupertino-inspired icons

---

# 11. Terminal Experience

# 11.1 Terminal Philosophy

The terminal is the core experience.

It must feel:
- fast
- immersive
- distraction-free

---

# 11.2 Terminal Layout

Avoid:
- heavy toolbars
- unnecessary controls

Prefer:
- clean top tabs
- subtle session metadata
- maximum usable space

---

# 11.3 Cursor

Cursor should:
- feel responsive
- have subtle animation
- remain visible in dark themes

---

# 12. Responsive Behavior

# 12.1 Desktop First

Shellbrick is desktop-first.

Not mobile-first.

Layouts should optimize for:
- large screens
- ultrawide monitors
- multi-window workflows

---

# 12.2 Minimum Width

Recommended minimum width:

```txt
1100px
```

---

# 13. Accessibility

# 13.1 Requirements

Support:
- keyboard navigation
- screen scaling
- readable contrast
- terminal readability

---

# 13.2 Keyboard Navigation

Everything important should be accessible through:
- shortcuts
- command palette
- keyboard traversal

---

# 14. UX Principles

# 14.1 Fast Paths

Frequent actions must require minimal clicks.

Examples:
- quick connect
- recent hosts
- favorites
- command palette

---

# 14.2 Progressive Complexity

Do not overwhelm new users.

Advanced features should appear progressively.

---

# 14.3 Trust

The interface should communicate:
- reliability
- professionalism
- stability

Avoid:
- gimmicks
- playful UI
- visual chaos

---

# 15. MVP Design Priorities

Highest priorities:

1. Terminal readability
2. Host navigation speed
3. Native desktop feel
4. Typography quality
5. Smooth keyboard workflows
6. Calm visual experience

---

# 16. Design Anti-Patterns

Never turn Shellbrick into:

- a dashboard SaaS
- an Electron-style web app
- a flashy cyberpunk terminal toy
- an overloaded DevOps platform
- a cluttered enterprise interface

---

# 17. Final Design Philosophy

Shellbrick should feel like:

> “A calm, modern SSH workspace built for serious developers who value focus, speed, and native desktop quality.”