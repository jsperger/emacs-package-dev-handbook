# Phase 2 — New-feature coverage (cold-start prompt)

You are starting Phase 2 of the Emacs 31 revision of the Emacs Package
Developer's Handbook. Phases 0 and 1 are complete and merged into
`develop`. Read, in this order: CLAUDE.md, PLAN.org (especially the
Operational notes section), NOTES.org (Lessons learned),
audit/inventory.org, and audit/byte-compile-warnings.org.

Setup: work on a feature branch named `phase-2/new-features` created
from `develop` (never commit to `master`). All Emacs operations use
the project-local config in `emacs.d/` — never the personal Emacs
config or its running daemon. From the repo root:

- batch one-shots: `emacs --batch --init-directory=emacs.d -l emacs.d/init.el <args>`
- or start a project daemon once: `emacs --init-directory=emacs.d --daemon=epdh`,
  then drive it with `emacsclient -s epdh -e '(...)'`

Phase 2 milestone: every package-development-relevant feature added
in Emacs 28–31 has a home in the guide. Scope is goal 3 from
PLAN.org. This is a content-writing phase: you are adding and
extending sections, not fixing deprecated forms (that was Phase 1)
or reviewing package recommendations (that is Phase 4).

## Method

1. **Build the candidate feature list.** Extract features from the
   reference material, triaging strictly for relevance to *package
   development* (writing, testing, distributing, maintaining Emacs
   Lisp packages) — not general Emacs use. Sources, in priority
   order:

   - `references/NEWS.29`, `references/NEWS.30`, `references/NEWS.31`
     — exhaustive, one major version per file. Search for new
     functions, macros, variables, hooks, major/minor modes, and
     behavioral changes that a package author would encounter.
   - `references/mastering-emacs-whats-new-28-1.md` — Emacs 28
     features (there is no NEWS.28 file; this article is the
     substitute). Also `mastering-emacs-whats-new-29-1.md`,
     `mastering-emacs-whats-new-30-1.md`, and
     `mastering-emacs-whats-new-301.md` for high-level summaries.
     Note: there is no mastering-emacs article for Emacs 31 yet.
   - `references/emacs-info` — the installed Emacs 31 info manuals.
     Use these to verify any feature's current documented behavior
     before writing about it. This is the authoritative source; do
     not rely on memory.

   Write the triaged list to `audit/new-features.org` before editing
   README.org. For each candidate, note: the feature, which NEWS
   file/line it comes from, which topic section it belongs to (or
   "new section" if none fits), and a one-line rationale for
   inclusion or exclusion. Excluded features get a brief reason
   (e.g. "general editing, not package-dev relevant").

2. **Place each feature.** Slot survivors into the existing
   alphabetical topic scheme under `* Emacs Lisp`. Do NOT create
   version-based sections (no "Emacs 29 features" heading). If a
   feature fits an existing topic (e.g. `pcase` extensions → Pattern
   matching, `cl-lib` changes → General/cl-lib), extend that
   topic's appropriate subsection (Articles / Best practices /
   Libraries / Tools / Snippets). If no existing topic fits, create
   a new `**` topic section in alphabetical order with the standard
   subheading scheme.

   Likely topics to extend (non-exhaustive — let the NEWS triage
   drive the actual list):

   - **General / cl-lib**: CL renames (`cl-incf` → `incf`, etc.),
     new `cl-lib` functions.
   - **General / subr-x**: new `subr-x` functions promoted or added.
   - **Packaging**: `use-package` built-in (Emacs 29), `Package-Requires`
     changes, new packaging conventions, `package-vc` (Emacs 29).
   - **Testing**: ERT improvements, new testing helpers.
   - **Debugging**: `backtrace` changes, new debugging tools.
   - **Collections**: new `map`/`seq` functions, hash-table changes.
   - **Strings**: new string functions (`string-lines`, `string-pad`, etc.).
   - **Networking**: `plz` additions, `url` changes.
   - **Optimization**: native-compilation maturity, new benchmarking
     considerations.
   - **Highlighting / font-locking**: tree-sitter fontification
     (treesit), `font-lock` variable changes (Emacs 31 obsoleted
     face variables).
   - A new **Tree-sitter** topic may be warranted if there is enough
     package-dev-relevant content (grammar authoring, `treesit.el`
     API for package authors).

