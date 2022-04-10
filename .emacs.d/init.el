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
  (evil-mode t)
  (evil-define-key 'insert 'global (kbd "C-v") (lambda ()
                                                 (interactive)
                                                 (evil-paste-before 1 ?+)
                                                 (call-interactively 'evil-append)
                                                 )))

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
    "w" 'save-buffer
    "m" 'math-preview-all
    ;; "m" (lambda ()
    ;;       (interactive)
    ;;       (if (math-preview--overlays (point-min) (point-max))
    ;;           (call-interactively 'math-preview-clear-all)
    ;;           (call-interactively 'math-preview-all)
    ;;           ))
    ))

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

(auto-image-file-mode t)
(add-to-list 'auto-mode-alist '("\\.(?:hlsl\\|ns\\|shader\\|surf\\|cginc)\\'" . c-mode))

(use-package lsp-mode
  :ensure t
  :init
  (evil-define-key 'normal 'global "gd" 'lsp-find-definition)
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq sgml-basic-offset 4)
  :commands lsp
  :hook ( ;; Start LSP mode hooks
         (csharp-mode . lsp-deferred)))
(use-package csharp-mode
  :ensure t)
(use-package rust-mode
  :ensure t)

(use-package company
  :ensure t
  :init
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.0) ;; default is 0.2
  (setq company-format-margin-function 'company-text-icons-margin
        company-text-icons-add-background t)
  (setq company-global-modes '(not shell-mode))
  :config
  (keymap-unset company-active-map "C-w")
  (keymap-set company-active-map "TAB" 'company-complete-selection)
  (keymap-set company-active-map "<tab>" 'company-complete-selection)
  (global-company-mode t)
  :hook (markdown-mode . (lambda ()
                           (setq-local company-backends '(company-files))
                           )))

;; Markdown settings

(use-package visual-fill-column
  :ensure t)
(use-package adaptive-wrap
  :ensure t)
(use-package markdown-mode
  :defer t
  :ensure t
  :init
  (setq markdown-enable-wiki-links t
        markdown-wiki-link-alias-first nil
        markdown-wiki-link-search-subdirectories t
        markdown-link-space-sub-char " "
        markdown-header-scaling t
        ;;markdown-enable-math t
        markdown-mouse-follow-link t)
  (add-hook 'markdown-mode-hook (lambda () ;; On markdown-mode:
                                  (setq mode-line-format nil) ;; Hide mode line
                                  (flyspell-mode t) ;; Spellcheck
                                  (visual-line-mode t) ;; Visual wrap at column 80
                                  (visual-fill-column-mode t)
                                  (adaptive-wrap-prefix-mode t)))
  :config
  (setq markdown-regex-italic "\\(?:^\\|[^\\]\\)\\(?1:\\(?2:[*]\\)\\(?3:[^ 
	\\]\\|[^ 
	*]\\(?:.\\|
[^
]\\)*?[^\\ ]\\)\\(?4:\\2\\)\\)") ;; Disable _ italics
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
(keymap-global-set "C-o" 'project-find-file)
(keymap-unset evil-motion-state-map "C-f")
(keymap-global-set "C-f" 'project-find-regexp)

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

(server-start)
(electric-pair-mode t)
(use-package prism
  :ensure t
  :init
  (setq prism-comments nil
        prism-parens nil)
  :config
  (defun hex-to-rgb (hex)
    (mapcar (lambda (x) (/ x 65535.0))
            (color-values hex)))
  (defun lerp (a b alpha)
    (+ a (* alpha (- b a))))
  (defun lerp-colors (a b alpha)
    (list (lerp (nth 0 a) (nth 0 b) alpha)
          (lerp (nth 1 a) (nth 1 b) alpha)
          (lerp (nth 2 a) (nth 2 b) alpha)))
  (add-hook 'prism-mode-hook (lambda () (prism-set-colors :num 24
    :attribute :background
    :colors (let ((bg (hex-to-rgb (face-attribute 'default :background))) (alpha 0.25))
              (mapcar (lambda (color)
                              (apply 'color-rgb-to-hex (lerp-colors bg (hex-to-rgb color) alpha)))
                            ;;(list "red" "orange" "yellow" "green" "blue" "purple" "violet")
                            (list "red" "blue" "orange" "green" "yellow" "purple" "brown")
                            )
               )))))

(setq gc-cons-threshold (* 50 (* 1024 1024)) ;; 50 MB GC threshold
      read-process-output-max (* 1024 1024))

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(setq visible-bell 1 ;; Disable bell
      warning-minimum-level :error ;; Disable warnings popup
      inhibit-startup-screen t ;; Disable startup screen
      make-backup-files nil ;; Disable backup files (file~)
      auto-save-default nil ;; Disable autosave files (#file#)
      create-lockfiles nil) ;; Disable interlock files (.#file)

(setq-default truncate-lines t ;; Disable line wrapping
              indent-tabs-mode nil ;; Disable tabs
              tab-width 4)

(setq scroll-margin 3 ;; Emulate vim like scrolling
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)
(pixel-scroll-precision-mode t)

(setq split-width-threshold 1) ;; Always vsplit on split

(set-frame-parameter (selected-frame) 'internal-border-width 40) ;; Padding
(set-fringe-mode 20) ;; Fringe left padding
(setq bookmark-set-fringe-mark nil)

(setq window-divider-default-places t ;; Use window-divider-mode instead of vertical-border
      window-divider-default-bottom-width 1
      window-divider-default-right-width 1)
(window-divider-mode t)

(use-package selectrum
  :ensure t
  :config
  (selectrum-mode t))
(use-package orderless
  :ensure t
  :custom (completion-styles '(orderless)))
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode t))

(use-package mood-line
  :ensure t
  :config
  (mood-line-mode t))
(use-package tab-bar-echo-area
  :ensure t
  :init
  (setq tab-bar-show nil)
  :config
  (tab-bar-echo-area-mode 1))

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

;; Some nice base16 themes: dirtysea, apprentice

(advice-add 'load-theme :after (lambda (&rest args) ;; Theme advice
                                 (set-face-attribute 'window-divider nil :foreground (face-foreground 'vertical-border))
                                 (let ((c (hex-to-rgb (face-background 'default))))
                                   (cl-rotatef (nth 0 c) (nth 2 c))
                                   (set-face-attribute 'math-preview-face nil :background (apply 'color-rgb-to-hex c)))
                                 (let ((c (hex-to-rgb (face-foreground 'default))))
                                   (cl-rotatef (nth 0 c) (nth 2 c))
                                   (set-face-attribute 'math-preview-face nil :foreground (apply 'color-rgb-to-hex c)))
                                 ))

;; Set unicode fallback font
(set-fontset-font "fontset-default" 'unicode (font-spec :family "NSimSun"))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(base16-apathy))
 '(custom-safe-themes t)
 '(display-line-numbers-type 'relative)
 '(evil-start-of-line t)
 '(evil-undo-system 'undo-redo)
 '(math-preview-margin '(0 . 0))
 '(math-preview-raise 0.3)
 '(math-preview-scale 0.8)
 '(package-selected-packages
   '(web-mode base16-theme latex-preview-pane auctex goose-theme gnugo prism osm vil tao-theme use-package adaptive-wrap visual-fill-column math-preview mood-line minimal-theme csharp-mode evil-mc-extras lsp-ui lsp-mode evil-leader evil))
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
 '(tab-bar ((t (:inherit default :background "systembuttonface" :foreground "systembuttontext"))))
 '(variable-pitch ((t (:foundry "outline" :family "Roman")))))
