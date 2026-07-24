# Phase 3 — Development-landscape overview (cold-start prompt)

You are starting Phase 3 of the Emacs 31 revision of the Emacs Package
Developer's Handbook. Phases 0–2 are complete; Phase 2 is on branch
`phase-2/new-features` (not yet merged to `develop`). Read, in this
order: CLAUDE.md, PLAN.org (especially the Operational notes section),
NOTES.org (Lessons learned), audit/inventory.org,
audit/new-features.org (especially the "Phase 3 candidates" heading),
and CHANGELOG.org.

Setup: work on a feature branch named `phase-3/landscape` created
from `develop` (never commit to `master`). If `phase-2/new-features`
has been merged into `develop` by the time you start, branch from the
updated `develop`; otherwise branch from `develop` as-is — Phase 3
does not depend on Phase 2's content. All Emacs operations use the
project-local config in `emacs.d/` — never the personal Emacs config
or its running daemon. From the repo root:

- batch one-shots: `emacs --batch --init-directory=emacs.d -l emacs.d/init.el <args>`
- or start a project daemon once: `emacs --init-directory=emacs.d --daemon=epdh`,
  then drive it with `emacsclient -s epdh -e '(...)'`

Phase 3 milestone: a new section summarizes how the Emacs package
development ecosystem has shifted since the guide's last substantive
update (~2024, Emacs 28/29 era). Scope is goal 4 from PLAN.org. This
is a content-writing phase: you are adding one new survey section,
not extending per-topic entries (that was Phase 2) or reviewing
package recommendations (that is Phase 4).

## Method

1. **Research the landscape shifts.** The starting point is the
   "Phase 3 candidates" list in `audit/new-features.org`:

   - NonGNU ELPA maturation and its role in the package ecosystem.
   - `package-vc` changing how users install from source (Git
     checkouts vs. tarballs) — affects package distribution strategy.
   - `use-package` built-in changing the "how to configure packages"
     landscape — every guide/tutorial now assumes it.
   - Tree-sitter becoming the default for many major modes in Emacs
     30+ (via `major-mode-remap-alist`) — affects mode authors.
   - Native compilation maturity (Emacs 28+ AOT, Emacs 30+
     `compilation-safety`) — affects performance advice.
   - Eglot built-in (Emacs 29) — LSP now a first-class citizen.
   - The `erts-mode` / `ert-test-erts-file` testing paradigm for
     buffer actions.

   This list is a starting point, not exhaustive. Research additional
   shifts using:

   - `references/NEWS.29`, `references/NEWS.30`, `references/NEWS.31`
     — search for packaging, archive, distribution, and tooling
     changes.
   - `references/mastering-emacs-whats-new-{28,29,30}-1.md` for
     high-level ecosystem commentary.
   - `references/emacs-info` — verify any built-in feature's current
     documented behavior before writing about it.
   - The web, for ecosystem-level changes not covered in the NEWS
     files: MELPA changes, NonGNU ELPA growth, CI tooling evolution
     (GitHub Actions replacing Travis CI for Emacs packages), new
     linting tools (package-lint maturity, Eask adoption), community
     resources (EmacsConf, r/emacs, Planet Emacsen changes), and the
     Compat library's role in cross-version package development.

   For each shift, note: what changed, which Emacs version(s) drove
   it, and why a package author should care.

