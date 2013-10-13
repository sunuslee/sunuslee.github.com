---
layout: post
title: "Mit 6828 lab1 ex12, Backtrace"
description: ""
category: ""
tags: ['6.828', 'Operating System', 'Stabs']
comments: true
---

##Exercise #12##

这次是Lab1的最后一个练习, 也牵涉到蛮多知识. 所以单独开一篇POST来总结.

> Exercise 12. Modify your stack backtrace function to display, for each eip, the function name, source file name, and line number corresponding to that eip.

> Add a backtrace command to the kernel monitor, and extend your implementation of mon_backtrace to call debuginfo_eip and print a line for each stack frame of the form:

{% highlight sh %}
K> backtrace
Stack backtrace:
ebp f010ff78  eip f01008ae  args 00000001 f010ff8c 00000000 f0110580 00000000
     kern/monitor.c:143: monitor+106
ebp f010ffd8  eip f0100193  args 00000000 00001aac 00000660 00000000 00000000
     kern/init.c:49: i386_init+59
ebp f010fff8  eip f010003d  args 00000000 00000000 0000ffff 10cf9a00 0000ffff
     kern/entry.S:70: <unknown>+0
K>
{% endhighlight %}

> Each line gives the file name and line within that file of the stack frame's eip, followed by the name of the function and the offset of the eip from the first instruction of the function (e.g., monitor+106 means the return eip is 106 bytes past the beginning of monitor).

> Be sure to print the file and function names on a separate line, to avoid confusing the grading script.

> You may find that some functions are missing from the backtrace. For example, you will probably see a call to monitor() but not to runcmd(). This is because the compiler in-lines some function calls. Other optimizations may cause you to see unexpected line numbers. If you get rid of the -O2 from GNUMakefile, the backtraces may make more sense (but your kernel will run more slowly).

本次练习的描述如上, 主要需要我们做这么一件事情. 编写一个 *backtrace* 函数(命令). 让我们能够在命令行通过 *backtrace* 命令来显示出当前栈帧的情况. 这对于调试是很有帮助的.
该 *traceback* 主要会输出执行到指令调用的文件, 行号, 函数名等信息, 很像 *gdb* 里的 *where* 指令.

我们首先, 最好把 *GNUMakefile* 文件里的编译优化选项设置为 **-O0** 来禁止优化, 为了防止我们一些函数名, 大部分是 *\__inline__* 的被优化掉.

其次, 阅读文件 *kern/kdebug.c*. 里边主要是有这么两个函数


{% highlight c %}    
static void stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
        int type, uintptr_t addr);

// debuginfo_eip(addr, info)
//
//	Fill in the 'info' structure with information about the specified
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info);
{% endhighlight %}


```debuginfo_eip``` 的函数看起来很简单, 也比较好理解. 传入参数 *addr* 即是需要查询的指令的地址(eip). 返回的信息则存入*info*中.

但是如何获取那些信息呢? 则需要从 *符号表(stabs)* 来搜索获取了. 函数 ```stab_binsearch``` 做的这是这么一件事情, 搜索符号表, 返回结果. 但是也并不像看起来的那么简单.

先说下符号表, 他在C程序内存中的表现是一个结构体数组. 每一个entry都是这样一个结构

{% highlight c%}
// Entries in the STABS table are formatted as follows.
struct Stab {
	uint32_t n_strx;	// index into string table of name
	uint8_t n_type;         // type of symbol
	uint8_t n_other;        // misc info (usually empty)
	uint16_t n_desc;        // description field
	uintptr_t n_value;	// value of symbol
}
{% endhighlight %}
    
每一个entry根据类型 *n_type*的不同, 它的成员 *n_desc*, *n_value* 都会表示不同的意思. [这儿][1]有文档说明对应的类型, 每个成员表示的意义. 主要看看 *N_SO, N_FUN, N_SLINE*
并且, 符号表每个entry的排列也是有一定规律的, 可以认为是这样. 架设只考虑类型 *N_SO, N_FUN, N_SLINE*

{% highlight sh %}
N_SO  file_1-start ...
...
N_FUN function_1-in-file-1-start .....
....
N_SLINE line_a-in-function_1
...
N_SLINE line_b-in-function_1
...
N_FUN function_2-in-file-1-start .....
...
N_SLINE line_c-in-function_2
...
N_SO file_2-start ......
....

N_FUN function_3-in-file-2-start .....
....
N_SO file_3-start ...

{% endhighlight %}

也就是说, 每个元素都存在一个包含的关系. 有点类似 *HTML DOM* , 通过对 *stabs_binsearch*指定类型, 我们是可以逐步缩小范围, 搜索到需要的entry的.

