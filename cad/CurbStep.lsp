;;; ===========================================================================
;;; CurbStep.lsp  -  step off a base curb line using the FBK Checker curb DB
;;; ---------------------------------------------------------------------------
;;; Works in AutoCAD and Civil 3D (any version with Visual LISP).
;;;
;;; Load:   APPLOAD  ->  pick CurbStep.lsp  (or add it to the Startup Suite)
;;;
;;; Commands
;;;   CURBSTEP      Pick a curb database, type a curb code (R624, L612, RPARK,
;;;                 ...), select the base line(s) (back of curb or flow line),
;;;                 and it draws one 3D polyline per H/V step of that code,
;;;                 plus optional cross-section "ribs" at every vertex.
;;;   CURBSTEPLIST  List every code + template in a database.
;;;   CURBSTEPDB    Re-pick the folder that holds the *_db.txt files.
;;;
;;; Database files (same ones the FBK Checker app ships in /data):
;;;   back-of-curb_db.txt   flow-line_db.txt   std-curb_db.txt
;;;   knock-down-curb_db.txt
;;;   One code per line:  R624,H-0.5 V0.0 H-0.67 V-0.5 H-2.67 V-0.38
;;;   Edit those text files and the routine picks the change up next run.
;;;
;;; Geometry - identical convention to the FBK Checker app (offsetAt):
;;;   * Each H/V pair is ONE offset line. H = horizontal offset from the base
;;;     line (NOT cumulative), V = elevation difference from the base Z.
;;;   * +H = RIGHT of the line's drawing direction, -H = LEFT.
;;;     If a run comes out on the wrong side (line drawn backwards), answer
;;;     Yes to "Flip to other side?" at the end.
;;;   * Corners are mitered/extended (CAD OFFSETGAPTYPE=0), arcs/bulges are
;;;     sampled into short chords (max chord = CurbStep chord setting).
;;;   * Output = 3D polylines with real Z per vertex. In Civil 3D you can turn
;;;     them into feature lines with CREATEFEATURELINES.
;;;
;;; Layers:  CURB-<code>-L1, -L2, ...  (one per step)   CURB-<code>-XS (ribs)
;;; ===========================================================================

(vl-load-com)

(setq *cs-files*
  '(("Boc"       . "back-of-curb_db.txt")
    ("Flowline"  . "flow-line_db.txt")
    ("Std"       . "std-curb_db.txt")
    ("Knockdown" . "knock-down-curb_db.txt")))
(if (not *cs-dbkey*) (setq *cs-dbkey* "Boc"))
(if (not *cs-step*)  (setq *cs-step* 1.0))      ; max chord (drawing units) when sampling arcs
(if (not *cs-ribs*)  (setq *cs-ribs* "Yes"))
(if (not *cs-code*)  (setq *cs-code* "R624"))

;;; ---------------------------------------------------------------- strings --
(defun cs:trim (s) (vl-string-trim " \t\r\n" s))

