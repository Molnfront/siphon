/* ITU-T G.729 Software Package Release 2 (November 2006) */
/*
   ITU-T G.729A Speech Coder    ANSI-C Source Code
   Version 1.1    Last modified: September 1996

   Copyright (c) 1996,
   AT&T, France Telecom, NTT, Universite de Sherbrooke
   All rights reserved.
*/

/*-------------------------------------------------------------------*
 * Function  Set zero()                                              *
 *           ~~~~~~~~~~                                              *
 * Set vector x[] to zero                                            *
 *-------------------------------------------------------------------*/

#include "typedef.h"
#include "basic_op.h"
#include "ld8a.h"

/* Random generator  */

Word16 Random()
{
  static Word16 seed = 21845;

  //seed = (Word32)seed * 31821LL + 13849LL;
  seed = extract_l(L_add(L_shr(L_mult(seed, 31821), 1), 13849L));

  return(seed);
}

