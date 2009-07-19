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

/*------------------------------------------------------------------------*
 * Function Post_Process()                                                *
 *                                                                        *
 * Post-processing of output speech.                                      *
 *   - 2nd order high pass filter with cut off frequency at 100 Hz.       *
 *   - Multiplication by two of output speech with saturation.            *
 *-----------------------------------------------------------------------*/

#include "typedef.h"
#include "ld8a.h"

#include "libavutil_common.h"

/*------------------------------------------------------------------------*
 * 2nd order high pass filter with cut off frequency at 100 Hz.           *
 * Designed with SPPACK efi command -40 dB att, 0.25 ri.                  *
 *                                                                        *
 * Algorithm:                                                             *
 *                                                                        *
 *  y[i] = b[0]*x[i]   + b[1]*x[i-1]   + b[2]*x[i-2]                      *
 *                     + a[1]*y[i-1]   + a[2]*y[i-2];                     *
 *                                                                        *
 *     b[3] = {0.93980581E+00, -0.18795834E+01, 0.93980581E+00};          *
 *     a[3] = {0.10000000E+01, 0.19330735E+01, -0.93589199E+00};          *
 *-----------------------------------------------------------------------*/
static Word32 y1, y2;
static Word16 x1, x2;

void Init_Post_Process(void)
{
  y1 = 0LL;
  y2 = 0LL;
  x1 = 0;
  x2 = 0;
}

/* acelp_high_pass_filter */
void Post_Process(
                  Word16 signal[],    /* input/output signal */
                  Word16 lg)          /* length of signal    */
{
  Word16 i;
  Word32 tmp;

  for (i = 0; i < lg; i++)
  {
    tmp  = (y1 * 15836LL) >> 13;
    tmp += (y2 * -7667LL) >> 13;
    tmp += 7699 * (signal[i] - 2*x1/*signal[i-1]*/ + x2/*signal[i-2]*/);

    x2 = x1;
    x1 = signal[i];

    /* With "+0x800" rounding, clipping is needed
     for ALGTHM and SPEECH tests. */
    signal[i] = av_clip_int16((tmp + 0x800) >> 12);

    y2 = y1;
    y1 = tmp;
  }
}

