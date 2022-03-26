(require 'package)

;; Package list
(setq package-list '(evil ;; evil
                     evil-leader
                     evil-collection
                     evil-mc
                     counsel ;; ivy
                     lsp-mode ;; lsp
                     lsp-ui
                     company
                     rust-mode ;; languages
                     csharp-mode
                     magit ;; misc
                     mood-line
                     ))

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

;; Evil mode settings
(setq evil-want-integration t
      evil-want-keybinding nil)

(setq evil-split-window-below t
      evil-vsplit-window-right t
      evil-want-C-u-scroll t
      evil-echo-state nil)

(require 'evil-leader)
(global-evil-leader-mode)
(evil-leader/set-leader "<SPC>")
(evil-leader/set-key
  "x" 'counsel-M-x
  "b" 'counsel-bookmark
  "g" 'magit-status
  "h" 'help-for-help
  "e" 'eval-defun
  "ff" 'find-function
  "q" 'evil-mc-undo-all-cursors
  "s" 'evil-mc-make-cursors-at-search
  "w" 'save-buffer)

(require 'evil)
(evil-mode t)

(require 'evil-collection)
(delete 'evil-mc evil-collection-mode-list)
(evil-collection-init)

(require 'evil-mc)
(global-evil-mc-mode t)
(setq evil-mc-enable-bar-cursor nil)
(setq evil-mc-undo-cursors-on-keyboard-quit t)
(defun evil-mc-make-cursors-at-search ()
  (interactive)
  (let ((search (car evil-search-forward-history)))
    (setq evil-mc-pattern (cons (evil-ex-make-search-pattern search) nil))
    (evil-mc-make-cursors-for-all)
    (let ((goto (or (evil-mc-find-next-cursor) (evil-mc-find-prev-cursor))))
      (evil-mc-goto-cursor goto nil)
      )))

;; LSP/Language settings

(evil-define-key 'normal 'global "gd" 'lsp-find-definition)

(setq company-minimum-prefix-length 1
      company-idle-delay 0.0) ;; default is 0.2
(setq lsp-headerline-breadcrumb-enable nil)

(setq sgml-basic-offset 4)

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

(set-frame-parameter (selected-frame) 'internal-border-width 40) ;; Padding

(mood-line-mode)

;; Save window position/dimensions

(setq desktop-path (list user-emacs-directory)) ;; Save in .emacs.d
(setq desktop-buffers-not-to-save ".*"
      desktop-files-not-to-save ".*") ;; Don't save buffers
(setq desktop-save t) ;; Always save
(desktop-save-mode t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(minimal-black))
 '(custom-safe-themes
   '("3e335d794ed3030fefd0dbd7ff2d3555e29481fe4bbb0106ea11c660d6001767" "4780d7ce6e5491e2c1190082f7fe0f812707fc77455616ab6f8b38e796cbffa9" "cc0dbb53a10215b696d391a90de635ba1699072745bf653b53774706999208e3" "33ea268218b70aa106ba51a85fe976bfae9cf6931b18ceaf57159c558bbcd1e6" default))
 '(display-line-numbers-type 'relative)
 '(evil-start-of-line t)
 '(evil-undo-system 'undo-redo)
 '(package-selected-packages
   '(mood-line minimal-theme csharp-mode evil-mc-extras lsp-ui lsp-mode evil-leader evil))
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Terminus" :foundry "raster" :slant normal :weight regular :height 151 :width normal))))
 '(fringe ((t (:background nil)))))