然后说下 ```debuginfo_eip```

{% highlight c %}
    int
    debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
    {
    	const struct Stab *stabs, *stab_end;
    	const char *stabstr, *stabstr_end;
    	int lfile, rfile, lfun, rfun, lline, rline;

    	// Initialize *info
    	info->eip_file = "<unknown>";
    	info->eip_line = 0;
    	info->eip_fn_name = "<unknown>";
    	info->eip_fn_namelen = 9;
    	info->eip_fn_addr = addr;
    	info->eip_fn_narg = 0;
    
        stabs_fix();

    	// Find the relevant set of stabs
    	if (addr >= ULIM) {
    		stabs = __STAB_BEGIN__;
    		stab_end = __STAB_END__;
    		stabstr = __STABSTR_BEGIN__;
    		stabstr_end = __STABSTR_END__;
    	} else {
                    // Can't search for user-level addresses yet!
      	        panic("User address");
    	}

    	// String table validity checks
    	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
    		return -1;

    	// Now we find the right stabs that define the function containing
    	// 'eip'.  First, we find the basic source file containing 'eip'.
    	// Then, we look in that source file for the function.  Then we look
    	// for the line number.

    	// Search the entire set of stabs for the source file (type N_SO).
    	lfile = 0;
    	rfile = (stab_end - stabs) - 1;
    	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
    	if (lfile == 0)
    		return -1;

    	// Search within that file's stabs for the function definition
    	// (N_FUN).
    	lfun = lfile;
    	rfun = rfile;
    	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);

    	if (lfun <= rfun) {
    		// stabs[lfun] points to the function name
    		// in the string table, but check bounds just in case.
    		if (stabs[lfun].n_strx < stabstr_end - stabstr)
    			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
    		info->eip_fn_addr = stabs[lfun].n_value;
    		addr -= info->eip_fn_addr;
    		// Search within the function definition for the line number.
    		lline = lfun;
    		rline = rfun;
    	} else {
    		// Couldn't find function stab!  Maybe we're in an assembly
    		// file.  Search the whole file for the line number.
    		info->eip_fn_addr = addr;
    		lline = lfile;
    		rline = rfile;
    	}
    	// Ignore stuff after the colon.
    	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
    	// Search within [lline, rline] for the line number stab.
    	// If found, set info->eip_line to the right line number.
    	// If not found, return -1.
    	//
    	// Hint:
    	//	There's a particular stabs type used for line numbers.
    	//	Look at the STABS documentation and <inc/stab.h> to find
    	//	which one.
    	// Your code here.
    	// SUNUS, 2013-10-09
    	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    	info->eip_line = stabs[lline].n_desc;
    	// Search backwards from the line number for the relevant filename
    	// stab.
    	// We can't just use the "lfile" stab because inlined functions
    	// can interpolate code from a different file!
    	// Such included source files use the N_SOL stab type.
    	while (lline >= lfile
    	       && stabs[lline].n_type != N_SOL
    	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
    		lline--;
    	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
    		info->eip_file = stabstr + stabs[lline].n_strx;


    	// Set eip_fn_narg to the number of arguments taken by the function,
    	// or 0 if there was no containing function.
    	if (lfun < rfun)
    		for (lline = lfun + 1;
    		     lline < rfun && stabs[lline].n_type == N_PSYM;
    		     lline++)
    			info->eip_fn_narg++;

    	return 0;
    }
{% endhighlight %}

搜索的主要流程为:

1. 搜索出对应eip的文件范围. 通过类型 *N_SO*, 搜索范围为整个stabs表.该步可以获得指令对应的文件名
2. 通过1可以得到在该文件范围内的所有指令的一个子集, 通过类型 *N_FUN* 在该范围内搜索指令对应的函数, 该步可以获得函数名称, 函数地址等.
3. 通过2可以得到在该函数范围内所有资料的一个子集,  通过类型 *N_SLINE* 可以搜索到对应指令的源文件中的行号 *N_SLINE*.

看起来还是很简单, 可是我在具体实现的过程中被一个我认为是外部因素的问题干扰了. 原因如下.
首先, 我的环境下, ```stabs_binsearch```是可以搜索到正确的文件名, 这没有问题. 但是, 在搜索函数对应的entry时则出错. 导致后边的运行结果也都是错的.

具体调试过程如下:

{% highlight sh %}
make qemu-nox-gdb

#Open anoter terminal to get the stabs directly from kernel for later exam.

objdump -G obj/kern/kernel > stabs

#Open another terminal to run gdb to debug.

