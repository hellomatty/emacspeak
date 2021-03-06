;;; emacspeak-python.el --- Speech enable Python development environment
;;; $Id$
;;; $Author: tv.raman.tv $ 
;;; Description: Auditory interface to python mode
;;; Keywords: Emacspeak, Speak, Spoken Output, python
;;{{{  LCD Archive entry: 

;;; LCD Archive Entry:
;;; emacspeak| T. V. Raman |raman@cs.cornell.edu 
;;; A speech interface to Emacs |
;;; $Date: 2007-08-25 18:28:19 -0700 (Sat, 25 Aug 2007) $ |
;;;  $Revision: 4532 $ | 
;;; Location undetermined
;;;

;;}}}
;;{{{  Copyright:

;;; Copyright (c) 1995 -- 2015, T. V. Raman
;;; All Rights Reserved. 
;;;
;;; This file is not part of GNU Emacs, but the same permissions apply.
;;;
;;; GNU Emacs is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2, or (at your option)
;;; any later version.
;;;
;;; GNU Emacs is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Emacs; see the file COPYING.  If not, write to
;;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;{{{ Introduction

;;; Commentary:

;;; This speech-enables python-mode available on sourceforge and ELPA

;;; Code:

;;}}}
;;{{{  Required modules
(require 'cl)
(require 'emacspeak-preamble)
(eval-when-compile
  (require 'python-mode "python-mode" 'no-error))
;;}}}
;;{{{  electric editing

(unless (and (boundp 'post-self-insert-hook)
             post-self-insert-hook
             (memq 'emacspeak-post-self-insert-hook post-self-insert-hook))
  (defadvice py-electric-comment (after emacspeak pre act comp)
    "Speak what you inserted"
    (when (ems-interactive-p )
      (dtk-say " pound "))))

(unless (and (boundp 'post-self-insert-hook)
             post-self-insert-hook
             (memq 'emacspeak-post-self-insert-hook post-self-insert-hook))
  (defadvice py-electric-colon (after emacspeak pre act comp)
    "Speak what you inserted")
  (when (ems-interactive-p )
    (dtk-say " colon ")))

(defadvice py-electric-backspace (around emacspeak pre act)
  "Speak character you're deleting."
  (cond
   ((ems-interactive-p  )
    (dtk-tone 500 30 'force)
    (emacspeak-speak-this-char (preceding-char ))
    ad-do-it)
   (t ad-do-it))
  ad-return-value)

(defadvice py-electric-delete (around emacspeak pre act)
  "Speak character you're deleting."
  (cond
   ((ems-interactive-p  )
    (dtk-tone 500 30 'force)
    (emacspeak-speak-this-char (preceding-char ))
    ad-do-it)
   (t ad-do-it))
  ad-return-value)

;;}}}
;;{{{ interactive programming

(defadvice py-shell (after emacspeak pre act comp)
  "Provide auditory feedback"
  (when (ems-interactive-p )
    (emacspeak-auditory-icon 'select-object)
    (emacspeak-speak-mode-line)))

(defadvice py-clear-queue (after emacspeak pre act comp)
  "Provide auditory feedback"
  (when (ems-interactive-p )
    (emacspeak-auditory-icon 'task-done)))

(defadvice py-execute-region (after emacspeak pre act comp)
  "Provide auditory feedback"
  (when (ems-interactive-p )
    (emacspeak-auditory-icon 'task-done)))

(defadvice py-execute-buffer (after emacspeak pre act comp)
  "Provide auditory feedback"
  (when (ems-interactive-p )
    (emacspeak-auditory-icon 'task-done)))

(defadvice py-goto-exception(after emacspeak pre act comp)
  "Speak line you moved to"
  (when (ems-interactive-p )
    (emacspeak-auditory-icon 'large-movement)
    (emacspeak-speak-line)))

(defadvice py-down-exception(after emacspeak pre act comp)
  "Speak line you moved to"
  (when (ems-interactive-p )
    (emacspeak-auditory-icon 'large-movement)
    (emacspeak-speak-line)))

(defadvice py-up-exception(after emacspeak pre act comp)
  "Speak line you moved to"
  (when (ems-interactive-p )
    (emacspeak-auditory-icon 'large-movement)
    (emacspeak-speak-line)))

;;}}}
;;{{{  whitespace management and indentation

(loop
 for f in
 (list 'py-fill-paragraph 'py-fill-comment 'py-fill-string)
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "Provide auditory feedback."
     (when (ems-interactive-p )
       (emacspeak-auditory-icon 'fill-object)))))

(defadvice py-newline-and-indent(after emacspeak pre act comp)
  "Speak line so we know current indentation"
  (when (ems-interactive-p )
    (dtk-speak-using-voice voice-annotate
                           (format
                            "indent %s"
                            (current-column)))
    (dtk-force)))

(defadvice py-shift-region-left (after emacspeak pre act comp)
  "Speak number of lines that were shifted"
  (when (ems-interactive-p )
    (emacspeak-auditory-icon 'large-movement)
    (dtk-speak
     (format "Left shifted block  containing %s lines"
             (count-lines  (region-beginning)
                           (region-end))))))

(defadvice py-shift-region-right (after emacspeak pre act comp)
  "Speak number of lines that were shifted"
  (when (ems-interactive-p )
    (dtk-speak
     (format "Right shifted block  containing %s lines"
             (count-lines  (region-beginning)
                           (region-end))))))

(defadvice py-indent-region (after emacspeak pre act comp)
  "Speak number of lines that were shifted"
  (when (ems-interactive-p )
    (emacspeak-auditory-icon 'large-movement)
    (dtk-speak
     (format "Indented region   containing %s lines"
             (count-lines  (region-beginning)
                           (region-end))))))

(defadvice py-comment-region (after emacspeak pre act comp)
  "Speak number of lines that were shifted"
  (when (ems-interactive-p )
    (dtk-speak
     (format "Commented  block  containing %s lines"
             (count-lines  (region-beginning)
                           (region-end))))))

;;}}}
;;{{{  buffer navigation
(loop
 for f in
 '(
   py-down py-up
           py-backward-statement py-forward-statement
           py-goto-block-up  py-go-to-beginning-of-comment
           py-beginning-of-statement py-end-of-statement
           py-beginning-of-block py-end-of-block
           py-beginning-of-clause py-end-of-clause
           py-next-statement py-previous-statement
           py-beginning-of-def-or-class py-end-of-def-or-class)
 do                  
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "Speak current statement after moving"
     (when (ems-interactive-p )
       (emacspeak-speak-line)
       (emacspeak-auditory-icon 'large-movement)))))

(loop
 for  f in
 '(
   py-mark-class-bol py-mark-clause py-mark-clause-bol py-mark-comment
                     py-mark-comment-bol py-mark-def py-mark-def-bol
                     py-mark-def-or-class py-mark-def-or-class-bol py-mark-except-block
                     py-mark-except-block-bol py-mark-expression py-mark-expression-bol
                     py-mark-if-block py-mark-if-block-bol py-mark-line py-mark-line-bol
                     py-mark-minor-block py-mark-minor-block-bol py-mark-paragraph
                     py-mark-paragraph-bol py-mark-partial-expression
                     py-mark-partial-expression-bol py-mark-section py-mark-statement
                     py-mark-statement-bol py-mark-top-level py-mark-top-level-bol
                     py-mark-try-block py-mark-try-block-bol )                 
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "Speak number of lines marked"
     (when (ems-interactive-p )
       (dtk-speak
        (format
         "Marked block containing %s lines"
         (count-lines (region-beginning) (region-end))))
       (emacspeak-auditory-icon 'mark-object)))))

(loop
 for f in
 '(

   Possible completions are:
            py-narrow-to-block  py-narrow-to-block-or-clause    py-narrow-to-class
            py-narrow-to-clause         py-narrow-to-def        py-narrow-to-def-or-class
            py-narrow-to-statement
            )
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "Provide auditory feedback."
     (when (ems-interactive-p )
       (message "Narrowed  %s lines"
                (count-lines (point-min) (point-max)))))))

(defadvice py-mark-def-or-class (after emacspeak pre act comp)
  "Speak number of lines marked"
  (when (ems-interactive-p )
    (dtk-speak
     (format "Marked block containing %s lines"
             (count-lines (region-beginning)
                          (region-end))))
    (emacspeak-auditory-icon 'mark-object)))

(defadvice py-forward-into-nomenclature(after emacspeak pre act comp)
  "Speak rest of current word"
  (when (ems-interactive-p )
    (emacspeak-speak-word 1)))

(defadvice py-backward-into-nomenclature(after emacspeak pre act comp)
  "Speak rest of current word"
  (when (ems-interactive-p )
    (emacspeak-speak-word 1)))

;;}}}
;;{{{ the process buffer

(defadvice py-process-filter (around emacspeak pre act)
  "Make comint in Python speak its output. "
  (declare (special emacspeak-comint-autospeak))
  (let ((prior (point ))
        (dtk-stop-immediately nil))
    ad-do-it 
    (when (and  emacspeak-comint-autospeak
                (window-live-p
                 (get-buffer-window (process-buffer (ad-get-arg 0)))))
      (condition-case nil
          (emacspeak-speak-region prior (point ))
        (error (emacspeak-auditory-icon 'scroll)
               (dtk-stop ))))
    ad-return-value))

;;}}}

;;{{{ Voice Mappings:
(voice-setup-add-map
 '(
   (py-number-face voice-lighten)
   (py-XXX-tag-face voice-animate)
   (py-pseudo-keyword-face voice-bolden-medium)
   (py-variable-name-face  emacspeak-voice-lock-variable-name-personality)
   (py-decorators-face voice-lighten)
   (py-builtins-face emacspeak-voice-lock-builtin-personality)
   (py-class-name-face voice-bolden-extra)
   (py-exception-name-face emacspeak-voice-lock-warning-personality)))

;;}}}
(provide 'emacspeak-py )
;;{{{ end of file 

;;; local variables:
;;; folded-file: t
;;; byte-compile-dynamic: nil
;;; end: 

;;}}}
