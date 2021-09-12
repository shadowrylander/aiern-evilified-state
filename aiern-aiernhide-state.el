;;; aiern-aiernhide-state.el --- A minimalistic aiern state
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; Keywords: convenience editing aiern spacemacs
;; Created: 22 Mar 2015
;; Version: 1.0
;; Package-Requires: ((aiern "1.0.9"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
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

;; Define a `aiernhide' aiern state inheriting from `emacs' state and
;; setting a minimalist list of Vim key bindings (like navigation, search, ...)

;; The shadowed original mode key bindings are automatically reassigned
;; following a set of rules:
;; Keys such as 
;; /,:,h,j,k,l,n,N,v,V,gg,G,C-f,C-b,C-d,C-e,C-u,C-y and C-z 
;; are working as in aiern.
;; Other keys will be moved according to this pattern:
;; a -> A -> C-a -> C-A
;; The first unreserved key will be used. 
;; There is an exception for g, which will be directly
;; bound to C-G, since G and C-g (latest being an important escape key in Emacs) 
;; are already being used.

;;; Code:

(require 'aiern)
(require 'bind-map)

(defvar aiernhide-state--aiern-surround nil
  "aiern surround mode variable backup.")
(make-variable-buffer-local 'aiernhide-state--aiern-surround)

(defvar aiernhide-state--normal-state-map nil
  "Local backup of normal state keymap.")
(make-variable-buffer-local 'aiernhide-state--normal-state-map)

(aiern-define-state aiernhide
  "aiernhide state.
 Hybrid `emacs state' with carrefully selected Vim key bindings.
 See spacemacs conventions for more info."
  :tag " <N'> "
  :enable (emacs)
  :message "-- aiernhide BUFFER --"
  :cursor box)

(bind-map spacemacs-default-map
  :prefix-cmd spacemacs-cmds
  :aiern-states (aiernhide)
  :override-minor-modes t)

(aiern-define-command aiern-force-aiernhide-state ()
  "Switch to aiernhide state without recording current command."
  :repeat abort
  :suppress-operator t
  (aiern-aiernhide-state))

(defun aiernhide-state--pre-command-hook ()
  "Redirect key bindings to `aiernhide-state'.
Needed to bypass keymaps set as text properties."
  (unless (bound-and-true-p isearch-mode)
    (when (memq aiern-state '(aiernhide visual))
      (let* ((map (get-char-property (point) 'keymap))
             (aiernhide-map (when map (cdr (assq 'aiernhide-state map))))
             (command (when (and aiernhide-map
                                 (eq 1 (length (this-command-keys))))
                        (lookup-key aiernhide-map (this-command-keys)))))
        (when command (setq this-command command))))))

(defun aiernhide-state--setup-normal-state-keymap ()
  "Setup the normal state keymap."
  (unless aiernhide-state--normal-state-map
    (setq-local aiernhide-state--normal-state-map
                (copy-keymap aiern-normal-state-map)))
  (setq-local aiern-normal-state-map
              (copy-keymap aiernhide-state--normal-state-map))
  (define-key aiern-normal-state-map [escape] 'aiern-aiernhide-state))

(defun aiernhide-state--restore-normal-state-keymap ()
  "Restore the normal state keymap."
  (setq-local aiern-normal-state-map aiernhide-state--normal-state-map))

(defun aiernhide-state--clear-normal-state-keymap ()
  "Clear the normal state keymap."
  (setq-local aiern-normal-state-map (cons 'keymap nil))
  (aiern-normalize-keymaps))

(defun aiernhide-state--setup-visual-state-keymap ()
  "Setup the normal state keymap."
  (setq-local aiern-visual-state-map
              (cons 'keymap (list (cons ?y 'aiern-yank)
                                  (cons 'escape 'aiern-exit-visual-state)))))

(defun aiernhide-state--aiernhide-state-on-entry ()
  "Setup aiernhide state."
  (when (derived-mode-p 'magit-mode)
    ;; Courtesy of aiern-magit package
    ;; without this set-mark-command activates visual-state which is just
    ;; annoying ;; and introduces possible bugs
    (remove-hook 'activate-mark-hook 'aiern-visual-activate-hook t))
  (when (bound-and-true-p aiern-surround-mode)
    (make-local-variable 'aiern-surround-mode)
    (aiern-surround-mode -1))
  (aiernhide-state--setup-normal-state-keymap)
  (aiernhide-state--setup-visual-state-keymap)
  (add-hook 'pre-command-hook 'aiernhide-state--pre-command-hook nil 'local)
  (add-hook 'aiern-visual-state-entry-hook
            'aiernhide-state--visual-state-on-entry nil 'local)
  (add-hook 'aiern-visual-state-exit-hook
            'aiernhide-state--visual-state-on-exit nil 'local))

(defun aiernhide-state--visual-state-on-entry ()
  "Setup visual state."
  ;; we need to clear temporarily the normal state keymap in order to reach
  ;; the mode keymap
  (when (eq 'aiernhide aiern-previous-state)
    (aiernhide-state--clear-normal-state-keymap)))

(defun aiernhide-state--visual-state-on-exit ()
  "Clean visual state"
  (aiernhide-state--restore-normal-state-keymap))

(add-hook 'aiern-aiernhide-state-entry-hook
          'aiernhide-state--aiernhide-state-on-entry)

;; default key bindings for all aiernhide buffers
(define-key aiern-aiernhide-state-map "/" 'aiern-search-forward)
(define-key aiern-aiernhide-state-map ":" 'aiern-ex)
(define-key aiern-aiernhide-state-map "h" 'aiern-backward-char)
(define-key aiern-aiernhide-state-map "j" 'aiern-next-visual-line)
(define-key aiern-aiernhide-state-map "k" 'aiern-previous-visual-line)
(define-key aiern-aiernhide-state-map "l" 'aiern-forward-char)
(define-key aiern-aiernhide-state-map "n" 'aiern-search-next)
(define-key aiern-aiernhide-state-map "N" 'aiern-search-previous)
(define-key aiern-aiernhide-state-map "v" 'aiern-visual-char)
(define-key aiern-aiernhide-state-map "V" 'aiern-visual-line)
(define-key aiern-aiernhide-state-map "gg" 'aiern-goto-first-line)
(define-key aiern-aiernhide-state-map "G" 'aiern-goto-line)
(define-key aiern-aiernhide-state-map (kbd "C-f") 'aiern-scroll-page-down)
(define-key aiern-aiernhide-state-map (kbd "C-b") 'aiern-scroll-page-up)
(define-key aiern-aiernhide-state-map (kbd "C-e") 'aiern-scroll-line-down)
(define-key aiern-aiernhide-state-map (kbd "C-y") 'aiern-scroll-line-up)
(define-key aiern-aiernhide-state-map (kbd "C-d") 'aiern-scroll-down)
(define-key aiern-aiernhide-state-map (kbd "C-u") 'aiern-scroll-up)
(define-key aiern-aiernhide-state-map (kbd "C-z") 'aiern-emacs-state)
(setq aiern-aiernhide-state-map-original (copy-keymap aiern-aiernhide-state-map))

;; old macro
;;;###autoload
(defmacro aiernhide-state-aiernhide (mode map &rest body)
  "Set `aiernhide state' as default for MODE.

BODY is a list of additional key bindings to apply for the given MAP in
`aiernhide state'."
  (let ((defkey (when body `(aiern-define-key 'aiernhide ,map ,@body))))
    `(progn (unless ,(null mode)
              (unless (or (bound-and-true-p holy-mode)
                          (eq 'aiernhide (aiern-initial-state ',mode)))
                (aiern-set-initial-state ',mode 'aiernhide)))
            (unless ,(null defkey) (,@defkey)))))
(put 'aiernhide-state-aiernhide 'lisp-indent-function 'defun)

;; new macro
;;;###autoload
(defmacro aiernhide-state-aiernhide-map (map &rest props)
  "aiernhide MAP.

Avaiblabe PROPS:

`:mode SYMBOL'
A mode SYMBOL associated with MAP. Used to add SYMBOL to the list of modes
defaulting to `aiernhide-state'.

`:aiernhide-map SYMBOL'
A map SYMBOL of an alternate aiernhide map, if nil then
`aiern-aiernhide-state-map' is used.

`:eval-after-load SYMBOL'
If specified the evilification of MAP is deferred to the loading of the feature
bound to SYMBOL. May be required for some lazy-loaded maps.

`:pre-bindings EXPRESSIONS'
One or several EXPRESSIONS with the form `KEY FUNCTION':
   KEY1 FUNCTION1
   KEY2 FUNCTION2
These bindings are set in MAP before the evilification happens.

`:bindings EXPRESSIONS'
One or several EXPRESSIONS with the form `KEY FUNCTION':
   KEY1 FUNCTION1
   KEY2 FUNCTION2
These bindings are set directly in aiern-aiernhide-state-map submap.
   ...
Each pair KEYn FUNCTIONn is defined in MAP after the evilification of it."
  (declare (indent 1))
  (let* ((mode (plist-get props :mode))
         (aiernhide-map (or (plist-get props :aiernhide-map)
                            'aiern-aiernhide-state-map-original))
         (eval-after-load (plist-get props :eval-after-load))
         (pre-bindings (aiernhide-state--mplist-get props :pre-bindings))
         (bindings (aiernhide-state--mplist-get props :bindings))
         (defkey (when bindings `(aiern-define-key 'aiernhide ,map ,@bindings)))
         (body
          (progn
            (aiernhide-state--define-pre-bindings map pre-bindings)
            `(
              ;; we need to work on a local copy of the aiernhide keymap to
              ;; prevent the original keymap from being mutated.
              (setq aiern-aiernhide-state-map (copy-keymap ,aiernhide-map))
              (let* ((sorted-map (aiernhide-state--sort-keymap
                                  aiern-aiernhide-state-map))
                    processed)
                (mapc (lambda (map-entry)
                        (unless (member (car map-entry) processed)
                          (setq processed (aiernhide-state--aiernhide-event
                                           ,map ',map aiern-aiernhide-state-map
                                           (car map-entry) (cdr map-entry)))))
                      sorted-map)
                (unless ,(null defkey)
                  (,@defkey)))
              (unless ,(null mode)
                (aiernhide-state--configure-default-state ',mode))))))
    (if (null eval-after-load)
        `(progn ,@body)
      `(with-eval-after-load ',eval-after-load (progn ,@body)))))
(put 'aiernhide-state-aiernhide-map 'lisp-indent-function 'defun)

(defun aiernhide-state--define-pre-bindings (map pre-bindings)
  "Define PRE-BINDINGS in MAP."
  (while pre-bindings
    (let ((key (pop pre-bindings))
          (func (pop pre-bindings)))
      (eval `(define-key ,map key ,func)))))

(defun aiernhide-state--configure-default-state (mode)
  "Configure default state for the passed mode."
  (aiern-set-initial-state mode 'aiernhide))

(defun aiernhide-state--aiernhide-event (map map-symbol aiern-map event aiern-value
                                           &optional processed pending-funcs)
  "aiernhide EVENT in MAP and return a list of PROCESSED events."
  (if (and event (or aiern-value pending-funcs))
      (let* ((kbd-event (kbd (single-key-description event)))
             (map-value (lookup-key map kbd-event))
             (aiern-value (or aiern-value
                             (lookup-key aiern-map kbd-event)
                             (car (pop pending-funcs)))))
        (when aiern-value
          (aiern-define-key 'aiernhide map kbd-event aiern-value))
        (when map-value
          (add-to-list 'pending-funcs (cons map-value event) 'append))
        (push event processed)
        (setq processed (aiernhide-state--aiernhide-event
                         map map-symbol aiern-map
                         (aiernhide-state--find-new-event event) nil
                         processed pending-funcs)))
    (when pending-funcs
      (spacemacs-buffer/warning
       (concat (format (concat "Auto-evilication could not remap these "
                               "functions in map `%s':\n")
                       map-symbol)
               (mapconcat (lambda (x)
                            (format "   - `%s' originally mapped on `%s'"
                                    (car x) (single-key-description (cdr x))))
                          pending-funcs "\n")))))
  processed)

(defun aiernhide-state--find-new-event (event)
  "Return a new event for the aiernhide EVENT."
  (when event
    (cond
     ((equal event ?\a) nil) ; C-g (cannot remap C-g)
     ((equal event 32) ?')   ; space
     ((equal event ?/) ?\\)
     ((equal event ?:) ?|)
     ((and (numberp event) (<= ?a event) (<= event ?z)) (- event 32))
     ((equal event ?G) (+ (expt 2 25) ?\a)) ; G is mapped directly to C-S-g
     ((and (numberp event) (<= ?A event) (<= event ?Z)) (- event 64))
     ((and (numberp event) (<= 1 event) (<= event 26)) (+ (expt 2 25) event)))))

(defun aiernhide-state--sort-keymap (map)
  "Sort MAP following the order: `s' > `S' > `C-s' > `C-S-s'"
  (let (list)
    (map-keymap (lambda (a b) (push (cons a b) list)) map)
    (sort list
          (lambda (a b)
            (setq a (car a) b (car b))
            (if (integerp a)
                (if (integerp b)
                    (if (and (< a 256) (< b 256))
                        (> a b)
                      (< a b))
                  t)
              (if (integerp b) nil
                (string< a b)))))))

(defun aiernhide-state--mplist-get (plist prop)
  "Get the values associated to PROP in PLIST, a modified plist.

A modified plist is one where keys are keywords and values are
all non-keywords elements that follow it.

If there are multiple properties with the same keyword, only the first property
and its values is returned.

Currently this function infloops when the list is circular."
  (let ((tail plist)
        result)
    (while (and (consp tail) (not (eq prop (car tail))))
      (pop tail))
    ;; pop the found keyword
    (pop tail)
    (while (and (consp tail) (not (keywordp (car tail))))
      (push (pop tail) result))
    (nreverse result)))

(provide 'aiern-aiernhide-state)

;;; aiern-aiernhide-state.el ends here
