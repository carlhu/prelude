;;; init.el --- Prelude's configuration entry point.
;;
;; Copyright (c) 2011 Bozhidar Batsov
;;
;; Author: Bozhidar Batsov <bozhidar@batsov.com>
;; URL: http://batsov.com/prelude
;; Version: 1.0.0
;; Keywords: convenience

;; This file is not part of GNU Emacs.

;;; Commentary:

;; This file simply sets up the default load path and requires
;; the various modules defined within Emacs Prelude.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:
(defvar current-user
      (getenv
       (if (equal system-type 'windows-nt) "USERNAME" "USER")))

(message "Prelude is powering up... Be patient, Master %s!" current-user)
(setq prelude-guru nil)

(when (version< emacs-version "24.1")
  (error "Prelude requires at least GNU Emacs 24.1"))

(defvar prelude-dir (file-name-directory load-file-name)
  "The root dir of the Emacs Prelude distribution.")
(defvar prelude-core-dir (expand-file-name "core" prelude-dir)
  "The home of Prelude's core functionality.")
(defvar prelude-modules-dir (expand-file-name  "modules" prelude-dir)
  "This directory houses all of the built-in Prelude modules.")
(defvar prelude-personal-dir (expand-file-name "personal" prelude-dir)
  "This directory is for your personal configuration.

Users of Emacs Prelude are encouraged to keep their personal configuration
changes in this directory.  All Emacs Lisp files there are loaded automatically
by Prelude.")
(defvar prelude-vendor-dir (expand-file-name "vendor" prelude-dir)
  "This directory houses packages that are not yet available in ELPA (or MELPA).")
(defvar prelude-savefile-dir (expand-file-name "savefile" prelude-dir)
  "This folder stores all the automatically generated save/history-files.")
(defvar prelude-modules-file (expand-file-name "prelude-modules.el" prelude-dir)
  "This files contains a list of modules that will be loaded by Prelude.")

(unless (file-exists-p prelude-savefile-dir)
  (make-directory prelude-savefile-dir))

(defun prelude-add-subfolders-to-load-path (parent-dir)
 "Add all level PARENT-DIR subdirs to the `load-path'."
 (dolist (f (directory-files parent-dir))
   (let ((name (expand-file-name f parent-dir)))
     (when (and (file-directory-p name)
                (not (equal f ".."))
                (not (equal f ".")))
       (add-to-list 'load-path name)
       (prelude-add-subfolders-to-load-path name)))))

;; add Prelude's directories to Emacs's `load-path'
(add-to-list 'load-path prelude-core-dir)
(add-to-list 'load-path prelude-modules-dir)
(add-to-list 'load-path prelude-vendor-dir)
(prelude-add-subfolders-to-load-path prelude-vendor-dir)

;; reduce the frequency of garbage collection by making it happen on
;; each 50MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 50000000)

;; the core stuff
(require 'prelude-packages)
(require 'prelude-ui)
(require 'prelude-core)
(require 'prelude-mode)
(require 'prelude-editor)
(require 'prelude-global-keybindings)

;; OSX specific settings
(when (eq system-type 'darwin)
  (require 'prelude-osx))

;; the modules
(when (file-exists-p prelude-modules-file)
  (load prelude-modules-file))

;; config changes made through the customize UI will be store here
(setq custom-file (expand-file-name "custom.el" prelude-personal-dir))

;; load the personal settings (this includes `custom-file')
(when (file-exists-p prelude-personal-dir)
  (message "Loading personal configuration files in %s..." prelude-personal-dir)
  (mapc 'load (directory-files prelude-personal-dir 't "^[^#].*el$")))

(setq visual-line-mode nil)
(setq global-visual-line-mode nil)
(setq org-indent-mode t)
(setq org-startup-truncated nil)
(setq auto-fill-mode -1)
(setq-default fill-column 99999)
(setq fill-column 99999)
(setq org-startup-indented t)
(setq org-confirm-babel-evaluate nil)
(setq org-yank-adjusted-subtrees t) ; advanced cut and paste behavior for orgmode points.
(setq org-yank-folded-subtrees t) ; advanced cut and paste behavior for orgmode points.
(setq org-hide-leading-stars t)
(setq org-odd-level-only nil)
;; configure org
(setq org-insert-heading-respect-content nil)
;; (setq org-M-RET-may-split-line t)
(setq org-M-RET-may-split-line '((item) (default . t)))
;(setq org-M-RET-may-split-line t)
(setq org-special-ctrl-a/e t)
(setq org-return-follows-link nil)
;(setq org-use-speed-commands t)
(setq org-startup-align-all-tables nil)
(setq org-tags-column 0)
;; (setq org-archive-location (concat org-directory "archive/%s_archive::"))
;; (setq org-agenda-remove-tags t)
;;(setq org-treat-S-cursor-todo-selection-as-state-change t)
(setq org-log-into-drawer nil)
(setq org-link-frame-setup '((vm . vm-visit-folder-other-frame)
                             (gnus . org-gnus-no-new-news)
                             (file . find-file-other-window)
                             (wl . wl-other-frame)))
(setq org-use-speed-commands t)
(setq org-speed-commands-user nil)
(add-to-list 'org-speed-commands-user
             '("n" ded/org-show-next-heading-tidily))
(add-to-list 'org-speed-commands-user
             '("p" ded/org-show-previous-heading-tidily))
(setq org-completion-use-ido t)
(setq ido-auto-merge-delay-time 1)
(setq ido-everywhere t)
(ido-mode 'both)
(global-auto-revert-mode t)
(global-set-key (kbd "\C-m") 'newline-and-indent)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
;; prompt simplification
(fset 'yes-or-no-p 'y-or-n-p)
(setq confirm-nonexistent-file-or-buffer nil)
(setq ido-create-new-buffer 'always)
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message t)
(setq kill-buffer-query-functions
      (remq 'process-kill-buffer-query-function
            kill-buffer-query-functions))
(require 'paren)
(set-face-background 'show-paren-match-face (face-background 'default))
(set-face-foreground 'show-paren-match-face "#def")
(set-face-attribute 'show-paren-match-face nil :weight 'extra-bold)
(show-paren-mode 1)
(setq show-paren-delay 0)
(prefer-coding-system 'utf-8)
(defadvice save-buffers-kill-emacs (around no-y-or-n activate)
  (flet ((yes-or-no-p (&rest args) t)
         (y-or-n-p (&rest args) t))
    ad-do-it))
(global-set-key [(control next)] 'next-buffer)
(global-set-key [(control prior)] 'previous-buffer)
(define-key global-map (kbd "M-c") 'quick-copy-line)
;(define-key global-map (kbd "<f4>") 'magit-status)
; (global-set-key (kbd "\C-x\C-e") 'org-export-as-html)
(define-key global-map (kbd "C-/") 'hippie-expand)
(define-key minibuffer-local-map (kbd "C-/") 'hippie-expand)
(define-key global-map (kbd "C-=") 'kill-current-buffer-and-frame)
(define-key global-map (kbd "M-<f3>") 'switch-to-minus-todo)
(define-key global-map (kbd "<f3>") 'switch-to-personal-todo)
(define-key global-map (kbd "C-<f3>") 'switch-to-init-el)
;; (define-key global-map (kbd "<f4>") 'org-archive-to-archive-sibling)
(define-key global-map (kbd "<f4>") 'org-archive-subtree)

; (define-key global-map (kbd "C-<f4>") 'ido-kill-buffer)
(define-key global-map (kbd "C-<escape>") 'switch-to-blank)

;(global-set-key (kbd "C-x C-f") 'lusty-file-explorer)
;(global-set-key (kbd "C-x f") 'find-file)
(global-set-key (kbd "<f2>") 'my-anything-occur)
(global-set-key (kbd "<f1>") 'my-anything-switcher)
(global-set-key (kbd "C-M-<up>") 'my-goto-first-org-item)
;; (global-set-key (kbd "M-t") 'my-anything-switcher-at-point)
;;(global-set-key (kbd "M-t") 'ido-switch-buffer)
(global-set-key (kbd "C-c n") 'switch-to-notes)
(global-set-key (kbd "C-S-f") 'my-anything-grep)
(global-set-key (kbd "C-<f2>") 'my-anything-grep)
(global-set-key (kbd "M-<f6>") 'my-anything-grep-sql)
(global-set-key (kbd "<f7>") 'my-anything-grep-def)
(global-set-key (kbd "S-<f7>") 'my-anything-grep)
(global-set-key (kbd "C-<f7>") 'my-anything-grep-ref)
(global-set-key (kbd "M-C-<f2>") 'anything-grep)
(global-set-key [M-up] 'move-text-up)
(global-set-key [M-down] 'move-text-down)
(global-set-key (kbd "C-S-o")  'occur)
(global-set-key (kbd "C-x b") 'switch-to-buffer)
(define-key global-map (kbd "C-g") 'keyboard-escape-quit)
(global-set-key (kbd "C-c C-8") 'org-ctrl-c-star)
;;; esc quits
(define-key global-map (kbd "<escape>") 'keyboard-escape-quit)
(define-key minibuffer-local-map [escape] 'keyboard-escape-quit)
(define-key minibuffer-local-ns-map [escape] 'keyboard-escape-quit)
(define-key minibuffer-local-completion-map [escape] 'keyboard-escape-quit)
(define-key minibuffer-local-must-match-map [escape] 'keyboard-escape-quit)
(define-key minibuffer-local-isearch-map [escape] 'keyboard-escape-quit)

(define-key global-map (kbd "<f9>") 'split-window-horizontally)

;; Tell orgmode table to consider extra chars to be numbers.
(setq org-table-number-regexp "^\\([<>]?[-+^.0-]*[0-9-\?][-+^.0-9eE dDx()%:xX,]*\\|\\(0[xX]\\)[0-9a-fA-F]+\\)$")

(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <left>") 'windmove-left)
(global-set-key (kbd "C-o") 'other-window)
(global-set-key (kbd "C-M-<right>") 'windmove-right)
(global-set-key (kbd "C-M-<left>") 'windmove-left)

(global-set-key (kbd "M-C-w") 'clipboard-kill-ring-save)

(setq my-org-heading-finder
   [?\C-u ?\C-c ?\C-w])

(define-key global-map (kbd "<f8>") 'my-org-heading-finder)
; (define-key global-map (kbd "C-<f1>") 'other-window)


(add-hook 'org-mode-hook
          '(lambda ()
             (define-key org-mode-map (kbd "C-<f5>") 'my-org2html)
             (define-key org-mode-map (kbd "C-S-<f5>") 'my-org2html-open)
             (define-key org-mode-map (kbd "C-c C-<f5>") 'my-pattern-export-orgmode)
             (define-key org-mode-map (kbd "M-<f5>") 'my-import-orgmode)
             (define-key org-mode-map (kbd "<f5>") 'my-blog-export)
             (define-key org-mode-map (kbd "<f4>") 'org-archive-subtree)
;             (define-key org-mode-map (kbd "<f7>") 'export-to-tex)
             ;; (define-key org-mode-map (kbd "M-W") 'org-copy-special)
             (define-key org-mode-map (kbd "M-W") 'my-copy-orgmode)
             (define-key org-mode-map (kbd "C-S-w") 'org-cut-special)
             (define-key org-mode-map (kbd "C-c C-d") 'org-time-stamp)
             (define-key org-mode-map (kbd "C-t") 'org-ctrl-c-ctrl-c)
             ))

;;; (define-key global-map (kbd "M-W") 'org-copy-special)


(add-hook 'html-mode-hook
          '(lambda ()
             (define-key html-mode-map (kbd "<f5>") 'my-blog-export)))

(add-hook 'css-mode-hook
          '(lambda ()
             (define-key css-mode-map (kbd "<f5>") 'my-blog-export)))

(add-hook 'xml-mode-hook
          '(lambda ()
             (define-key xml-mode-map (kbd "<f5>") 'my-blog-export)))

(global-set-key [(control next)] 'next-buffer)
(global-set-key [(control prior)] 'previous-buffer)
(define-key global-map (kbd "M-c") 'quick-copy-line)
;(define-key global-map (kbd "<f4>") 'magit-status)
; (global-set-key (kbd "\C-x\C-e") 'org-export-as-html)
(define-key global-map (kbd "C-/") 'hippie-expand)
(define-key minibuffer-local-map (kbd "C-/") 'hippie-expand)
(define-key global-map (kbd "C-=") 'kill-current-buffer-and-frame)
(define-key global-map (kbd "M-<f3>") 'switch-to-minus-todo)
(define-key global-map (kbd "<f3>") 'switch-to-personal-todo)
(define-key global-map (kbd "C-<f3>") 'switch-to-init-el)
;; (define-key global-map (kbd "<f4>") 'org-archive-to-archive-sibling)
(define-key global-map (kbd "<f4>") 'org-archive-subtree)

; (define-key global-map (kbd "C-<f4>") 'ido-kill-buffer)
(define-key global-map (kbd "C-<escape>") 'switch-to-blank)

;(global-set-key (kbd "C-x C-f") 'lusty-file-explorer)
;(global-set-key (kbd "C-x f") 'find-file)
(global-set-key (kbd "<f2>") 'my-anything-occur)
(global-set-key (kbd "<f1>") 'my-anything-switcher)
(global-set-key (kbd "C-M-<up>") 'my-goto-first-org-item)
;; (global-set-key (kbd "M-t") 'my-anything-switcher-at-point)
;;(global-set-key (kbd "M-t") 'ido-switch-buffer)
(global-set-key (kbd "C-c n") 'switch-to-notes)
(global-set-key (kbd "C-S-f") 'my-anything-grep)
(global-set-key (kbd "C-<f2>") 'my-anything-grep)
(global-set-key (kbd "M-<f6>") 'my-anything-grep-sql)
(global-set-key (kbd "<f7>") 'my-anything-grep-def)
(global-set-key (kbd "S-<f7>") 'my-anything-grep)
(global-set-key (kbd "C-<f7>") 'my-anything-grep-ref)
(global-set-key (kbd "M-C-<f2>") 'anything-grep)
(global-set-key [M-up] 'move-text-up)
(global-set-key [M-down] 'move-text-down)
(global-set-key (kbd "C-S-o")  'occur)
(global-set-key (kbd "C-x b") 'switch-to-buffer)

(global-set-key (kbd "M-[")  'cua-scroll-down)
(global-set-key (kbd "M-]") 'cua-scroll-up)


(define-key global-map (kbd "C-g") 'keyboard-escape-quit)
(global-set-key (kbd "C-c C-8") 'org-ctrl-c-star)
;;; esc quits
(define-key global-map (kbd "<escape>") 'keyboard-escape-quit)
(define-key minibuffer-local-map [escape] 'keyboard-escape-quit)
(define-key minibuffer-local-ns-map [escape] 'keyboard-escape-quit)
(define-key minibuffer-local-completion-map [escape] 'keyboard-escape-quit)
(define-key minibuffer-local-must-match-map [escape] 'keyboard-escape-quit)
(define-key minibuffer-local-isearch-map [escape] 'keyboard-escape-quit)

(define-key global-map (kbd "<f9>") 'split-window-horizontally)

;; Tell orgmode table to consider extra chars to be numbers.
(setq org-table-number-regexp "^\\([<>]?[-+^.0-]*[0-9-\?][-+^.0-9eE dDx()%:xX,]*\\|\\(0[xX]\\)[0-9a-fA-F]+\\)$")

(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <left>") 'windmove-left)
(global-set-key (kbd "C-o") 'other-window)
(global-set-key (kbd "C-M-<right>") 'windmove-right)
(global-set-key (kbd "C-M-<left>") 'windmove-left)

(global-set-key (kbd "M-C-w") 'clipboard-kill-ring-save)

(setq my-org-heading-finder
   [?\C-u ?\C-c ?\C-w])

(define-key global-map (kbd "<f8>") 'my-org-heading-finder)
; (define-key global-map (kbd "C-<f1>") 'other-window)


(add-hook 'org-mode-hook
          '(lambda ()
             (define-key org-mode-map (kbd "C-<f5>") 'my-org2html)
             (define-key org-mode-map (kbd "C-S-<f5>") 'my-org2html-open)
             (define-key org-mode-map (kbd "C-c C-<f5>") 'my-pattern-export-orgmode)
             (define-key org-mode-map (kbd "M-<f5>") 'my-import-orgmode)
             (define-key org-mode-map (kbd "<f5>") 'my-blog-export)
             (define-key org-mode-map (kbd "<f4>") 'org-archive-subtree)
;             (define-key org-mode-map (kbd "<f7>") 'export-to-tex)
             ;; (define-key org-mode-map (kbd "M-W") 'org-copy-special)
             (define-key org-mode-map (kbd "M-W") 'my-copy-orgmode)
             (define-key org-mode-map (kbd "C-S-w") 'org-cut-special)
             (define-key org-mode-map (kbd "C-c C-d") 'org-time-stamp)
             (define-key org-mode-map (kbd "C-t") 'org-ctrl-c-ctrl-c)
             ))

;;; (define-key global-map (kbd "M-W") 'org-copy-special)


(add-hook 'html-mode-hook
          '(lambda ()
             (define-key html-mode-map (kbd "<f5>") 'my-blog-export)))

(add-hook 'css-mode-hook
          '(lambda ()
             (define-key css-mode-map (kbd "<f5>") 'my-blog-export)))

(add-hook 'xml-mode-hook
          '(lambda ()
             (define-key xml-mode-map (kbd "<f5>") 'my-blog-export)))

(add-hook 'org-mode-hook
      (lambda ()
        (if window-system
            nil
          (progn
            (define-key org-mode-map "\C-\M-j" 'org-meta-return)
            (define-key org-mode-map "\C-j" 'org-insert-heading-respect-content)))))

(require 'color-theme)
(color-theme-initialize)
(setq color-theme-is-global t)
(color-theme-sanityinc-solarized-dark)
;(enable-theme 'zenburn)
(blink-cursor-mode 0)

(defun color-theme-solarize-adjust ()
  (interactive)
  (color-theme-install
   '(color-theme-solarize-adjust
     (
      (foreground-color . "#9baaaa")
      (cursor-color . "#93a1a1" ) ; Cursor
      ;(background-color . "002b36") ; this is solarized default base 02 background color. it's too bright.
      ;(background-color . "#00111d") ; very good color! deep deep blue.
      (background-color . "#00112a") ; trying this one for now. slightly brighter deep blue.
      (help-highlight-face . underline)
      (ibuffer-dired-buffer-face . font-lock-function-name-face)
      (ibuffer-help-buffer-face . font-lock-comment-face)
      (ibuffer-hidden-buffer-face . font-lock-warning-face)
      (ibuffer-read-only-buffer-face . font-lock-type-face)
      (ibuffer-special-buffer-face . font-lock-keyword-face)
      (ibuffer-title-face . font-lock-type-face)
      (ps-line-number-color . "black")
      (ps-zebra-color . 0.95)
;      (tags-tag-face ((t (:foreground "#555"))))
      (view-highlight-face . highlight)
      (widget-mouse-face . highlight)
      (highlight ((t (:foreground "#000000"  :background "#bbbbbb"))))
;      (mode-line-buffer-id ((,class (:foreground "#555555" :background nil :weight normal ))))
;      (mode-line ((,class (:foreground "#555555" :background "#333333" :weight normal :font "Consolas-11"))))
      )
     (ibuffer-deletion-face ((t (:foreground "#00ffff"))))
     (ibuffer-marked-face ((t (:foreground "#00ffff"))))
     (menu ((t (nil))))
     (show-paren-match-face ((t (:foreground "#ffffff" :background nil))))
     (show-paren-mismatch-face ((t (:background "#ffffff" :foreground nil))))
     (scroll-bar ((t ("#444444"))))
     (secondary-selection ((t (:foreground "#ffffff" :background "#444444"))))
     (org-done ((t (  :foreground "#586e75"))))
     (org-drawer ((t (:foreground  "#586e75"))))
     (org-ellipsis ((t (:foreground "#555555" :underline nil))))
     (org-hide ((t (:foreground "#000000"))))
     ; B&W based org-levels
     ;; (org-todo ((t (  :foreground "#b58900" :background nil))))
     ;; (org-level-1 ((t (  :foreground "#93a1a1"  ))))
     ;; (org-level-2 ((t (  :foreground  "#839496"))))
     ;; (org-level-3 ((t (  :foreground  "#657b83"))))
     ;; (org-level-4 ((t (  :foreground "#586e75"  :weight normal :slant normal))))
     ;; (org-level-5 ((t (  :foreground "#586e75"  :weight normal :slant normal))))
     ;; (org-level-6 ((t (  :foreground "#586e75"  :weight normal :slant normal))))
     ; Color based org-levels
     (org-todo ((t (  :foreground "#c61b7a" :background nil)))) ; magenta, darker.
     (org-level-1 ((t (  :foreground "#2aa494"  ))))
     (org-level-2 ((t (  :foreground  "#b38700"))))
     (org-level-3 ((t (  :foreground  "#368bc2"))))
     (org-level-4 ((t (  :foreground  "#859900"))))
     (org-level-5 ((t (  :foreground  "#6f74c9"))))
     (org-tag ((t (:bold nil :weight normal :foreground "#cb4b16"))))
     (org-table ((t (:foreground "#93a1a1"))))
     (org-link ((t (:underline nil :foreground  "#cb4b16" ))))
     ;; Other stuff.
     (isearch ((t (:underline nil :foreground "#ffffff" :underline nil :weight bold))))
     (region ((t (:inverse-video t)))) ; Visual
     ))
  )

;(set-face-attribute 'fringe nil :foreground "#222222")
;(set-face-attribute 'linum nil :foreground "#444444")
; (set-face-attribute 'fringe nil :foreground "#111111" :background "#000000")

(color-theme-solarize-adjust)

(global-hl-line-mode 0) ; turn it on for all modes by default

(cua-mode t)
(setq cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
(transient-mark-mode nil)               ;; No region when it is not highlighted
(setq cua-keep-region-after-copy nil)



(setq org-blank-before-new-entry '((heading . nil) (plain-list-item . nil)))


(message "Prelude is ready to do thy bidding, Master %s!" current-user)

(prelude-eval-after-init
 ;; greet the use with some useful tip
 (run-at-time 5 nil 'prelude-tip-of-the-day))

(setq prelude-guru nil)

;;; init.el ends here
