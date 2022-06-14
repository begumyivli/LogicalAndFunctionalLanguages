; begüm yivli
; 2019400147
; compiling: yes
; complete: yes

#lang racket

(provide (all-defined-out))
(define (member? x list)
     (if (or (null? list) (not (list? list)) ) #f
         (if (equal? x (car list)) #t                   
              (member? x (cdr list)))))                 

; 10 points
(define := (lambda (var value)(list var value)))

; 10 points
(define -- (lambda args (list 'let args)))

; 10 points
(define (append list1 list2)
  (if (null? list1) 
      list2
      (cons (car list1) 
            (append (cdr list1) list2))))
(define @ (lambda (bindings expr) (append bindings expr)))

; 20 points
(define split_at_delim (lambda (delim args) (split_helper delim args '() '())))

(define (split_helper delim mylist res box)
  (if (empty? mylist)
      (append res (list box))
      (if (equal? (car mylist) delim)
          (split_helper delim (cdr mylist) (append res (list box)) '())
          (split_helper delim (cdr mylist) res (append box (list (car mylist)))))))
      

; 30 points
(define parse_expr (lambda (expr) (parse expr)))
(define (parse expr)
  (if (empty? expr)
      empty
      (if (member? '+ expr)  ;+
         (cons '+ (map parse_expr (split_at_delim '+ expr)))
         (if (member? '* expr)   ;*
             (cons '* (map parse_expr (split_at_delim '* expr)))
             (if (and (list? expr) (eqv? (length expr) 1)) ;(())
                 (parse_expr (car expr))
                 (if (member? '@ expr)  ;@
                     (list 'let (parse_binding (car (split_at_delim '@ expr))) (parse (cdr (split_at_delim '@ expr))))
                     expr ))))))


(define (parse_binding expr)
  (if (and (eqv? (length expr) 1) (list?  expr))
      (parse_binding (car expr))
      (map parse_assign (reverse (cdr(reverse(split_at_delim '-- expr)))))))

(define (parse_assign expr)
  (eval(list ':= (car expr) (caddr expr))))

; 20 points
(define eval_expr (lambda (expr) (eval (parse_expr expr))))
