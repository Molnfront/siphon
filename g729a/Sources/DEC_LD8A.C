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

/*-----------------------------------------------------------------*
 *   Functions Init_Decod_ld8a  and Decod_ld8a                     *
 *-----------------------------------------------------------------*/

#include "typedef.h"
#include "basic_op.h"
#include "ld8a.h"

/*---------------------------------------------------------------*
 *   Decoder constant parameters (defined in "ld8a.h")           *
 *---------------------------------------------------------------*
 *   L_FRAME     : Frame size.                                   *
 *   L_SUBFR     : Sub-frame size.                               *
 *   M           : LPC order.                                    *
 *   MP1         : LPC order+1                                   *
 *   PIT_MIN     : Minimum pitch lag.                            *
 *   PIT_MAX     : Maximum pitch lag.                            *
 *   L_INTERPOL  : Length of filter for interpolation            *
 *   PRM_SIZE    : Size of vector containing analysis parameters *
 *---------------------------------------------------------------*/

/*--------------------------------------------------------*
 *         Static memory allocation.                      *
 *--------------------------------------------------------*/

        /* Excitation vector */

 static Word16 old_exc[L_FRAME+PIT_MAX+L_INTERPOL];
 static Word16 *exc;

        /* Lsp (Line spectral pairs) */

 static Word16 lsp_old[M]={
             30000, 26000, 21000, 15000, 8000, 0, -8000,-15000,-21000,-26000};

        /* Filter's memory */

 static Word16 mem_syn[M];

 static Word16 sharp;           /* pitch sharpening of previous frame */
 static Word16 old_T0;          /* integer delay of previous frame    */
 static Word16 gain_code;       /* Code gain                          */
 static Word16 gain_pitch;      /* Pitch gain                         */

/*-----------------------------------------------------------------*
 *   Function Init_Decod_ld8a                                      *
 *            ~~~~~~~~~~~~~~~                                      *
 *                                                                 *
 *   ->Initialization of variables for the decoder section.        *
 *                                                                 *
 *-----------------------------------------------------------------*/

void Init_Decod_ld8a(void)
{

  /* Initialize static pointer */

  exc = old_exc + PIT_MAX + L_INTERPOL;

  /* Static vectors to zero */

  Set_zero(old_exc, PIT_MAX+L_INTERPOL);
  Set_zero(mem_syn, M);

  sharp  = SHARPMIN;
  old_T0 = 60;
  gain_code = 0;
  gain_pitch = 0;

  Lsp_decw_reset();
 return;
}

/*-----------------------------------------------------------------*
 *   Function Decod_ld8a                                           *
 *           ~~~~~~~~~~                                            *
 *   ->Main decoder routine.                                       *
 *                                                                 *
 *-----------------------------------------------------------------*/

