(define (inverter input output)
  (define (invert-input)
    (let ((new-value (logical-not (get-signal input))))
      (after-delay inverter-delay
                   (lambda () (set-signal! output new-value)))))
  (add-action! input invert-input)
  'ok)

(define (logical-not s)
  (cond ((= s 0) 1)
        ((= s 1) 0)
        (else (error " invalid input" s))))

(define (and-gate a1 a2 output)
  (define (and-action-procedure)
    (let ((new-value (logical-and (get-signal a1)
                                  (get-signal a2))))
      (after-delay and-gate-delay (lambda () (set-signal! output new-value)))))
  (add-action! a1 and-action-procedure)
  (add-action! a2 and-action-procedure)
  'ok)

(define (or-gate a1 a2 output)
  (define (or-action-procedure)
    (let ((new-value (logical-or (get-signal a1)
                                 (get-signal a2))))
      (after-delay inverter-delay
                   (lambda () (set-signal! output new-value)))))
  (add-action! a1 or-action-procedure)
  (add-action! a2 or-action-procedure)
  'ok)

(define (logical-or a1 a2)
  (cond
   ((and (= a1 0) (= a2 0)) 0)
   (else 1)))

(define (logical-and a1 a1)
  (cond
   ((and (= a1 1) (= a2 1)) 1)
   (else 0)))

(define (half-adder a b s c)
  (let ((d (make-wire))
        (e (make-wire)))
    (or-gate a b d)
    (and-gate a b c)
    (inverter c e)
    (and-gate d e s)
    'ok))
(define (full-adder a b c-in sum c-out)
  (let ((s (make-wire))
        (c1 (make-wire))
        (c2 (make-wire)))
    (half-adder b c-in s c2)
    (half-adder a s sum c1)
    (or-gate c1 c2 c-out)
    'ok))

(define (ripple-carry-adder As Bs Ss C-in)
  (if (null? As)
      'ok
      (let ((c-out (make-wire)))
        (full-adder (car As) (car Bs) C-in (car Ss) c-out)
        (ripple-carry-adder (cdr As) (cdr Bs) (cdr Ss) c-out))))

(define (make-wire)
  (let ((signal-value 0) (action-procedure '()))
    (define (set-my-signal! new-value)
      (if (not (= signal-value new-value))
          (begin (set! signal-value new-value)
                 (call-each action-procedure))
          'done))
    (define (accept-action-procedure! proc)
      (set! action-procedure (cons proc action-procedure))
      (proc))
    (define (dispatch m)
      (cond ((eq? m 'get-signal) signal-value)
            ((eq? m 'set-signal!) set-my-signal!)
            ((eq? m 'add-action!) accept-action-procedure!)
            (else (error "unknown operation"))))
    dispatch))

(define (call-each procedures)
  (if (null? procedures)
      'done
      (begin ((car procedures))
             (call-each (cdr procedures)))))

(define (get-signal wire)
  (wire 'get-signal))
(define (set-signal! wire value)
  ((wire 'set-signal!) value))
(define (add-action! wire action-procedure)
  ((wire 'add-action!) action-procedure))
