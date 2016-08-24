;;; hamburger-menu.el --- Mode line hamburger menu  -*- lexical-binding: t -*-

;; Copyright © 2016 Iain Nicol

;; Author: Iain Nicol
;; Maintainer: Iain Nicol
;; URL: https://gitlab.com/iain/hamburger-menu-mode
;; Version: 1.0.0
;; Keywords: hamburger, menu
;; Package-Requires: ((emacs "24.5"))

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; A minor mode which adds a hamburger menu button to the mode line.
;; Use instead of `menu-bar-mode' to save vertical space.
;;
;; Configure as follows:
;;
;;     M-x customize-set-variable RET global-hamburger-menu-mode RET y
;;     M-x customize-set-variable RET menu-bar-mode RET n
;;     M-x customize-save-customized
;;
;;; Change Log:
;;
;; Run `git log' in the repository.

;;; Code:

(require 'menu-bar)
(require 'mouse)
(require 'tmm)

(defconst hamburger-menu--indicator " ☰")

(defun hamburger-menu--obey-final-items (final-items keymap)
  "Return a keymap respecting FINAL-ITEMS, based upon KEYMAP.
This typically places the Help menu last, after menu items
specific to the major mode."
  ;; This method is borrowed from tmm.el.
  (let ((menu-bar '())
        (menu-end '()))
    (map-keymap
     (lambda (key binding)
       (push (cons key binding)
             ;; If KEY is the name of an item that we want to put last,
             ;; move it to the end.
             (if (memq key final-items)
                 menu-end
               menu-bar)))
     keymap)
    `(keymap
      ,@(reverse menu-bar)
      ,@(reverse menu-end))))

(defun hamburger-menu--minor-mode-menu-from-indicator--advice
    (overridden &rest args)
  "Override `minor-mode-menu-from-indicator', for the hamburger menu.
OVERRIDDEN is the underlying function
`minor-mode-menu-from-indicator', and ARGS are its arguments."
  (let ((indicator (car args)))
    (if (string-equal indicator hamburger-menu--indicator)
	(let* ((menu-main (tmm-get-keybind [menu-bar]))
	       (menu-main (hamburger-menu--obey-final-items
			   menu-bar-final-items menu-main))
	       (menu `(keymap (hamburger-menu-heading menu-item
						      "Hamburger Menu")
			      (sep-hamburger-menu "--")
			      ,menu-main)))
	  (popup-menu menu))
      (apply overridden args))))

(defun hamburger-menu--enable ()
  "Enable Hamburger Menu mode."
  (advice-add #'minor-mode-menu-from-indicator
	      :around
	      #'hamburger-menu--minor-mode-menu-from-indicator--advice)
  ;; Message is disabled because it behaved badly with the
  ;; minibuffer, interfering with completions.  To reproduce:
  ;;     C-h f advice- TAB
  ;; (message "Hamburger Menu enabled."))
  )

(defun hamburger-menu--disable ()
  "Disable Hamburger Menu mode."
  ;; Ideally we'd advice-remove.  But I'm not sure how to check
  ;; whether the advice is still needed for other buffers.

  ;; No message here because there's no corresponding message in
  ;; --enable.
  ;; (message "Hamburger Menu disabled."))
  )

;;;###autoload
(define-minor-mode hamburger-menu-mode
  "Mode which adds a hamburger menu button to the mode line."
  :lighter hamburger-menu--indicator
  (if hamburger-menu-mode
      (hamburger-menu--enable)
    (hamburger-menu--disable)))

(defun hamburger-menu-mode-on ()
  "Turn on, or keep turned on, Hamburger Menu mode."
  (hamburger-menu-mode 1))

;;;###autoload
(define-globalized-minor-mode
  global-hamburger-menu-mode
  hamburger-menu-mode hamburger-menu-mode-on)

(provide 'hamburger-menu)
;;; hamburger-menu.el ends here
