(add-to-list 'exec-path "/usr/local/bin/")
(setenv "PATH" (concat (getenv "PATH") ":/home/logan/.nvm/versions/node/v14.16.1/bin"))
(setq exec-path (append exec-path '("/home/logan/.nvm/versions/node/v14.16.1/bin")))

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)

(setq use-package-always-ensure t)

(setq inhibit-startup-message t)
;; Disable scroll bar
(scroll-bar-mode -1)

;; Disable toolbar
(tool-bar-mode -1)

;; Disable tooltips
(tooltip-mode -1)

;; Give the fringe some breathing room
(set-fringe-mode 10)

;; Disable menu bar
(menu-bar-mode -1)

;; Flash bell
(setq visible-bell t)

;; Ctrl-g / ESC do the same thing now
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(global-display-line-numbers-mode t)

(column-number-mode)

;; disable line numbers in certain modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package all-the-icons)

(use-package doom-themes
  :init (load-theme 'doom-dracula t))

;; todo
(use-package doom-modeline
  :ensure t
  :custom ((doom-modeline height 35))
  :init (doom-modeline-mode 1))

  ;; Currently not used
(defvar logan/default-font-size 180)
(defvar logan/default-variable-font-size 180)
;; (set-face-attribute 'default nil :font "Fira Code" :height 280)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))


(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

;; get ivy rich stuff into useful counsel commands
(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history)))

(setq completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)
(use-package smart-tab
  :config
  (global-smart-tab-mode 1)
  (setq hippie-expand-try-functions-list (list
                                          'try-expand-dabbrev-visible
                                          'try-expand-dabbrev
                                          'try-expand-dabbrev-all-buffers
                                          'try-expand-dabbrev-from-kill
                                          'try-complete-file-name-partially
                                          'try-complete-file-name
                                          ))

  (setq smart-tab-using-hippie-expand t)
  (setq smart-tab-disabled-major-modes '(term-mode inf-ruby-mode org-mode eshell-mode)))

(use-package helpful
  :ensure t
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package general
  :config
  (general-create-definer logan/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "C-SPC")
    ;; :global-prefix "C-SPC")

  (logan/leader-keys
   "t" '(:ignore t :which-key "toggles")
   "tt" '(counsel-load-theme :which-key "choose theme")))

(use-package hydra)

;; a way to zoom in and out
(defhydra hydra-text-scale (:timeout 4)
     "scale text"
     ("j" text-scale-increase "in")
     ("k" text-scale-decrease "out")
     ("d" (text-scale-adjust 0) "default")
     ("f" nil "finished" :exit t))

(logan/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text"))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(general-define-key
 "C-M-j" 'counsel-switch-buffer)
;;
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/work/frameable")
    (setq projectile-project-search-path '("~/work/frameable")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(defun logan/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . logan/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
   :hook (lsp-mode . lsp-ui-mode)
   :custom
   (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)
(use-package lsp-ivy)

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2))

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
  (:map lsp-mode-map
        ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package js2-mode
  :ensure t
  :init
  (setq js-basic-indent 2)
  (setq-default js2-basic-indent 2
                js2-basic-offset 2
                js2-auto-indent-p t
                js2-cleanup-whitespace t
                js2-enter-indents-newline t
                js2-indent-on-enter-key t
                js2-global-externs (list "window" "module" "require" "buster" "sinon" "assert" "refute" "setTimeout" "clearTimeout" "setInterval" "clearInterval" "location" "__dirname" "console" "JSON" "jQuery" "$"))

  (add-hook 'js2-mode-hook
            (lambda ()
              (push '("function" . ?ƒ) prettify-symbols-alist)))

  (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode)))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; read up on more
(use-package forge)

(defun logan/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1) ;; This can affect tables/sql etc
  (visual-line-mode 1)
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    ;; (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))
    (set-face-attribute (car face) nil :weight 'regular :height (cdr face)))
  (dolist (face '(org-table))

    (set-face-attribute face nil :inherit 'fixed-pitch))
  (setq evil-auto-ident nil))

;; org notifier look into
(use-package org
  :hook (org-mode . logan/org-mode-setup)
  :config
  (setq org-ellipsis " ▾"
        org-hide-emphasis-markers t)
  (setq org-agenda-start-with-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
;;  (setq org-agenda-files
;;	'("~/work/personal/emacs/org-files/Tasks.org"
;;	  "~/work/personal/emacs/org-files/Birthdays.org"))
  (logan/org-mode-setup))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;; this will disable line numbers
(defun logan/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . logan/org-mode-visual-fill))

(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))

(defun logan/org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/work/personal/.dotfiles/Emacs.org"))

    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'logan/org-babel-tangle-config)))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (perl . t )
   (python . t )))

(setq org-confirm-babel-evaluate nil)
