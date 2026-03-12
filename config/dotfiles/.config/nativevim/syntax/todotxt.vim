if exists("b:current_syntax")
  finish
endif

syntax match todoPriorityA "^(A)\s"
syntax match todoPriorityB "^(B)\s"
syntax match todoPriorityC "^(C)\s"
syntax match todoPriorityAny "^([D-Z])\s"

syntax match todoDate "\d\{4\}-\d\{2\}-\d\{2\}"
syntax match todoProject "+\S\+"
syntax match todoContext "@\S\+"
syntax match todoDone "^x .*"

highlight default link todoDate PreProc
highlight default link todoProject String
highlight default link todoContext Type
highlight default link todoDone Comment

highlight todoPriorityA ctermfg=Red     guifg=#FF0000 gui=bold
highlight todoPriorityB ctermfg=Yellow  guifg=#EBCB8B gui=bold
highlight todoPriorityC ctermfg=Green   guifg=#A3BE8C
highlight todoPriorityAny ctermfg=Blue  guifg=#81A1C1

let b:current_syntax = "todotxt"
