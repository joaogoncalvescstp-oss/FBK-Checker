;;; ===========================================================================
;;; CurbStep.lsp  -  step off curb lines from the FBK Checker curb database
;;; ---------------------------------------------------------------------------
;;; AutoCAD / Civil 3D (any version with Visual LISP).  Single file - the curb
;;; database is BUILT IN (see the DATABASE block at the bottom), nothing else
;;; to install.
;;;
;;; Load:   APPLOAD -> CurbStep.lsp   (add to the Startup Suite to always load)
;;;
;;; CURBSTEP
;;;   1. Popup window: pick the database (Back of curb / Flow line / Std /
;;;      Knockdown) and the curb type.  The window shows every offset step.
;;;   2. Select the base line: LINE, POLYLINE, 3D POLYLINE, LWPOLYLINE, ARC,
;;;      SPLINE, Civil 3D FEATURE LINE or ALIGNMENT.
;;;   3. Pick a point on the side the curb steps toward (the side of the
;;;      outermost / gutter line).
;;;   4. Keep selecting more base lines with the same curb type; Enter = done.
;;; CURBSTEPLIST   list the built-in database in the text window.
;;;
;;; Geometry (same rules as the FBK Checker app's offsetAt):
;;;   * Each H/V pair is one offset line: H = horizontal offset from the base
;;;     line (not cumulative), V = elevation difference from the base Z.
;;;   * The picked side decides the direction: the step with the largest |H|
;;;     goes toward the picked point, every other step keeps its sign relative
;;;     to it (so flow-line codes with a back-of-curb step behind the base
;;;     still come out right).
;;;   * Corners are mitered/extended (OFFSETGAPTYPE=0); arcs are sampled into
;;;     short chords.
;;;   * Output: 3D polylines with real Z on layers CURB-<code>-L1, -L2, ...
;;;     and cross-section ribs on CURB-<code>-XS.  In Civil 3D, run
;;;     CREATEFEATURELINES on them if you want feature lines.
;;;   * Alignments have no elevation, so you are asked for a base elevation.
;;;
;;; To change the database: edit data/*_db.txt in the FBK-Checker repo and
;;; run  python3 cad/embed_db.py  - it rewrites the DATABASE block below.
;;; ===========================================================================

(vl-load-com)

(if (not *cs-dbkey*) (setq *cs-dbkey* "Boc"))
(if (not *cs-code*)  (setq *cs-code* "R624"))
(if (not *cs-step*)  (setq *cs-step* 0.5))     ; max chord (drawing units) on arcs
(if (not *cs-ribs*)  (setq *cs-ribs* T))
(if (not *cs-alz*)   (setq *cs-alz* 0.0))      ; base elevation used for alignments

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
(defun cs:db-rows (key) (caddr (assoc key *cs-db*)))
(defun cs:db-keys () (mapcar 'car *cs-db*))
(defun cs:db-labels () (mapcar 'cadr *cs-db*))
(defun cs:pad (s n) (while (< (strlen s) n) (setq s (strcat s " "))) s)

(defun cs:list-db (key)
  (textscr)
  (princ (strcat "\n---- " (cadr (assoc key *cs-db*)) " ----"))
  (foreach r (cs:db-rows key) (princ (strcat "\n  " (cs:pad (car r) 10) (cdr r))))
  (princ "\n"))

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

(defun cs:ok (fn args) (not (vl-catch-all-error-p (vl-catch-all-apply fn args))))

;;; sample by vertex parameter (polylines, feature lines): exact corners, arcs chorded
(defun cs:sample-params (e p0 p1 / i j k n pa pb pm len out)
  (setq i p0
        out (list (cons (vlax-curve-getPointAtParam e p0) T)))
  (while (< (+ i 1e-9) p1)
    (setq j  (min p1 (+ i 1.0))
          pa (vlax-curve-getPointAtParam e i)
          pb (vlax-curve-getPointAtParam e j)
          pm (vlax-curve-getPointAtParam e (/ (+ i j) 2.0)))
    (if (and pa pb pm (> (distance (cs:xy pm) (cs:mid2 pa pb)) 1e-4))      ; arc segment
      (progn
        (setq len (- (vlax-curve-getDistAtParam e j) (vlax-curve-getDistAtParam e i))
              n   (max 4 (min 360 (fix (+ 0.999 (/ len *cs-step*)))))
              k   1)
        (while (< k n)
          (setq out (cons (cons (vlax-curve-getPointAtParam e (+ i (* (- j i) (/ (float k) n)))) nil) out)
                k   (1+ k)))))
    (if pb (setq out (cons (cons pb T) out)))
    (setq i j))
  (reverse out))

;;; sample by distance (arcs, splines, alignments)
(defun cs:sample-dist (e / tot n k out)
  (setq tot (vlax-curve-getDistAtParam e (vlax-curve-getEndParam e))
        n   (max 8 (min 5000 (fix (+ 0.999 (/ tot *cs-step*)))))
        k   0)
  (while (<= k n)
    (setq out (cons (cons (if (= k n)
                              (vlax-curve-getEndPoint e)
                              (vlax-curve-getPointAtDist e (* tot (/ (float k) n))))
                          (or (= k 0) (= k n)))
                    out)
          k   (1+ k)))
  (reverse out))

;;; feature line fallback when vlax-curve is not available on it
(defun cs:featureline-pts (e / obj r arr lst out)
  (setq obj (vlax-ename->vla-object e))
  (foreach mode '(3 1)                                  ; all points, then PIs only
    (if (null arr)
      (progn
        (setq r (vl-catch-all-apply 'vlax-invoke (list obj 'GetPoints mode)))
        (if (not (vl-catch-all-error-p r)) (setq arr r)))))
  (setq lst (if (= (type arr) 'VARIANT) (vlax-safearray->list (vlax-variant-value arr)) arr))
  (while (>= (length lst) 3)
    (setq out (cons (cons (list (car lst) (cadr lst) (caddr lst)) T) out)
          lst (cdddr lst)))
  (reverse out))

;;; -> (closed . ((pt . isRealVertex) ...)) or nil
(defun cs:curve-pts (e / typ p0 p1 out closed)
  (setq typ (cdr (assoc 0 (entget e))))
  (cond
    ((not (cs:ok 'vlax-curve-getEndParam (list e)))
     (if (= typ "AECC_FEATURE_LINE")
       (setq out (cs:featureline-pts e) closed nil)))
    ((= typ "LINE")
     (setq out (list (cons (vlax-curve-getStartPoint e) T)
                     (cons (vlax-curve-getEndPoint e) T))))
    (T
     (setq p0     (vlax-curve-getStartParam e)
           p1     (vlax-curve-getEndParam e)
           closed (vlax-curve-isClosed e)
           out    (if (and (member typ '("LWPOLYLINE" "POLYLINE" "AECC_FEATURE_LINE"))
                           (< (- p1 p0) 20000))
                    (cs:sample-params e p0 p1)
                    (cs:sample-dist e)))))
  (setq out (vl-remove-if '(lambda (r) (null (car r))) (cs:dedupe out)))
  (if (and closed (> (length out) 2)
           (< (distance (cs:xy (car (car out))) (cs:xy (car (last out)))) 1e-6))
    (setq out (reverse (cdr (reverse out)))))
  (if (> (length out) 1) (cons closed out)))

;;; +1 if pt is RIGHT of the line's travel direction, -1 if left (nearest segment)
(defun cs:side-of (pts closed pt / segs best a b dx dy l2 tt q d cr)
  (setq segs (mapcar 'list pts (cdr pts)))
  (if closed (setq segs (append segs (list (list (last pts) (car pts))))))
  (foreach s segs
    (setq a (car s) b (cadr s)
          dx (- (car b) (car a)) dy (- (cadr b) (cadr a))
          l2 (+ (* dx dx) (* dy dy)))
    (if (> l2 1e-12)
      (progn
        (setq tt (/ (+ (* (- (car pt) (car a)) dx) (* (- (cadr pt) (cadr a)) dy)) l2)
              tt (max 0.0 (min 1.0 tt))
              q  (list (+ (car a) (* tt dx)) (+ (cadr a) (* tt dy)))
              d  (distance (cs:xy pt) q)
              cr (- (* dx (- (cadr pt) (cadr a))) (* dy (- (car pt) (car a)))))
        (if (or (null best) (< d (car best))) (setq best (list d cr))))))
  (if (and best (> (cadr best) 0)) -1 1))

;;; sign of the template's outermost (largest |H|) step
(defun cs:nat-sign (steps / big)
  (foreach s steps (if (or (null big) (> (abs (car s)) (abs big))) (setq big (car s))))
  (if (and big (< big 0)) -1 1))

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

;;; draw every step line (+ ribs). steps already carry their final signed H.
(defun cs:build (pts flags closed steps code ribs / lanes li made k rib)
  (setq made '() li 0)
  (setq lanes
    (mapcar
      '(lambda (st / k o z out)
         (setq k 0 out '())
         (foreach p pts
           (setq o   (cs:offset-pt pts k (car st) closed)
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
  (if ribs
    (progn
      (setq k 0)
      (foreach p pts
        (if (nth k flags)
          (setq rib  (cons (list (car p) (cadr p) (if (caddr p) (caddr p) 0.0))
                           (mapcar '(lambda (ln) (nth k ln)) lanes))
                made (cons (cs:make-3dpoly rib (cs:layer (strcat "CURB-" code "-XS") 8) nil) made)))
        (setq k (1+ k)))))
  made)

;;; ----------------------------------------------------------------- dialog --
(setq *cs-dcl*
  '("curbstep : dialog {"
    "  label = \"CurbStep - pick curb type\";"
    "  : row {"
    "    : column {"
    "      : popup_list { key = \"db\"; label = \"Database:\"; width = 34; }"
    "      : edit_box { key = \"flt\"; label = \"Filter:\"; edit_width = 14; allow_accept = false; }"
    "      : list_box { key = \"codes\"; label = \"Curb type:\"; height = 18; width = 34; }"
    "    }"
    "    : column {"
    "      : text { key = \"tmpl\"; width = 46; }"
    "      : list_box { key = \"steps\"; label = \"Offset lines (#, H offset, V elev):\"; height = 10; width = 46; tabs = \"5 18\"; }"
    "      : toggle { key = \"ribs\"; label = \"Draw cross-section ribs at vertices\"; }"
    "      : edit_box { key = \"chord\"; label = \"Max chord on arcs:\"; edit_width = 8; }"
    "      : text { label = \"After OK: select base line, then pick the side.\"; }"
    "    }"
    "  }"
    "  ok_cancel;"
    "  errtile;"
    "}"))

(defun cs:dlg-steps (row / i)
  (set_tile "tmpl" (if row (strcat (car row) ":  " (cdr row)) ""))
  (start_list "steps")
  (if row
    (progn
      (setq i 0)
      (foreach s (cs:parse-template (cdr row))
        (add_list (strcat (itoa (setq i (1+ i))) "\tH " (rtos (car s) 2 2) "\tV " (rtos (cdr s) 2 3))))))
  (end_list))

(defun cs:dlg-fill (/ flt idx)
  (setq flt (strcase (cs:trim (get_tile "flt")))
        *cs-rows* (vl-remove-if-not
                    '(lambda (r) (or (= flt "") (vl-string-search flt (car r))))
                    (cs:db-rows *cs-dbkey*)))
  (start_list "codes")
  (foreach r *cs-rows* (add_list (car r)))
  (end_list)
  (setq idx (vl-position *cs-code* (mapcar 'car *cs-rows*)))
  (if (and (not idx) *cs-rows*) (setq idx 0))
  (if idx
    (progn (set_tile "codes" (itoa idx)) (cs:dlg-steps (nth idx *cs-rows*)))
    (cs:dlg-steps nil)))

(defun cs:dlg-db (v)
  (setq *cs-dbkey* (nth (atoi v) (cs:db-keys)))
  (cs:dlg-fill))

(defun cs:dlg-code (v / row)
  (if (setq row (nth (atoi v) *cs-rows*))
    (progn (setq *cs-code* (car row)) (cs:dlg-steps row))))

(defun cs:dlg-accept (/ v row ch)
  (setq v (get_tile "codes")
        row (if (/= v "") (nth (atoi v) *cs-rows*))
        ch (distof (get_tile "chord") 2))
  (cond
    ((not row) (set_tile "error" "Pick a curb type."))
    ((or (not ch) (<= ch 0)) (set_tile "error" "Max chord must be a number > 0."))
    (T (setq *cs-code* (car row)
             *cs-step* ch
             *cs-ribs* (= (get_tile "ribs") "1"))
       (done_dialog 1))))

;;; -> T if the user pressed OK
(defun cs:dialog (/ fn fh id res)
  (setq fn (vl-filename-mktemp "cstep" nil ".dcl")
        fh (open fn "w"))
  (foreach l *cs-dcl* (write-line l fh))
  (close fh)
  (setq id (load_dialog fn))
  (if (and (>= id 0) (new_dialog "curbstep" id))
    (progn
      (start_list "db") (foreach l (cs:db-labels) (add_list l)) (end_list)
      (if (not (member *cs-dbkey* (cs:db-keys))) (setq *cs-dbkey* (car (cs:db-keys))))
      (set_tile "db" (itoa (vl-position *cs-dbkey* (cs:db-keys))))
      (set_tile "ribs" (if *cs-ribs* "1" "0"))
      (set_tile "chord" (rtos *cs-step* 2 2))
      (cs:dlg-fill)
      (action_tile "db" "(cs:dlg-db $value)")
      (action_tile "flt" "(cs:dlg-fill)")
      (action_tile "codes" "(cs:dlg-code $value)")
      (action_tile "accept" "(cs:dlg-accept)")
      (action_tile "cancel" "(done_dialog 0)")
      (setq res (start_dialog))
      (unload_dialog id))
    (princ "\nCould not open the CurbStep dialog."))
  (vl-file-delete fn)
  (= res 1))

;;; --------------------------------------------------------------- commands --
(defun cs:pick-base (/ sel e typ done)
  (while (not done)
    (setvar "ERRNO" 0)
    (setq sel (entsel "\nSelect base line (line/polyline/feature line/alignment) <done>: "))
    (cond
      ((and (not sel) (= (getvar "ERRNO") 7)) (princ "\nMissed - try again."))
      ((not sel) (setq done T e nil))
      (T
       (setq e (car sel) typ (cdr (assoc 0 (entget e))))
       (cond
         ((not (wcmatch typ "LINE,LWPOLYLINE,POLYLINE,ARC,SPLINE,AECC_FEATURE_LINE,AECC_ALIGNMENT"))
          (princ (strcat "\nThat is a " typ " - pick a line, polyline, feature line or alignment.")))
         ((and (= typ "POLYLINE") (/= 0 (logand 80 (cdr (assoc 70 (entget e))))))
          (princ "\nMeshes are not supported."))
         (T (setq done T))))))
  e)

(defun c:CURBSTEP (/ *error* doc tmpl steps e data closed samp pts flags pt fac signed made total z)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (defun *error* (msg)
    (vla-EndUndoMark doc)
    (if (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*,*EXIT*")) (princ (strcat "\nCURBSTEP error: " msg)))
    (princ))
  (if (cs:dialog)
    (progn
      (setq tmpl  (cdr (assoc *cs-code* (cs:db-rows *cs-dbkey*)))
            steps (cs:parse-template tmpl)
            total 0)
      (princ (strcat "\n" *cs-code* " = " tmpl))
      (vla-StartUndoMark doc)
      (while (setq e (cs:pick-base))
        (if (not (setq data (cs:curve-pts e)))
          (princ "\nCould not read that object's geometry.")
          (progn
            (setq closed (car data) samp (cdr data))
            ;; alignments carry no elevation
            (if (= (cdr (assoc 0 (entget e))) "AECC_ALIGNMENT")
              (progn
                (initget 0)
                (if (setq z (getreal (strcat "\nAlignment has no elevation - base elevation <"
                                             (rtos *cs-alz* 2 3) ">: ")))
                  (setq *cs-alz* z))
                (setq samp (mapcar '(lambda (r) (cons (list (car (car r)) (cadr (car r)) *cs-alz*) (cdr r)))
                                   samp))))
            (setq pts (mapcar 'car samp) flags (mapcar 'cdr samp))
            (if (setq pt (getpoint "\nPick the side to offset toward (gutter / outermost line side): "))
              (progn
                (setq fac    (* (cs:side-of pts closed pt) (cs:nat-sign steps))
                      signed (mapcar '(lambda (s) (cons (* fac (car s)) (cdr s))) steps)
                      made   (cs:build pts flags closed signed *cs-code* *cs-ribs*)
                      total  (+ total (length made)))
                (princ (strcat "\n" (itoa (length made)) " 3D polyline(s) on CURB-" *cs-code* "-*.")))))))
      (vla-EndUndoMark doc)
      (princ (strcat "\nCURBSTEP done: " (itoa total) " object(s) created."))))
  (princ))

(defun c:CURBSTEPLIST (/ opt)
  (initget "Boc Flowline Std Knockdown")
  (if (setq opt (getkword (strcat "\nList which database [Boc/Flowline/Std/Knockdown] <" *cs-dbkey* ">: ")))
    (setq *cs-dbkey* opt))
  (cs:list-db *cs-dbkey*)
  (princ))

;;; =========================================================================
;;; DATABASE - generated from data/*_db.txt by cad/embed_db.py. Format:
;;;   (key "label" (("CODE" . "H.. V.. H.. V..") ...))
;;; <<DB-BEGIN>>
(setq *cs-db*
  '(
    ("Boc" "Back of curb (RBCB)"
     (
      ("L612" . "H0.5 V0.0 H0.67 V-0.5 H1.67 V-0.44")
      ("R612" . "H-0.5 V0.0 H-0.67 V-0.5 H-1.67 V-0.44")
      ("L624" . "H0.5 V0.0 H0.67 V-0.5 H2.67 V-0.38")
      ("R624" . "H-0.5 V0.0 H-0.67 V-0.5 H-2.67 V-0.38")
      ("LPARK" . "H1 V0.0 H1.17 V-0.5 H2.17 V-0.44")
      ("RPARK" . "H-1 V0.0 H-1.17 V-0.5 H-2.17 V-0.44")
      ("L606" . "H0.5 V0.0 H0.67 V-0.5 H1.17 V-0.47")
      ("R606" . "H-0.5 V0.0 H-0.67 V-0.5 H-1.17 V-0.47")
      ("LD418" . "H1 V-0.33 H2.5 V-0.24")
      ("RD418" . "H-1 V-0.33 H-2.5 V-0.24")
      ("R618" . "H-0.5 V0.0 H-0.67 V-0.5 H-2.18 V-0.41")
      ("L618" . "H0.5 V0.0 H0.67 V-0.5 H2.18 V-0.41")
      ("L812" . "H0.5 V0.0 H0.67 V-0.67 H1.67 V-0.61")
      ("R812" . "H-0.5 V0.0 H-0.67 V-0.67 H-1.67 V-0.61")
      ("R818" . "H0.5 V0.0 H0.67 V-0.67 H2.18 V-0.58")
      ("L818" . "H-0.5 V0.0 H-0.67 V-0.67 H-2.18 V-0.58")
      ("L824" . "H0.5 V0.0 H0.67 V-0.67 H2.67 V-0.55")
      ("R824" . "H-0.5 V0.0 H-0.67 V-0.67 H-2.67 V-0.55")
      ("RD" . "H-0.5 V0.0")
      ("LD" . "H0.5 V0.0")
      ("RDPRK" . "H-0.5 V0.0")
      ("LDPRK" . "H0.5 V0.0")
      ("L006" . "H0.5 V0.0 H0.67 V-0.02 H1.17 V0.01")
      ("R006" . "H-0.5 V0.0 H-0.67 V-0.02 H-1.17 V0.01")
      ("L106" . "H0.5 V0.0 H0.67 V-0.08 H1.17 V-0.05")
      ("R106" . "H-0.5 V0.0 H-0.67 V-0.08 H-1.17 V-0.05")
      ("L206" . "H0.5 V0.0 H0.67 V-0.17 H1.17 V-0.14")
      ("R206" . "H-0.5 V0.0 H-0.67 V-0.17 H-1.17 V-0.14")
      ("L306" . "H0.5 V0.0 H0.67 V-0.25 H1.17 V-0.22")
      ("R306" . "H-0.5 V0.0 H-0.67 V-0.25 H-1.17 V-0.22")
      ("L406" . "H0.5 V0.0 H0.67 V-0.33 H1.17 V-0.3")
      ("R406" . "H-0.5 V0.0 H-0.67 V-0.33 H-1.17 V-0.3")
      ("L506" . "H0.5 V0.0 H0.67 V-0.42 H1.17 V-0.39")
      ("R506" . "H-0.5 V0.0 H-0.67 V-0.42 H-1.17 V-0.39")
      ("L012" . "H0.5 V0.0 H0.67 V-0.02 H1.67 V0.04")
      ("R012" . "H-0.5 V0.0 H-0.67 V-0.02 H-1.67 V0.04")
      ("L112" . "H0.5 V0.0 H0.67 V-0.08 H1.67 V-0.02")
      ("R112" . "H-0.5 V0.0 H-0.67 V-0.08 H-1.67 V-0.02")
      ("L212" . "H0.5 V0.0 H0.67 V-0.17 H1.67 V-0.11")
      ("R212" . "H-0.5 V0.0 H-0.67 V-0.17 H-1.67 V-0.11")
      ("L312" . "H0.5 V0.0 H0.67 V-0.25 H1.67 V-0.19")
      ("R312" . "H-0.5 V0.0 H-0.67 V-0.25 H-1.67 V-0.19")
      ("L412" . "H0.5 V0.0 H0.67 V-0.33 H1.67 V-0.27")
      ("R412" . "H-0.5 V0.0 H-0.67 V-0.33 H-1.67 V-0.27")
      ("L512" . "H0.5 V0.0 H0.67 V-0.42 H1.67 V-0.36")
      ("R512" . "H-0.5 V0.0 H-0.67 V-0.42 H-1.67 V-0.36")
      ("L018" . "H0.5 V0.0 H0.67 V-0.02 H2.18 V0.07")
      ("R018" . "H-0.5 V0.0 H-0.67 V-0.02 H-2.18 V0.07")
      ("L118" . "H0.5 V0.0 H0.67 V-0.08 H2.18 V0.01")
      ("R118" . "H-0.5 V0.0 H-0.67 V-0.08 H-2.18 V0.01")
      ("L218" . "H0.5 V0.0 H0.67 V-0.17 H2.18 V-0.08")
      ("R218" . "H-0.5 V0.0 H-0.67 V-0.17 H-2.18 V-0.08")
      ("L318" . "H0.5 V0.0 H0.67 V-0.25 H2.18 V-0.16")
      ("R318" . "H-0.5 V0.0 H-0.67 V-0.25 H-2.18 V-0.16")
      ("L418" . "H0.5 V0.0 H0.67 V-0.33 H2.18 V-0.24")
      ("R418" . "H-0.5 V0.0 H-0.67 V-0.33 H-2.18 V-0.24")
      ("L518" . "H0.5 V0.0 H0.67 V-0.42 H2.18 V-0.33")
      ("R518" . "H-0.5 V0.0 H-0.67 V-0.42 H-2.18 V-0.33")
      ("L024" . "H0.5 V0.0 H0.67 V-0.02 H2.67 V0.1")
      ("R024" . "H-0.5 V0.0 H-0.67 V-0.02 H-2.67 V0.1")
      ("L124" . "H0.5 V0.0 H0.67 V-0.08 H2.67 V0.04")
      ("R124" . "H-0.5 V0.0 H-0.67 V-0.08 H-2.67 V0.04")
      ("L224" . "H0.5 V0.0 H0.67 V-0.17 H2.67 V-0.05")
      ("R224" . "H-0.5 V0.0 H-0.67 V-0.17 H-2.67 V-0.05")
      ("L324" . "H0.5 V0.0 H0.67 V-0.25 H2.67 V-0.13")
      ("R324" . "H-0.5 V0.0 H-0.67 V-0.25 H-2.67 V-0.13")
      ("L424" . "H0.5 V0.0 H0.67 V-0.33 H2.67 V-0.21")
      ("R424" . "H-0.5 V0.0 H-0.67 V-0.33 H-2.67 V-0.21")
      ("L524" . "H0.5 V0.0 H0.67 V-0.42 H2.67 V-0.3")
      ("R524" . "H-0.5 V0.0 H-0.67 V-0.42 H-2.67 V-0.3")
     ))
    ("Flowline" "Flow line (RCFL)"
     (
      ("L612" . "H-0.67 V0.5 H-0.17 V0.5 H1 V0.06")
      ("R612" . "H0.67 V0.5 H0.17 V0.5 H-1 V0.06")
      ("L624" . "H-0.67 V0.5 H-0.17 V0.5 H2 V0.12")
      ("R624" . "H0.67 V0.5 H0.17 V0.5 H-2 V0.12")
      ("L024" . "H-0.67 V0.02 H-0.17 V0.02 H2 V0.12")
      ("R024" . "H0.67 V0.02 H0.17 V0.02 H-2 V0.12")
      ("L124" . "H-0.67 V0.08 H-0.17 V0.08 H2 V0.12")
      ("R124" . "H0.67 V0.08 H0.17 V0.08 H-2 V0.12")
      ("L224" . "H-0.67 V0.17 H-0.17 V0.17 H2 V0.12")
      ("R224" . "H0.67 V0.17 H0.17 V0.17 H-2 V0.12")
      ("L324" . "H-0.67 V0.25 H-0.17 V0.25 H2 V0.12")
      ("R324" . "H0.67 V0.25 H0.17 V0.25 H-2 V0.12")
      ("L424" . "H-0.67 V0.33 H-0.17 V0.33 H2 V0.12")
      ("R424" . "H0.67 V0.33 H0.17 V0.33 H-2 V0.12")
      ("L524" . "H-0.67 V0.42 H-0.17 V0.42 H2 V0.12")
      ("R524" . "H0.67 V0.42 H0.17 V0.42 H-2 V0.12")
      ("LPARK" . "H-1.17 V0.5 H-0.17 V0.5 H1 V0.06")
      ("RPARK" . "H1.17 V0.5 H0.17 V0.5 H-1 V0.06")
      ("L606" . "H-0.67 V0.5 H-0.17 V0.5 H0.5 V0.03")
      ("R606" . "H0.67 V0.5 H0.17 V0.5 H-0.5 V0.03")
      ("LD418" . "H-1 V0.33 H1.5 V0.09")
      ("RD418" . "H1 V0.33 H-1.5 V0.09")
      ("R618" . "H0.67 V0.5 H0.17 V0.5 H-1.51 V0.09")
      ("L618" . "H-0.67 V0.5 H-0.17 V0.5 H1.51 V0.09")
      ("L812" . "H-0.67 V0.67 H-0.17 V0.67 H1 V0.06")
      ("R812" . "H0.67 V0.67 H0.17 V0.67 H-1 V0.06")
      ("R818" . "H-0.67 V0.67 H-0.17 V0.67 H1.51 V0.09")
      ("L818" . "H0.67 V0.67 H0.17 V0.67 H-1.51 V0.09")
      ("L824" . "H-0.67 V0.67 H-0.17 V0.67 H2 V0.12")
      ("R824" . "H0.67 V0.67 H0.17 V0.67 H-2 V0.12")
      ("RD" . "H-0.5 V0")
      ("LD" . "H0.5 V0")
      ("RDPRK" . "H-0.5 V0")
      ("LDPRK" . "H0.5 V0")
      ("L006" . "H-0.67 V0.02 H-0.17 V0.02 H0.5 V0.03")
      ("R006" . "H0.67 V0.02 H0.17 V0.02 H-0.5 V0.03")
      ("L106" . "H-0.67 V0.08 H-0.17 V0.08 H0.5 V0.03")
      ("R106" . "H0.67 V0.08 H0.17 V0.08 H-0.5 V0.03")
      ("L206" . "H-0.67 V0.17 H-0.17 V0.17 H0.5 V0.03")
      ("R206" . "H0.67 V0.17 H0.17 V0.17 H-0.5 V0.03")
      ("L306" . "H-0.67 V0.25 H-0.17 V0.25 H0.5 V0.03")
      ("R306" . "H0.67 V0.25 H0.17 V0.25 H-0.5 V0.03")
      ("L406" . "H-0.67 V0.33 H-0.17 V0.33 H0.5 V0.03")
      ("R406" . "H0.67 V0.33 H0.17 V0.33 H-0.5 V0.03")
      ("L506" . "H-0.67 V0.42 H-0.17 V0.42 H0.5 V0.03")
      ("R506" . "H0.67 V0.42 H0.17 V0.42 H-0.5 V0.03")
      ("L012" . "H-0.67 V0.02 H-0.17 V0.02 H1 V0.06")
      ("R012" . "H0.67 V0.02 H0.17 V0.02 H-1 V0.06")
      ("L112" . "H-0.67 V0.08 H-0.17 V0.08 H1 V0.06")
      ("R112" . "H0.67 V0.08 H0.17 V0.08 H-1 V0.06")
      ("L212" . "H-0.67 V0.17 H-0.17 V0.17 H1 V0.06")
      ("R212" . "H0.67 V0.17 H0.17 V0.17 H-1 V0.06")
      ("L312" . "H-0.67 V0.25 H-0.17 V0.25 H1 V0.06")
      ("R312" . "H0.67 V0.25 H0.17 V0.25 H-1 V0.06")
      ("L412" . "H-0.67 V0.33 H-0.17 V0.33 H1 V0.06")
      ("R412" . "H0.67 V0.33 H0.17 V0.33 H-1 V0.06")
      ("L512" . "H-0.67 V0.42 H-0.17 V0.42 H1 V0.06")
      ("R512" . "H0.67 V0.42 H0.17 V0.42 H-1 V0.06")
      ("L018" . "H-0.67 V0.02 H-0.17 V0.02 H1.51 V0.09")
      ("R018" . "H0.67 V0.02 H0.17 V0.02 H-1.51 V0.09")
      ("L118" . "H-0.67 V0.08 H-0.17 V0.08 H1.51 V0.09")
      ("R118" . "H0.67 V0.08 H0.17 V0.08 H-1.51 V0.09")
      ("L218" . "H-0.67 V0.17 H-0.17 V0.17 H1.51 V0.09")
      ("R218" . "H0.67 V0.17 H0.17 V0.17 H-1.51 V0.09")
      ("L318" . "H-0.67 V0.25 H-0.17 V0.25 H1.51 V0.09")
      ("R318" . "H0.67 V0.25 H0.17 V0.25 H-1.51 V0.09")
      ("L418" . "H-0.67 V0.33 H-0.17 V0.33 H1.51 V0.09")
      ("R418" . "H0.67 V0.33 H0.17 V0.33 H-1.51 V0.09")
      ("L518" . "H-0.67 V0.42 H-0.17 V0.42 H1.51 V0.09")
      ("R518" . "H0.67 V0.42 H0.17 V0.42 H-1.51 V0.09")
     ))
    ("Std" "Standard curb"
     (
      ("L612" . "H0.5 V0.0 H0.67 V-0.5 H1.67 V-0.44")
      ("R612" . "H-0.5 V0.0 H-0.67 V-0.5 H-1.67 V-0.44")
      ("L624" . "H0.5 V0.0 H0.67 V-0.5 H2.67 V-0.38")
      ("R624" . "H-0.5 V0.0 H-0.67 V-0.5 H-2.67 V-0.38")
      ("LPARK" . "H1 V0.0 H1.17 V-0.5 H2.17 V-0.44")
      ("RPARK" . "H-1 V0.0 H-1.17 V-0.5 H-2.17 V-0.44")
      ("L606" . "H0.5 V0.0 H0.67 V-0.5 H1.17 V-0.47")
      ("R606" . "H-0.5 V0.0 H-0.67 V-0.5 H-1.17 V-0.47")
      ("LD418" . "H1 V-0.33 H2.5 V-0.24")
      ("RD418" . "H-1 V-0.33 H-2.5 V-0.24")
      ("R618" . "H0.5 V0.0 H0.67 V-0.5 H2.18 V-0.41")
      ("L618" . "H-0.5 V0.0 H-0.67 V-0.5 H-2.18 V-0.41")
      ("L812" . "H0.5 V0.0 H0.67 V-0.67 H1.67 V-0.61")
      ("R812" . "H-0.5 V0.0 H-0.67 V-0.67 H-1.67 V-0.61")
      ("R818" . "H0.5 V0.0 H0.67 V-0.67 H2.18 V-0.58")
      ("L818" . "H-0.5 V0.0 H-0.67 V-0.67 H-2.18 V-0.58")
      ("L824" . "H0.5 V0.0 H0.67 V-0.67 H2.67 V-0.55")
      ("R824" . "H-0.5 V0.0 H-0.67 V-0.67 H-2.67 V-0.55")
      ("RD" . "H-0.5 V0.0")
      ("LD" . "H0.5 V0.0")
      ("RDPRK" . "H-0.5 V0.0")
      ("LDPRK" . "H0.5 V0.0")
     ))
    ("Knockdown" "Knockdown curb"
     (
      ("L612" . "H0.5 V0.0 H0.67 V-0.5 H1.67 V-0.44")
      ("R612" . "H-0.5 V0.0 H-0.67 V-0.5 H-1.67 V-0.44")
      ("L624" . "H0.5 V0.0 H0.67 V-0.5 H2.67 V-0.38")
      ("R624" . "H-0.5 V0.0 H-0.67 V-0.5 H-2.67 V-0.38")
      ("LPARK" . "H1 V0.0 H1.17 V-0.5 H2.17 V-0.44")
      ("RPARK" . "H-1 V0.0 H-1.17 V-0.5 H-2.17 V-0.44")
      ("L606" . "H0.5 V0.0 H0.67 V-0.5 H1.17 V-0.47")
      ("R606" . "H-0.5 V0.0 H-0.67 V-0.5 H-1.17 V-0.47")
      ("LD418" . "H1 V-0.33 H2.5 V-0.24")
      ("RD418" . "H-1 V-0.33 H-2.5 V-0.24")
      ("L618" . "H0.5 V0.0 H0.67 V-0.5 H2.18 V-0.41")
      ("R618" . "H-0.5 V0.0 H-0.67 V-0.5 H-2.18 V-0.41")
     ))
   ))
;;; <<DB-END>>
;;; =========================================================================

(princ "\nCurbStep loaded.  Commands: CURBSTEP, CURBSTEPLIST")
(princ)
