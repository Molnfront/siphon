
/*___________________________________________________________________________
 |                                                                           |
 |   Constants and Globals                                                   |
 |___________________________________________________________________________|
*/
extern Flag Overflow;
extern Flag Carry;

#define MAX_32 (Word32)0x7fffffffL
#define MIN_32 (Word32)0x80000000L

#define MAX_16 (Word16)0x7fff
#define MIN_16 (Word16)0x8000


/*___________________________________________________________________________
 |                                                                           |
 |   Operators prototypes                                                    |
 |___________________________________________________________________________|
*/

Word16 sature(Word32 L_var1);             /* Limit to 16 bits,    1 */
Word16 add(Word16 var1, Word16 var2);     /* Short add,           1 */
Word16 sub(Word16 var1, Word16 var2);     /* Short sub,           1 */
Word16 abs_s(Word16 var1);                /* Short abs,           1 */
Word16 shl(Word16 var1, Word16 var2);     /* Short shift left,    1 */
Word16 shr(Word16 var1, Word16 var2);     /* Short shift right,   1 */
Word16 mult(Word16 var1, Word16 var2);    /* Short mult,          1 */
Word32 L_mult(Word16 var1, Word16 var2);  /* Long mult,           1 */
Word16 g_round(Word32 L_var1);              /* Round,               1 */
Word32 L_mac(Word32 L_var3, Word16 var1, Word16 var2); /* Mac,    1 */
Word32 L_msu(Word32 L_var3, Word16 var1, Word16 var2); /* Msu,    1 */

Word32 L_add(Word32 L_var1, Word32 L_var2);   /* Long add,        2 */
Word32 L_sub(Word32 L_var1, Word32 L_var2);   /* Long sub,        2 */
Word32 L_add_c(Word32 L_var1, Word32 L_var2); /*Long add with c,  2 */
Word32 L_sub_c(Word32 L_var1, Word32 L_var2); /*Long sub with c,  2 */
Word16 mult_r(Word16 var1, Word16 var2);  /* Mult with round,     2 */
Word32 L_shl(Word32 L_var1, Word16 var2); /* Long shift left,     2 */
Word32 L_shr(Word32 L_var1, Word16 var2); /* Long shift right,    2 */
Word16 shr_r(Word16 var1, Word16 var2);/* Shift right with round, 2 */
Word16 mac_r(Word32 L_var3, Word16 var1, Word16 var2);/* Mac with rounding, 2*/
Word16 msu_r(Word32 L_var3, Word16 var1, Word16 var2);/* Msu with rounding, 2*/

Word32 L_abs(Word32 L_var1);            /* Long abs,              3 */

Word16 norm_s(Word16 var1);             /* Short norm,           15 */

Word16 div_s(Word16 var1, Word16 var2); /* Short division,       18 */

Word16 norm_l(Word32 L_var1);           /* Long norm,            30 */

#define L_deposit_h(var1) ((Word32)(var1) << 16)
#define L_deposit_l(var1) ((Word32)(var1))
#define extract_h(L_var1) ((Word16)((L_var1) >> 16))
#define extract_l(L_var1) ((Word16)(L_var1))

#define L_shr_r(L_var1, var2) (((L_var1) >> (var2)) + ((L_var1) & ((Word32)1 << ((var2) - 1) ) ? 1 : 0))

#define negate(var1) (((var1) == MIN_16) ? MAX_16 : -(var1))
#define L_negate(L_var1) (((L_var1) == MIN_32) ? MAX_32 : -(L_var1))

//#define g_round(L_var1) (Word16)(((L_var1) + 0x8000L) >> 16)
