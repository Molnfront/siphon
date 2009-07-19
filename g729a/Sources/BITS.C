/**
 *  g729a codec for iPhone and iPod Touch
 *  Copyright (C) 2009 Samuel <samuelv0304@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

/*****************************************************************************/
/* bit stream manipulation routines                                          */
/*****************************************************************************/
#include "typedef.h"
#include "ld8a.h"
#include "tab_ld8a.h"

#include "libavcodec_get_bits.h"
#include "libavcodec_put_bits.h"

/*----------------------------------------------------------------------------
 * prm2bits_ld8k -converts encoder parameter vector into vector of serial bits
 * bits2prm_ld8k - converts serial received bits to  encoder parameter vector
 *
 * The transmitted parameters are:
 *
 *     LPC:     1st codebook           7+1 bit
 *              2nd codebook           5+5 bit
 *
 *     1st subframe:
 *          pitch period                 8 bit
 *          parity check on 1st period   1 bit
 *          codebook index1 (positions) 13 bit
 *          codebook index2 (signs)      4 bit
 *          pitch and codebook gains   4+3 bit
 *
 *     2nd subframe:
 *          pitch period (relative)      5 bit
 *          codebook index1 (positions) 13 bit
 *          codebook index2 (signs)      4 bit
 *          pitch and codebook gains   4+3 bit
 *----------------------------------------------------------------------------
 */
void prm2bits_ld8k(
                    Word16 prm[],           /* input : encoded parameters  (PRM_SIZE parameters)  */
                    UWord8 *bits            /* output: serial bits (SERIAL_SIZE )*/
)
{
  PutBitContext pb;
  int i;

  init_put_bits(&pb, bits, 10);
  for (i = 0; i < PRM_SIZE; ++i)
    put_bits(&pb, bitsno[i], prm[i]);
  flush_put_bits(&pb);
}

/*----------------------------------------------------------------------------
 *  bits2prm_ld8k - converts serial received bits to  encoder parameter vector
 *----------------------------------------------------------------------------
 */
void bits2prm_ld8k(
                   UWord8  *bits,            /* input : serial bits (80)                       */
                   Word16   prm[]            /* output: decoded parameters (11 parameters)     */
)
{
  GetBitContext gb;
  int i;

  init_get_bits(&gb, bits, 10 /*buf_size*/);
  for (i = 0; i < PRM_SIZE; ++i)
    prm[i] = get_bits(&gb, bitsno[i]);
}
