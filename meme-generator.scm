(script-fu-register
 "script-fu-meme-generator"
 "Generar Meme"
 "Genera un meme :o"
 "Eduardo Vazquez (hao)"
 "Public Domain"
 "2015-08-22"
 ""
 SF-STRING     "Text"               "TLDR"
 SF-ADJUSTMENT "Font size (pixels)" '(150 2 1000 1 10 0 1)
 )

(script-fu-menu-register "script-fu-meme-generator" "<Image>/File/Create/Texto")

(define (script-fu-meme-generator text size)
  (let* ((img (car (gimp-image-new 256 256 RGB)))
         (font "Impact Condensed")
         (logo-layer (car (gimp-text-fontname img -1 0 0 text 10 TRUE size PIXELS font)))
         (width (car (gimp-drawable-width logo-layer)))
         (height (car (gimp-drawable-height logo-layer)))
         (bg-layer (car (gimp-layer-new img width height RGBA-IMAGE "Background" 100 NORMAL-MODE)))
         (outline-layer (car (gimp-layer-new img width height RGBA-IMAGE "Outline" 100 NORMAL-MODE))))

    (gimp-image-undo-disable img)

    (gimp-context-push)
    (gimp-context-set-defaults)

    (gimp-selection-none img)
    (script-fu-util-image-resize-from-layer img logo-layer)
    (script-fu-util-image-add-layers img outline-layer bg-layer)

    (gimp-context-set-foreground "white")
    (gimp-layer-set-lock-alpha logo-layer TRUE)
    (gimp-edit-fill logo-layer FOREGROUND-FILL)

    (gimp-context-set-background "white") ;; BACKGROUND
    (gimp-edit-fill bg-layer BACKGROUND-FILL)

    (gimp-edit-clear outline-layer)
    (gimp-image-select-item img CHANNEL-OP-REPLACE logo-layer)
    (gimp-selection-grow img (/ size 10))
    (gimp-context-set-background "black")
    (gimp-edit-fill outline-layer BACKGROUND-FILL)

    (gimp-context-pop)

    (gimp-image-undo-enable img)
    (gimp-display-new img)))

;; Debug
;;(script-fu-meme-generator "Test" 50)
