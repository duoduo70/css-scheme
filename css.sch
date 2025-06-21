(library (css)
  (export css)
  (import (rnrs))

  (define (atom? e) (not (pair? e)))

  (define (e->css-term-calling-string e)
    (define (atom->css-term-calling-string atom)
      (cond [(number? atom) (number->string atom)]
            [(string? atom) (string-append "\"" atom "\"")]
            [(symbol? atom) (symbol->string atom)]))

    (cond [(atom? e) (atom->css-term-calling-string e)]
          [(list? e) (apply string-append
                      `(,(symbol->string (car e)) "(" ,@(map e->css-term-calling-string (cdr e)) ")"))]))

  (define (list-split-on e lst)
    (define (iter e lst collected-lst)
      (cond [(null? lst)          (values collected-lst '())]
            [(equal? (car lst) e) (values collected-lst (cdr lst))]
            [else                 (iter e (cdr lst) (cons (car lst) collected-lst))]))
    (let-values ([(before after) (iter e lst '())])
      (values (reverse before) (reverse after))))

  (define (css-body->string body)
    (define (iter body will-append-strs)
      (define (handle body)
        (let* ([head           (car body)]
               [tail           (cdr body)]
               [snd            (car tail)]
               [tail-tail      (cdr tail)])
          (let ([head-stringifed (symbol->string head)])
            (if (and (symbol? snd) (symbol=? snd '=>))
              (let ([thrd           (car tail-tail)]
                    [more-later-all (cdr tail-tail)])
                (values
                  (let ([subbody thrd])
                    (if (list? subbody)
                      more-later-all
                      ""))
                  (css-item->string body)))
              (values
                tail-tail
                (string-append
                  head-stringifed
                  ": "
                  (e->css-term-calling-string snd)
                  ";"))))))
      (cond [(null? body) will-append-strs]
            [else (let-values ([(next curr-collected) (handle body)])
                    (iter next (cons curr-collected will-append-strs)))]))
    (if (null? body)
      ""
      (let ([head (car body)])
       (if (list? head)
        (css-body->string head)
        (apply string-append (iter body '()))))))

  (define (css-item->string item)
    (define (splice-head&body head-string body-string)
      (string-append head-string "{\n" body-string "\n}"))
    (define (insert-between lst sep)
      (cond
        ((null? lst) '())
        ((null? (cdr lst)) lst)
        (else (cons (car lst)
                    (cons sep (insert-between (cdr lst) sep))))))
    (let-values ([(head body) (list-split-on '=> item)])
      (splice-head&body
        (apply string-append (insert-between (map e->css-term-calling-string head) " "))
        (css-body->string body))))

  (define (css-transform . items)
    (call/cc (lambda (err-break)
              (apply string-append
                (map
                  (lambda (item) (css-item->string item))
                  items)))))

  (define-syntax css
    (syntax-rules ()
      [(_ lst ...) (css-transform 'lst ...)])))
