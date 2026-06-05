---
name: Architectural Continuity
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#c1c6d7'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#8b90a0'
  outline-variant: '#414755'
  surface-tint: '#adc6ff'
  primary: '#adc6ff'
  on-primary: '#002e69'
  primary-container: '#4b8eff'
  on-primary-container: '#00285c'
  inverse-primary: '#005bc1'
  secondary: '#c0c1ff'
  on-secondary: '#1000a9'
  secondary-container: '#3131c0'
  on-secondary-container: '#b0b2ff'
  tertiary: '#b9c8de'
  on-tertiary: '#233143'
  tertiary-container: '#8392a6'
  on-tertiary-container: '#1c2b3c'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a41'
  on-primary-fixed-variant: '#004493'
  secondary-fixed: '#e1e0ff'
  secondary-fixed-dim: '#c0c1ff'
  on-secondary-fixed: '#07006c'
  on-secondary-fixed-variant: '#2f2ebe'
  tertiary-fixed: '#d4e4fa'
  tertiary-fixed-dim: '#b9c8de'
  on-tertiary-fixed: '#0d1c2d'
  on-tertiary-fixed-variant: '#39485a'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
  state-healthy: '#10b981'
  state-informational: '#3b82f6'
  state-attention: '#f59e0b'
  state-awaiting: '#8b5cf6'
  state-blocked: '#ef4444'
  state-escalated: '#dc2626'
  surface-primary: '#020617'
  surface-secondary: '#1e293b'
  border-subtle: '#334155'
typography:
  intent-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  intent-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  operational-sm:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  operational-xs:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  architectural-label:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  technical-data:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 16px
  margin-desktop: 24px
  panel-width-md: 320px
  inspector-width-lg: 480px
---

## Brand & Style

This design system is built for "Software Evolution." It prioritizes **Architectural Continuity** and **Execution Transparency**. The brand personality is professional, authoritative, and precise—designed to feel like a high-stakes engineering environment rather than a creative playground.

The aesthetic follows a **Corporate / Modern** approach with **Minimalist** and **Technical** influences. It utilizes a "Pro" dark-themed logic to reduce visual fatigue during deep work while maintaining a rigid, structural grid. The design philosophy of **Progressive Complexity Disclosure** ensures that the "machinery" of the platform (agents, graphs, workers) is accessible but never overwhelming, surfacing only when the user requires deeper technical context.

**Core Principles:**
- **Specification Primacy:** The UI must reflect that software is an artifact of intent.
- **Traceability:** Every element has a lineage; the UI must visually support "upstream" and "downstream" logic.
- **State-Dominance:** Color is used functionally to communicate the health and operational status of the software evolution process.

## Colors

The palette is anchored in a deep "Midnight" neutral range to provide an architectural foundation. **Primary Blue** is reserved for purposeful action and intent, while the **Semantic State Palette** handles the heavy lifting of operational communication.

- **Background Strategy:** Use `surface-primary` for the main workspace and `surface-secondary` for persistent panels and inspectors.
- **State Application:** Colors like `state-blocked` or `state-healthy` should be used as high-contrast accents (pills, borders, or text) against neutral backgrounds. 
- **Accessibility:** Never rely on color alone. Status indicators must pair a semantic color with an explicit text label (e.g., a "Blocked" icon must be accompanied by the word "Blocked").

## Typography

The typography system mirrors the mental model of the platform, moving from high-level "Intent" to deep "Technical" data.

1.  **Intent (Headlines):** Uses **Hanken Grotesk**. Bold and clean for high-level goals and project names.
2.  **Operational (Body):** Uses **Inter**. Optimized for readability in forms, logs, and status descriptions.
3.  **Architectural & Technical (Labels/Monospace):** Uses **JetBrains Mono**. Reserved for entities, interfaces, graph logic, and line-level technical data. 

On mobile devices, scale `intent-lg` down to 24px (`intent-lg-mobile`) and prioritize the `operational-sm` size for all body text to maintain density.

## Layout & Spacing

The design system employs a **Fixed-Fluid Hybrid** model. The global shell is fixed, while the central workspace is fluid to accommodate complex architectural diagrams or specification documents.

- **Simultaneous Context:** The desktop layout must support a three-tier hierarchy:
  - **Left:** Global/Project Navigation (Condensed).
  - **Center:** Main Workspace (Flexible).
  - **Right:** Contextual/Impact Panel (Fixed `panel-width-md`).
- **Progressive Disclosure:** Deep technical data should reside in **Drawers** that slide over the Impact Panel or **Inspectors** that occupy a wider temporary footprint (`inspector-width-lg`).
- **Grid:** Use a 4px baseline grid. All component padding and margins should be multiples of 4px to ensure architectural alignment.

## Elevation & Depth

Hierarchy is conveyed through **Tonal Layers** rather than heavy shadows. This reinforces the "Architectural" feel by treating the UI as a series of stacked, precision-cut surfaces.

- **Level 0 (Canvas):** `surface-primary`. Used for the root background.
- **Level 1 (Panels):** `surface-secondary`. Used for persistent sidebars and navigation shells.
- **Level 2 (Cards/Modules):** A slightly lighter tint of the neutral scale with a `1px` solid border using `border-subtle`.
- **Level 3 (Overlays):** Drawers and Modals. These use a subtle **Backdrop Blur** (Glassmorphism) to maintain context of the underlying workspace while signaling a temporary focus shift.
- **Traceability Highlighting:** When an element is selected, its "Upstream" and "Downstream" connections are highlighted using low-opacity glow effects in the primary brand color, rather than traditional elevation shadows.

## Shapes

The shape language is **Soft (0.25rem)**. This provides a professional, engineered feel that avoids the playfulness of fully rounded corners while remaining more modern and approachable than sharp 90-degree angles.

- **Standard Elements:** Buttons, Inputs, and Cards use the base 4px (0.25rem) radius.
- **Status Pills:** Use `rounded-lg` (8px) to distinguish them as floating status metadata.
- **Data Containers:** Technical logs and monospaced code blocks should use sharp corners (0px) to reinforce their "raw data" nature.

## Components

- **Buttons:** High-contrast, rectangular with minimal rounding. Primary buttons use a solid fill; secondary buttons use a ghost style with a `border-subtle`.
- **Status Indicators:** Explicit pills containing both an icon and text (e.g., [!] Blocked). The color of the pill background should be at 10% opacity of the state color, with the text and icon at 100% opacity for legibility.
- **Contextual Drawers:** Slide-in surfaces from the right for "Lineage" and "Impact" inspection. They should include a header with breadcrumbs showing the object's position in the architectural graph.
- **Impact Cards:** Standardized modules used across the platform to show "What will change." They must display four metrics: Summary, Scope, Impact Score, and Traceability.
- **Input Fields:** Minimalist design. Dark background, `border-subtle`, and `jetbrainsMono` font for technical values. Use a high-contrast `primary_color` border for the active/focus state.
- **Traceability Icons:** Use specific glyphs for "Source" (Square-into-Arrow), "Effect" (Arrow-into-Square), and "Evolution" (Clock-Arrow).