true : ;nasm -Iasmlib/ -f bin -o print $0 && ls -l print && chmod +x print && objdas ./print && echo strace -i ./print foobar; echo ret $?; exit

%imacro vvv 1
%assign v %1
%xdefine w %1

%xdefine e1 %eval(v)
%deftok e2 %num(v)
%assign e3 (%1 % 0xFFFFFFFF)
%warning val %1 v h1 h2
%warning vv,e3,vv

%endmacro

vvv 12
vvv -12
vvv -103
v 0xFFFFFF99

and	eax, %hex(1234)
