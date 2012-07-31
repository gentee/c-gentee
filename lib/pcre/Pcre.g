/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* @Author: Alexander Antypenko ( santy ) v. 1.00 
*
******************************************************************************/
define
{
/* Options */
 PCRE_CASELESS           =0x0001
 PCRE_MULTILINE          =0x0002
 PCRE_DOTALL             =0x0004
 PCRE_EXTENDED           =0x0008
 PCRE_ANCHORED           =0x0010
 PCRE_DOLLAR_ENDONLY     =0x0020
 PCRE_EXTRA              =0x0040
 PCRE_NOTBOL             =0x0080
 PCRE_NOTEOL             =0x0100
 PCRE_UNGREEDY           =0x0200
 PCRE_NOTEMPTY           =0x0400
 PCRE_UTF8               =0x0800
 PCRE_NO_AUTO_CAPTURE    =0x1000
 PCRE_NO_UTF8_CHECK      =0x2000

/* Exec-time and get/set-time error codes */

 PCRE_ERROR_NOMATCH       = -1
 PCRE_ERROR_NULL          = -2
 PCRE_ERROR_BADOPTION     = -3
 PCRE_ERROR_BADMAGIC      = -4
 PCRE_ERROR_UNKNOWN_NODE  = -5
 PCRE_ERROR_NOMEMORY      = -6
 PCRE_ERROR_NOSUBSTRING   = -7
 PCRE_ERROR_MATCHLIMIT    = -8
 PCRE_ERROR_CALLOUT       = -9  /* Never used by PCRE itself */
 PCRE_ERROR_BADUTF8       =-10

/* Request types for pcre_fullinfo() */

 PCRE_INFO_OPTIONS            =0
 PCRE_INFO_SIZE               =1
 PCRE_INFO_CAPTURECOUNT       =2
 PCRE_INFO_BACKREFMAX         =3
 PCRE_INFO_FIRSTBYTE          =4
 PCRE_INFO_FIRSTCHAR          =4  /* For backwards compatibility */
 PCRE_INFO_FIRSTTABLE         =5
 PCRE_INFO_LASTLITERAL        =6
 PCRE_INFO_NAMEENTRYSIZE      =7
 PCRE_INFO_NAMECOUNT          =8
 PCRE_INFO_NAMETABLE         =9
 PCRE_INFO_STUDYSIZE         =10

/* Request types for pcre_config() */

 PCRE_CONFIG_UTF8                    =0
 PCRE_CONFIG_NEWLINE                 =1
 PCRE_CONFIG_LINK_SIZE               =2
 PCRE_CONFIG_POSIX_MALLOC_THRESHOLD  =3
 PCRE_CONFIG_MATCH_LIMIT             =4

/* Bit flags for the pcre_extra structure */

 PCRE_EXTRA_STUDY_DATA          =0x0001
 PCRE_EXTRA_MATCH_LIMIT         =0x0002
 PCRE_EXTRA_CALLOUT_DATA        =0x0004
}

define
{
 OSIZE = 30
 NULL  = 0
}

import "pcre.dll"
{
 uint  pcre_malloc(uint);
       pcre_free(uint);
       regfree(uint);
 uint  pcre_callout(uint);
 

 uint  pcre_compile(uint,uint,uint,uint,uint)
  int  pcre_config(uint, uint)
  int  pcre_copy_named_substring(uint,uint,uint , uint,uint,uint, uint)
  int  pcre_copy_substring(uint, uint , uint, uint,uint , uint);
  int  pcre_exec(uint,uint,uint, uint, uint, uint, uint , uint);
       pcre_free_substring(uint);
       pcre_free_substring_list(uint);
  int  pcre_fullinfo(uint,uint, uint,uint);
  int  pcre_get_named_substring(uint,uint,uint , uint,uint,uint);
  int  pcre_get_stringnumber(uint,uint);
  int  pcre_get_substring(uint,uint,uint,uint,uint);
  int  pcre_get_substring_list(uint, uint , uint,uint);
  int  pcre_info(uint, uint , uint );
 uint  pcre_maketables();
 uint  pcre_study(uint, uint, uint);
 uint  pcre_version();
 
}

func str_print(str sPrn_str)
{
  print(sPrn_str);
}

type pcre_extra
{
  ulong flags;                /* Bits for which fields are set */     
  uint study_data;            /* Opaque data from pcre_study() */     
  ulong match_limit;          /* Maximum number of calls to match() */
  uint callout_data;          /* Data passed back in callouts */      
}


type pcre
{
 str error_message
 str src_text
}

/*-----------------------------------------------------------------------------
* @syntax  [ pcre1.re_version () ]
*
* @return Get version of pcre library.
*
* @example
* [ str str_version = pcre1.re_version() ]
-----------------------------------------------------------------------------*/
method str pcre.re_version <result>()
{
 str sVersion;
 result = sVersion.copy(pcre_version());
}

/*-----------------------------------------------------------------------------
* @syntax [ pcre1.srcText = sText ]
*
* Property srcText sets source text data for parsing (set method)
-----------------------------------------------------------------------------*/
property pcre.srcText(str sText) : this.src_text = sText

/*-----------------------------------------------------------------------------
* @syntax [ str pcre1.srcText = sText ]
*
* Property srcText Get source text data for parsing (get method)
-----------------------------------------------------------------------------*/
property str pcre.srcText() : return this.src_text

