;;; init.el --- Project-local Emacs config for the EPDH -*- lexical-binding: t; -*-

;; Project-specific config for working on the Emacs Package Developer's
;; Handbook without touching the personal Emacs configuration.
;;
;; Usage, from the repo root:
;;
;;   emacs --init-directory=emacs.d README.org         ; interactive session
;;   emacs --init-directory=emacs.d --daemon=epdh      ; project daemon, then:
;;   emacsclient -s epdh -e '(epdh-publish)'           ; drive it via emacsclient
;;   emacsclient -s epdh --no-wait README.org
;;
;; One-shot batch publish (no daemon):
;;
;;   emacs --batch --init-directory=emacs.d -l emacs.d/init.el -f epdh-publish
;;
;; Packages, native-comp cache, and customizations all live inside
;; emacs.d/ (gitignored), so nothing leaks into ~/.emacs.d or
;; ~/.config/emacs.  First launch downloads the few required packages.

;;; Code:

(defconst epdh-root (file-name-directory (directory-file-name user-emacs-directory))
  "Root directory of the emacs-package-dev-handbook repository.")

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

(setq native-comp-async-report-warnings-errors 'silent)

;;;; Packages

(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

(defvar epdh-required-packages '(org-make-toc htmlize dash s)
  "Packages the publishing pipeline and epdh.el depend on.")

(let ((missing (seq-remove #'package-installed-p epdh-required-packages)))
  (when missing
    (package-refresh-contents)
    (mapc #'package-install missing)))

;;;; Load paths and pipeline requirements

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(add-to-list 'load-path epdh-root)

(require 'org-make-toc)

;; Stable, title-derived HTML anchors (vendored from alphapapa's
;; unpackaged.el); README.org's file-local variables expect this mode.
(require 'epdh-useful-ids)
(unpackaged/org-export-html-with-useful-ids-mode 1)

;; Benchmark macros (bench, bench-multi, ...) tangled from README.org.
;; Failure to load is survivable (e.g. mid-edit during revision work).
(condition-case err
    (require 'epdh)
  (error (message "init.el: could not load epdh.el: %S" err)))

;;;; Export settings

;; The darksun theme styles code with export/styles/darksun/css/htmlize.css,
;; so htmlize must emit class names, not inline colors.
(setq org-html-htmlize-output-type 'css)

;; Trust README.org's file-local variables (ToC/tangle/export save hooks)
;; so visiting it doesn't prompt every session.
(setq safe-local-variable-values
      (append
       '((eval require 'org-make-toc)
         (eval unpackaged/org-export-html-with-useful-ids-mode 1)
         (before-save-hook . org-make-toc)
         (after-save-hook lambda nil
                          (org-babel-tangle)
                          (when (org-html-export-to-html)
                            (rename-file "README.html" "index.html" t)))
         (org-export-with-properties)
         (org-export-with-title . t)
         (org-export-with-broken-links . t)
         (org-id-link-to-org-use-id)
         (org-export-initial-scope . buffer)
         (org-make-toc-insert-custom-ids . t))
       safe-local-variable-values))

;;;; Commands

(defun epdh-publish ()
  "Regenerate ToC, epdh.el, and index.html from README.org.
Equivalent to the file-local save hooks, but runnable on demand
\(including in batch mode)."
  (interactive)
  (require 'ox-html)
  (with-current-buffer (find-file-noselect (expand-file-name "README.org" epdh-root))
    (org-make-toc)
    (when (buffer-modified-p)
      ;; Save without the file-local hooks; tangle/export run below.
      (let ((before-save-hook nil)
            (after-save-hook nil))
        (save-buffer)))
    (org-babel-tangle)
    (when (org-html-export-to-html)
      (rename-file (expand-file-name "README.html" epdh-root)
                   (expand-file-name "index.html" epdh-root)
                   t))
    (message "epdh-publish: done")))

;;; init.el ends here
