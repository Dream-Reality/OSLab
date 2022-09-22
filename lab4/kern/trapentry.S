/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(Handler_DIVIDE, T_DIVIDE)
TRAPHANDLER_NOEC(Handler_DEBUG, T_DEBUG)
TRAPHANDLER_NOEC(Handler_NMI, T_NMI)
TRAPHANDLER_NOEC(Handler_BRKPT, T_BRKPT)
TRAPHANDLER_NOEC(Handler_OFLOW, T_OFLOW)
TRAPHANDLER_NOEC(Handler_BOUND, T_BOUND)
TRAPHANDLER_NOEC(Handler_ILLOP, T_ILLOP)
TRAPHANDLER_NOEC(Handler_DEVICE, T_DEVICE)
TRAPHANDLER(Handler_DBLFLT, T_DBLFLT)
TRAPHANDLER(Handler_TSS, T_TSS)
TRAPHANDLER(Handler_SEGNP, T_SEGNP)
TRAPHANDLER(Handler_STACK, T_STACK)
TRAPHANDLER(Handler_GPFLT, T_GPFLT)
TRAPHANDLER(Handler_PGFLT, T_PGFLT)
TRAPHANDLER_NOEC(Handler_FPERR, T_FPERR)
TRAPHANDLER(Handler_ALIGN, T_ALIGN)
TRAPHANDLER_NOEC(Handler_MCHK, T_MCHK)
TRAPHANDLER_NOEC(Handler_SIMDERR, T_SIMDERR)
TRAPHANDLER_NOEC(Handler_SYSCALL, T_SYSCALL)



TRAPHANDLER_NOEC(Handler_IRQ0, IRQ_OFFSET)
TRAPHANDLER_NOEC(Handler_IRQ1, IRQ_OFFSET+1)
TRAPHANDLER_NOEC(Handler_IRQ2, IRQ_OFFSET+2)
TRAPHANDLER_NOEC(Handler_IRQ3, IRQ_OFFSET+3)
TRAPHANDLER_NOEC(Handler_IRQ4, IRQ_OFFSET+4)
TRAPHANDLER_NOEC(Handler_IRQ5, IRQ_OFFSET+5)
TRAPHANDLER_NOEC(Handler_IRQ6, IRQ_OFFSET+6)
TRAPHANDLER_NOEC(Handler_IRQ7, IRQ_OFFSET+7)
TRAPHANDLER_NOEC(Handler_IRQ8, IRQ_OFFSET+8)
TRAPHANDLER_NOEC(Handler_IRQ9, IRQ_OFFSET+9)
TRAPHANDLER_NOEC(Handler_IRQ10, IRQ_OFFSET+10)
TRAPHANDLER_NOEC(Handler_IRQ11, IRQ_OFFSET+11)
TRAPHANDLER_NOEC(Handler_IRQ12, IRQ_OFFSET+12)
TRAPHANDLER_NOEC(Handler_IRQ13, IRQ_OFFSET+13)
TRAPHANDLER_NOEC(Handler_IRQ14, IRQ_OFFSET+14)
TRAPHANDLER_NOEC(Handler_IRQ15, IRQ_OFFSET+15)
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushw $0x0
    pushw %ds
	pushw $0x0
    pushw %es
    pushal
    movl $GD_KD, %eax
    movw %ax, %ds
    movw %ax, %es
    push %esp
    call trap