/*-----------------------------------------------------------------------------
* @syntax [ pcre1.errorMessage = sText ]
*
* Property errorMessage sets error message text data (set method)
-----------------------------------------------------------------------------*/
property pcre.errorMessage(str sText) : this.error_message = sText
/*-----------------------------------------------------------------------------
* @syntax [ str pcre1.errorMessage = sText ]
*
* Property errorMessage Get error message text data (get method)
-----------------------------------------------------------------------------*/
property str pcre.errorMessage() : return this.error_message


method int pcre.errorAnalize(int nMatch)
{
 switch nMatch
 {
  case $PCRE_ERROR_NOMATCH 	: return 0
  case $PCRE_ERROR_NULL 	: this.errorMessage = "Pcre ERROR NULL" 	; return -1
  case $PCRE_ERROR_BADOPTION 	: this.errorMessage = "Pcre ERROR BAD OPTION" 	; return -1
  case $PCRE_ERROR_BADMAGIC 	: this.errorMessage = "Pcre ERROR BAD MAGIC" 	; return -1
  case $PCRE_ERROR_UNKNOWN_NODE : this.errorMessage = "Pcre ERROR UNKNOWN NODE"; return -1
  case $PCRE_ERROR_NOMEMORY 	: this.errorMessage = "Pcre ERROR NO MEMORY" 	; return -1
  case $PCRE_ERROR_MATCHLIMIT 	: this.errorMessage = "Pcre ERROR MATCH LIMIT"	; return -1
 }
 return nMatch
}

/*-----------------------------------------------------------------------------
* @syntax  [ pcre1.matchGetAll(str sPattern,int iOption, arrstr s ) ]
*
* @param sPattern zero-terminated string containing the regular expression to be compiled
* @param iOption  zero or more option bits
* @param saReturn strings array where to put resuld data
*
* @return Count matched strings.
*
* @example
* [ arrstr allData
*   sPattern = "^\\s*([^:])"
*   int iCount = reData.matchGetAll (sPattern, $PCRE_NOTEMPTY,allData) 
* ]
-----------------------------------------------------------------------------*/
method int pcre.matchGetAll(str sPattern,int iOption, arrstr saReturn )
{
 arr ovector[$OSIZE] of uint;
 uint erroffset,ptrRegex,iAddrStr;
 str errorptr,sConv;
 int numMatch,iReslist

 ptrRegex = pcre_compile (sPattern.ptr(), $NULL, errorptr.ptr(), &erroffset, $NULL)
 if ( ptrRegex == $NULL )
 {
   sConv.out4("%d",erroffset)
   this.errorMessage = "Error compiling pattern" + sPattern + " at offset" + sConv + " - " //+ errorptr.setlenptr()//copy(errorptr.ptr(),mlen(errorptr.ptr()+1)); 
   return - 1
 }
 numMatch = pcre_exec(ptrRegex, 0, this.srcText.ptr(),*this.srcText, 0, iOption, ovector.ptr(), *ovector )
 if (numMatch  == $NULL)
 {
   this.errorMessage = "OSIZE value is too small!"
   regfree (ptrRegex)  
   return - 1
 }
 int iCode = this.errorAnalize(numMatch)
 if (iCode <= 0) : return iCode
 uint i;
 str sTekStr,sdemo;
 fornum i=1, numMatch
 {
   sTekStr.clear()
   //print(" From \(ovector[2*i] ) len \(ovector[2*i+1] - ovector[2*i]) \n ")
   sTekStr.substr(this.srcText,ovector[2*i],ovector[2*i+1] - ovector[2*i])
   saReturn += sTekStr;
 }
 regfree (ptrRegex)
 return numMatch;
}


/*-----------------------------------------------------------------------------
* @syntax  [ pcre1.match(str sPattern,int iOption) ]
*
* @param sPattern zero-terminated string containing the regular expression to be compiled
* @param iOption  zero or more option bits
*
* @return Count matched strings.
*
* @example
* [ 
*   sPattern = "^\\s*([^:])"
*   int iCount = reData.match(sPattern, $PCRE_NOTEMPTY) 
* ]
-----------------------------------------------------------------------------*/
method int pcre.match(str sPattern,int iOption)
{
 arr ovector[$OSIZE] of uint;
 uint erroffset,ptrRegex;
 str errorptr, sConv;
 int numMatch;

 ptrRegex = pcre_compile(sPattern.ptr(), $NULL, errorptr.ptr(), &erroffset, $NULL)
 if (ptrRegex == $NULL)
 {
   sConv.out4("%d",erroffset) 
   this.errorMessage = "Error compiling pattern "+sPattern+" at offset"+ sConv + " - "+ errorptr.setlenptr() 
   return - 1;

 }
 numMatch = pcre_exec (ptrRegex, 0, this.srcText.ptr(),*this.srcText, 0, iOption, ovector.ptr(), *ovector )
 if (numMatch  == $NULL)
 {
   this.errorMessage = "OSIZE value is too small!";
   regfree (ptrRegex);  
   return - 1;
 }
 
 int iCode = this.errorAnalize(numMatch)
 if (iCode <= 0) : return iCode
 
 regfree (ptrRegex)
 return numMatch;
}