(defun cs:split (s ch / i out)
  (setq out '())
  (while (setq i (vl-string-search ch s))
    (setq out (cons (substr s 1 i) out)
          s   (substr s (+ i 1 (strlen ch)))))
  (reverse (cons s out)))

;;; "H-0.5 V0.0 H-0.67 V-0.5" -> ((-0.5 . 0.0) (-0.67 . -0.5))
;;; Same rule as the app: H opens a step, the next V closes it.
(defun cs:parse-template (tmpl / steps ax val)
  (setq steps '())
  (foreach tok (vl-remove "" (cs:split (strcase (cs:trim tmpl)) " "))
    (setq ax  (substr tok 1 1)
          val (distof (substr tok 2) 2))
    (cond
      ((and val (= ax "H")) (setq steps (cons (list val 0.0 T) steps)))
      ((and val (= ax "V"))
       (if (and steps (caddr (car steps)))
         (setq steps (cons (list (car (car steps)) val nil) (cdr steps)))
         (setq steps (cons (list 0.0 val nil) steps))))))
  (mapcar '(lambda (s) (cons (car s) (cadr s))) (reverse steps)))

;;; --------------------------------------------------------------- database --
(defun cs:has-db (d)
  (and d (vl-file-directory-p d)
       (vl-some '(lambda (f) (findfile (strcat d "\\" (cdr f)))) *cs-files*)))

(defun cs:pickdir (/ f)
  (if (setq f (getfiled "Select any FBK curb database file (e.g. back-of-curb_db.txt)"
                        (if *cs-dbdir* (strcat *cs-dbdir* "\\") "") "txt" 0))
    (progn
      (setq *cs-dbdir* (vl-filename-directory f))
      (setenv "CurbStepDbDir" *cs-dbdir*)
      *cs-dbdir*)))

(defun cs:dbdir (/ d f)
  (cond
    ((cs:has-db *cs-dbdir*) *cs-dbdir*)
    ((cs:has-db (setq d (getenv "CurbStepDbDir"))) (setq *cs-dbdir* d))
    ((setq f (findfile "back-of-curb_db.txt")) (setq *cs-dbdir* (vl-filename-directory f)))
    ((and (setq f (findfile "CurbStep.lsp"))
          (cs:has-db (setq d (strcat (vl-filename-directory f) "\\..\\data"))))
     (setq *cs-dbdir* d))
    (T (cs:pickdir))))

;;; -> list of ("CODE" . "H.. V.. ...") in file order
(defun cs:read-db (key / dir path fh ln i db)
  (setq dir (cs:dbdir))
  (if (and dir (setq path (findfile (strcat dir "\\" (cdr (assoc key *cs-files*))))))
    (progn
      (setq fh (open path "r"))
      (while (setq ln (read-line fh))
        (setq ln (cs:trim ln))
        (if (and (/= ln "") (setq i (vl-string-search "," ln)))
          (setq db (cons (cons (strcase (cs:trim (substr ln 1 i)))
                               (cs:trim (substr ln (+ i 2))))
                         db))))
      (close fh)
      (reverse db))
    (progn
      (princ (strcat "\nCould not find " (cdr (assoc key *cs-files*))
                     (if dir (strcat " in " dir) "") ". Run CURBSTEPDB to pick the folder."))
      nil)))

(defun cs:list-db (db)
  (textscr)
  (princ "\n---- code ------ template ----------------------------------")
  (foreach r db (princ (strcat "\n  " (cs:pad (car r) 12) (cdr r))))
  (princ "\n------------------------------------------------------------\n"))

(defun cs:pad (s n) (while (< (strlen s) n) (setq s (strcat s " "))) s)

;;; --------------------------------------------------------------- geometry --
(defun cs:xy (p) (list (car p) (cadr p)))
(defun cs:mid2 (a b) (list (/ (+ (car a) (car b)) 2.0) (/ (+ (cadr a) (cadr b)) 2.0)))

;;; unit normal to the RIGHT of travel a->b (matches app: {E:dN/L, N:-dE/L})
(defun cs:perp (a b / dx dy l)
  (setq dx (- (car b) (car a))
        dy (- (cadr b) (cadr a))
        l  (sqrt (+ (* dx dx) (* dy dy))))
  (if (< l 1e-12) (setq l 1.0))
  (list (/ dy l) (/ (- dx) l)))

(defun cs:shift (p nrm h) (list (+ (car p) (* h (car nrm))) (+ (cadr p) (* h (cadr nrm)))))

;;; intersection of lines p+t*d and q+u*e (2D), nil if parallel
(defun cs:line-x (p d q e / den t1)
  (setq den (- (* (car d) (cadr e)) (* (cadr d) (car e))))
  (if (> (abs den) (* 1e-10 (distance '(0 0) d) (distance '(0 0) e)))
    (progn
      (setq t1 (/ (- (* (- (car q) (car p)) (cadr e)) (* (- (cadr q) (cadr p)) (car e))) den))
      (list (+ (car p) (* t1 (car d))) (+ (cadr p) (* t1 (cadr d)))))))

;;; offset point at vertex k, mitered/extended at a corner (port of app offsetAt)
(defun cs:offset-pt (pts k h closed / n a b c n1 n2 x)
  (setq n (length pts)
        b (nth k pts)
        a (cond ((> k 0) (nth (1- k) pts)) (closed (nth (1- n) pts)))
        c (cond ((< k (1- n)) (nth (1+ k) pts)) (closed (nth 0 pts))))
  (cond
    ((and a c)
     (setq n1 (cs:perp a b)
           n2 (cs:perp b c)
           x  (cs:line-x (cs:shift a n1 h) (list (- (car b) (car a)) (- (cadr b) (cadr a)))
                         (cs:shift b n2 h) (list (- (car c) (car b)) (- (cadr c) (cadr b)))))
     ;; straight-through or near-reversal (runaway miter) -> plain perpendicular
     (if (and x (<= (distance (cs:xy b) x) (max (* 10.0 (abs h)) 1e-9)))
       x
       (cs:shift b n1 h)))
    (a (cs:shift b (cs:perp a b) h))
    (c (cs:shift b (cs:perp b c) h))
    (T (cs:xy b))))

;;; drop consecutive duplicate points, keeping the "real vertex" flag
(defun cs:dedupe (lst / out)
  (foreach p lst
    (if (and out (< (distance (cs:xy (car p)) (cs:xy (car (car out)))) 1e-6))
      (setq out (cons (cons (car (car out)) (or (cdr p) (cdr (car out)))) (cdr out)))
      (setq out (cons p out))))
  (reverse out))

;;; -> (closed . ((pt . isRealVertex) ...)) ; arcs/bulges sampled into chords
(defun cs:curve-pts (e / typ p0 p1 i j k n pa pb pm len tot out closed)
  (setq typ    (cdr (assoc 0 (entget e)))
        p0     (vlax-curve-getStartParam e)
        p1     (vlax-curve-getEndParam e)
        closed (vlax-curve-isClosed e)
        out    '())
  (cond
    ((= typ "LINE")
     (setq out (list (cons (vlax-curve-getEndPoint e) T)
                     (cons (vlax-curve-getStartPoint e) T))))
    ((member typ '("LWPOLYLINE" "POLYLINE"))
     (setq i p0
           out (list (cons (vlax-curve-getPointAtParam e p0) T)))
     (while (< (+ i 1e-9) p1)
       (setq j  (min p1 (+ i 1.0))
             pa (vlax-curve-getPointAtParam e i)
             pb (vlax-curve-getPointAtParam e j)
             pm (vlax-curve-getPointAtParam e (/ (+ i j) 2.0)))
       (if (> (distance (cs:xy pm) (cs:mid2 pa pb)) 1e-4)          ; bulge / arc segment
         (progn
           (setq len (- (vlax-curve-getDistAtParam e j) (vlax-curve-getDistAtParam e i))
                 n   (max 4 (min 360 (fix (+ 0.999 (/ len *cs-step*)))))
                 k   1)
           (while (< k n)
             (setq out (cons (cons (vlax-curve-getPointAtParam e (+ i (* (- j i) (/ (float k) n)))) nil) out)
                   k   (1+ k)))))
       (setq out (cons (cons pb T) out)
             i   j)))
    (T                                                              ; ARC, SPLINE, CIRCLE, ELLIPSE ...
     (setq tot (vlax-curve-getDistAtParam e p1)
           n   (max 8 (min 2000 (fix (+ 0.999 (/ tot *cs-step*)))))
           k   0)
     (while (<= k n)
       (setq out (cons (cons (if (= k n)
                                 (vlax-curve-getEndPoint e)
                                 (vlax-curve-getPointAtDist e (* tot (/ (float k) n))))
                             (or (= k 0) (= k n)))
                       out)
             k   (1+ k)))))
  (setq out (vl-remove-if '(lambda (r) (null (car r))) (cs:dedupe (reverse out))))
  (if (and closed (> (length out) 2)
           (< (distance (cs:xy (car (car out))) (cs:xy (car (last out)))) 1e-6))
    (setq out (reverse (cdr (reverse out)))))
  (cons closed out))

;;; ----------------------------------------------------------------- output --
(defun cs:layer (name color)
  (if (not (tblsearch "LAYER" name))
    (entmake (list '(0 . "LAYER") '(100 . "AcDbSymbolTableRecord") '(100 . "AcDbLayerTableRecord")
                   (cons 2 name) '(70 . 0) (cons 62 color) '(6 . "Continuous"))))
  name)

(defun cs:make-3dpoly (pts lay closed)
  (entmake (list '(0 . "POLYLINE") '(100 . "AcDbEntity") (cons 8 lay)
                 '(100 . "AcDb3dPolyline") '(66 . 1) '(10 0.0 0.0 0.0)
                 (cons 70 (if closed 9 8))))
  (foreach p pts
    (entmake (list '(0 . "VERTEX") '(100 . "AcDbEntity") (cons 8 lay)
                   '(100 . "AcDbVertex") '(100 . "AcDb3dPolylineVertex")
                   (cons 10 p) '(70 . 32))))
  (entmake (list '(0 . "SEQEND") '(100 . "AcDbEntity") (cons 8 lay)))
  (entlast))

(setq *cs-colors* '(3 4 5 6 1 2 30 140))

;;; build every step line (+ ribs) for one base entity; sgn = 1 or -1 (flip)
(defun cs:build (ent steps code ribs sgn / data closed samp pts flags z lanes li made k rib)
  (setq data   (cs:curve-pts ent)
        closed (car data)
        samp   (cdr data)
        pts    (mapcar 'car samp)
        flags  (mapcar 'cdr samp)
        made   '()
        li     0)
  (if (< (length pts) 2)
    (progn (princ "\n  skipped: base line has fewer than 2 points.") nil)
    (progn
      ;; one 3D polyline per H/V step
      (setq lanes
        (mapcar
          '(lambda (st / k o out)
             (setq k 0 out '())
             (foreach p pts
               (setq o   (cs:offset-pt pts k (* sgn (car st)) closed)
                     z   (if (caddr p) (caddr p) 0.0)
                     out (cons (list (car o) (cadr o) (+ z (cdr st))) out)
                     k   (1+ k)))
             (reverse out))
          steps))
      (foreach ln lanes
        (setq li   (1+ li)
              made (cons (cs:make-3dpoly ln
                                         (cs:layer (strcat "CURB-" code "-L" (itoa li))
                                                   (nth (rem (1- li) (length *cs-colors*)) *cs-colors*))
                                         closed)
                         made)))
      ;; cross-section ribs at the base line's real vertices: base -> step1 -> step2 ...
      (if (= ribs "Yes")
        (progn
          (setq k 0)
          (foreach p pts
            (if (nth k flags)
              (progn
                (setq rib (cons (list (car p) (cadr p) (if (caddr p) (caddr p) 0.0))
                                (mapcar '(lambda (ln) (nth k ln)) lanes)))
                (setq made (cons (cs:make-3dpoly rib (cs:layer (strcat "CURB-" code "-XS") 8) nil) made))))
            (setq k (1+ k)))))
      made)))

;;; --------------------------------------------------------------- commands --
(defun cs:lookup-code (db / s tmpl done)
  (while (not done)
    (setq s (strcase (cs:trim (getstring (strcat "\nCurb code (? = list, or type an H/V template) <"
                                                 *cs-code* ">: ")))))
    (if (= s "") (setq s *cs-code*))
    (cond
      ((= s "?") (cs:list-db db))
      ((setq tmpl (cdr (assoc s db)))
       (setq *cs-code* s done (cons s tmpl)))
      ((and (wcmatch s "H*,V*") (cs:parse-template s))
       (setq done (cons "CUSTOM" s)))
      (T (princ (strcat "\n\"" s "\" is not in this database. Type ? to list codes.")))))
  done)                                   ; -> ("CODE" . "template")

(defun c:CURBSTEP (/ *error* doc opt db tmpl code steps ss i ent typ made ents sgn ans cnt)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (defun *error* (msg)
    (vla-EndUndoMark doc)
    (if (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*,*EXIT*")) (princ (strcat "\nCURBSTEP error: " msg)))
    (princ))

  (initget "Boc Flowline Std Knockdown")
  (if (setq opt (getkword (strcat "\nCurb database [Boc/Flowline/Std/Knockdown] <" *cs-dbkey* ">: ")))
    (setq *cs-dbkey* opt))
  (if (not (setq db (cs:read-db *cs-dbkey*))) (exit))

  (setq tmpl  (cs:lookup-code db)
        code  (car tmpl)
        tmpl  (cdr tmpl)
        steps (cs:parse-template tmpl))
  (if (not steps) (progn (princ "\nTemplate has no H/V steps.") (exit)))
  (princ (strcat "\n" code " = " tmpl "  (" (itoa (length steps)) " offset line"
                 (if (> (length steps) 1) "s" "") ")"))

  (initget "Yes No")
  (if (setq opt (getkword (strcat "\nDraw cross-section ribs at vertices? [Yes/No] <" *cs-ribs* ">: ")))
    (setq *cs-ribs* opt))
  (initget 6)
  (if (setq opt (getdist (strcat "\nMax chord length on arcs <" (rtos *cs-step* 2 2) ">: ")))
    (setq *cs-step* opt))

  (princ "\nSelect base curb line(s) (polyline / 3D polyline / line / arc / spline): ")
  (if (not (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE,LINE,ARC,SPLINE,CIRCLE,ELLIPSE")))))
    (exit))
  (setq i 0 ents '())
  (while (< i (sslength ss))
    (setq ent (ssname ss i) i (1+ i))
    ;; skip polyface/polygon meshes (POLYLINE flags 16/64)
    (if (not (and (= (cdr (assoc 0 (entget ent))) "POLYLINE")
                  (/= 0 (logand 80 (cdr (assoc 70 (entget ent)))))))
      (setq ents (cons ent ents))))

  (vla-StartUndoMark doc)
  (setq sgn 1 ans "Yes")
  (while (= ans "Yes")
    (foreach m made (if (entget m) (entdel m)))
    (setq made '())
    (foreach ent ents (setq made (append (cs:build ent steps code *cs-ribs* sgn) made)))
    (setq cnt (length made))
    (princ (strcat "\nCreated " (itoa cnt) " 3D polyline(s) on layers CURB-" code "-*."))
    (initget "Yes No")
    (setq ans (getkword "\nFlip to other side? [Yes/No] <No>: "))
    (if (= ans "Yes") (setq sgn (- sgn))))
  (vla-EndUndoMark doc)
  (princ))

(defun c:CURBSTEPLIST (/ opt db)
  (initget "Boc Flowline Std Knockdown")
  (if (setq opt (getkword (strcat "\nList which database [Boc/Flowline/Std/Knockdown] <" *cs-dbkey* ">: ")))
    (setq *cs-dbkey* opt))
  (if (setq db (cs:read-db *cs-dbkey*)) (cs:list-db db))
  (princ))

(defun c:CURBSTEPDB ()
  (if (cs:pickdir) (princ (strcat "\nCurb databases folder: " *cs-dbdir*)))
  (princ))

(princ "\nCurbStep loaded.  Commands: CURBSTEP, CURBSTEPLIST, CURBSTEPDB")
(princ)
