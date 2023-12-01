;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Huang Bin"
      user-mail-address "huangbin88@foxmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!
(setq doom-font (font-spec :family "Monaco" :size 18))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Display fullscreen after startup.
;; (add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Set the default tab-width
(setq-default tab-width 4)

;; Fullscreen
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;;; Doom extentions

(use-package key-chord
  :config (key-chord-mode 1))

(when (string= system-type "darwin")
  (if (eq mac-command-modifier 'super)
      (progn
        (setq mac-command-modifier 'meta)
        (setq mac-option-modifier 'super))
    (setq mac-command-modifier 'meta)
    (setq mac-option-modifier 'super)))

;; My personal backward kill
(defun +default-backward-kill-word-or-region ()
  (interactive)
  (if mark-active
      (kill-region (region-beginning) (region-end))
    (doom/delete-backward-word 1)))

;;; Global settings

(bind-key "<f1>" 'help-command)

;; Zen mode ;-p
(bind-key "M-<return>" 'toggle-frame-fullscreen)

(bind-key "s-0" 'balance-windows)
(bind-key "M-0" 'delete-window)
(bind-key "M-1" 'delete-other-windows)
(bind-key "M-2" 'split-window-vertically)
(bind-key "M-3" 'split-window-horizontally)
(bind-key "M-k" 'kill-this-buffer)

(bind-key "C-h" '+default--delete-backward-char-a)
(bind-key "C-w" '+default-backward-kill-word-or-region)
(bind-key "M-<backspace>" 'kill-whole-line)

(bind-key "C-/" 'undo-fu-only-undo)
(bind-key "C-?" 'undo-fu-only-redo)

(bind-key "C-o" '+default/newline-below)
(bind-key "C-M-o" '+default/newline-above)

(bind-key "M-g" '+default/search-project-for-symbol-at-point)

(bind-key "M-t" 'projectile-find-file)
(bind-key "M-e" 'projectile-recentf)

(bind-key "C-x \\" 'align-regexp)

(bind-key "M-h" 'er/expand-region)

(bind-key "C-z" nil)

;;; My Toolset

(use-package! ace-window
  :defer t
  :commands (ace-window
             ace-swap-window)
  :bind (("C-x o" . 'ace-window)
         ("M-o" . 'other-window)
         ("M-O" . (lambda () (interactive) (other-window -1)))))

(use-package! crux
  :commands (crux-move-beginning-of-line
             crux-top-join-line
             crux-cleanup-buffer-or-region)
  :config
  (crux-with-region-or-buffer indent-region)
  (crux-with-region-or-buffer untabify)

  :bind (("C-a" . 'crux-move-beginning-of-line)
         ("s-j" . 'crux-top-join-line)
         ("s-M-l" . 'crux-cleanup-buffer-or-region)))

(use-package! evil
  :bind (("M-[" . evil-jump-backward)
         ("M-]" . evil-jump-forward)))

(use-package! highlight-symbol
  :defer t
  :commands (highlight-symbol
             highlight-symbol-next
             highlight-symbol-prev)
  :init
  (setq highlight-symbol-colors
        '("Yellow" "YellowGreen" "pink" "Purple" "PeachPuff" "RoyalBlue" "LightBlue" "SlateBlue" "SteelBlue"
          "violet" "cyan" "SeaGreen" "#A0522D" "SpringGreen" "LimeGreen" "LightSeaGreen" "MistyRose" "Magenta"
          "orange" "PaleVioletRed" "#FF6347" "grey" "brown" "RosyBrown" "SandyBrown"))
  :bind (("M-'" . 'highlight-symbol)
         ("M-n" . 'highlight-symbol-next)
         ("M-p" . 'highlight-symbol-prev)))

(use-package! multiple-cursors
  :defer t
  :commands (mc/edit-lines
             mc/mark-all-symbols-like-this
             mc/mark-next-like-this-symbol
             mc/mark-previous-like-this-symbol)
  :bind (("C-S-c C-S-c" . 'mc/edit-lines)
         ("C-*" . 'mc/mark-all-symbols-like-this)
         ("C->" . 'mc/mark-next-like-this-symbol)
         ("C-<" . 'mc/mark-previous-like-this-symbol)))

(use-package! smart-shift
  :defer t
  :commands (smart-shift-left
             smart-shift-right)
  :bind (("s-[" . 'smart-shift-left)
         ("s-]" . 'smart-shift-right)))

(use-package! neotree
  :defer t
  :custom
  (neo-banner-message "\" Press ? for help.")
  (neo-theme 'ascii)
  (neo-show-hidden-files nil)
  :bind (:map neotree-mode-map
              ("d" . nil)
              ("D" . neotree-delete-node)
              ("I" . neotree-hidden-file-toggle))
  :config
  (add-to-list 'neo-hidden-regexp-list ".DS_Store\\|TAGS\\|GPATH\\|GRTAGS\\|GTAGS"))

(use-package! vertico
  :commands (vertico-repeat)
  :bind (("M-z" . 'vertico-repeat)))

(use-package! company
  :commands (+company/complete)
  :init
  (setq company-idle-delay nil)
  :bind (("M-/" . +company/complete)
         :map company-active-map
         ("C-h" . backward-delete-char)))

;;; Programming Languages

;; (use-package! lsp-mode
;;   :defer t
;;   )

;;; Ruby Programming Language

(use-package! ruby-mode
  :config
  (setq ruby-insert-encoding-magic-comment nil)
  (setq rspec-use-spring-when-possible nil)

  (font-lock-add-keywords
   'ruby-mode
   '(("\\(\\b\\sw[_a-zA-Z0-9]*:\\)\\(?:\\s-\\|$\\)" (1 font-lock-constant-face))
     ("\\(^\\|[^_:.@$\\W]\\|\\.\\.\\)\\b\\(include\\|extend\\|require\\|autoload\\)\\b[^_:.@$\\W]" . font-lock-function-name-face)))

  (defun hbin-ruby-mode-hook ()
    (setq-local whitespace-line-column 120)

    (modify-syntax-entry ?$ "w")   ; Words prefixed with $ are global variables,
    (modify-syntax-entry ?@ "w"))  ; prefixed with @ are instance variables.
  (add-hook 'ruby-mode-hook 'hbin-ruby-mode-hook))

(use-package! ruby-hash-syntax
  :defer t
  :requires ruby-mode
  :commands (ruby-toggle-hash-syntax)
  :bind (:map ruby-mode-map
              ("C-c #" . 'ruby-toggle-hash-syntax)))

(use-package! projectile-rails
  :defer t
  :requires (projectile ruby-mode)
  :custom
  (projectile-rails-expand-snippet nil)
  (projectile-rails-keymap-prefix (kbd "C-c ;"))
  (projectile-rails-font-lock-face-name 'font-lock-function-name-face)

  :bind (("s-<return>". 'projectile-rails-goto-file-at-point)
         ("C-c ; r" . 'projectile-rails-find-spec)
         ("C-c ; R" . 'projectile-rails-find-current-spec)
         ("C-c ; p" . 'projectile-rails-console)
         ("C-c ; P" . 'projectile-rails-server)))

;;; Go Programming Language

(use-package! go-playground
  :defer t)

;;; Others

(use-package! dockerfile-mode
  :defer t
  :mode (("Dockerfile\\'" . dockerfile-mode)))

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Monaco" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(use-package org
  :config
  (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-directory "~/org/")
  (setq org-agenda-files '("~/org/Tasks.org"))

  (efs/org-font-setup))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list
   '("◉" "○" "●" "○" "●" "○" "●")))
