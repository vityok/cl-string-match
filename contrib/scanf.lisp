;;; A trivial scanf implementation in Lisp

;; There are two ways to implement the scanf function:
;;
;;  1. Compile the format string into machine code and run this
;;     program on the input string(s)
;;
;;  2. Interpret directives from the format string on the fly
;;
;; The code in this file follows the 2nd way.

;; As a source of ideas and documentation following resources were
;; used:

;; FreeBSD scanf implementation can be viewed here:
;; https://github.com/freebsd/freebsd/blob/master/lib/libc/stdio/vfscanf.c
;; It goes char-after-char in the given format and dispatches current
;; action depending on the character read
;;
;; Man page is located here:
;; http://www.freebsd.org/cgi/man.cgi?query=scanf&sektion=3
;;
;; This Common Lisp implementation is influenced and uses some
;; documentation from the FreeBSD scanf that is:
;;
;; * Copyright (c) 1990, 1993
;; *	The Regents of the University of California.  All rights reserved.
;; *
;; * Copyright (c) 2011 The FreeBSD Foundation
;; * All rights reserved.
;; * Portions of this software were developed by David Chisnall
;; * under sponsorship from the FreeBSD Foundation.


(defpackage :trivial-scanf
  (:use :common-lisp :alexandria :iterate :proc-parse)
  (:nicknames :snf)
  (:documentation "A trivial scanf implementation in Common Lisp.")

  (:export
   :scanf))

;; --------------------------------------------------------

(in-package :trivial-scanf)

;; --------------------------------------------------------

(defun sscanf (fmt str &key (start 0) end))

(defun fscanf (fmt stream &key (start 0)))

(defun scanf (fmt str &key (start 0))
  "Parse the given string according to the fmt

Each returned value corresponds properly with each successive
conversion specifier (but see the * conversion below). All conversions
are introduced by the % (percent sign) character.

White space (such as blanks, tabs, or newlines) in the format string
match any amount of white space, including none, in the
input. Everything else matches only itself. Scanning stops when an
input character does not match such a format character. Scanning also
stops when an input conversion cannot be made (see below).

Following the % character introducing a conversion there may be a
number of flag characters, as follows:

 * Suppresses assignment.  The conversion that follows occurs as
   usual, but no pointer is used; the result of the conversion is
   simply discarded.

In addition to this flag, there may be an optional maximum field
width, expressed as a decimal integer, between the % and the
conversion. If no width is given, a default of ``infinity'' is
used (with one exception, below); otherwise at most this many bytes
are scanned in processing the conversion.

The following conversions are available:

 % Matches a literal `%'.  That is, ``%%'' in the format string
   matches a single input `%' character.  No conversion is done, and
   assignment does not occur.

 d Matches an optionally signed decimal integer; result is an int.

 i Matches an optionally signed integer.  The integer is read in base
   16 if it begins with `0x' or `0X', in base 8 if it begins with `0',
   and in base 10 otherwise.  Only characters that correspond to the
   base are used.

 o Matches an octal integer.

 u Matches an optionally signed decimal integer.

 x, X  Matches an optionally signed hexadecimal integer.

 a, A, e, E, f, F, g, G
   Matches a floating-point number in the style of strtod(3).

 s Matches a sequence of non-white-space characters The input string
   stops at white space or at the maximum field width, whichever
   occurs first.

 S The same as s.

 c Matches a sequence of width count characters (default 1) The usual
   skip of leading white space is suppressed. To skip white space
   first, use an explicit space in the format.

 C The same as c.

 [ Matches a nonempty sequence of characters from the specified set of
   accepted characters The usual skip of leading white space is
   suppressed.  The string is to be made up of characters in
   (or not in) a particular set; the set is defined by the characters
   between the open bracket [ character and a close bracket ]
   character.  The set excludes those characters if the first
   character after the open bracket is a circumflex ^.  To include a
   close bracket in the set, make it the first character after the
   open bracket or the circumflex; any other position will end the
   set.  The hyphen character - is also special; when placed between
   two other characters, it adds all intervening characters to the
   set.  To include a hyphen, make it the last character before the
   final close bracket.  For instance, `[^]0-9-]' means the set
   ``everything except close bracket, zero through nine, and hyphen''.
   The string ends with the appearance of a character not in the (or,
   with a circumflex, in) set or when the field width runs out.

 n Nothing is expected; instead, the number of characters consumed
   thus far from the input is stored in results list.  This is not a
   conversion, although it can be suppressed with the * flag.

"

  (let ((fmt-pos 0)
	(fmt-len (length fmt))
	(str-pos start)
	(results '()))
    (iter
      ;; todo: what if the string is too short?
      (while (< fmt-pos fmt-len))
      (for c = (char fmt fmt-pos))
      (case c
	;; directive
	(#\%
	 ;; todo: handle more directives
	 (incf fmt-pos)
	 (case (char fmt fmt-pos)
	   (#\d
	    ;; read and store a decimal integer
	    (multiple-value-bind (int end-pos)
		(parse-integer str :start str-pos :junk-allowed T)
	      (push int results)
	      (setf str-pos end-pos)))
	   (#\f
	    (error "not yet implemented"))
	   (#\c
	    ;; read and store a single character
	    (push (char str str-pos) results)
	    (incf str-pos))
	   (#\%
	    ;; handle '%' similar to an ordinary character,
	    (unless (char= #\% (char str str-pos))
	      (error "mismatch"))
	    (incf str-pos))
	   (otherwise
	    (error "invalid directive")))
	 ;; advance to the next format character
	 (incf fmt-pos))

	;; an ordinary character
	(otherwise
	 (unless (char= (char str str-pos)
			(char fmt fmt-pos))
	   (error "mismatch"))
	 (incf str-pos)
	 (incf fmt-pos))))

    (let ((rresults (reverse results)))

      (push str-pos rresults)
      rresults)))

;; EOF
