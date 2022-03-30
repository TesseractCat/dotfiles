(require 'package)

;; Package list
(setq package-list '(use-package))

;; Add Melpa as the default Emacs Package repository
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

;; Activate all the packages (in particular autoloads)
(package-initialize)

;; Update your local package index
(unless package-archive-contents
  (package-refresh-contents))

;; Install all missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;; Display loading time/order for packages
;; (setq use-package-verbose t)

;; Evil mode settings

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil)
  (setq evil-split-window-below t
        evil-vsplit-window-right t
        evil-want-C-u-scroll t
        evil-echo-state nil)
  :config
  (evil-mode t))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (delete 'evil-mc evil-collection-mode-list)
  (evil-collection-init))

(use-package evil-leader
  :after evil-collection
  :ensure t
  :config
  (global-evil-leader-mode)
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "x" 'execute-extended-command
    "b" 'bookmark-jump
    "g" 'magit-status
    "h" 'help-for-help
    "e" 'eval-defun
    "ff" 'find-function
    "q" 'evil-mc-undo-all-cursors
    "s" 'evil-mc-make-cursors-at-search
    "w" 'save-buffer))

(use-package evil-mc
  :after evil-leader
  :ensure t
  :init
  (setq evil-mc-enable-bar-cursor nil
        evil-mc-undo-cursors-on-keyboard-quit t)
  :config
  (keymap-unset evil-mc-key-map "<normal-state> M-n")
  (keymap-unset evil-mc-key-map "<normal-state> M-p")
  (global-evil-mc-mode t)

  (defun evil-mc-make-cursors-at-search ()
    (interactive)
    (let ((search (car evil-search-forward-history)))
      (setq evil-mc-pattern (cons (evil-ex-make-search-pattern search) nil))
      (evil-mc-make-cursors-for-all)
      (let ((goto (or (evil-mc-find-next-cursor) (evil-mc-find-prev-cursor))))
        (evil-mc-goto-cursor goto nil)
        ))))

(evil-global-set-key 'visual (kbd "gc") 'comment-dwim)

;; LSP/Language settings

(use-package lsp-mode
  :ensure t
  :init
  (evil-define-key 'normal 'global "gd" 'lsp-find-definition)
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq sgml-basic-offset 4)
  :commands lsp)
(use-package csharp-mode
  :after lsp-mode
  :ensure t)
(use-package rust-mode
  :after lsp-mode
  :ensure t)

(use-package company
  :ensure t
  :init
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.0) ;; default is 0.2
  (setq company-format-margin-function 'company-text-icons-margin
        company-text-icons-add-background t)
  (setq company-global-modes '(not markdown-mode shell-mode))
  :config
  (keymap-unset company-active-map "C-w")
  (keymap-set company-active-map "TAB" 'company-complete-selection)
  (keymap-set company-active-map "<tab>" 'company-complete-selection)
  (global-company-mode t))

;; Markdown settings

(use-package visual-fill-column
  :ensure t)
(use-package adaptive-wrap
  :ensure t)
(use-package markdown-mode
  :defer t
  :ensure t
  :init
  (setq markdown-enable-math t
        markdown-enable-wiki-links t
        markdown-wiki-link-alias-first nil
        markdown-wiki-link-search-subdirectories t
        markdown-link-space-sub-char " "
        markdown-header-scaling t
        markdown-mouse-follow-link t)
  (add-hook 'markdown-mode-hook (lambda () ;; On markdown-mode:
                                  (setq mode-line-format nil) ;; Hide mode line
                                  (visual-line-mode t) ;; Visual wrap at column 80
                                  (visual-fill-column-mode t)
                                  (adaptive-wrap-prefix-mode t)))
  :config
  (keymap-set markdown-mode-map "M-n" (lambda ()
                                        (interactive)
                                        (call-interactively
                                         'markdown-next-visible-heading)
                                        (call-interactively
                                         'evil-scroll-line-to-top)))
  (keymap-set markdown-mode-map "M-p" (lambda ()
                                        (interactive)
                                        (call-interactively
                                         'markdown-previous-visible-heading)
                                        (call-interactively
                                         'evil-scroll-line-to-top)))
  (keymap-set markdown-mode-map "M-N" 'markdown-next-link)
  (keymap-set markdown-mode-map "M-P" 'markdown-previous-link))

(keymap-unset evil-motion-state-map "C-o")
(keymap-global-set "C-o" 'find-file)

;; Hide math-preview on hover
(use-package math-preview
  :ensure t
  :config
  (defvar-local math-preview-hover--prev-range nil)
  (defun math-preview-hover--enter ()
    (let ((overlay-here (car (overlays-at (point)))))
      (when overlay-here
        (when (string-equal (overlay-get overlay-here 'category) 'math-preview)
          (setq math-preview-hover--prev-range
                (cons (overlay-start overlay-here) (overlay-end overlay-here)))
          (math-preview-clear-at-point)))))
  (defun math-preview-hover--exit ()
    (when math-preview-hover--prev-range
      ;; Increment range on keypress
      (when (eq last-command 'self-insert-command)
        (setf (cdr math-preview-hover--prev-range) (1+ (cdr math-preview-hover--prev-range))))
      ;; Exit current overlay range
      (when (not (and (>= (point) (car math-preview-hover--prev-range)) (<= (point) (cdr math-preview-hover--prev-range))))
        (save-excursion
          (goto-char (car math-preview-hover--prev-range))
          (math-preview-at-point))
        (setq math-preview-hover--prev-range nil)
    )))
  (add-hook 'post-command-hook 'math-preview-hover--exit 1)
  (add-hook 'post-command-hook 'math-preview-hover--enter 2))

;; Misc settings

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(setq visible-bell 1 ;; Disable bell
      warning-minimum-level :error ;; Disable warnings popup
      inhibit-startup-screen t ;; Disable startup screen
      make-backup-files nil ;; Disable backup files (file~)
      create-lockfiles nil) ;; Disable interlock files (.#file)

(setq-default truncate-lines t ;; Disable line wrapping
              indent-tabs-mode nil ;; Disable tabs
              tab-width 4)

(setq scroll-margin 3 ;; Emulate vim like scrolling
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)

(setq split-width-threshold 1) ;; Always vsplit on split

(set-frame-parameter (selected-frame) 'internal-border-width 40) ;; Padding

(use-package selectrum
  :ensure t
  :config
  (selectrum-mode t))
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode t))
(use-package mood-line
  :ensure t
  :config
  (mood-line-mode t))

(use-package magit
  :defer t
  :ensure t)

;; Save window position/dimensions

(setq desktop-path (list user-emacs-directory)) ;; Save in .emacs.d
(setq desktop-buffers-not-to-save ".*"
      desktop-files-not-to-save ".*") ;; Don't save buffers
(add-hook 'desktop-after-read-hook (lambda () ;; Don't save tabs
                                     (tab-bar-close-other-tabs)))
(setq desktop-save t) ;; Always save
(desktop-save-mode t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(minimal-black))
 '(custom-safe-themes
   '("184b3a18e5d1ef9c8885ceb9402c3f67d656616d76bf91f709d1676407c7cf1d" "801a567c87755fe65d0484cb2bded31a4c5bb24fd1fe0ed11e6c02254017acb2" "dbade2e946597b9cda3e61978b5fcc14fa3afa2d3c4391d477bdaeff8f5638c5" "3e335d794ed3030fefd0dbd7ff2d3555e29481fe4bbb0106ea11c660d6001767" "4780d7ce6e5491e2c1190082f7fe0f812707fc77455616ab6f8b38e796cbffa9" "cc0dbb53a10215b696d391a90de635ba1699072745bf653b53774706999208e3" "33ea268218b70aa106ba51a85fe976bfae9cf6931b18ceaf57159c558bbcd1e6" default))
 '(display-line-numbers-type 'relative)
 '(evil-start-of-line t)
 '(evil-undo-system 'undo-redo)
 '(math-preview-scale 0.8)
 '(package-selected-packages
   '(tao-theme use-package adaptive-wrap visual-fill-column math-preview mood-line minimal-theme csharp-mode evil-mc-extras lsp-ui lsp-mode evil-leader evil))
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Terminus" :foundry "raster" :slant normal :weight regular :height 151 :width normal))))
 '(fringe ((t (:background nil))))
 '(markdown-italic-face ((t (:inherit italic :foreground "light coral"))))
 '(variable-pitch ((t (:foundry "outline" :family "Roman")))))