void Decod_ld8a(
  Word16  parm[],      /* (i)   : vector of synthesis parameters
                                  parm[0] = bad frame indicator (bfi)  */
  Word16  synth[],     /* (o)   : synthesis speech                     */
  Word16  A_t[],       /* (o)   : decoded LP filter in 2 subframes     */
  Word16  *T2          /* (o)   : decoded pitch lag in 2 subframes     */
)
{
  Word16  *Az;                  /* Pointer on A_t   */
  Word16  lsp_new[M];           /* LSPs             */
  Word16  code[L_SUBFR];        /* ACELP codevector */

  /* Scalars */

  Word16  i, j, i_subfr;
  Word16  T0, T0_frac, index;
  Word16  bfi;
  Word32  L_temp;

  Word16 bad_pitch;             /* bad pitch indicator */
  extern Word16 bad_lsf;        /* bad LSF indicator   */

  /* Test bad frame indicator (bfi) */

  bfi = *parm++;

  /* Decode the LSPs */

  D_lsp(parm, lsp_new, add(bfi, bad_lsf));
  parm += 2;

  /*
  Note: "bad_lsf" is introduce in case the standard is used with
         channel protection.
  */

  /* Interpolation of LPC for the 2 subframes */

  Int_qlpc(lsp_old, lsp_new, A_t);

  /* update the LSFs for the next frame */

  Copy(lsp_new, lsp_old, M);

/*------------------------------------------------------------------------*
 *          Loop for every subframe in the analysis frame                 *
 *------------------------------------------------------------------------*
 * The subframe size is L_SUBFR and the loop is repeated L_FRAME/L_SUBFR  *
 *  times                                                                 *
 *     - decode the pitch delay                                           *
 *     - decode algebraic code                                            *
 *     - decode pitch and codebook gains                                  *
 *     - find the excitation and compute synthesis speech                 *
 *------------------------------------------------------------------------*/

  Az = A_t;            /* pointer to interpolated LPC parameters */

  for (i_subfr = 0; i_subfr < L_FRAME; i_subfr += L_SUBFR)
  {

    index = *parm++;            /* pitch index */

    if(i_subfr == 0)
      bad_pitch = bfi + *parm++; /* get parity check result */
    else
      bad_pitch = bfi;
    if( bad_pitch == 0)
    {
      Dec_lag3(index, PIT_MIN, PIT_MAX, i_subfr, &T0, &T0_frac);
      old_T0 = T0;
    }
    else        /* Bad frame, or parity error */
    {
      T0  =  old_T0++;
      T0_frac = 0;
      if( old_T0 > PIT_MAX)
          old_T0 = PIT_MAX;
    }
    *T2++ = T0;

   /*-------------------------------------------------*
    * - Find the adaptive codebook vector.            *
    *-------------------------------------------------*/

    Pred_lt_3(&exc[i_subfr], T0, T0_frac, L_SUBFR);

   /*-------------------------------------------------------*
    * - Decode innovative codebook.                         *
    * - Add the fixed-gain pitch contribution to code[].    *
    *-------------------------------------------------------*/

    if(bfi != 0)        /* Bad frame */
    {

      parm[0] = Random() & (Word16)0x1fff;     /* 13 bits random */
      parm[1] = Random() & (Word16)0x000f;     /*  4 bits random */
    }
    Decod_ACELP(parm[1], parm[0], code);
    parm +=2;

    j = shl(sharp, 1);          /* From Q14 to Q15 */
    if(T0 < L_SUBFR ) {
        for (i = T0; i < L_SUBFR; i++) {
          //code[i] = add(code[i], mult(code[i-T0], j));
          code[i] += ((Word32)code[i-T0] * (Word32)j) >> 15;
        }
    }

   /*-------------------------------------------------*
    * - Decode pitch and codebook gains.              *
    *-------------------------------------------------*/

    index = *parm++;      /* index of energy VQ */

    Dec_gain(index, code, L_SUBFR, bfi, &gain_pitch, &gain_code);

   /*-------------------------------------------------------------*
    * - Update pitch sharpening "sharp" with quantized gain_pitch *
    *-------------------------------------------------------------*/

    sharp = gain_pitch;
    if (sharp > SHARPMAX) { sharp = SHARPMAX;  }
    if (sharp < SHARPMIN) { sharp = SHARPMIN;  }

   /*-------------------------------------------------------*
    * - Find the total excitation.                          *
    * - Find synthesis speech corresponding to exc[].       *
    *-------------------------------------------------------*/

    for (i = 0; i < L_SUBFR;  i++)
    {
       /* exc[i] = gain_pitch*exc[i] + gain_code*code[i]; */
       /* exc[i]  in Q0   gain_pitch in Q14               */
       /* code[i] in Q13  gain_codeode in Q1              */
       L_temp = (exc[i+i_subfr] * gain_pitch + code[i] * gain_code) << 2;
       exc[i+i_subfr] = g_round(L_temp);
    }

    Overflow = 0;
    Syn_filt(Az, &exc[i_subfr], &synth[i_subfr], L_SUBFR, mem_syn, 0);
    if(Overflow != 0)
    {
      /* In case of overflow in the synthesis          */
      /* -> Scale down vector exc[] and redo synthesis */

      for(i=0; i<PIT_MAX+L_INTERPOL+L_FRAME; i++)
        old_exc[i] >>= 2;

      Syn_filt(Az, &exc[i_subfr], &synth[i_subfr], L_SUBFR, mem_syn, 1);
    }
    else
      Copy(&synth[i_subfr+L_SUBFR-M], mem_syn, M);

    Az += MP1;    /* interpolated LPC parameters for next subframe */
  }

 /*--------------------------------------------------*
  * Update signal for next frame.                    *
  * -> shift to the left by L_FRAME  exc[]           *
  *--------------------------------------------------*/

  Copy(&old_exc[L_FRAME], &old_exc[0], PIT_MAX+L_INTERPOL);
}

