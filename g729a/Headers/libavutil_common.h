/*
 * copyright (c) 2006 Michael Niedermayer <michaelni@gmx.at>
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

/**
 * @file libavutil/common.h
 * common internal and external API header
 */

#ifndef AVUTIL_COMMON_H
#define AVUTIL_COMMON_H

#define FFMAX(a,b) ((a) > (b) ? (a) : (b))
#define FFMIN(a,b) ((a) > (b) ? (b) : (a))

#define FFSWAP(type,a,b) do{type SWAP_tmp= b; b= a; a= SWAP_tmp;}while(0)

/**
 * Clips a signed integer value into the amin-amax range.
 * @param a value to clip
 * @param amin minimum value of the clip range
 * @param amax maximum value of the clip range
 * @return clipped value
 */
static inline Word32 av_clip(Word32 a, Word32 amin, Word32 amax)
{
  if      (a < amin) return amin;
  else if (a > amax) return amax;
  else               return a;
}

/**
 * Clips a signed integer value into the 0-255 range.
 * @param a value to clip
 * @return clipped value
 */
static inline UWord8 av_clip_uint8(Word32 a)
{
  if (a&(~255)) return (-a)>>31;
  else          return a;
}

/**
 * Clips a signed integer value into the -32768,32767 range.
 * @param a value to clip
 * @return clipped value
 */
static inline Word16 av_clip_int16(Word32 a)
{
  if ((a+32768) & ~65535) return (a>>31) ^ 32767;
  else                    return a;
}


#endif /* AVUTIL_COMMON_H */

