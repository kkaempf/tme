AS_INIT

# $Id: m68k-misc-auto.sh,v 1.11 2007/02/16 02:50:23 fredette Exp $

# ic/m68k/m68k-misc-auto.sh - automatically generates C code 
# for miscellaneous m68k emulation support:

#
# Copyright (c) 2002, 2003 Matt Fredette
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by Matt Fredette.
# 4. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

header=false

for option
do
    case $option in
    --header) header=true ;;
    esac
done

PROG=`basename $0`
cat <<EOF
/* automatically generated by $PROG, do not edit! */
EOF

# we need our own inclusion protection, since the instruction word
# fetch macros need to be multiply included:
if $header; then
    AS_ECHO([""])
    AS_ECHO(["#ifndef _IC_M68K_MISC_H"])
    AS_ECHO(["#define _IC_M68K_MISC_H"])
fi

# emit the register mapping macros:
if $header; then

    AS_ECHO([""])
    AS_ECHO(["/* the register mapping: */"])
    AS_ECHO(["#define TME_M68K_IREG_UNDEF		(-1)"])
    ireg32_next=0
    
    # NB: these are in a deliberate order, matching the order of
    # registers in instruction encodings:
    for regtype in d a; do
	capregtype=`AS_ECHO([${regtype}]) | tr a-z A-Z`
	for regnum in 0 1 2 3 4 5 6 7; do
	    AS_ECHO(["#define TME_M68K_IREG_${capregtype}${regnum}		(${ireg32_next})"])
	    AS_ECHO(["#define tme_m68k_ireg_${regtype}${regnum}		tme_m68k_ireg_uint32(TME_M68K_IREG_${capregtype}${regnum})"])
	    ireg32_next=`expr ${ireg32_next} + 1`
	done
    done

    # the current, next, and last program counter:
    AS_ECHO(["#define TME_M68K_IREG_PC		(${ireg32_next})"])
    AS_ECHO(["#define tme_m68k_ireg_pc		tme_m68k_ireg_uint32(TME_M68K_IREG_PC)"])
    ireg32_next=`expr ${ireg32_next} + 1`
    AS_ECHO(["#define TME_M68K_IREG_PC_NEXT		(${ireg32_next})"])
    AS_ECHO(["#define tme_m68k_ireg_pc_next		tme_m68k_ireg_uint32(TME_M68K_IREG_PC_NEXT)"])
    ireg32_next=`expr ${ireg32_next} + 1`
    AS_ECHO(["#define TME_M68K_IREG_PC_LAST		(${ireg32_next})"])
    AS_ECHO(["#define tme_m68k_ireg_pc_last		tme_m68k_ireg_uint32(TME_M68K_IREG_PC_LAST)"])
    ireg32_next=`expr ${ireg32_next} + 1`
    
    # the status register and ccr:
    AS_ECHO(["#define tme_m68k_ireg_sr		tme_m68k_ireg_uint16(${ireg32_next} << 1)"])
    AS_ECHO(["#define tme_m68k_ireg_ccr		tme_m68k_ireg_uint8(${ireg32_next} << 2)"])
    ireg32_next=`expr ${ireg32_next} + 1`

    # the shadow status register and format/offset word:
    AS_ECHO(["#define TME_M68K_IREG_SHADOW_SR	(${ireg32_next} << 1)"])
    AS_ECHO(["#define tme_m68k_ireg_shadow_sr	tme_m68k_ireg_uint16(TME_M68K_IREG_SHADOW_SR)"])
    AS_ECHO(["#define TME_M68K_IREG_FORMAT_OFFSET	((${ireg32_next} << 1) + 1)"])
    AS_ECHO(["#define tme_m68k_ireg_format_offset	tme_m68k_ireg_uint16(TME_M68K_IREG_FORMAT_OFFSET)"])
    ireg32_next=`expr ${ireg32_next} + 1`

    # the memory buffers:
    for mem_which in x y z; do
	cap_mem_which=`AS_ECHO([${mem_which}]) | tr a-z A-Z`
	AS_ECHO(["#define TME_M68K_IREG_MEM${cap_mem_which}32		(${ireg32_next})"])
	AS_ECHO(["#define tme_m68k_ireg_mem${mem_which}32		tme_m68k_ireg_uint32(TME_M68K_IREG_MEM${cap_mem_which}32)"])
	AS_ECHO(["#define TME_M68K_IREG_MEM${cap_mem_which}16		(${ireg32_next} << 1)"])
	AS_ECHO(["#define tme_m68k_ireg_mem${mem_which}16		tme_m68k_ireg_uint16(TME_M68K_IREG_MEM${cap_mem_which}16)"])
	AS_ECHO(["#define TME_M68K_IREG_MEM${cap_mem_which}8		(${ireg32_next} << 2)"])
	AS_ECHO(["#define tme_m68k_ireg_mem${mem_which}8		tme_m68k_ireg_uint8(TME_M68K_IREG_MEM${cap_mem_which}8)"])
	ireg32_next=`expr ${ireg32_next} + 1`
    done

    # the control registers:
    for reg in usp isp msp sfc dfc vbr cacr caar; do
	capreg=`AS_ECHO([$reg]) | tr a-z A-Z`
	AS_ECHO(["#define TME_M68K_IREG_${capreg}		(${ireg32_next})"])
	AS_ECHO(["#define tme_m68k_ireg_${reg}		tme_m68k_ireg_uint32(TME_M68K_IREG_${capreg})"])
	ireg32_next=`expr ${ireg32_next} + 1`
    done

    # this is the count of variable 32-bit registers:
    AS_ECHO(["#define TME_M68K_IREG32_COUNT		(${ireg32_next})"])

    # the immediate register.  there are actually three 32-bit
    # registers in a row, to allow the fpgen specop to fetch up to a
    # 96-bit immediate:
    AS_ECHO(["#define TME_M68K_IREG_IMM32		(${ireg32_next})"])
    AS_ECHO(["#define tme_m68k_ireg_imm32		tme_m68k_ireg_uint32(TME_M68K_IREG_IMM32)"])
    ireg32_next=`expr ${ireg32_next} + 3`

    # the effective address register:
    AS_ECHO(["#define TME_M68K_IREG_EA		(${ireg32_next})"])
    AS_ECHO(["#define tme_m68k_ireg_ea		tme_m68k_ireg_uint32(TME_M68K_IREG_EA)"])
    ireg32_next=`expr ${ireg32_next} + 1`

    # the constant registers:
    for reg in zero one two three four five six seven eight; do
	capreg=`AS_ECHO([$reg]) | tr a-z A-Z`
	AS_ECHO(["#define TME_M68K_IREG_${capreg}		(${ireg32_next})"])
	ireg32_next=`expr ${ireg32_next} + 1`
    done
