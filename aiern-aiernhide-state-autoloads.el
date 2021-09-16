;;; aiern-aiernhide-state-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "aiern-aiernhide-state" "aiern-aiernhide-state.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from aiern-aiernhide-state.el

(autoload 'aiernhide-state-aiernhide "aiern-aiernhide-state" "\
Set `aiernhide state' as default for MODE.

BODY is a list of additional key bindings to apply for the given MAP in
`aiernhide state'.

\(fn MODE MAP &rest BODY)" nil t)

(autoload 'aiernhide-state-aiernhide-map "aiern-aiernhide-state" "\
aiernhide MAP.

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
Each pair KEYn FUNCTIONn is defined in MAP after the evilification of it.

\(fn MAP &rest PROPS)" nil t)

(function-put 'aiernhide-state-aiernhide-map 'lisp-indent-function '1)

(register-definition-prefixes "aiern-aiernhide-state" '("aiernhide-state--"))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; aiern-aiernhide-state-autoloads.el ends here