2. **Write the section.** Add a new top-level section to README.org
   titled `* Development landscape` (or similar), placed after the
   `* Emacs Lisp` section and before `* Blogs`. This is a
   /survey with pointers/, consistent with the guide's link-heavy
   style — not a tutorial or a NEWS digest.

   Structure the section with `**` subsections for each major theme.
   Suggested themes (let the research drive the actual list):

   - **Package archives and distribution**: GNU ELPA / NonGNU ELPA /
     MELPA roles today; `package-vc` and source installs; the User
     Lisp directory (Emacs 31); `package-install-upgrade-built-in`.
   - **Package configuration**: `use-package` built-in (Emacs 29);
     how init-file conventions have changed.
   - **Built-in packages that changed the landscape**: Eglot (LSP),
     `which-key` (Emacs 30), `compat` stub (Emacs 30), tree-sitter
     modes as defaults (Emacs 30).
   - **Native compilation**: maturity since Emacs 28; AOT;
     `compilation-safety`; what it means for performance advice.
   - **Tree-sitter**: from optional (Emacs 29) to default (Emacs 30+);
     impact on mode authors; `major-mode-remap-alist`.
   - **Testing and CI**: `erts-mode` paradigm; ERT JUnit reports;
     GitHub Actions replacing Travis; Eask / eldev / makem.sh
     evolution.
   - **Cross-version compatibility**: the Compat library;
     `static-if` / `static-when`; `Package-Requires` strategies.

   Each subsection should be 1–3 short paragraphs with org links to
   manuals, articles, or project pages. Use the guide's existing
   style: link-heavy, concise, practical. Add `:PROPERTIES:` with
   `:CUSTOM_ID:` for every heading. Add appropriate filter tags from
   the existing vocabulary.

3. **Cross-reference.** Where the landscape section mentions a
   feature already covered in a topic section (e.g. `use-package` in
   Packaging, tree-sitter in the Tree-sitter topic), add a brief
   cross-reference link (`[[#custom-id][see ...]]`) rather than
   duplicating the content.

4. **Update the inventory.** Add a row for the new section in
   `audit/inventory.org` with Phase 3 marked DONE.

## Constraints

- **Verify every claim** against `references/emacs-info` or the NEWS
  files before writing it. For web-sourced claims (MELPA stats, CI
  trends), link to the source and keep the claim factual and
  hedged where appropriate.
- **Preserve every existing CUSTOM_ID**; published anchors must not
  break. Keep the existing tag vocabulary.
- **Do not hand-edit index.html or epdh.el.** This phase adds no
  tangled code.
- **Do not re-run benchmarks** (Phase 5) or review package
  recommendations (Phase 4). If you notice a package that should be
  added or removed from a topic's Libraries/Tools subsection, note it
  in `audit/inventory.org` or the commit message for Phase 4.
- **Do not modify existing topic sections** except to add
  cross-reference links pointing to the new landscape section. Phase 3
  adds a new section; it does not rewrite existing content.
- **Keep the section a survey.** Each subsection should be a few
  paragraphs with links, not a deep dive. The per-topic sections
  already have the detail. If you find yourself writing more than
  ~10 lines of prose per subsection, consider whether the content
  belongs in a topic section instead (flag it for Phase 4 if so).
- **Keep commits focused**: one commit for the new section, one for
  any cross-references, one for the inventory update. Commit messages
  in `Prefix: description` style, e.g. `Add: Development landscape
  overview section`.

## Verification

After writing:

1. Verify all CUSTOM_IDs are preserved:

       python3 -c "
       import re
       with open('README.org') as f:
           ids = re.findall(r':CUSTOM_ID:\s+(\S+)', f.read())
       print(f'Total: {len(ids)}')
       "

   Compare against the count before your edits (should be ≥ 263).

2. Verify all links you added resolve. For GNU manual links, check
   they follow the established URL pattern
   (`https://www.gnu.org/software/emacs/manual/html_node/...`). For
   web links, spot-check a sample.

3. Tangle and byte-compile to confirm nothing broke (should be
   unchanged):

       emacs --batch --init-directory=emacs.d -l emacs.d/init.el \
         --eval '(with-current-buffer (find-file-noselect "README.org") (org-babel-tangle))'
       emacs --batch --init-directory=emacs.d -l emacs.d/init.el \
         --eval '(byte-compile-file "epdh.el")'

   Zero warnings required. Then `git checkout -- epdh.el`.

4. Run the full acceptance checklist from PLAN.org (Content accuracy,
   Document integrity, Build, and Process sections all apply).

5. Commit in `Prefix: description` style, push the branch, do NOT
   merge into develop.

Finish by reporting: the themes covered, per-subsection summary,
checklist results, any findings deferred to Phases 4, 5, or 6, and
any web sources used that should be checked for link rot in Phase 6.