fi

# emit the flags->conditions mapping.  note that the nesting of the
# flag variables is deliberate, to make this array indexable with the
# condition code register:
if $header; then :; else
    AS_ECHO([""])
    AS_ECHO(["/* the flags->conditions mapping: */"])
    AS_ECHO(["const tme_uint16_t _tme_m68k_conditions[[32]] = {"])
    for xflag in 0 1; do
	for nflag in 0 1; do
	    for zflag in 0 1; do
		for vflag in 0 1; do
		    for cflag in 0 1; do
		    
			# the True condition:
			AS_ECHO_N(["TME_BIT(TME_M68K_C_T)"])
			
			# the High condition:
			if test $cflag != 1 && test $zflag != 1; then
			    AS_ECHO_N([" | TME_BIT(TME_M68K_C_HI)"])
			fi
			
			# the Low or Same condition:
			if test $cflag = 1 || test $zflag = 1; then
			    AS_ECHO_N([" | TME_BIT(TME_M68K_C_LS)"])
			fi
			
			# the Carry Clear and Carry Set conditions:
			if test $cflag != 1; then
			    AS_ECHO_N([" | TME_BIT(TME_M68K_C_CC)"])
			else
			    AS_ECHO_N([" | TME_BIT(TME_M68K_C_CS)"])
			fi
			
			# the Not Equal and Equal conditions:
			if test $zflag != 1; then
			    AS_ECHO_N([" | TME_BIT(TME_M68K_C_NE)"])
			else
			    AS_ECHO_N([" | TME_BIT(TME_M68K_C_EQ)"])
			fi
			
			# the Overflow Clear and Overflow Set conditions:
			if test $vflag != 1; then
			    AS_ECHO_N([" | TME_BIT(TME_M68K_C_VC)"])
			else
			    AS_ECHO_N([" | TME_BIT(TME_M68K_C_VS)"])
			fi
			
			# the Plus and Minus conditions:
			if test $nflag != 1; then
			    AS_ECHO_N([" | TME_BIT(TME_M68K_C_PL)"])
			else
			    AS_ECHO_N([" | TME_BIT(TME_M68K_C_MI)"])
			fi
			
			# the Greater or Equal condition:
			if (test $nflag = 1 && test $vflag = 1) || \
			   (test $nflag != 1 && test $vflag != 1); then
			    AS_ECHO_N([" | TME_BIT(TME_M68K_C_GE)"])
			fi
			
			# the Less Than condition:
			if (test $nflag = 1 && test $vflag != 1) || \
			   (test $nflag != 1 && test $vflag = 1); then
			    AS_ECHO_N([" | TME_BIT(TME_M68K_C_LT)"])
			fi

			# the Greater Than condition:
			if (test $nflag = 1 && test $vflag = 1 && test $zflag != 1) || \
			   (test $nflag != 1 && test $vflag != 1 && test $zflag != 1); then
			    AS_ECHO_N([" | TME_BIT(TME_M68K_C_GT)"])
			fi
		    
			# the Less Than or Equal condition:
			if test $zflag = 1 || \
			   (test $nflag = 1 && test $vflag != 1) || \
			   (test $nflag != 1 && test $vflag = 1); then
			    AS_ECHO_N([" | TME_BIT(TME_M68K_C_LE)"])
			fi

			AS_ECHO([","])
		    done
		done
	    done
	done
    done
    AS_ECHO(["};"])
