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

#include "typedef.h"
#include "basic_op.h"
#include "ld8a.h"

/*-----------------------------------------------------*
 * procedure Syn_filt:                                 *
 *           ~~~~~~~~                                  *
 * Do the synthesis filtering 1/A(z).                  *
 *-----------------------------------------------------*/

/* ff_celp_lp_synthesis_filter */
void Syn_filt(
  Word16 a[],     /* (i) Q12 : a[m+1] prediction coefficients   (m=10)  */
  Word16 x[],     /* (i)     : input signal                             */
  Word16 y[],     /* (o)     : output signal                            */
  Word16 lg,      /* (i)     : size of filtering                        */
  Word16 mem[],   /* (i/o)   : memory associated with this filtering.   */
  Word16 update   /* (i)     : 0=no update, 1=update of memory.         */
)
{
  Word16 i, j;
  Word32 s;
  Word16 tmp[100];     /* This is usually done by memory allocation (lg+M) */
  Word16 *yy;

  /* Copy mem[] to yy[] */

  yy = tmp;
  Copy(mem, yy, M);
  yy += M;

  /* Do the filtering. */

  for (i = 0; i < lg; i++)
  {
    s = x[i] * a[0];
    for (j = 1; j <= M; j++)
      s -= a[j] * yy[-j];

    s <<= 4;
    *yy++ = g_round(s);
    //*y++ = (Word16)((s + 0x8000L) >> 16);
    /*s >>= 12;
    if(s + 0x8000 > 0xFFFFU)
    {
      s = (s >> 31) ^ 32767;
    }
    *yy++ = s;*/
  }

  Copy(&tmp[M], y, lg);

  /* Update of memory if update==1 */
  if(update)
    Copy(&y[lg-M], mem, M);
}

/*-----------------------------------------------------------------------*
 * procedure Residu:                                                     *
 *           ~~~~~~                                                      *
 * Compute the LPC residual  by filtering the input speech through A(z)  *
 *-----------------------------------------------------------------------*/

void Residu(
  Word16 a[],    /* (i) Q12 : prediction coefficients                     */
  Word16 x[],    /* (i)     : speech (values x[-m..-1] are needed         */
  Word16 y[],    /* (o)     : residual signal                             */
  Word16 lg      /* (i)     : size of filtering                           */
)
{
  Word16 i, j;
  Word32 s;

  for (i = 0; i < lg; i++)
  {
    s = x[i] * a[0];
    for (j = 1; j <= M; j++)
      s += a[j] * x[i-j];

    s <<= 4;
    y[i] = g_round(s);
  }
  return;
}

