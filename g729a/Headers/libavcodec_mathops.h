/*
 * simple math operations
 * Copyright (c) 2006 Michael Niedermayer <michaelni@gmx.at> et al
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#ifndef AVCODEC_ARM_MATHOPS_H
#define AVCODEC_ARM_MATHOPS_H

#include <stdint.h>
#include "libavutil_common.h"

#   define MULL MULL
static inline int MULL(int a, int b, unsigned shift)
{
    int lo, hi;
    __asm__("smull %0, %1, %2, %3     \n\t"
            "mov   %0, %0,     lsr %4 \n\t"
            "add   %1, %0, %1, lsl %5 \n\t"
            : "=&r"(lo), "=&r"(hi)
            : "r"(b), "r"(a), "ir"(shift), "ir"(32-shift));
    return hi;
}

#endif /* AVCODEC_ARM_MATHOPS_H */
