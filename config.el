;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

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

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


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


;;; defaults
;;;
(setq undo-limit 80000000               ; Raise undo-limit to 80Mb
      evil-want-fine-undo t             ; By default while in insert all changes are one big blob. Be more granular
      truncate-string-ellipsis "…"                ; Unicode ellispis are nicer than "...", and also save /precious/ space
)



;;
;; Treemacs
;; Since it has its own iternal concept of project, it needs an external helper to be able to synchronise with other project management tools, such as projectile.
;; To be able to synchronise treemacs and projectile the treemacs-projectile module must be used. It can be activated using

(use-package treemacs-projectile
  :after (treemacs projectile))

(after! (treemacs projectile)
  (treemacs-project-follow-mode 1))

; biblio

(setq! citar-bibliography '("~/Nextcloud/BIBFILE/bib.bib")
       citar-library-paths '("~/Nextcloud/BIBFILE/")
       citar-notes-paths '("~/Nextcloud/BIBFILE/notes/"))

;;; company
(set-company-backend!
  '(text-mode
    markdown-mode
    gfm-mode)
  '(:separate
    company-ispell
    company-files
    company-yasnippet))

;; ;; tng not selecting https://github.com/doomemacs/doomemacs/issues/1335
;; (with-eval-after-load 'company
;;   (add-hook 'evil-local-mode-hook
;;             (lambda ()
;;               ;; Note:
;;               ;; Check if `company-emulation-alist' is in
;;               ;; `emulation-mode-map-alists', if true, call
;;               ;; `company-ensure-emulation-alist' to ensure
;;               ;; `company-emulation-alist' is the first item of
;;               ;; `emulation-mode-map-alists', thus has a higher
;;               ;; priority than keymaps of evil-mode.
;;               ;; We raise the priority of company-mode keymaps
;;               ;; unconditionally even when completion is not
;;               ;; activated. This should not cause problems,
;;               ;; because when completion is activated, the value of
;;               ;; `company-emulation-alist' is ((t . company-my-keymap)),
;;               ;; when completion is not activated, the value is ((t . nil)).
;;               (when (memq 'company-emulation-alist emulation-mode-map-alists)
;;                 (company-ensure-emulation-alist)))))

;; (add-hook! ess-mode #'evil-normalize-keymaps)


;; ;; dictonary
;;
(setq ispell-personal-dictionary
      (expand-file-name "ispell_personal" doom-private-dir))


;;; ESS stuff
;;;
;; fixes issue with black letters in black background
;;https://github.com/emacs-ess/ESS/issues/1199#issuecomment-1144181944
    (defun my-inferior-ess-init ()
      (setq-local ansi-color-for-comint-mode 'filter)
      (smartparens-mode 1))
    (add-hook 'inferior-ess-mode-hook 'my-inferior-ess-init)

;; control enter only in interactive mode
(after! ess-r-mode
  (map! :map ess-r-mode-map
        "C-S-<return>" #'ess-eval-buffer))

(set-company-backend! 'ess-r-mode '(company-R-args company-R-objects company-dabbrev-code :separate))

; Syntax highlighting is nice, so let’s turn all of that on
(setq ess-R-font-lock-keywords
      '((ess-R-fl-keyword:keywords . t)
        (ess-R-fl-keyword:constants . t)
        (ess-R-fl-keyword:modifiers . t)
        (ess-R-fl-keyword:fun-defs . t)
        (ess-R-fl-keyword:assign-ops . t)
        (ess-R-fl-keyword:%op% . t)
        (ess-fl-keyword:fun-calls . t)
        (ess-fl-keyword:numbers . t)
        (ess-fl-keyword:operators . t)
        (ess-fl-keyword:delimiters . t)
        (ess-fl-keyword:= . t)
        (ess-R-fl-keyword:F&T . t)))


;We don’t want R evaluation to hang the editor, hence
(setq ess-eval-visibly 'nowait)

(after! ess-r-mode
   (set-ligatures! 'ess-r-mode
    ;; Functional
    :def "function"
    ;; Types
    :null "NULL"
    ;; :true "TRUE"
    ;; :false "FALSE"
    :int "int"
    :floar "float"
    :bool "bool"
    ;; Flow
    :not "!"
    ;; :and "&&" :or "||"
    :for "for"
    :in "%in%"
    :return "return"
    ;; Other
    :assign "<-"
    :multiply "%*%"))



(setq projectile-project-search-path
      '(("~/dev" . 2) ("~/Nextcloud/" . 1)))

(modify-syntax-entry ?_ "w")
