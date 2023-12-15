1. main.c:

#include <stdio.h>

int main(void) {
	printf("hello world\n");
	return 0;
}


2. clang -ccc-print-phases main.c  	# 显示编译过程阶段


3. clang -E main.c | less  			# 预处理


4. clang -E -Xclang -dump-tokens main.c | less 		# 词法分析


5. clang -fsyntax-only -Xclang -ast-dump main.c		# 语法树


6. clang -S -emit-llvm main.c && cat main.ll        # LLVM IR 中间语言



## https://llvm-tutorial-cn.readthedocs.io/en/latest/index.html

