;;---------------------------------------------------------------------------------------------;;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Disable Menubar & Toolbar ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;;
(menu-bar-mode -1)									       ;;
(tool-bar-mode -1)									       ;;
;;---------------------------------------------------------------------------------------------;;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Disable Startup Screen	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;;
(setq inhibit-startup-screen t)								       ;;
;;---------------------------------------------------------------------------------------------;;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Display Line Numbers In Every Buffer ~~~~~~~~~~~~~~~~~~~~~~~~~;;
(global-display-line-numbers-mode 1)							       ;;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Put Column NumberS In Display ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;;
(setq column-number-mode t)                                                                    ;;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Delete Selected Text When Pasting ~~~~~~~~~~~~~~~~~~~~~~~~~~~~;;
(delete-selection-mode 1)                                                                      ;;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Scroll 1 line at a time ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;;
(setq scroll-step 1)                                                                           ;;
;;---------------------------------------------------------------------------------------------;;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Stop Creating Backup Files ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;;
(setq make-backup-files nil)								       ;;
;;---------------------------------------------------------------------------------------------;;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MELPA Packages	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;;
(require 'package)									       ;;
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))		       ;;
;;---------------------------------------------------------------------------------------------;;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Straight Package Manager ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;;
(defvar bootstrap-version)								       ;;
(let ((bootstrap-file									       ;;
      (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))       ;;
      (bootstrap-version 5))								       ;;
  (unless (file-exists-p bootstrap-file)						       ;;
    (with-current-buffer								       ;;
        (url-retrieve-synchronously							       ;;
        "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"	       ;;
        'silent 'inhibit-cookies)							       ;;
      (goto-char (point-max))								       ;;
      (eval-print-last-sexp)))								       ;;
  (load bootstrap-file nil 'nomessage))							       ;;
;;---------------------------------------------------------------------------------------------;;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Enable Use Package Option ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;;
(straight-use-package 'use-package)                                                            ;;
;;use-package will use straight.el to automatically install missing packages                   ;;
(use-package el-patch                                                                          ;;
  :straight t)                                                                                 ;;
;;---------------------------------------------------------------------------------------------;;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Theme & Fonts ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;;
(straight-use-package 'gruvbox-theme)							       ;;
(load-theme 'gruvbox-dark-hard t)							       ;;
(set-frame-font "Cascadia Code 10" nil t)						       ;;
;;---------------------------------------------------------------------------------------------;;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Custom Keymaps ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;;
;; Ctrl + s = SAVE                                                                             ;;
(global-set-key (kbd "C-s") 'save-buffer)                                                      ;;
;; Ctrl + f = SEARCH                                                                           ;;
(global-set-key (kbd "C-f") 'isearch-forward)                                                  ;;
(define-key isearch-mode-map "\C-f" 'isearch-repeat-forward)                                   ;;
;; Ctrl + c = COPY                                                                             ;;
;; Global map has the lowest precedence. Bind it with higher precedence bind-key*              ;;
(bind-key* (kbd "C-c") 'kill-ring-save)                                                        ;;
;; Ctrl + v = PASTE                                                                            ;;
(global-set-key (kbd "C-v") 'yank)                                                             ;;
;; Ctrl + x = CUT                                                                              ;;
(global-set-key (kbd "C-x") 'kill-region)                                                      ;;
;; Ctrl + z = UNDO                                                                             ;;
(global-set-key (kbd "C-z") 'undo)                                                             ;;
;; Ctrl + R = Redo                                                                             ;;
(global-set-key (kbd "C-r") 'redo)                                                             ;;
;; Ctrl + a = SELECT ALL                                                                       ;;
(global-set-key (kbd "C-a") 'mark-whole-buffer)                                                ;;
;; Ctrl + o = Open A File                                                                      ;;
(global-set-key (kbd "C-o") 'find-file)                                                        ;;
;; Ctrl + n = A New Unsaved Buffer                                                             ;;
(global-set-key (kbd "C-n") 'switch-to-buffer)                                                 ;;
;; Alt + x = the functionality of C-x                                                          ;;
(global-set-key (kbd "M-x") ctl-x-map)                                                         ;;
;; Alt + c = the functionality of C-c                                                          ;;
(global-set-key (kbd "M-c") 'mode-specific-command-prefix)                                     ;;
;; Ctrl + Shift + p = Executing commands                                                       ;;
(global-set-key (kbd "C-S-p") 'execute-extended-command)                                       ;;
;; Ctrl + <tab> = Switching Window                                                             ;;
(global-set-key (kbd "C-<tab>") 'other-window)                                                 ;;
;; Ctrl + q = kill the current buffer                                                          ;;
(global-set-key (kbd "C-q") 'kill-this-buffer)                                                 ;;
;;---------------------------------------------------------------------------------------------;;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Some Hacks ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;;
;; Scroll Down Touchpad Fix                                                                    ;;
(pixel-scroll-precision-mode 1)                                                                ;;
(save-place-mode 1)         ;; save cursor position                                            ;;
(desktop-save-mode 0)       ;; dont save the desktop session                                   ;;
(savehist-mode 1)           ;; save history                                                    ;;
(global-auto-revert-mode 1) ;; revert buffers when the underlying file has changed             ;;
;;---------------------------------------------------------------------------------------------;;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Treesitter Mode ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;;
(require 'treesit)                                                                             ;;
(straight-use-package 'treesit-auto)                                                           ;;
(use-package treesit-auto                                                                      ;;
  :custom                                                                                      ;;
  (treesit-auto-install 't)                                                                    ;;
  :config                                                                                      ;;
  (treesit-auto-add-to-auto-mode-alist 'all)                                                   ;;
  (global-treesit-auto-mode))                                                                  ;;
;;---------------------------------------------------------------------------------------------;;
