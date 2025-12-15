;; BOOTSTRAP: STRAIGHT.EL & USE-PACKAGE
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install use-package and integrate with straight.el
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)


;; UI & BASIC PREFERENCES
(menu-bar-mode -1)
(tool-bar-mode -1)
(setq inhibit-startup-screen t)


;; Line numbers & highlighting
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)
(column-number-mode t)

;; TAB = 4 spaces 
(setq-default tab-width 4)
(setq-default indent-tabs-mode t)
(global-set-key (kbd "TAB") #'tab-to-tab-stop) 
(global-set-key (kbd "<tab>") #'tab-to-tab-stop)

;; Parenthesis matching
(electric-pair-mode t)
(show-paren-mode t)


;; Smooth scrolling
(setq scroll-step 1
      scroll-conservatively 10000)
(pixel-scroll-precision-mode 1)


;; File handling behavior
(delete-selection-mode 1)  ; Typing replaces selection
(setq make-backup-files nil) ; Stop creating ~ files
(save-place-mode 1)        ; Save cursor position
(savehist-mode 1)          ; Save command history
(global-auto-revert-mode 1); Auto-refresh buffers if file changes on disk


;; THEME & FONTS
(use-package gruvbox-theme
  :config
  (load-theme 'gruvbox-dark-hard t))

;; Set font (fail gracefully if font not found)
(ignore-errors
  (set-frame-font "Cascadia Code 13" nil t))


;; CUA MODE (Windows/Modern Keybindings)
;; This automatically handles:
;; C-c (Copy), C-v (Paste), C-x (Cut), C-z (Undo)
;; It intelligently keeps C-x as a command prefix when no text is selected.
(cua-mode 1)


;; CUSTOM KEYBINDINGS (VS Code Style overrides)
;; C-s = SAVE
(global-set-key (kbd "C-s") 'save-buffer)
;; C-f = SEARCH (Replacing standard forward-char)
(global-set-key (kbd "C-f") 'isearch-forward)
(define-key isearch-mode-map (kbd "C-f") 'isearch-repeat-forward)
;; C-a = SELECT ALL (Replacing standard move-beginning-of-line)
(global-set-key (kbd "C-a") 'mark-whole-buffer)
;; C-o = OPEN FILE
(global-set-key (kbd "C-o") 'find-file)
;; C-n = SWITCH BUFFER (Replacing standard next-line)
(global-set-key (kbd "C-n") 'switch-to-buffer)
;; C-Shift-P = COMMAND PALETTE (Execute extended command)
(global-set-key (kbd "C-S-p") 'execute-extended-command)
;; C-q = KILL BUFFER
(global-set-key (kbd "C-q") 'kill-current-buffer)
;; M-o = SWITCH WINDOW
(global-set-key (kbd "M-o") 'other-window)
;; Escape = Quit (C-g behavior)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)


;; Scratch / Tab bar / Restore Mods
(defvar my/scratch-session-file "~/.emacs.d/scratch-session.el"
  "File to save all unsaved scratch buffers for restoration.")

(defun my/new-scratch-name-datetime ()
  "Generate a unique scratch buffer name with current date and time."
  (let ((time-str (format-time-string "%Y-%m-%d_%H-%M-%S")))
    (generate-new-buffer-name (concat "*scratch-" time-str "*"))))

(defun my/prompt-save-scratch-buffer (&rest _args)
  "Prompt to save current scratch buffer if it is modified."
  (when (and (string-match-p "^\\*scratch" (buffer-name))
             (buffer-modified-p))
    (when (y-or-n-p
           (format "Scratch buffer %s modified. Save before proceeding? "
                   (buffer-name)))
      (let ((file (expand-file-name
                   (concat (buffer-name) ".org")
                   "~/.emacs.d/scratch-backup/")))
        (make-directory (file-name-directory file) t)
        (write-region (point-min) (point-max) file)
        (set-buffer-modified-p nil)))))

(defun my/tab-bar-new-tab-scratch (&rest _args)
  "After creating a new tab, switch to a timestamped scratch buffer."
  (let ((scratch-name (my/new-scratch-name-datetime)))
    (switch-to-buffer scratch-name)
    (text-mode)
    (goto-char (point-max))))

(defun my/tab-bar-close-tab-smart (&rest _args)
  "If closing the last tab, replace it with a scratch buffer.
Prompt to save if modified."
  (my/prompt-save-scratch-buffer)
  (when (= (length (tab-bar-tabs)) 1)
    (let ((scratch-name (my/new-scratch-name-datetime)))
      (switch-to-buffer scratch-name)
      (text-mode))))

(defun my/find-file-prompt-save-scratch (orig-fun &rest args)
  "Prompt to save the current scratch buffer if modified before opening a file."
  (my/prompt-save-scratch-buffer)
  (apply orig-fun args))

(defun my/find-file-dnd-smart (orig-fun filename &rest args)
  "Open dragged files:
- Replace *scratch* if it's the current buffer
- Otherwise open in a new tab"
  (let ((current (buffer-name (window-buffer))))
    (if (and (consp last-command-event) ; drag & drop
             (not (string-match-p "^\\*scratch" current)))
        (tab-bar-new-tab))
    (apply orig-fun filename args)))

(defun my/kill-buffer-advice (orig-fun &rest args)
  (let* ((buf (or (car args) (current-buffer)))
         (name (buffer-name buf)))
    (if (and (= (length (window-list)) 1)
             (string-match-p "^\\*scratch" name))
        (progn
          (with-current-buffer buf
            (erase-buffer)
            (text-mode)
            (message "Scratch in last tab cleared instead of closing.")))
      (apply orig-fun args))))

;; Save all scratch buffers to session file
(defun my/save-scratch-session ()
  "Save all scratch buffers to the scratch session file."
  (with-temp-file my/scratch-session-file
    (dolist (buf (buffer-list))
      (when (and (buffer-live-p buf)
                 (string-match-p "^\\*scratch" (buffer-name buf)))
        (let ((name (buffer-name buf))
              (contents (with-current-buffer buf (buffer-string))))
          (insert (format "(%S . %S)\n" name contents)))))))

;; Restore scratch buffers from session file
(defun my/restore-scratch-session ()
  "Restore scratch buffers from session file before tab-bar-mode."
  (when (file-exists-p my/scratch-session-file)
    (with-temp-buffer
      (insert-file-contents my/scratch-session-file)
      (goto-char (point-min))
      (while (< (point) (point-max))
        (let ((pair (read (current-buffer))))
          (let ((buf (get-buffer-create (car pair))))
            (tab-bar-new-tab)
            (switch-to-buffer buf)
            (erase-buffer)
            (insert (cdr pair))
            (text-mode)))))))

;; Setup advices
(defun my/setup-tab-scratch-advices ()
  "Setup all advices for tab and scratch buffer management."
  (advice-add 'tab-bar-new-tab :before #'my/prompt-save-scratch-buffer)
  (advice-add 'tab-bar-new-tab :after #'my/tab-bar-new-tab-scratch)
  (advice-add 'tab-bar-close-tab :before #'my/tab-bar-close-tab-smart)
  (advice-add 'find-file :around #'my/find-file-prompt-save-scratch)
  (advice-add 'find-file :around #'my/find-file-dnd-smart)
  (advice-add 'kill-buffer :around #'my/kill-buffer-advice))

;; Main setup function
(defun my/setup-tab-scratch-system ()
  "Initialize the tab and scratch buffer management system."
  ;; Restore session
  (my/restore-scratch-session)
  
  ;; Setup advices
  (my/setup-tab-scratch-advices)
  
  ;; Save session on exit
  (add-hook 'kill-emacs-hook #'my/save-scratch-session)
  
  ;; Setup tab bar
  (add-hook 'emacs-startup-hook
            (lambda ()
              (tab-bar-mode 1)
              (setq tab-bar-show 1)
              (when (fboundp 'tab-bar--update-tab-bar-lines)
                (tab-bar--update-tab-bar-lines))
              (setq tab-bar-tab-name-function #'tab-bar-tab-name-current)))
  
  ;; Keyboard shortcuts
  (global-set-key (kbd "C-<tab>") #'tab-bar-switch-to-next-tab)
  (global-set-key (kbd "C-S-<tab>") #'tab-bar-switch-to-prev-tab)
  
  ;; Other modes
  (recentf-mode 1)
  (savehist-mode 1)
  (save-place-mode 1)
  (desktop-save-mode 1)
  (setq desktop-load-locked-desktop t
        desktop-restore-frames t))

;; Initialize the system
(my/setup-tab-scratch-system)











;; =====================================================
;; VS Code–like IntelliSense for Emacs 30
;; =====================================================

;; -------------------------
;; Completion UI (CORFU)
;; -------------------------
(straight-use-package 'corfu)
(straight-use-package 'orderless)
(straight-use-package 'cape)

(setq corfu-auto t
      corfu-cycle t
      corfu-preselect 'prompt
      corfu-preview-current nil)

(global-corfu-mode 1)

;; -------------------------
;; Ctrl + Space = IntelliSense
;; -------------------------
(global-set-key (kbd "C-SPC") #'completion-at-point)

;; Prevent mark conflicts
(setq mark-ring-max 32)
(setq global-mark-ring-max 32)

;; -------------------------
;; Completion filtering
;; -------------------------
(setq completion-styles '(orderless basic)
      completion-category-overrides
      '((eglot (styles orderless))))

;; -------------------------
;; Extra completion sources
;; -------------------------
(add-to-list 'completion-at-point-functions #'cape-file)
(add-to-list 'completion-at-point-functions #'cape-dabbrev)
(add-to-list 'completion-at-point-functions #'cape-keyword)

;; -------------------------
;; LSP (Eglot – built-in)
;; -------------------------
(add-hook 'python-mode-hook #'eglot-ensure)
(add-hook 'c-mode-hook #'eglot-ensure)
(add-hook 'c++-mode-hook #'eglot-ensure)

(setq eglot-autoshutdown t
      eglot-send-changes-idle-time 0.1)

;; -------------------------
;; Documentation on hover
;; -------------------------
(setq eldoc-echo-area-use-multiline-p t)

;; -------------------------
;; Symbol navigation (VS Code Outline)
;; -------------------------
(straight-use-package 'consult)

(global-set-key (kbd "C-S-o") #'consult-imenu)       ;; current file symbols
(global-set-key (kbd "C-S-l") #'consult-lsp-symbols) ;; project symbols

;; -------------------------
;; Go to definition / references
;; -------------------------
(global-set-key (kbd "<f12>") #'eglot-find-definition)
(global-set-key (kbd "<S-f12>") #'eglot-find-references)

;; -------------------------
;; Optional: icons in popup (nice)
;; -------------------------
(straight-use-package 'kind-icon)

(setq kind-icon-default-face 'corfu-default)
(add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter)

;; -------------------------
;; Better minibuffer UX
;; -------------------------
(straight-use-package 'vertico)
(vertico-mode 1)

(straight-use-package 'marginalia)
(marginalia-mode 1)



;; =====================================================
;; END
;; =====================================================


(add-hook 'c-mode-hook
          (lambda ()
            (remove-hook 'flymake-diagnostic-functions 'flymake-cc t)))

(add-hook 'c++-mode-hook
          (lambda ()
            (remove-hook 'flymake-diagnostic-functions 'flymake-cc t)))

