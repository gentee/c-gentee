#ifndef _BYTECODE_H_
#define _BYTECODE_H_

   #ifdef __cplusplus
      extern "C" {
   #endif // __cplusplus

enum
{      
//  SH_TYPE,  // type
              //  top  cmd
  SHN3_1 = 1, //   -3   1    
  SHN2_1,     //   -2   1    
  SHN1_2,     //   -1   2
  SHN1_1,     //   -1   1    
  SH0_2,      //   0    2
  SH0_1,      //   0    1    
  SH1_3,      //   1    3
  SH1_2,      //   1    2
  SH1_1,      //   1    1
  SH2_1,      //   2    1
  SH2_3,      //   2    3
};

#define  CMDCOUNT  235
#define  STACK_COUNT  217

enum {
   CNone,        //   0x0,  0 Error command
   TInt,         //   0x1,  1 int type
   TUint,        //   0x2,  2 uint type
   TByte,        //   0x3,  3 byte type
   TUbyte,       //   0x4,  4 ubyte type
   TShort,       //   0x5,  5 short type
   TUshort,      //   0x6,  6 ushort type
   TFloat,       //   0x7,  7 float type
   TDouble,      //   0x8,  8 double type
   TLong,        //   0x9,  9 long type
   TUlong,       //   0xA,  10 ulong type
   TReserved,    //   0xB,  11 reserved type
   TBuf,         //   0xC,  12 buf type
   TStr,         //   0xD,  13 str type
   TArr,         //   0xE,  14 arr type
   TCollection,  //   0xF,  15 collection type
   TAny,         //  0x10,  16 any type
   TFordata,     //  0x11,  17 foreach type
   CNop,         //  0x12,  18 The command does nothing
   CGoto,        //  0x13,  19 The unconditional jump.
   CGotonocls,   //  0x14,  20 The unconditional jump without clearing stack.
   CIfze,        //  0x15,  21 The conditional jump
   CIfznocls,    //  0x16,  22 The conditional jump without clearing stack
   CIfnze,       //  0x17,  23 The conditional jump
   CIfnznocls,   //  0x18,  24 The conditional jump without clearing stack.
   CByload,      //  0x19,  25 The next ubyte push into stack. GE only
   CShload,      //  0x1A,  26 The next ushort push into stack. GE only
   CDwload,      //  0x1B,  27 The next uint push into stack.
   CCmdload,     //  0x1C,  28 The next ID push into stack.
   CResload,     //  0x1D,  29 The next ID (resource) push into stack.
   CQwload,      //  0x1E,  30 The next ulong push into stack.
   CDwsload,     //  0x1F,  31 The next uints ( cmd 1 ) ( cmd 2 ) push into the stack
   CVarload,     //  0x20,  32 Load the value of parameter or variable with number ( cmd 1)
   CVarptrload,  //  0x21,  33 Load the pointer to value of parameter or variable with number ( cmd 1)
   CDatasize,    //  0x22,  34 Load the pointer to the next data and the size
   CLoglongtrue, //  0x23,  35 Return 1 if ulong in stack is not zero
   CLognot,      //  0x24,  36 Logical not
   CLoglongnot,  //  0x25,  37 Logical NOT for long ulong
   CDup,         //  0x26,  38 Duplicate top value
   CDuplong,     //  0x27,  39 Duplicate two top value
   CTop,         //  0x28,  40 Return the pointer to top
   CPop,         //  0x29,  41 Delete the top value
   CGetUB,       //  0x2A,  42  * ( pubyte ) 
   CGetB,        //  0x2B,  43  * ( pbyte ) 
   CGetUS,       //  0x2C,  44  * ( pushort ) 
   CGetS,        //  0x2D,  45  * ( pshort ) 
   CGetI,        //  0x2E,  46  * ( puint && pint && float ) 
   CGetL,        //  0x2F,  47  * ( pulong && plong && double ) 
   CSetUB,       //  0x30,  48  * ( pubyte ) = 
   CSetB,        //  0x31,  49  * ( pbyte ) = 
   CSetUS,       //  0x32,  50  * ( pushort ) = 
   CSetS,        //  0x33,  51  * ( pshort ) = 
   CSetI,        //  0x34,  52  * ( puint && pint && float ) = 
   CSetL,        //  0x35,  53  * ( pulong && plong && double ) = 
   CAddUIUI,     //  0x36,  54  + 
   CSubUIUI,     //  0x37,  55  - 
   CMulUIUI,     //  0x38,  56  * 
   CDivUIUI,     //  0x39,  57  / 
   CModUIUI,     //  0x3A,  58  % 
   CAndUIUI,     //  0x3B,  59  & 
   COrUIUI,      //  0x3C,  60  | 
   CXorUIUI,     //  0x3D,  61  ^ 
   CLeftUIUI,    //  0x3E,  62  << 
   CRightUIUI,   //  0x3F,  63  >> 
   CLessUIUI,    //  0x40,  64  < 
   CGreaterUIUI, //  0x41,  65  > 
   CEqUIUI,      //  0x42,  66  == 
   CNotUI,       //  0x43,  67  ~ 
   CIncLeftUI,   //  0x44,  68  ++i 
   CIncRightUI,  //  0x45,  69  i++ 
   CDecLeftUI,   //  0x46,  70  --i 
   CDecRightUI,  //  0x47,  71  i-- 
   CAddUI,       //  0x48,  72  += 
   CSubUI,       //  0x49,  73  -= 
   CMulUI,       //  0x4A,  74  *= 
   CDivUI,       //  0x4B,  75  /= 
   CModUI,       //  0x4C,  76  %= 
   CAndUI,       //  0x4D,  77  &= 
   COrUI,        //  0x4E,  78  |= 
   CXorUI,       //  0x4F,  79  ^= 
   CLeftUI,      //  0x50,  80  <<= 
   CRightUI,     //  0x51,  81  >>= 
   CVarsInit,    //  0x52,  82 Initialize variables in block cmd1 
   CGetText,     //  0x53,  83 Get current output of text function
   CSetText,     //  0x54,  84 Print string to current output of text function
   CPtrglobal,   //  0x55,  85 Get to the global variable
   CSubcall,     //  0x56,  86 Call a subfunc cmd 1 - goto
   CSubret,      //  0x57,  87 The number of returned uint cmd 1
   CSubpar,      //  0x58,  88 Paraneters of subfunc. cmd 1 - Set block cndshift = 1
   CSubreturn,   //  0x59,  89 Return from a subfunc
   CCmdcall,     //  0x5A,  90 Call a funcion
   CCallstd,     //  0x5B,  91 Call a stdcall or cdecl funcion
   CReturn,      //  0x5C,  92 Return from the function.
   CDbgTrace,    //  0x5D,  93 Debug line tracing
   CDbgFunc,     //  0x5E,  94 Debug func entering
   CMulII,       //  0x5F,  95  * 
   CDivII,       //  0x60,  96  / 
   CModII,       //  0x61,  97  % 
   CLeftII,      //  0x62,  98  << 
   CRightII,     //  0x63,  99  >> 
   CSignI,       //  0x64,  100  change sign 
   CLessII,      //  0x65,  101  < 
   CGreaterII,   //  0x66,  102  > 
   CMulI,        //  0x67,  103  *= 
   CDivI,        //  0x68,  104  /= 
   CModI,        //  0x69,  105  %= 
   CLeftI,       //  0x6A,  106  <<= 
   CRightI,      //  0x6B,  107  >>= 
   CMulB,        //  0x6C,  108  *= 
   CDivB,        //  0x6D,  109  /= 
   CModB,        //  0x6E,  110  %= 
   CLeftB,       //  0x6F,  111  <<= 
   CRightB,      //  0x70,  112  >>= 
   CMulS,        //  0x71,  113  *= 
   CDivS,        //  0x72,  114  /= 
   CModS,        //  0x73,  115  %= 
   CLeftS,       //  0x74,  116  <<= 
   CRightS,      //  0x75,  117  >>= 
   Cd2f,         //  0x76,  118 double 2 float
   Cd2i,         //  0x77,  119 double 2 int
   Cd2l,         //  0x78,  120 double 2 long
   Cf2d,         //  0x79,  121 float 2 double
   Cf2i,         //  0x7A,  122 float 2 int
   Cf2l,         //  0x7B,  123 float 2 long
   Ci2d,         //  0x7C,  124 int 2 double
   Ci2f,         //  0x7D,  125 int 2 float
   Ci2l,         //  0x7E,  126 int 2 long
   Cl2d,         //  0x7F,  127 long 2 double
   Cl2f,         //  0x80,  128 long 2 float
   Cl2i,         //  0x81,  129 long 2 int
   Cui2d,        //  0x82,  130 uint 2 double
   Cui2f,        //  0x83,  131 uint 2 float
   Cui2l,        //  0x84,  132 uint 2 long
   CAddULUL,     //  0x85,  133 +
   CSubULUL,     //  0x86,  134 -
   CMulULUL,     //  0x87,  135 *
   CDivULUL,     //  0x88,  136 /
   CModULUL,     //  0x89,  137 %
   CAndULUL,     //  0x8A,  138 &
   COrULUL,      //  0x8B,  139 |
   CXorULUL,     //  0x8C,  140 ^
   CLeftULUL,    //  0x8D,  141 <<
   CRightULUL,   //  0x8E,  142 >>
   CLessULUL,    //  0x8F,  143 <
   CGreaterULUL, //  0x90,  144 >
   CEqULUL,      //  0x91,  145 ==
   CNotUL,       //  0x92,  146 ~
   CIncLeftUL,   //  0x93,  147 ++
   CIncRightUL,  //  0x94,  148 ++
   CDecLeftUL,   //  0x95,  149 --
   CDecRightUL,  //  0x96,  150 --
   CAddUL,       //  0x97,  151 +=
   CSubUL,       //  0x98,  152 -=
   CMulUL,       //  0x99,  153 *=
   CDivUL,       //  0x9A,  154 /=
   CModUL,       //  0x9B,  155 %
   CAndUL,       //  0x9C,  156 &=
   COrUL,        //  0x9D,  157 |=
   CXorUL,       //  0x9E,  158 &=
   CLeftUL,      //  0x9F,  159 <<=
   CRightUL,     //  0xA0,  160 >>=
   CMulLL,       //  0xA1,  161 *
   CDivLL,       //  0xA2,  162 /
   CModLL,       //  0xA3,  163 %
   CLeftLL,      //  0xA4,  164 <<=
   CRightLL,     //  0xA5,  165 >>=
   CSignL,       //  0xA6,  166 sign
   CLessLL,      //  0xA7,  167 <
   CGreaterLL,   //  0xA8,  168 >
   CMulL,        //  0xA9,  169 *=
   CDivL,        //  0xAA,  170 /=
   CModL,        //  0xAB,  171 %=
   CLeftL,       //  0xAC,  172 <<=
   CRightL,      //  0xAD,  173 >>=
   CAddFF,       //  0xAE,  174 +
   CSubFF,       //  0xAF,  175 -
   CMulFF,       //  0xB0,  176 *
   CDivFF,       //  0xB1,  177 /
   CSignF,       //  0xB2,  178 sign
   CLessFF,      //  0xB3,  179 <
   CGreaterFF,   //  0xB4,  180 >
   CEqFF,        //  0xB5,  181 ==
   CIncLeftF,    //  0xB6,  182 ++
   CIncRightF,   //  0xB7,  183 ++
   CDecLeftF,    //  0xB8,  184 --
   CDecRightF,   //  0xB9,  185 --
   CAddF,        //  0xBA,  186 +=
   CSubF,        //  0xBB,  187 -=
   CMulF,        //  0xBC,  188 *=
   CDivF,        //  0xBD,  189 /=
   CAddDD,       //  0xBE,  190 +
   CSubDD,       //  0xBF,  191 -
   CMulDD,       //  0xC0,  192 *
   CDivDD,       //  0xC1,  193 /
   CSignD,       //  0xC2,  194 sign
   CLessDD,      //  0xC3,  195 <
   CGreaterDD,   //  0xC4,  196 >
   CEqDD,        //  0xC5,  197 ==
   CIncLeftD,    //  0xC6,  198 ++
   CIncRightD,   //  0xC7,  199 ++
   CDecLeftD,    //  0xC8,  200 --
   CDecRightD,   //  0xC9,  201 --
   CAddD,        //  0xCA,  202 +=
   CSubD,        //  0xCB,  203 -=
   CMulD,        //  0xCC,  204 *=
   CDivD,        //  0xCD,  205 /=
   CIncLeftUB,   //  0xCE,  206 ++
   CIncRightUB,  //  0xCF,  207 ++
   CDecLeftUB,   //  0xD0,  208 --
   CDecRightUB,  //  0xD1,  209 --
   CAddUB,       //  0xD2,  210 +=
   CSubUB,       //  0xD3,  211 -=
   CMulUB,       //  0xD4,  212 *=
   CDivUB,       //  0xD5,  213 /=
   CModUB,       //  0xD6,  214 %=
   CAndUB,       //  0xD7,  215 &=
   COrUB,        //  0xD8,  216 |=
   CXorUB,       //  0xD9,  217 ^=
   CLeftUB,      //  0xDA,  218 <<=
   CRightUB,     //  0xDB,  219 >>=
   CIncLeftUS,   //  0xDC,  220 ++
   CIncRightUS,  //  0xDD,  221 ++
   CDecLeftUS,   //  0xDE,  222 --
   CDecRightUS,  //  0xDF,  223 --
   CAddUS,       //  0xE0,  224 +=
   CSubUS,       //  0xE1,  225 -=
   CMulUS,       //  0xE2,  226 *=
   CDivUS,       //  0xE3,  227 /=
   CModUS,       //  0xE4,  228 %=
   CAndUS,       //  0xE5,  229 &=
   COrUS,        //  0xE6,  230 |=
   CXorUS,       //  0xE7,  231 ^=
   CLeftUS,      //  0xE8,  232 <<=
   CRightUS,     //  0xE9,  233 >>=
   CCollectadd,  //  0xEA,  234 Run-time loading collection
};


typedef struct CmpInfo{
    char* name;
    char* comment;
}CmpInfo;




extern const CmpInfo pCmpInfo[];
extern const ubyte shifts[];
extern const ubyte embtypes[];

extern const ubyte embfuncs[];
#define  FUNCCOUNT  118

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _BYTECODE_H_