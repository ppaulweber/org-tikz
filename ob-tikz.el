;;; ob-tikz.el --- org-babel functions for tikz evaluation

;; Copyright (C) Philipp Paulweber

;; Author: Philipp Paulweber
;; Keywords: latex, tikz, svg
;; Homepage: http://orgmode.org
;; Version: 0.01

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.


(require 'ob)
(require 'ob-ref)
(require 'ob-comint)
(require 'ob-eval)

(defvar org-babel-default-header-args:tikz
  '((:results . "silent")
    (:exports . "results")
    )
  "Default arguments for evaluating a tikz source block.")

(defun org-babel-execute:tikz (body params)
  "Execute a block of tikz code with org-babel.
This function is called by `org-babel-execute-src-block'"
  (let* (
         (processed-params (org-babel-process-params params))
         (outfile
          (let ((el (cdr (assoc :file params))))
            (or el
                (error "tikz code block requires :file header argument"))))
         (latex (assoc :latex params))
         
         (tmppath (org-babel-temp-file "tikz-"))
         
         (texfile (org-babel-process-file-name (concat tmppath ".tex")))
         (dvifile (org-babel-process-file-name (concat tmppath ".dvi")))
         (svgfile (org-babel-process-file-name (concat tmppath ".svg")))

         (sfile (org-babel-process-file-name outfile))
         (tfile (org-babel-process-file-name (concat outfile ".tex")))
         
         (cmdtex2dvi (concat "latex -output-format=dvi " texfile))
         (cmddvi2svg (concat "dvisvgm " dvifile))
         )
    
    ;(print processed-params)
    ;(print outfile)
    ;(print latex)
    
    ; write data to texfile
    (with-temp-file texfile
      (insert
       (concat "\\documentclass{standalone}\n"
               "\\usepackage[utf8]{inputenc}\n"
               "\\usepackage{graphicx}\n"
               "\\usepackage{tabularx}\n"
               "\\usepackage{multirow}\n"
               "\\usepackage{subfiles}\n"
               "\\usepackage{setspace}\n"
               "\\usepackage[usenames,dvipsnames]{xcolor}\n"
               "\\usepackage{amsmath}\n"
               "\\usepackage{amssymb}\n"
               "\\usepackage{tikz}\n"
               "\\usetikzlibrary{shapes,arrows,calc,fit,matrix,positioning}\n"
               "\\usepackage{lmodern}\n"
               "\\usepackage[T1]{fontenc}\n"
               "\\begin{document}\n"
               (if (eq latex nil)
                   "\\begin{tikzpicture}\n"
                 "")
               body
               "\n"
               (if (eq latex nil)
                   "\\end{tikzpicture}\n"
                 "")
               "\\end{document}\n"
               )))
    
    (with-temp-file tfile
      (insert
       (concat "%% +++\n"
               body
               "\n"
               "%% ---\n"
               )))
    
    (let* ((default-directory tmppath)
          )
      (message cmdtex2dvi)(shell-command cmdtex2dvi)
      (message cmddvi2svg)(shell-command cmddvi2svg)
      nil
      )
    
    (copy-file svgfile sfile 'ok-if-already-exists)
    nil
  )
)

(defun org-babel-prep-session:tikz (session params)
  "Return an error because tikz does not support sessions."
  (error "tikz does not support sessions"))

(provide 'ob-tikz)

;;; ob-tikz.el ends here
