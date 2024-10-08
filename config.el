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

; evil respect visual lines (not working)https://github.com/doomemacs/doomemacs/issues/7249
(use-package-hook! evil
  :pre-init
  (setq evil-respect-visual-line-mode t) ;; sane j and k behavior
  t)

;; workaround
(map!
 :nv "<up>" #'evil-previous-visual-line
 :nv "<down>" #'evil-next-visual-line
 :nv "<home>" #'evil-beginning-of-visual-line
 :nv "<end>" #'evil-end-of-visual-line)


;; enable word-wrap (almost) everywhere
;; (+global-word-wrap-mode +1) ; not working for some reason

(global-visual-line-mode t)
;; disable global word-wrap in emacs-lisp-mode
;(add-to-list '+word-wrap-disabled-modes 'emacs-lisp-mode)

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

(setq! citar-bibliography '("~/ownCloud/BIBFILE/bib.bib")
       citar-library-paths '("~/ownCloud/BIBFILE/")
       citar-notes-paths '("~/ownCloud/BIBFILE/notes/"))
(after! citar
  (dolist
    (ext '("pdf" "odt" "docx" "doc"))
    (add-to-list 'citar-file-open-functions `(,ext . citar-file-open-external))))
;;; company
(set-company-backend!
  '(text-mode
    markdown-mode
    gfm-mode
    stan-mode)
  '(:separate
    company-ispell
    company-files
    company-yasnippet))

;;;;;;;;;;;;;;;;;
;; interactive citar bibliography of Rmds
(defun my/set-citar-bibliography-from-rmd ()
  "Set `citar-bibliography` based on the bibliography field in the Rmd buffer.
   Overwrites the content of `citar-bibliography` and stores it as (\"fullpath/references.bib\")."
  (interactive)
  (setq citar-bibliography nil) ;; Clear any previous value
  (when (and (buffer-file-name)
             (string-equal (file-name-extension (buffer-file-name)) "Rmd"))
    (save-excursion
      (goto-char (point-min))
      ;; Look for the bibliography line with a filename that ends with .bib
     (if (re-search-forward "^bibliography: ?\\([^ \t\n]+\\.bib\\) ?$" nil t)
          (let* ((bib-file (match-string 1)) ;; extract the filename ending with .bib
                 (full-path (expand-file-name bib-file (file-name-directory (buffer-file-name)))))
            ;; Set the citar-bibliography variable to the full path inside parentheses
            (setq citar-bibliography (list full-path))
            ;; Feedback message
            (message "citar-bibliography set to %s" citar-bibliography))
        ;; If no match is found, provide feedback
        (message "No valid bibliography found in the Rmd file.")))));;;;;;;;
;;;;;;;;;;;
;;;;;;;;;;;
;;;;;;;;;;;

(use-package stan-mode
  :mode ("\\.stan\\'" . stan-mode)
  :hook (stan-mode . stan-mode-setup)
  ;;
  :config
  ;; The officially recommended offset is 2.
  (setq stan-indentation-offset 2))

;;; company-stan.el
(use-package company-stan
  :hook (stan-mode . company-stan-setup)
  ;;
  :config
  ;; Whether to use fuzzy matching in `company-stan'
  (setq company-stan-fuzzy nil))

;;; eldoc-stan.el
(use-package eldoc-stan
  :hook (stan-mode . eldoc-stan-setup)
  ;;
  :config
  ;; No configuration options as of now.
  )

;;; flycheck-stan.el
(use-package flycheck-stan
  ;; Add a hook to setup `flycheck-stan' upon `stan-mode' entry
  :hook ((stan-mode . flycheck-stan-stanc2-setup)
         (stan-mode . flycheck-stan-stanc3-setup))
  :config
  ;; A string containing the name or the path of the stanc2 executable
  ;; If nil, defaults to `stanc2'
  (setq flycheck-stanc-executable nil)
  ;; A string containing the name or the path of the stanc2 executable
  ;; If nil, defaults to `stanc3'
  (setq flycheck-stanc3-executable nil))

;;; stan-snippets.el
(use-package stan-snippets
  :hook (stan-mode . stan-snippets-initialize)
  ;;
  :config
  ;; No configuration options as of now.
  );; change the default pdf viewer


(after! tex
 (setq TeX-view-program-selection
        '(
          (output-pdf "Evince")
         (output-pdf "Zathura")
          (output-pdf "PDF Tools")
          (output-pdf "Okular")
         (output-pdf "preview-pane")
          ((output-dvi has-no-display-manager)
           "dvi2tty")
          ((output-dvi style-pstricks)
           "dvips and gv")
          (output-dvi "xdvi")
          (output-html "xdg-open")
         )))


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

(setq
   ess-style 'RStudio
   ess-offset-continued 2
   ess-expression-offset 0)

;; control enter only in interactive mode
;; (after! ess-r-mode
;;   (map! :map ess-r-mode-map
;;         "C-S-<return>" #'ess-eval-buffer
;;          "C-<return>" #'ess-eval-region-or-function-or-paragraph-and-step)
(after! ess
  (map! :map ess-r-mode-map
        :n "C-<return>" #'ess-eval-region-or-line-visibly-and-step
        :v "C-<return>" #'ess-eval-region
        :n "C-S-<return>" #'ess-eval-buffer
        :v "C-S-<return>" #'ess-eval-buffer
        :i "C-S-<return>" #'ess-eval-buffer
        )
  )




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
    ;; :def "function"
    ;; Types
    ;; :null "NULL"
    ;; :true "TRUE"
    ;; :false "FALSE"
    ;; :int "int"
    ;; :float "float"
    ;; :bool "bool"
    ;; Flow
    ;; :not "!"
    ;; :and "&&" :or "||"
    ;; :for "for"
    ;; :in "%in%"
    ;; :return "return"
    ;; Other
    :assign "<-"
    ;; :multiply "%*%"
    ))

;; don't move the comments around
(setq ess-fancy-comments nil)

(setq projectile-project-search-path
      '(("~/dev" . 2) ("~/ownCloud/" . 1)))

(modify-syntax-entry ?_ "w")


;; config forge
(setq auth-sources '("~/.authinfo.gpg"))
(add-hook 'code-review-mode-hook
          (lambda ()
            ;; include *Code-Review* buffer into current workspace
            (persp-add-buffer (current-buffer))))