gdb
b debuginfo_eip
c
Breakpoint 1, debuginfo_eip (addr=4027580555, info=0xf0110edc) at kern/kdebug.c:137
137     info->eip_file = "<unknown>";
(gdb) where
#0  debuginfo_eip (addr=4027580555, info=0xf0110edc) at kern/kdebug.c:137
#1  0xf0100b8b in mon_backtrace (argc=0, argv=0x0, tf=0x0) at kern/monitor.c:70
#2  0xf010008b in test_backtrace (x=0) at kern/init.c:18
#3  0xf010006d in test_backtrace (x=1) at kern/init.c:16
#4  0xf010006d in test_backtrace (x=2) at kern/init.c:16
#5  0xf010006d in test_backtrace (x=3) at kern/init.c:16
#6  0xf010006d in test_backtrace (x=4) at kern/init.c:16
#7  0xf010006d in test_backtrace (x=5) at kern/init.c:16
#8  0xf01000f1 in i386_init () at kern/init.c:39
#9  0xf010003e in relocated () at kern/entry.S:80
{% endhighlight %}

gdb显示的traceback是正确的, 可以看到准确的函数调用过程.

在debuginfo_eip内, 运行第一次搜索的代码是(搜索源文件).

	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
    # lfile == 69 , rfile == 155

然后对照之前得到的stabs表进行检查.(有删减)
由于该表是由-1开始索引, 索引实际返回的范围是[68, 154]

{% highlight c %}
obj/kern/kernel:     file format elf32-i386

Contents of .stab section:

Symnum n_type n_othr n_desc n_value  n_strx String

-1     HdrSym 0      1519   00001d04 1     
0      SO     0      0      f0100000 1      {standard input}
1      SOL    0      0      f010000c 18     kern/entry.S
..
62     LSYM   0      145    00000000 2622   pde_t:t(3,2)=(2,9)
63     EINCL  0      0      00000000 0      
64     GSYM   0      33     00000000 2641   entry_pgtable:G(0,19)=ar(0,20)=r(0,20);0;037777777777;;0;1023;(3,1)
65     GSYM   0      21     00000000 2709   entry_pgdir:G(0,21)=ar(0,20);0;1023;(3,2)
66     SO     0      0      f0100040 0      
67     SO     0      2      f0100040 31     /home/sunus/myProjects/6828/jos/
68     SO     0      2      f0100040 2751   kern/init.c
...
88     BINCL  0      0      00000000 2763   ./inc/stdio.h
89     BINCL  0      0      00000650 2777   ./inc/stdarg.h
90     LSYM   0      6      00000000 2792   va_list:t(2,1)=(2,2)=*(0,2)
91     EINCL  0      0      00000000 0      
92     EINCL  0      0      00000000 0      
93     BINCL  0      0      00000000 2820   ./inc/string.h
94     EXCL   0      0      00005d17 839    ./inc/types.h
95     EINCL  0      0      00000000 0      
96     FUN    0      12     f0100040 2835   test_backtrace:F(0,18)
97     PSYM   0      12     00000008 2858   x:p(0,1)
98     BNSYM  0      0      f0100040 0      
99     SLINE  0      13     00000000 0      
100    SLINE  0      14     00000006 0      
101    SLINE  0      15     00000019 0      
102    SLINE  0      16     0000001f 0      
103    SLINE  0      18     0000002f 0      
104    SLINE  0      19     0000004b 0      
105    SLINE  0      20     0000005e 0      
106    FUN    0      0      00000060 0      
107    ENSYM  0      0      f01000a0 0      
108    FUN    0      23     f01000a0 2867   i386_init:F(0,18)
109    BNSYM  0      0      f01000a0 0      
110    SLINE  0      24     00000000 0      
111    SLINE  0      30     00000006 0      
....
154    GSYM   0      51     00000000 2988   panicstr:G(0,19)
155    SO     0      0      f01001ac 0      
156    SO     0      2      f01001ac 31     /home/sunus/myProjects/6828/jos/
157    SO     0      2      f01001ac 3005   kern/console.c
{% endhighlight %}

可以看到, 68行正是当前eip的所在文件. 并且155也是当前文件结束的范围.
即文件名搜索是 *正确* 的. 接下来搜索 *函数信息*

{% highlight c %}
// Search within that file's stabs for the function definition
// (N_FUN).
lfun = lfile;
rfun = rfile;
stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
#lfun == 107, rfun == 108
{% endhighlight %}

然后, 检查下表中的107项是什么?

```
106    FUN    0      0      00000060 0      
```

嗯? 这是什么东西? 我不知道.. 但是, 对stabs信息的查看, 得到stabs有这么一条:

```
96     FUN    0      12     f0100040 2835   test_backtrace:F(0,18)
```

很明显, 这条才是我们需要的.
我的猜想可能是 *编译器* 或者某些编译选项造成的, 但是我搜索, 调查之后没结果. 并且类似106行这样的entry, 出现得很有规律.

{% highlight sh %}

grep -rn 'N_FUN' stabs

stabs:105:96     FUN    0      12     f0100040 2835   test_backtrace:F(0,18)
stabs:115:106    FUN    0      0      00000060 0
stabs:117:108    FUN    0      23     f01000a0 2867   i386_init:F(0,18)
stabs:125:116    FUN    0      0      0000005f 0
stabs:127:118    FUN    0      58     f01000ff 2885   _panic:F(0,18)
stabs:145:136    FUN    0      0      00000067 0
stabs:147:138    FUN    0      83     f0100166 2961   _warn:F(0,18)
stabs:161:152    FUN    0      0      00000046 0
stabs:195:186    FUN    0      16     f01001ac 3047   delay:f(0,18)
stabs:202:193    FUN    0      0      00000048 0
stabs:204:195    FUN    0      51     f01001f4 3061   serial_proc_data:f(0,1)
stabs:219:210    FUN    0      0      00000044 0
stabs:221:212    FUN    0      59     f0100238 3085   serial_intr:F(0,18)
stabs:227:218    FUN    0      0      0000001f 0
stabs:229:220    FUN    0      66     f0100257 3105   serial_putc:f(0,18)
stabs:251:242    FUN    0      0      00000059 0
stabs:253:244    FUN    0      79     f01002b0 3142   serial_init:f(0,18)
stabs:266:257    FUN    0      0      000000cb 0
stabs:268:259    FUN    0      112    f010037b 3162   lpt_putc:f(0,18)
stabs:289:280    FUN    0      0      00000079 0
stabs:291:282    FUN    0      133    f01003f4 3179   cga_init:f(0,18)
stabs:330:321    FUN    0      0      000000cc 0
stabs:332:323    FUN    0      163    f01004c0 3241   cga_putc:f(0,18)
stabs:381:372    FUN    0      0      00000212 0
stabs:383:374    FUN    0      316    f01006d2 3258   kbd_proc_data:f(0,1)
stabs:433:424    FUN    0      0      00000189 0
stabs:435:426    FUN    0      364    f010085b 3311   kbd_intr:F(0,18)
stabs:440:431    FUN    0      0      00000014 0
stabs:442:433    FUN    0      370    f010086f 3328   kbd_init:f(0,18)
stabs:446:437    FUN    0      0      00000005 0
stabs:448:439    FUN    0      392    f0100874 3345   cons_intr:f(0,18)
stabs:463:454    FUN    0      0      0000004d 0
stabs:465:456    FUN    0      407    f01008c1 3391   cons_getc:F(0,1)
stabs:480:471    FUN    0      0      0000005c 0
stabs:482:473    FUN    0      429    f010091d 3408   cons_putc:f(0,18)
stabs:490:481    FUN    0      0      00000029 0
stabs:492:483    FUN    0      438    f0100946 3426   cons_init:F(0,18)
{% endhighlight %}

至于为何会出现106行那样的entry, 我至今没有结果. 希望知道的朋友可以留言. 但是, 我写了一个简单的 *stabs_fix* 去除那些我暂时认为是无效的条目.
即在 *debuginfo_eip* 开始阶段手动标记那些条目, 这样在 *stab_binsearch* 的时候则不会采用他们.

{% highlight c %}
// add a quick & dirct fix to skip stabs N_FUN entry with n_value below KERNBASE

#define N_INVAILD_FUN 0x73
static void stabs_fix()
{
    const struct Stab *stabs, *stab_end;
    stabs = __STAB_BEGIN__;
    stab_end = __STAB_END__;
    static int is_fixed = 0;
    int i = 0;
    uint8_t *p_fix;
    if(is_fixed)
        return ;
    for(; i < stab_end - stabs; i++) {
        if ((stabs[i].n_type == N_FUN) && (stabs[i].n_value < KERNBASE)) {
            p_fix = (uint8_t *)&stabs[i].n_type;
            *p_fix = N_INVAILD_FUN;
        }
    }
    cprintf("stabs fixed!\n");
    is_fixed = 1;
}

{% endhighlight %}

于是, 问题都解决了. 完整代码可以见[github][2]


[1]: http://www.math.utah.edu/docs/info/stabs_toc.html#SEC52
[2]: https://github.com/sunuslee/Mit-6.828-Fall-2012/commit/b40ecde68da8c9482bf1b4b4cfff7599afa135ec
