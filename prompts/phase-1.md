# Phase 1 — Correctness sweep (cold-start prompt)

You are starting Phase 1 of the Emacs 31 revision of the Emacs Package
Developer's Handbook. Phase 0 is complete. Read, in this order:
CLAUDE.md, PLAN.org, audit/pipeline-notes.org,
audit/byte-compile-warnings.org, and audit/inventory.org.

Setup: work on a feature branch named `phase-1/correctness` created
from `develop` (never commit to `master`). All Emacs operations use the
project-local config in `emacs.d/` — never the personal Emacs config or
its running daemon. From the repo root:

- batch one-shots: `emacs --batch --init-directory=emacs.d -l emacs.d/init.el <args>`
- or start a project daemon once: `emacs --init-directory=emacs.d --daemon=epdh`,
  then drive it with `emacsclient -s epdh -e '(...)'`

Phase 1 milestone: the guide makes no false or deprecated claims when
read against Emacs 31. Scope is goals 1–2 from PLAN.org: deprecated
references, and advice that is no longer true or needed. Adding new
content is Phase 2 — do not start it here beyond one-line rewrites.

Method — work topic by topic through audit/inventory.org, one commit
per topic (skip topics with nothing to change, marking them done):

1. Build the audit list first. From references/NEWS.29, NEWS.30, and
   NEWS.31 (plus references/mastering-emacs-whats-new-28-1.md and the
   Phase 0 byte-compile warnings for the Emacs 28 era), extract
   symbols and behaviors that were deprecated, removed, renamed, or
   obsoleted. Then sweep README.org (including code in src blocks) for
   each. Do not rely on memory for what is deprecated — every finding
   must trace to a NEWS entry, a byte-compiler warning, or the manuals
   under references/emacs-info.

2. For each hit: rewrite to the modern equivalent, or remove. If the
   old way is worth keeping as context, keep it but explicitly mark it
   historical. Verify every replacement against references/emacs-info
   before writing it.

3. Separately judge each topic's prose advice: tips, workarounds, and
   "best practices" that Emacs 28–31 made unnecessary (now built in,
   default, or fixed) get removed or rewritten. When you remove
   something, note it and the reason in the commit message.

4. Update the Phase 1 column of audit/inventory.org as each topic is
   completed.

Constraints:
- Preserve every existing CUSTOM_ID property; published anchors must
  not break. Keep the alphabetical topic order, the recurring
  subheading scheme, and the existing tag vocabulary.
- Do not hand-edit index.html or epdh.el; do not commit regenerated
  versions of them in this phase. If your edits change tangled blocks,
  regenerate epdh.el via the pipeline only to test, then restore it —
  a fresh tangle/export commit is a separate, deliberate step.
- Do not re-run benchmarks (Phase 5); if a benchmark's code uses a
  deprecated form, fix the code, leave the results table, and flag the
  row in audit/inventory.org for Phase 5.
- If a change would require judgment about removing a package
  recommendation, leave the entry and flag it in the inventory for
  Phase 4 — this phase is about factual correctness only.

Verification: after the sweep, tangle and byte-compile epdh.el on
Emacs 31 via the project config, e.g.

    emacs --batch --init-directory=emacs.d -l emacs.d/init.el \
      --eval '(byte-compile-file "epdh.el")'

(using a tangle-fresh epdh.el, then `git checkout -- epdh.el` after).
There must be no NEW warnings versus audit/byte-compile-warnings.org,
and warnings whose cause you fixed should be gone — the known
`buffer-substring` generalized-variable warning should be among the
fixed. Then run the full acceptance checklist from PLAN.org. Commit in
`Prefix: description` style, push the branch, do NOT merge into
develop — finish by reporting: per-topic summary of changes, checklist
results, and any findings you deliberately deferred to Phases 2, 4,
or 5.
