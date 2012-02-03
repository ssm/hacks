;;; A flymake handler for puppet manifests
;;;
;;; Author: Stig Sandbeck Mathisen <ssm@fnord.no>
;;;
;;; Homepage: http://fnord.no/
;;;
;;; Usage:
;;;   (require 'flymake-puppet-lint)
;;;   (add-hook 'puppet-mode-hook 'flymake-puppet-lint-load)
;;;
;;; You should have puppet-lint installed for this to work, it should
;;; be at least version 0.1.11, and I'm too lazy to find version
;;; comparing lisp code. Contributions welcome, of course. :)
;;;
;;; Note: For manifest files of more than a few thousand lines, this
;;; will be rather slow. (You should probably should have refactored
;;; by then, anyway)

(require 'flymake)

(defvar flymake-puppet-lint-allowed-file-name-masks '(("\\.pp$" flymake-puppet-lint-init)))

(defvar flymake-puppet-lint-executable "puppet-lint")

(defvar flymake-puppet-lint-err-line-patterns
  '((".+: \\(.+\\):\\([0-9]+\\) \\(.+\\)" 1 2 nil 3)))

(defun flymake-puppet-lint-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list "puppet-lint"
          (list "--fail-on-warnings"
                                        ; The emacs puppet mode indent
                                        ; code and puppet-lint
                                        ; disagree on how and when to
                                        ; indent. Emacs wins. :)
                "--no-2sp_soft_tabs-check"
                                        ; FIXME: flymake checks a
                                        ; temporary file with another
                                        ; name, so disable the
                                        ; autoloader layout check
                "--no-autoloader_layout-check"
                                        ; If you change the output log
                                        ; format, also adjust
                                        ; flymake-puppet-lint-err-line-patterns
                "--log-format"
                "%{kind}: %{filename}:%{linenumber} %{message}"
                local-file))))

(defun flymake-puppet-lint-load ()
  (interactive)
  (set (make-local-variable 'flymake-allowed-file-name-masks)
       flymake-puppet-lint-allowed-file-name-masks)
  (set (make-local-variable 'flymake-err-line-patterns)
       flymake-puppet-lint-err-line-patterns)
  (if (executable-find flymake-puppet-lint-executable)
      (flymake-mode t)
    (message "not emabling flymake: executable '%s' not found"
             flymake-puppet-lint-executable)))
(provide 'flymake-puppet-lint)
