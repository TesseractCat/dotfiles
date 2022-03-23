(require 'package)

;; List the packages you want
(setq package-list '(evil ;; evil
		     evil-leader
		     evil-collection
                     evil-mc
		     counsel ;; ivy
		     lsp-mode ;; lsp
		     lsp-ui
		     company))

;; Add Melpa as the default Emacs Package repository
;; only contains a very limited number of packages
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

;; Evil mode
(setq evil-want-integration t
      evil-want-keybinding nil)

(setq evil-split-window-below t
      evil-vsplit-window-right t
      evil-want-C-u-scroll t)

(require 'evil-leader)
(global-evil-leader-mode)
(evil-leader/set-leader "<SPC>")
(evil-leader/set-key
  "x" 'counsel-M-x
  "q" 'evil-mc-undo-all-cursors
  "b" 'switch-to-buffer
  "w" 'save-buffer)

(require 'evil)
(evil-mode t)

(require 'evil-collection)
(evil-collection-init)

(require 'evil-mc)
(global-evil-mc-mode t)

;; LSP settings

(evil-define-key 'normal 'global "gd" 'lsp-find-definition)

(setq company-minimum-prefix-length 1
      company-idle-delay 0.0) ;; default is 0.2

;; Misc settings

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(setq visible-bell 1) ;; Disable bell
(setq warning-minimum-level :error) ;; Disable warnings popup
(setq inhibit-startup-screen t) ;; Disable startup screen
(setq make-backup-files nil) ;; Disable backup files (file~)
(setq create-lockfiles nil) ;; Disable interlock files (.#file)

(setq-default truncate-lines t) ;; Disable line wrapping
(global-display-line-numbers-mode)

(setq scroll-margin 3 ;; Emulate vim like scrolling
  scroll-step 1
  scroll-conservatively 10000
  scroll-preserve-screen-position 1)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(wombat))
 '(display-line-numbers-type 'relative)
 '(evil-start-of-line t)
 '(evil-undo-system 'undo-redo)
 '(helm-minibuffer-history-key "M-p")
 '(package-selected-packages '(evil-mc-extras lsp-ui lsp-mode evil-leader evil))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
