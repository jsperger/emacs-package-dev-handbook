# Phase 0 — Baseline & tooling (cold-start prompt)

You are starting Phase 0 of the Emacs 31 revision of the Emacs Package
Developer's Handbook. Read CLAUDE.md and PLAN.org before doing anything
else; PLAN.org defines this phase's milestone and the acceptance
checklist that gates completion.

Setup: work on a feature branch named `phase-0/baseline` created from
`develop` (never commit to `master`). All Emacs operations use the
project-local config in `emacs.d/` — never the personal Emacs config or
its running daemon. From the repo root:

- batch one-shots: `emacs --batch --init-directory=emacs.d -l emacs.d/init.el <args>`
- or start a project daemon once: `emacs --init-directory=emacs.d --daemon=epdh`,
  then drive it with `emacsclient -s epdh -e '(...)'`

First launch bootstraps packages into `emacs.d/elpa/` (needs network
access; the directory is gitignored).

Phase 0 milestone: the publishing pipeline is reproducible on Emacs 31
with unchanged content. A first verification pass was already done on
2026-07-23 (see the `emacs.d/` commit on develop): `epdh-publish` ran
end to end on Emacs 31.0.90; org-make-toc and tangle reproduced
README.org and epdh.el byte-identically; only index.html differed
(cosmetic churn from the newer Org HTML exporter). Your job is to
confirm that baseline, systematize it, and produce the audit artifacts.
Deliverables, in order:

1. Pipeline verification. Run
   `emacs --batch --init-directory=emacs.d -l emacs.d/init.el -f epdh-publish`
   and confirm: exit code 0; README.org and epdh.el unchanged per
   `git status`; index.html regenerated with title-based anchors
   (e.g. `href="#emacs-lisp"`, not only random `#orgNNNNNNN` IDs).
   Then discard the regenerated file: `git checkout -- index.html`.
   Record the procedure, results, Emacs/Org versions, and anything the
   project config still lacks in audit/pipeline-notes.org.
   Constraints:
   - Do NOT commit a regenerated index.html or epdh.el in this phase.
     Regeneration of index.html is deliberate and deferred (PLAN.org
     Phase 7).
   - Do not let export or tangle EVALUATE src blocks — the benchmark
     blocks must not re-run in this phase. Check :eval headers and keep
     `org-confirm-babel-evaluate` protective.

2. Byte-compilation baseline. Byte-compile epdh.el (as committed) under
   Emacs 31 via the project config and record EVERY warning verbatim in
   audit/byte-compile-warnings.org. One warning is already known:
   `buffer-substring` used as an obsolete generalized variable, from
   `(setf (buffer-substring ...))` in `epdh/emacs-lisp-macroreplace`.
   These warnings are seed data for the Phase 1 deprecation audit —
   completeness matters more than tidiness.

3. Link baseline. Pick a link-checking approach (a script is fine; put
   it in audit/ if you write one), extract every external URL from
   README.org, check them, and write the full report to
   audit/links-baseline.org with columns: URL, section, HTTP status,
   disposition (ok / redirect / dead / unknown). Do not fix any links —
   this phase only measures.

4. Topic inventory. Create audit/inventory.org: a table with one row
   per topic section of README.org (the `**` headings under "Emacs
   Lisp", plus Blogs/People), and status columns for Phase 1
   (correctness), Phase 4 (packages), Phase 5 (benchmarks), Phase 6
   (links), all initialized to TODO. Later phases update this table.

Completion: verify your work against the acceptance checklist in
PLAN.org (the Build and Process sections apply fully; Content sections
apply to the audit files you wrote). Commit with the
`Prefix: description` style, push the branch, but do NOT merge into
develop — finish by reporting checklist results and anything surprising
you found, and wait for review.
