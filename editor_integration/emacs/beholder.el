;;; beholder.el - Beholders integration with emacs.
;;; Inspired by Ryan Davis' (Zen Spider) autotest.el

;; Copyright (C) 2009 by Aaron Bedra

;; Author: Aaron Bedra <aaron@aaronbedra.com>
;; Version 1.0
;; Keywords: testing, ruby, convenience, micronaut
;; Created: 01-09-2009
;; Compatibility: Emacs 22, 23
;; URL(en): http://github.com/abedra/beholder-emacs
;; by Aaron Bedra - aaron@aaronbedra.com

;;; The MIT License:

;; http://en.wikipedia.org/wiki/MIT_License
;;
;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject to
;; the following conditions:

;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
;; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
;; CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
;; TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
;; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

;; Sets up a beholder buffer and provides convenience methods.

(require 'shell)

(defcustom beholder-command "beholder"
  "Command name to use to execute beholder."
  :group 'beholder
  :type '(string))

(defun beholder ()
  "Fire up an instance of beholder in its own buffer with shell bindings and compile-mode highlighting and linking."
  (interactive)
  (let ((buffer (shell "*beholder*")))
    (define-key shell-mode-map "\C-c\C-a" 'beholder-switch)
    (comint-send-string buffer (concat beholder-command "\n"))))

(defun beholder-switch ()
  "Switch back and forth between beholder and the previous buffer"
  (interactive)
  (if (equal "*beholder*" (buffer-name))
      (switch-to-buffer (other-buffer))
    (switch-to-buffer "*beholder*")))

(provide 'beholder)

   