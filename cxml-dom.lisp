;;;;  HTML5 parser for Common Lisp
;;;;
;;;;  Copyright (C) 2012 Thomas Bakketun <thomas.bakketun@copyleft.no>
;;;;  Copyright (C) 2012 Asgeir Bjørlykke <asgeir@copyleft.no>
;;;;  Copyright (C) 2012 Mathias Hellevang
;;;;  Copyright (C) 2012 Stian Sletner <stian@copyleft.no>
;;;;
;;;;  This library is free software: you can redistribute it and/or modify
;;;;  it under the terms of the GNU Lesser General Public License as published
;;;;  by the Free Software Foundation, either version 3 of the License, or
;;;;  (at your option) any later version.
;;;;
;;;;  This library is distributed in the hope that it will be useful,
;;;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;;;  GNU General Public License for more details.
;;;;
;;;;  You should have received a copy of the GNU General Public License
;;;;  along with this library.  If not, see <http://www.gnu.org/licenses/>.

(in-package #:html5-parser)

(defun node-to-cxml-dom (node &optional (document (make-instance 'cxml-dom::document)))
  (ecase (node-type node)
    (:document
     (let (root)
       (element-map-children (lambda (n)
                               (when (string= (node-name n) "html")
                                 (setf root n)))
                             node)
       (assert root)
       (node-to-cxml-dom root document)))
    (:fragment
     (let ((fragment (dom:create-document-fragment document)))
       (element-map-children (lambda (node)
                               (dom:append-child fragment (node-to-cxml-dom node document)))
                             node)
       fragment))
    (:element
     (let ((element (dom:create-element document (node-name node))))
              
       (element-map-attributes (lambda (name namespace value)
                                 (declare (ignore namespace))
                                 (dom:set-attribute element name value))
                               node)
       (element-map-children (lambda (c)
                               (dom:append-child element (node-to-cxml-dom c document)))
                             node)
       element))
    (:text
     (dom:create-text-node document (node-value node)))
    (:comment
     (dom:create-comment document (node-value node)))))

(defmethod transform-html5-dom ((to-type (eql :cxml-dom)) node)
  (node-to-cxml-dom node))
