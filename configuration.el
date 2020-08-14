(require 'use-package-ensure)
(setq use-package-always-ensure t)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package auto-package-update
  :ensure t
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe))

(use-package auto-compile
  :config (auto-compile-on-load-mode))
(setq load-prefer-newer t)

(defun iz/visit-emacs-config ()
  (interactive)
  (find-file "~/.emacs.d/configuration.org"))

(global-set-key (kbd "C-x e") 'iz/visit-emacs-config)

(use-package org-bullets
  :ensure t
  )
(add-hook 'org-mode-hook #'org-bullets-mode)
(org-bullets-mode t)

(defconst emacs-tmp-dir (format "~%s%s%s/" temporary-file-directory "emacs" (user-uid)))
(setq backup-directory-alist `((".*" . ,emacs-tmp-dir)))
(setq auto-save-file-name-transforms `((".*" ,emacs-tmp-dir t)))
(setq auto-save-list-file-prefix emacs-tmp-dir)

(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
)
(setq yas-snippet-dirs '("~/.emacs.d/snippets"))
(yas-global-mode 1)

(setq custom-file "~/.emacs.d/custom-variables.el")
(when (file-exists-p custom-file)
    (load custom-file))

(use-package diminish
:ensure t)

(use-package bind-key :ensure t)

(show-paren-mode t)
(electric-pair-mode t)

;; include single quote for electric pair mode, I found it more annoying with elisp
;; (setq electric-pair-pairs '(
;; 			    (?\' . ?\')
;; 			    ))

(setq-default indent-tabs-mode nil)

(winner-mode t)

(use-package exec-path-from-shell
:ensure t)
(setq exec-path-from-shell-check-startup-files nil)
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode -1)

(set-window-scroll-bars (minibuffer-window) nil nil)

;;
;; hideshow
;;
(add-hook 'prog-mode-hook #'hs-minor-mode)

(use-package multiple-cursors
  :ensure t
  :bind (
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         :map ctl-x-map
         ("\C-m" . mc/mark-all-dwim)
         ("<return>" . mule-keymap)
         ))

;; (when (window-system)
;;   (set-default-font "Source Code Pro 14"))

(when (window-system)                   
  (set-default-font "Source Code Pro 16"))

(global-prettify-symbols-mode t)

(use-package powerline
:ensure t)

(powerline-default-theme)

(use-package monokai-pro-theme
  :if (window-system)
  :ensure t
  :init
  (setq monokai-use-variable-pitch nil))

(use-package leuven-theme
:ensure t)
  (load-theme 'leuven)

(defun switch-theme (theme)
  "Disables any currently active themes and loads THEME."
  ;; This interactive call is taken from `load-theme'
  (interactive
   (list
    (intern (completing-read "Load custom theme: "
                             (mapc 'symbol-name
                                   (custom-available-themes))))))
  (let ((enabled-themes custom-enabled-themes))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme theme t)))

(defun disable-active-themes ()
  "Disables any currently active themes listed in `custom-enabled-themes'."
  (interactive)
  (mapc #'disable-theme custom-enabled-themes))

(bind-key "<f9>" 'switch-theme)
(bind-key "<f8>" 'disable-active-themes)

(defun move-text-internal (arg)
   (cond
    ((and mark-active transient-mark-mode)
     (if (> (point) (mark))
            (exchange-point-and-mark))
     (let ((column (current-column))
              (text (delete-and-extract-region (point) (mark))))
       (forward-line arg)
       (move-to-column column t)
       (set-mark (point))
       (insert text)
       (exchange-point-and-mark)
       (setq deactivate-mark nil)))
    (t
     (beginning-of-line)
     (when (or (> arg 0) (not (bobp)))
       (forward-line)
       (when (or (< arg 0) (not (eobp)))
            (transpose-lines arg))
       (forward-line -1)))))

(defun move-text-down (arg)
   "Move region (transient-mark-mode active) or current line
  arg lines down."
   (interactive "*p")
   (move-text-internal arg))

(defun move-text-up (arg)
   "Move region (transient-mark-mode active) or current line
  arg lines up."
   (interactive "*p")
   (move-text-internal (- arg)))

(global-set-key [\M-\S-up] 'move-text-up)
(global-set-key [\M-\S-down] 'move-text-down)

(defun duplicate-line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank)
)
(global-set-key (kbd "C-S-d") 'duplicate-line)

(use-package ivy
  :ensure t
  :diminish (ivy-mode . "")
  :config
  (ivy-mode 1)
  (setq ivy-use-virutal-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-height 10)
  (setq ivy-initial-inputs-alist nil)
  (setq ivy-count-format "%d/%d")
  (setq ivy-re-builders-alist
        `((t . ivy--regex-ignore-order)))
  )

;;
;; counsel
;;
(use-package counsel
  :ensure t
  :bind (("M-x" . counsel-M-x)
         ("\C-x \C-f" . counsel-find-file)))

(use-package swiper
  :ensure t
  :bind (("\C-s" . swiper))
  )

;;
;; company
;;
(use-package company
  :ensure t
  :config
  (global-company-mode t)
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 3)
  (setq company-backends
        '((company-files
           company-yasnippet
           company-keywords
           company-capf
           )
          (company-abbrev company-dabbrev))))

(add-hook 'emacs-lisp-mode-hook (lambda ()
                                  (add-to-list  (make-local-variable 'company-backends)
                                                '(company-elisp))))

;;
;; change C-n C-p
;;
(with-eval-after-load 'company
  (define-key company-active-map (kbd "\C-n") #'company-select-next)
  (define-key company-active-map (kbd "\C-p") #'company-select-previous)
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil))



;;
;; change company complete common
;;
;; With this code, yasnippet will expand the snippet if company didn't complete the word
;; replace company-complete-common with company-complete if you're using it
;;

(advice-add 'company-complete-common :before (lambda () (setq my-company-point (point))))
(advice-add 'company-complete-common :after (lambda () (when (equal my-company-point (point))
                                                         (yas-expand))))

;;
;; flycheck
;;

(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode t)
  )

;;
;; magit
;;
(use-package magit
  :ensure t
  :bind (("\C-x g" . magit-status))
  )

;;
;; projectile
;;
(use-package projectile
  :ensure t
  :bind-keymap
  ("\C-c p" . projectile-command-map)
  :config
  (projectile-mode t)
  (setq projectile-completion-system 'ivy)
  (use-package counsel-projectile
    :ensure t)
  )

(setq python-shell-interpreter "/usr/bin/python3")

(use-package ob-ipython
  :ensure t)
(require 'ob-js)
(setq org-babel-python-command "/usr/bin/python3")
(setq py-python-command "/usr/bin/python3")

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (ipython . t)
   (C . t)
   (calc . t)
   (latex . t)
   (java . t)
   (ruby . t)
   (lisp . t)
   (scheme . t)
   (shell . t)
   (sqlite . t)
   (js . t)))

(org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages)
(add-to-list 'org-babel-tangle-lang-exts '("js" . "js"))

(defun my-org-confirm-babel-evaluate (lang body)
  "Do not confirm evaluation for these languages."
  (not (or (string= lang "C")
           (string= lang "ipython")
           (string= lang "java")
           (string= lang "python")
           (string= lang "emacs-lisp")
           (string= lang "js")
           (string= lang "sqlite"))))
(setq org-confirm-babel-evaluate 'my-org-confirm-babel-evaluate)

;; js
(setq org-babel-js-function-wrapper
      "console.log(require('util').inspect(function(){\n%s\n}(), { depth: 100 }))")

;;; display/update images in the buffer after I evaluate
(add-hook 'org-babel-after-execute-hook 'org-display-inline-images 'append)

;;; web.el --- Web related setup                     -*- lexical-binding: t; -*-

;; 

;;; Code:
(use-package web-mode
  :ensure t
  :mode ("\\.html\\'" "\\.vue\\'")
  :config
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-enable-current-element-highlight t)
  (setq web-mode-enable-css-colorization t)
  (set-face-attribute 'web-mode-html-tag-face nil :foreground "royalblue")
  (set-face-attribute 'web-mode-html-attr-name-face nil :foreground "powderblue")
  (set-face-attribute 'web-mode-doctype-face nil :foreground "lightskyblue")
  (setq web-mode-content-types-alist
        '(("vue" . "\\.vue\\'")))
  (use-package company-web
    :ensure t)
  (add-hook 'web-mode-hook (lambda()
                             (cond ((equal web-mode-content-type "html")
                                    (my/web-html-setup))
                                   ((member web-mode-content-type '("vue"))
                                    (my/web-vue-setup))
                                   )))
  )

;;
;; html
;;
(defun my/web-html-setup()
  "Setup for web-mode html files."
  (message "web-mode use html related setup")
  (flycheck-add-mode 'html-tidy 'web-mode)
  (flycheck-select-checker 'html-tidy)
  (add-to-list (make-local-variable 'company-backends)
               '(company-web-html company-files company-css company-capf company-dabbrev))
  (add-hook 'before-save-hook #'sgml-pretty-print)

  )


;;
;; web-mode for vue
;;
(defun my/web-vue-setup()
  "Setup for js related."
  (message "web-mode use vue related setup")
  (setup-tide-mode)
  (prettier-js-mode)
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  (flycheck-select-checker 'javascript-eslint)
  (my/use-eslint-from-node-modules)
  (add-to-list (make-local-variable 'company-backends)
               '(comany-tide company-web-html company-css company-files))
  )


;;
;; eslint use local
;;
(defun my/use-eslint-from-node-modules ()
  "Use local eslint from node_modules before global."
  (let* ((root (locate-dominating-file
                (or (buffer-file-name) default-directory)
                "node_modules"))
         (eslint (and root
                      (expand-file-name "node_modules/eslint/bin/eslint.js"
                                        root))))
    (when (and eslint (file-executable-p eslint))
      (setq-local flycheck-javascript-eslint-executable eslint))))

(add-hook 'flycheck-mode-hook #'my/use-eslint-from-node-modules)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;                 rjsx                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package rjsx-mode
  :ensure t
  :mode ("\\.js\\'")
  :config
  (setq js2-basic-offset 2)
  (add-hook 'rjsx-mode-hook (lambda()
                              (flycheck-add-mode 'javascript-eslint 'rjsx-mode)
                              (my/use-eslint-from-node-modules)
                              (flycheck-select-checker 'javascript-eslint)
                              ))
  (setq js2-basic-offset 2)
  )

(use-package react-snippets
  :ensure t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;                 css                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package css-mode
  :ensure t
  :mode "\\.css\\'"
  :config
  (add-hook 'css-mode-hook (lambda()
                             (add-to-list (make-local-variable 'company-backends)
                                          '(company-css company-files company-yasnippet company-capf))))
  (setq css-indent-offset 2)
  (setq flycheck-stylelintrc "~/.stylelintrc")
  )


(use-package scss-mode
  :ensure t
  :mode "\\scss\\'"
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;                emmet                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package emmet-mode
  :ensure t
  :hook (web-mode css-mode scss-mode sgml-mode rjsx-mode)
  :config
  (add-hook 'emmet-mode-hook (lambda()
                              (setq emmet-indent-after-insert t)))

  )

(use-package mode-local
  :ensure t
  :config
  (setq-mode-local rjsx-mode emmet-expand-jsx-className? t)
  (setq-mode-local web-mode emmet-expand-jsx-className? nil)  
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;                  js                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package js2-mode
  :ensure t
  ;; :mode (("\\.js\\'" . js2-mode)
  ;;        ("\\.json\\'" . javascript-mode))
  :init
  (setq indent-tabs-mode nil)
  (setq js2-basic-offset 2)
  (setq js-indent-level 2)
  (setq js2-global-externs '("module" "require" "assert" "setInterval" "console" "__dirname__") )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;              typescript             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun setup-tide-mode ()
  "Setup tide mode for other mode."
  (interactive)
  (message "setup tide mode")
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))


(add-hook 'js2-mode-hook #'setup-tide-mode)
(add-hook 'typescript-mode-hook #'setup-tide-mode)
(add-hook 'rjsx-mode-hook #'setup-tide-mode)



(use-package tide
  :ensure t
  :after (typescript-mode company flycheck)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode))
  ;;(before-save . tide-format-before-save))
  :config
  (setq tide-completion-enable-autoimport-suggestions t)
  )

(use-package prettier-js
  :ensure t
  :hook ((js2-mode . prettier-js-mode)
         (typescript-mode . prettier-js-mode)
         (css-mode . prettier-js-mode)
         (web-mode . prettier-js-mode))
  :config
  (setq prettier-js-args '(
                           "--trailing-comma" "es5"
                           "--bracket-spacing" "false"
                           ))
  )


;;
;; restful client
;;


(use-package restclient
  :ensure t
  :mode ("\\.http\\'" . restclient-mode)
  )

(provide 'web)
;;; web.el ends here

;;; python.el --- python related                     -*- lexical-binding: t; -*-

;; Copyright (C) 2018  vagrant
;;; Commentary:

;; Author: vagrant <vagrant@node1.onionstudio.com.tw>
;; Keywords: languages, abbrev
;;; Code:


;;
;; need pip install autopep8, flake8, jedi and elpy
;;
(use-package python
  :ensure t
  :mode (
  ("\\.py\\'" . python-mode)
  ("\\.ipy\\'" . python-mode)
  )
  :interpreter ("python" . python-mode)
  :config
  (setq indent-tabs-mode nil)
  (setq python-indent-offset 4)
  (use-package py-autopep8
    :ensure t
    :hook ((python-mode . py-autopep8-enable-on-save))
    )
  )



;;
;; company jedi use jedi-core
;;
(use-package company-jedi
  :ensure t
  :config
  (add-hook 'python-mode-hook 'jedi:setup)
  (add-hook 'python-mode-hook (lambda ()
                                (add-to-list (make-local-variable 'company-backends)
                                             'company-jedi)))
  )

(use-package elpy
  :ensure t
  :commands (elpy-enable)
  :config
  (setq elpy-rpc-backend "jedi")
  )

(provide 'python)
;;; python.el ends here

(use-package pipenv
  :hook (python-mode . pipenv-mode)
  :init
  (setq
   pipenv-projectile-after-switch-function
   #'pipenv-projectile-after-switch-extended))

;;; c.el --- c/c++ mode                              -*- lexical-binding: t; -*-

;; Copyright (C) 2018  vagrant

;; Author: vagrant <vagrant@node1.onionstudio.com.tw>
;; Keywords: c

;;; Code:


;;
;; irony is for auto-complete, syntax checking and documentation
;;
;; You will need to install irony-server first time use
;; to install irony-server, your system need to install clang, cmake and clang-devel in advance
;;
(use-package irony
  :ensure t
  :hook ((c++-mode . irony-mode)
         (c-mode . irony-mode))
  :config
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
  (use-package company-irony-c-headers
    :ensure t)
  (use-package company-irony
    :ensure t
    :config
    (add-to-list (make-local-variable 'company-backends)
                 '(company-irony company-irony-c-headers)))
  (use-package flycheck-irony
    :ensure t
    :config
    (add-hook 'flycheck-mode-hook #'flycheck-irony-setup)
    )
  (use-package irony-eldoc
    :ensure t
    :config
    (add-hook 'irony-mode-hook #'irony-eldoc)
    )
  )


;;
;; rtags enable jump-to-function definition
;; system need to install rtags first
;;
;; for centos, you need llvm-devel, cppunit-devl
;; install gcc-4.9, cmake 3.1 and download rtags from github and make it
;;

(use-package rtags
  :ensure t
  :config
  (rtags-enable-standard-keybindings)
  (setq rtags-autostart-diagnostics t)
  (rtags-diagnostics)
  (setq rtags-completions-enabled t)
  (define-key c-mode-base-map (kbd "M-.")
    (function rtags-find-symbol-at-point))
  (define-key c-mode-base-map (kbd "M-,")
    (function rtags-find-references-at-point))
  )

;;
;; cmake-ide enable rdm(rtags) auto start and rc(rtags) to watch directory
;;
(use-package cmake-ide
  :ensure t
  :config
  (cmake-ide-setup)
  )


;;
;; for editting CMakeLists.txt
;;
(use-package cmake-mode
  :ensure t
  :mode (("CMakeLists\\.txt\\'" . cmake-mode)
         ("\\.cmake\\'" . cmake-mode))
  :config
  (add-hook 'cmake-mode-hook (lambda()
                               (add-to-list (make-local-variable 'company-backends)
                                            'company-cmake)))
  )

;;
;; for c formatting
;;
(use-package clang-format
  :ensure t
  :config
  (setq clang-format-style-option "llvm")
  (add-hook 'c-mode-hook (lambda() (add-hook 'before-save-hook 'clang-format-buffer)))
  (add-hook 'c++-mode-hook (lambda() (add-hook 'before-save-hook 'clang-format-buffer)))
  )

(provide 'c)
;;; c.el ends here

(use-package go-mode
  :ensure t
  :mode (("\\.go\\'" . go-mode))
  :hook ((before-save . gofmt-before-save))
  :config
  (setq gofmt-command "goimports")


  (use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (go-mode . lsp-deferred))

  ;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; Optional - provides fancier overlays.
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

;; Company mode is a standard completion package that works well with lsp-mode.
(use-package company
  :ensure t
  :config
  ;; Optionally enable completion-as-you-type behavior.
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 1))

;; Optional - provides snippet support.
(use-package yasnippet
  :ensure t
  :commands yas-minor-mode
  :hook (go-mode . yas-minor-mode))

  (use-package go-eldoc
    :ensure t
    :hook (go-mode . go-eldoc-setup)
    )
  (use-package go-guru
    :ensure t
    :hook (go-mode . go-guru-hl-identifier-mode)
    )
  (use-package go-rename
    :ensure t)
  )

(provide 'go)
;;; go.el ends here
