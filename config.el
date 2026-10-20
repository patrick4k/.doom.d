;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
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

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'modus-vivendi)
(setq doom-font (font-spec :size 16 :family "JetBrains Mono" ))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'visual)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
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

(add-hook 'prog-mode-hook
          (lambda () (modify-syntax-entry ?_ "w")))

(map!
 "M-L" #'evil-window-right
 "M-H" #'evil-window-left
 "M-K" #'evil-window-up
 "M-J" #'evil-window-down
 )

;; Idk what the right way to do this is
(map!
 :map evil-normal-state-map
 :prefix "SPC p"
 "/" #'projectile-replace
 "?" #'projectile-replace-regexp)

;; https://github.com/doomelpa/code-review
(add-hook 'code-review-mode-hook
          (lambda ()
            ;; include *Code-Review* buffer into current workspace
            (persp-add-buffer (current-buffer))))

(defalias 'perl-mode 'cperl-mode)

;; Ghub 5.x moved `ghub-graphql' (which code-review calls) into
;; ghub-legacy.el, which nothing loads by default.
(after! code-review
  (require 'ghub-legacy))


(add-to-list 'auto-mode-alist '("\\.typ\\'" . typst-ts-mode))
(after! eglot
  (after! typst-ts-mode
    (add-to-list 'eglot-server-programs
                 '(typst-ts-mode . ("tinymist")))))
(add-hook 'typst-ts-mode-hook #'eglot-ensure)

(defun my/zig-program ()
  "Guess the executable to debug: the one named after the project, else the first."
  (let* ((root (if-let ((p (project-current))) (project-root p) default-directory))
         (bin (expand-file-name "zig-out/bin/" root))
         (exes (and (file-directory-p bin)
                    (seq-filter #'file-regular-p (directory-files bin t "^[^.]"))))
         (proj-name (file-name-nondirectory (directory-file-name root))))
    (or (seq-find (lambda (f) (equal (file-name-nondirectory f) proj-name)) exes)
        (car exes)
        (expand-file-name proj-name bin))))

(after! dape
  (add-to-list 'dape-configs
               `(zig-debug
                 modes (zig-mode zig-ts-mode)
                 command "lldb-dap"
                 command-cwd dape-command-cwd
                 compile "zig build"
                 :type "lldb-dap"
                 :request "launch"
                 :cwd "."
                 :program my/zig-program
                 :args [])))

(global-hl-line-mode -1)
(add-hook! '(prog-mode-hook text-mode-hook conf-mode-hook special-mode-hook)
           #'hl-line-mode)
