.source code.txt
.class public test
.super java/lang/Object

.method public <init>()V
aload_0
invokenonvirtual java/lang/Object/<init>()V
return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 100
.limit stack 100
.line 1
iconst_0
istore 1
.line 2
L_0:
ldc 0
istore 1
.line 3
L_1:
L_2:
iload 1
ldc 5
if_icmplt L_3
goto L_4
L_3:
.line 4
iload 1
ldc 1
iadd
istore 1
.line 5
goto L_2
.line 6
L_4:
iconst_0
istore 2
.line 7
L_5:
iload 1
istore 2
.line 8
L_6:
iload 2
ldc 5
if_icmpeq L_7
goto L_8
L_7:
.line 9
iload 1
ldc 3
imul
istore 2
.line 10
goto L_9
L_8:
.line 11
iload 1
ldc 3
iadd
istore 2
.line 12
L_9:
return
.end method