3. **Write the content.** Match the guide's existing style:

   - Link-heavy: each entry is typically an org link as the heading
     (or a short heading with a link in the body), with 1–3
     sentences of context.
   - Use the recurring subheading names: `Articles`, `Best
     practices`, `Examples`, `Libraries`, `Tools`, `Snippets`.
   - For built-in features, link to the relevant info manual node
     (e.g. `[[https://www.gnu.org/software/emacs/manual/html_node/elisp/...][...]]`)
     or the Emacs source on GitHub.
   - For code snippets, use `#+BEGIN_SRC elisp` blocks. Only add
     `:tangle epdh.el` if the snippet is a reusable utility function
     (not a demonstration). If you tangle new code, verify it
     byte-compiles cleanly.
   - Add `:PROPERTIES:` with a `:CUSTOM_ID:` for every new heading
     (use a lowercase, hyphenated slug of the heading text).
   - Add appropriate filter tags from the existing vocabulary (e.g.
     `:built_in:`, `:testing:`, `:packaging:`).

4. **Update the inventory.** Mark the Phase 1 column as DONE for any
   topic you touch (it should already be DONE from Phase 1). Add a
   note in the commit message about what was added.

## Constraints

- **Verify every claim** against `references/emacs-info` before
  writing it. Do not describe a feature from memory or from the NEWS
  file alone — confirm the current documented signature, behavior,
  and availability.
- **Preserve every existing CUSTOM_ID**; published anchors must not
  break. Keep alphabetical topic order, the recurring subheading
  scheme, and the existing tag vocabulary.
- **Do not hand-edit index.html or epdh.el.** If your edits add
  tangled blocks, regenerate epdh.el via the pipeline only to test
  byte-compilation, then restore it (`git checkout -- epdh.el`).
- **Do not re-run benchmarks** (Phase 5). If you add a new benchmark
  snippet, add the code block but leave a placeholder results table
  and flag it in the inventory for Phase 5.
- **Do not remove or rewrite existing content** unless it is
  factually wrong (that was Phase 1). Phase 2 adds; it does not
  subtract. If you find something that should be removed, flag it
  for Phase 4.
- **Do not start Phase 3 work** (development-landscape overview).
  If you notice ecosystem-level shifts worth documenting, note them
  in `audit/new-features.org` under a "Phase 3 candidates" heading.
- **Keep commits focused**: one commit per topic section (or per
  logical group if a feature spans multiple topics). Commit messages
  in `Prefix: description` style, e.g. `Add: use-package built-in
  (Emacs 29)` or `Change: Extend Packaging with package-vc`.

## Verification

After the sweep:

1. Tangle and byte-compile epdh.el (if any tangled blocks were
   added or changed):

       emacs --batch --init-directory=emacs.d -l emacs.d/init.el \
         --eval '(with-current-buffer (find-file-noselect "README.org") (org-babel-tangle))'
       emacs --batch --init-directory=emacs.d -l emacs.d/init.el \
         --eval '(byte-compile-file "epdh.el")'

   Zero warnings required. Then `git checkout -- epdh.el`.

2. Run the full acceptance checklist from PLAN.org (Content accuracy,
   Document integrity, Build, and Process sections all apply).

3. Commit in `Prefix: description` style, push the branch, do NOT
   merge into develop.

Finish by reporting: the triaged feature list summary (how many
candidates, how many included, how many excluded and why), per-topic
summary of additions, checklist results, and any findings deferred to
Phases 3, 4, or 5.
