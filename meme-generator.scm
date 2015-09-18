(script-fu-register
 "script-fu-meme-generator"
 _"_Generar Meme"
 _"Genera un meme :o"
 "Eduardo Vazquez (hao)"
 "Public Domain"
 "2015-09-18"
 ""
 SF-IMAGE      "Image" 1
 SF-STRING     "Text"               "TLDR"
 SF-ADJUSTMENT "Font size (pixels)" '(150 2 1000 1 10 0 1)
 )

(script-fu-menu-register "script-fu-meme-generator"
                         "<Image>/File/Create/Text")

(define (gimp-image-list-count)
  (car (gimp-image-list)))

(define (gimp-image-list-items)
  (cadr (gimp-image-list)))

(define (gimp-image-latest)
  (when (= (gimp-image-list-count) 0)
    (gimp-image-new 256 256 RGB))
  (aref (gimp-image-list-items) 0))

(define (gimp-layer-hide-all from-image)
  (let ((hide-layer (lambda (layer) (gimp-layer-set-visible layer 0)))
      (layers (vector->list (cadr (gimp-image-get-layers from-image)))))
    (map hide-layer layers)))

(define (gimp-layer-unhide-all from-image)
  (let ((layers (vector->list (cadr (gimp-image-get-layers from-image)))))
    (map (lambda (layer) (gimp-layer-set-visible layer 1)) layers)))

(define (with-undo-disabled in-image do-this)
  (gimp-image-undo-disable in-image)
  `(map (lambda (x) (x)) ,@do-this)
  (gimp-image-undo-enable in-image))

(define (script-fu-meme-generator img text size)
  (gimp-layer-hide-all img)
  (let* ((font "Impact Condensed")
      (logo-layer (car (gimp-text-fontname img -1 0 0 text 10 TRUE size PIXELS font)))
      (width (car (gimp-drawable-width logo-layer)))
      (height (car (gimp-drawable-height logo-layer)))
      (outline-layer (car (gimp-layer-new img width height RGBA-IMAGE text 100 NORMAL-MODE))))

    (with-undo-disabled
     img
     (gimp-selection-none img)
     (script-fu-util-image-add-layers img outline-layer)

     (gimp-context-set-foreground "white")
     (gimp-layer-set-lock-alpha logo-layer TRUE)
     (gimp-edit-fill logo-layer FOREGROUND-FILL)

     (gimp-edit-clear outline-layer)
     (gimp-image-select-item img CHANNEL-OP-REPLACE logo-layer)
     (gimp-selection-grow img (/ size 10))
     (gimp-context-set-background "black")
     (gimp-edit-fill outline-layer BACKGROUND-FILL)

     (gimp-image-merge-visible-layers img 1)
     (gimp-layer-unhide-all img))
    (gimp-displays-flush)))

;; Debug
;;(script-fu-meme-generator (gimp-image-latest) "Test" 500)
