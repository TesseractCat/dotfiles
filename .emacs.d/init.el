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
(setq gc-cons-threshold (* 50 (* 1024 1024)) ;; 50 MB GC threshold
      read-process-output-max (* 1024 1024))

;; Evil mode settings

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t
        evil-want-minibuffer t
        evil-want-keybinding nil)
  (setq evil-split-window-below t
        evil-vsplit-window-right t
        evil-want-C-u-scroll t
        evil-echo-state nil)
  :config
  (evil-mode t)

  (evil-define-key 'normal minibuffer-mode-map (kbd "<escape>") 'abort-recursive-edit)
  (global-set-key (kbd "<escape>") 'keyboard-escape-quit)

  (evil-define-key 'insert minibuffer-mode-map
    (kbd "C-n") 'selectrum-next-candidate
    (kbd "C-p") 'selectrum-previous-candidate
    (kbd "C-j") 'selectrum-next-candidate
    (kbd "C-k") 'selectrum-previous-candidate)
  
  (evil-ex-define-cmd "q[uit]" (lambda ()
                                 (interactive)
                                 (if (and (> (length (tab-bar-tabs)) 1) (= (count-windows) 1))
                                     (call-interactively 'tab-close)
                                   (call-interactively 'evil-quit))
                                 ))
  (evil-ex-define-cmd "ls" 'ibuffer)

  (evil-define-key '(normal visual) 'global
    (kbd "H") 'evil-first-non-blank
    (kbd "L") 'evil-end-of-line)
  (evil-define-key 'visual 'global (kbd "gc") 'comment-dwim)
  (evil-define-key 'normal 'global (kbd "M-=") 'universal-argument)

  (evil-define-key 'normal 'global
    (kbd "gd") 'xref-find-definitions
    (kbd "K") 'eldoc-doc-buffer)

  (evil-define-key 'normal 'global (kbd "C-w x") 'tab-close)
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
(use-package evil-surround
  :after evil
  :ensure t
  :config
  (global-evil-surround-mode 1))
(use-package evil-leader
  :after evil-collection
  :ensure t
  :config
  (defun project-vc-split ()
    (interactive)
    (automatic-window-split)
    (project-vc-dir))

  (global-evil-leader-mode)
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "x" 'execute-extended-command
    "g" 'project-vc-split
    "e" 'eval-defun
    "ff" 'find-function

    ;; "q" 'evil-mc-undo-all-cursors
    ;; "a" 'evil-mc-make-cursors-at-search

    "b" 'bookmark-jump
    "s" 'switch-to-buffer
    "p" 'project-switch-to-buffer
    "P" 'project-switch-project

    "w" 'save-buffer
    "m" 'math-preview-all
    ))

(use-package drag-stuff
  :ensure t
  :config
  (evil-define-key '(normal visual) 'global
    (kbd "M-k") 'drag-stuff-up
    (kbd "M-j") 'drag-stuff-down)
  (drag-stuff-global-mode t))

;; (use-package evil-mc
;;   :after evil-leader
;;   :ensure t
;;   :init
;;   (setq evil-mc-enable-bar-cursor nil
;;         evil-mc-undo-cursors-on-keyboard-quit t)
;;   :config
;;   (keymap-unset evil-mc-key-map "<normal-state> M-n")
;;   (keymap-unset evil-mc-key-map "<normal-state> M-p")
;;   (global-evil-mc-mode t)
;;
;;   (defun evil-mc-make-cursors-at-search ()
;;     (interactive)
;;     (let ((search (car evil-search-forward-history)))
;;       (setq evil-mc-pattern (cons (evil-ex-make-search-pattern search) nil))
;;       (evil-mc-make-cursors-for-all)
;;       (let ((goto (or (evil-mc-find-next-cursor) (evil-mc-find-prev-cursor))))
;;         (evil-mc-goto-cursor goto nil)
;;         ))))

;; LSP/Language settings

(auto-image-file-mode t)
(add-to-list 'auto-mode-alist '("\\.\\(?:hlsl\\|ns\\|shader\\|surf\\|cginc\\|compute\\)\\'" . c-mode))
(add-to-list 'auto-mode-alist '("\\.toml\\'" . conf-mode))

(use-package eglot
  :ensure t
  :init
  (setq eldoc-echo-area-display-truncation-message nil
        eldoc-echo-area-prefer-doc-buffer t
        eldoc-echo-area-use-multiline-p 1)
  :config
  (setq eglot-ignored-server-capabilites '(:documentHighlightProvider))

  (evil-define-key 'normal eglot-mode-map
    (kbd "M-p") 'flymake-goto-prev-error
    (kbd "M-n") 'flymake-goto-next-error)
  :commands eglot)
;; (use-package eldoc-box
;;   :ensure t
;;   :hook (eldoc-mode . eldoc-box-hover-at-point-mode))
(use-package csharp-mode
  :defer t
  :ensure t)
(use-package rust-mode
  :defer t
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
  (delete 'company-clang company-backends)
  :hook (markdown-mode . (lambda ()
                           (setq-local company-backends '(company-files))
                           )))

;; Markdown settings

(setq flyspell-issue-message-flag nil
      flyspell-issue-welcome-flag nil)

(use-package visual-fill-column
  :defer t
  :ensure t
  :custom (visual-fill-column-center-text t))
(use-package adaptive-wrap
  :defer t
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
                                  (setq fill-column 80)
                                  (flyspell-mode t) ;; Spellcheck
                                  (visual-line-mode t) ;; Visual wrap at column 80
                                  (visual-fill-column-mode t)
                                  (adaptive-wrap-prefix-mode t)))
  :config
  (setq markdown-link-space-sub-char " ")
  (setq markdown-regex-italic "\\(?:^\\|[^\\]\\)\\(?1:\\(?2:[*]\\)\\(?3:[^ 
	\\]\\|[^ 
	*]\\(?:.\\|
[^
]\\)*?[^\\ ]\\)\\(?4:\\2\\)\\)") ;; Disable _ italics
  (evil-define-key 'normal markdown-mode-map
    (kbd "M-n") (lambda ()
            (interactive)
            (call-interactively
             'markdown-next-visible-heading)
            (call-interactively
             'evil-scroll-line-to-top))
    (kbd "M-p") (lambda ()
            (interactive)
            (call-interactively
             'markdown-previous-visible-heading)
            (call-interactively
             'evil-scroll-line-to-top))
    (kbd "M-N") 'markdown-next-link
    (kbd "M-P") 'markdown-previous-link))

(keymap-unset evil-motion-state-map "C-o")
(keymap-global-set "C-o" 'project-find-file)
(keymap-unset evil-motion-state-map "C-f")
(keymap-global-set "C-f" 'project-find-regexp)

;; Hide math-preview on hover
(use-package math-preview
  :defer t
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
(defalias 'yes-or-no-p 'y-or-n-p) ;; Replace yes/no prompts with y/n

(use-package ansi-color
  :init
  (setq comint-terminfo-terminal "ansi")
  (add-to-list 'comint-output-filter-functions 'ansi-color-process-output)
  :hook (shell-mode . ansi-color-for-comint-mode-on))

(setq-default buffer-file-coding-system 'prefer-utf-8-dos)

(setq visible-bell 1 ;; Disable bell
      warning-minimum-level :error ;; Disable warnings popup
      inhibit-startup-screen t ;; Disable startup screen
      make-backup-files nil ;; Disable backup files (file~)
      auto-save-default nil ;; Disable autosave files (#file#)
      create-lockfiles nil) ;; Disable interlock files (.#file)

(setq-default truncate-lines t ;; Disable line wrapping
              indent-tabs-mode nil ;; Disable tabs
              tab-width 4)
(use-package cc-mode
  :config
  (setq c-basic-offset 4)
  (push '(c-mode . "linux") c-default-style))

(use-package window
  :config
  (setq split-height-threshold 0
        split-width-threshold 0
        help-window-select t) ;; Always select help split
  (winner-mode t) ;; Track window configuration

  (defun automatic-window-split (&optional window)
    "Split sensibly based on ratio"
    (interactive)
    (let ((window (or window (get-buffer-window))))
    (cond
     ((and (> (window-width window)
              (* 2 (window-height window)))
           (window-splittable-p window 'horizontal))
      (with-selected-window window
        (split-window-right)))
     ((window-splittable-p window)
      (with-selected-window window
        (split-window-below))))))

  (setq split-window-preferred-function 'automatic-window-split))

(setq scroll-margin 3 ;; Emulate vim like scrolling
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)
(pixel-scroll-precision-mode t)

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
  (evil-define-key 'normal 'global (kbd "C-t") 'tab-bar-new-tab)
  (keymap-global-set "C-<tab>" 'tab-bar-switch-to-next-tab)
  (keymap-global-set "C-S-<tab>" 'tab-bar-switch-to-prev-tab)
  (keymap-global-set "M-<right>" 'tab-bar-move-tab)
  (keymap-global-set "M-<left>" 'tab-bar-move-tab-backward)
  (setq tab-bar-show nil)
  :config
  (tab-bar-echo-area-mode 1))

(use-package epa
  :config
  (setq epa-pinentry-mode 'loopback))

;; Global zoom

(defun zoom-frame (&optional amt)
  (let ((height (+ (face-attribute 'default :height) amt)))
    (set-face-attribute 'default nil :height height)
    (message "Zoomed by %d -> Height %d" amt height)
    ))

(defun zoom-frame-in ()
  "Globally zoom in."
  (interactive)
  (zoom-frame 20))
(defun zoom-frame-out ()
  "Globally zoom out."
  (interactive)
  (zoom-frame -20))

;; Save window position/dimensions

(use-package desktop
  :init
  (setq desktop-path (list user-emacs-directory)) ;; Save in .emacs.d
  ;; (setq desktop-buffers-not-to-save ".*"
  ;;       desktop-files-not-to-save ".*") ;; Don't save buffers
  ;; (add-hook 'desktop-after-read-hook (lambda () ;; Don't save tabs
  ;;                                      (tab-bar-close-other-tabs)))
  ;; (setq desktop-buffers-not-to-save-function (lambda (b)
  ;;                                              (get-buffer-window b)))
  (setq desktop-restore-eager 5
        desktop-save t) ;; Always save

  ;; Never save theme elements
  (push '(foreground-color . :never) frameset-filter-alist)
  (push '(background-color . :never) frameset-filter-alist)
  (push '(font . :never) frameset-filter-alist)
  (push '(cursor-color . :never) frameset-filter-alist)
  (push '(border-color . :never) frameset-filter-alist)
  (push '(ns-appearance . :never) frameset-filter-alist)
  (push '(background-mode . :never) frameset-filter-alist)
  :config
  (desktop-save-mode t)
  (defun desktop-force-quit ()
    "Ignores desktop-save-mode, remove's the desktop file, and quits."
    (interactive)
    (desktop-save-mode-off)
    (desktop-remove)
    (kill-emacs)))

;; Highlight keywords

(add-hook 'prog-mode-hook
          (lambda ()
            (font-lock-add-keywords nil
                                    '(("\\<\\(FIXME\\|TODO\\|BUG\\):" 1 font-lock-warning-face t)))))

;; Some nice base16 themes: dirtysea, apprentice

(use-package base16-theme
  :ensure t
  :config
  (advice-add 'load-theme :after (lambda (&rest args) ;; Theme advice
                                   (set-face-attribute 'window-divider nil :foreground (face-foreground 'vertical-border))
                                   (let ((c (hex-to-rgb (face-background 'default))))
                                     (cl-rotatef (nth 0 c) (nth 2 c))
                                     (set-face-attribute 'math-preview-face nil :background (apply 'color-rgb-to-hex c)))
                                   (let ((c (hex-to-rgb (face-foreground 'default))))
                                     (cl-rotatef (nth 0 c) (nth 2 c))
                                     (set-face-attribute 'math-preview-face nil :foreground (apply 'color-rgb-to-hex c)))
                                   ))
  )

;; Set unicode fallback font
(set-fontset-font "fontset-default" 'unicode (font-spec :family "NSimSun"))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(base16-da-one-gray))
 '(custom-safe-themes t)
 '(display-line-numbers-type 'relative)
 '(evil-start-of-line t)
 '(evil-undo-system 'undo-redo)
 '(math-preview-margin '(0 . 0))
 '(math-preview-raise 0.3)
 '(math-preview-scale 0.8)
 '(menu-bar-mode nil)
 '(package-selected-packages '(vil use-package))
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Terminus" :slant normal :weight regular :height 151 :width normal))))
 '(fixed-pitch-serif ((t (:weight bold :family "Terminus"))))
 '(font-lock-comment-face ((t (:weight bold))))
 '(fringe ((t (:background nil))))
 '(info-menu-header ((t (:inherit variable-pitch :weight bold :height 1.25))))
 '(markdown-italic-face ((t (:inherit (italic font-lock-keyword-face) :underline t))))
 '(tab-bar ((t (:inherit default :background "systembuttonface" :foreground "systembuttontext"))))
 '(tooltip ((t (:inherit default :foreground "#eee"))))
 '(variable-pitch ((t (:foundry "outline" :family "Modern")))))