fi

# emit the instruction word fetch macros:
if $header; then

    # emit the simple signed and unsigned fetch macros:
    #
    AS_ECHO([""])
    AS_ECHO(["/* the simple signed and unsigned fetch macros: */"])

    # permute over size:
    #
    for size in 16 32; do

	# permute for signed or unsigned:
	#
	for capsign in U S; do
	    if test $capsign = U; then sign=u ; un=un ; else sign= ; un= ; fi

	    AS_ECHO(["#define _TME_M68K_EXECUTE_FETCH_${capsign}${size}(v) \\"])
	    AS_ECHO(["  _TME_M68K_EXECUTE_FETCH_${size}(tme_${sign}int${size}_t, v)"])
	    if test ${size} = 16 && test ${capsign} = U; then
		AS_ECHO(["#define _TME_M68K_EXECUTE_FETCH_${capsign}${size}_FIXED(v, field) \\"])
		AS_ECHO(["  _TME_M68K_EXECUTE_FETCH_${size}_FIXED(tme_${sign}int${size}_t, v, field)"])
	    fi
	done
    done

    AS_ECHO([""])
    AS_ECHO(["#endif /* _IC_M68K_MISC_H */"])

    # permute for the fast vs. slow executors:
    for executor in fast slow; do

	AS_ECHO([""])
	AS_ECHO_N(["#if"])
	if test $executor = slow; then AS_ECHO_N(["n"]); fi
	AS_ECHO(["def _TME_M68K_EXECUTE_FAST"])
	AS_ECHO([""])
	AS_ECHO(["/* these macros are for the ${executor} executor: */"])

	# permute over size:
	#
	for size in 16 32; do

	    AS_ECHO([""])
	    AS_ECHO(["/* this fetches a ${size}-bit value for the ${executor} executor: */"])
	    AS_ECHO(["#undef _TME_M68K_EXECUTE_FETCH_${size}"])
	    AS_ECHO(["#define _TME_M68K_EXECUTE_FETCH_${size}(type, v) \\"])

	    if test $executor = slow; then

		# this expression gives the current fetch offset in the instruction:
		#
		offset_fetch="ic->_tme_m68k_insn_fetch_slow_next"

		AS_ECHO(["  /* macros for the ${executor} executor are simple, because \\"])
		AS_ECHO(["     tme_m68k_fetch${size}() takes care of all endianness, alignment, \\"])
		AS_ECHO(["     and atomic issues, and also stores the fetched value in the \\"])
		AS_ECHO(["     instruction fetch buffer (if a previous fetch before a fault \\"])
		AS_ECHO(["     didn't store all or part of it there already): */ \\"])
		AS_ECHO(["  (v) = (type) tme_m68k_fetch${size}(ic, linear_pc); \\"])
		AS_ECHO(["  linear_pc += sizeof(tme_uint${size}_t)"])
	    
	    else

		# this expression gives the current fetch offset in the instruction:
		#
		offset_fetch="(fetch_fast_next - ic->_tme_m68k_insn_fetch_fast_start)"
		
		AS_ECHO(["  /* use the raw fetch macro to fetch the value into the variable, \\"])
		AS_ECHO(["     and then save it in the instruction buffer.  the save doesn't \\"])
		AS_ECHO(["     need to be atomic; no one else can see the instruction buffer. \\"])
		AS_ECHO(["     however, the raw fetch macro has already advanced fetch_fast_next, \\"])
		AS_ECHO(["     so we need to compensate for that here: */ \\"])
		AS_ECHO(["  __TME_M68K_EXECUTE_FETCH_${size}(type, v); \\"])
		AS_ECHO(["  tme_memory_write${size}(((tme_uint${size}_t *) ((((tme_uint8_t *) &ic->_tme_m68k_insn_fetch_buffer[[0]]) - sizeof(tme_uint${size}_t)) + ${offset_fetch})), (tme_uint${size}_t) (v), sizeof(tme_uint16_t))"])

		AS_ECHO([""])
		AS_ECHO(["/* this does a raw fetch of a ${size}-bit value for the ${executor} executor: */"])
		AS_ECHO(["#undef __TME_M68K_EXECUTE_FETCH_${size}"])
		AS_ECHO(["#define __TME_M68K_EXECUTE_FETCH_${size}(type, v) \\"])
		AS_ECHO(["  /* if we can't do the fast read, we need to redispatch: */ \\"])
		AS_ECHO(["  /* NB: checks in tme_m68k_go_slow(), and proper setting of \\"])
		AS_ECHO(["     ic->_tme_m68k_insn_fetch_fast_last in _TME_M68K_EXECUTE_NAME(), \\"])
		AS_ECHO(["     allow  us to do a simple pointer comparison here, for \\"])
		AS_ECHO(["     any fetch size: */ \\"])
		AS_ECHO(["  if (__tme_predict_false(fetch_fast_next > ic->_tme_m68k_insn_fetch_fast_last)) \\"])
		AS_ECHO(["    goto _tme_m68k_fast_fetch_failed; \\"])
		AS_ECHO(["  (v) = ((type) \\"])
		AS_ECHO(["         tme_betoh_u${size}(tme_memory_bus_read${size}((const tme_shared tme_uint${size}_t *) fetch_fast_next, \\"])
		AS_ECHO(["                                             tlb->tme_m68k_tlb_bus_rwlock, \\"])
		AS_ECHO(["                                             sizeof(tme_uint16_t), \\"])
		AS_ECHO(["                                             sizeof(tme_uint32_t)))); \\"])
		AS_ECHO(["  fetch_fast_next += sizeof(tme_uint${size}_t)"])
	    fi

	    # if this size doesn't get a fixed fetch macro, continue now:
	    #
	    if test ${size} != 16; then
		continue
	    fi

	    AS_ECHO([""])
	    AS_ECHO(["/* this fetches a ${size}-bit value at a fixed instruction position"])
	    AS_ECHO(["   for the ${executor} executor: */"])
	    AS_ECHO(["#undef _TME_M68K_EXECUTE_FETCH_${size}_FIXED"])
	    AS_ECHO(["#define _TME_M68K_EXECUTE_FETCH_${size}_FIXED(type, v, field) \\"])
	    AS_ECHO(["  assert(&((struct tme_m68k *) 0)->field \\"])
	    AS_ECHO(["         == (type *) (((tme_uint8_t *) &((struct tme_m68k *) 0)->_tme_m68k_insn_fetch_buffer[[0]]) + ${offset_fetch})); \\"])
	    AS_ECHO_N(["  "])
	    if test ${executor} = fast; then AS_ECHO_N([_]) ; fi
	    AS_ECHO(["_TME_M68K_EXECUTE_FETCH_${size}(type, v)"])

	done

	AS_ECHO([""])
	AS_ECHO_N(["#endif /* "])
	if test $executor = slow; then AS_ECHO_N(["!"]); fi
	AS_ECHO(["_TME_M68K_EXECUTE_FAST */"])
    done
fi

# done:
exit 0
