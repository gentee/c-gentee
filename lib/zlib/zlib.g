/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexander Antypenko ( santy ) v. 1.00
*
******************************************************************************/
import "zlib1.dll"
{
  uint gzopen(uint,uint)  
  uint gzdopen(uint,uint)
  int  gzsetparams(uint,int,int)
  int  gzread(uint,uint,uint)
  int  gzwrite(uint,uint,uint)
  int  gzputs(uint,uint)
  uint gzgets(uint,uint,int)
  int  gzputc(uint,int)
  int  gzgetc(uint)
  int  gzungetc(int,uint)
  int  gzflush(uint,int)
  uint gzseek(uint,uint,int)
  int  gzrewind (uint)
  uint gztell(uint)
  int  gzeof(uint)
  int  gzdirect(uint)
  int  gzclose(uint)
  uint gzerror(uint,uint)
       gzclearerr(uint)
  //
  int  compress(uint,uint,uint,uint)
  int  compress2(uint,uint,uint,uint,int)
  uint compressBound(uint)
  int  uncompress(uint,uint,uint,uint)

  
}

define
{

 Z_NO_FLUSH      = 0
 Z_PARTIAL_FLUSH = 1 	/* will be removed, use Z_SYNC_FLUSH instead */
 Z_SYNC_FLUSH    = 2
 Z_FULL_FLUSH    = 3
 Z_FINISH        = 4
 Z_BLOCK         = 5

 /* Allowed flush values; see deflate() and inflate() below for details */

 Z_OK            = 0
 Z_STREAM_END    = 1
 Z_NEED_DICT     = 2
 Z_ERRNO         = (-1)
 Z_STREAM_ERROR  = (-2)
 Z_DATA_ERROR    = (-3)
 Z_MEM_ERROR     = (-4)
 Z_BUF_ERROR     = (-5)
 Z_VERSION_ERROR = (-6)

 /* 
 * Return codes for the compression/decompression functions. Negative
 * values are errors, positive values are used for special but normal events.
 */

 Z_NO_COMPRESSION         = 0
 Z_BEST_SPEED             = 1
 Z_BEST_COMPRESSION       = 9
 Z_DEFAULT_COMPRESSION    = (-1)
 /* compression levels */

 Z_FILTERED            = 1
 Z_HUFFMAN_ONLY        = 2
 Z_RLE                 = 3
 Z_FIXED               = 4
 Z_DEFAULT_STRATEGY    = 0  /* compression strategy; see deflateInit2() below for details */

 Z_BINARY   = 0
 Z_TEXT     = 1
 Z_ASCII    = $Z_TEXT   /* for compatibility with 1.2.2 and earlier */
 Z_UNKNOWN  = 2     	/* Possible values of the data_type field (though see inflate()) */

 Z_DEFLATED   = 8 	/* The deflate compression method (the only one supported in this version) */
 Z_NULL       = 0  	/* for initializing zalloc, zfree, opaque */
}


/*-----------------------------------------------------------------------------
* @syntax  squeeze (str src_buffer)
*
* @param src_buffer Input uncompressed string data  
*
* @return The string containing the compressed str_buffer.
*
* @example
* [ str str_z = squeeze ("Demo string") ]
-----------------------------------------------------------------------------*/
func str squeeze<result>(str src_buffer)
{
  buf dest_buffer
  str out_buffer=""
  
  uint srclen = *src_buffer
  uint destlen = srclen+ uint( (float(srclen) * 1.01f) + 12f)
  uint lpdestlen  = malloc(destlen)
  dest_buffer.reserve(destlen)

  if (compress(dest_buffer.ptr(),&lpdestlen,src_buffer.ptr(),srclen) == $Z_OK) : out_buffer.load(dest_buffer.ptr(),lpdestlen)
  mfree(&lpdestlen)
  result=out_buffer
}

/*-----------------------------------------------------------------------------
* @syntax unsqueeze(str src_buffer)
*
* @param src_buffer Input compressed buffer 
*
* @return The original uncompressed string from a compressed buffer in src_buffer
*
* @example
* [ str str_z1 = unsqueeze(str_z) ]
-----------------------------------------------------------------------------*/
func str unsqueeze<result>(str src_buffer)
{

  buf dest_buffer
  str out_buffer=""
  uint uRetCode
  
  uint srclen = *src_buffer
  uint destlen = srclen*3
  uint lpdestlen  = malloc(destlen)
  dest_buffer.reserve(destlen)
  while (uRetCode = uncompress(dest_buffer.ptr(),&lpdestlen,src_buffer.ptr(),srclen) == $Z_BUF_ERROR) 
  {
     destlen = destlen*2  
     dest_buffer.reserve(destlen)
  }
  if (uRetCode  == $Z_OK): out_buffer.load(dest_buffer.ptr(),lpdestlen)
  mfree(&lpdestlen)
  result=out_buffer
}

/*-----------------------------------------------------------------------------
* @syntax [ gzfile_read (str gzfilename)]
*
* @return A string buffer with the original contents.
*
* Uncompresses the GZ compressed file in gzfilename.
*
* @example
* [ str s_buffer = gzfile_read("arhive.gz") ]
-----------------------------------------------------------------------------*/
func str gzfile_read<result>(str gzfilename)
{
  buf tmp_buffer
  str out_buffer =""
  uint length_buf = 0
  tmp_buffer.reserve(0x1000)

  uint fileNum = gzopen(gzfilename.ptr(),"rb".ptr())    

  if (fileNum != 0)  {
    while (length_buf = (gzread(fileNum,tmp_buffer.ptr(),0x1000)) ) : out_buffer.append(tmp_buffer.ptr(),length_buf) 
    gzclose(fileNum)
  }

  result = out_buffer
}

/*-----------------------------------------------------------------------------
* @syntax [ gzfile_write (str gzfilename, str src_buffer) ]
*
* @return The number of bytes in src_buffer.
*
* Does a GZ compatible comrpression of a buffer in src_buffer and
*   writes it to the file in gzfilename.
*
* @example
* [ uint cnt_bytes = gzfile_write("arhive.gz",src_buffer) ]
-----------------------------------------------------------------------------*/
func uint gzfile_write(str gzfilename, str src_buffer)
{
  uint count_bytes = 0
  uint fileNum = gzopen(gzfilename.ptr(),"wb".ptr())    
  print("1 \(fileNum) \n")
  if (fileNum != 0)  {
    count_bytes = gzwrite(fileNum,src_buffer.ptr(),*src_buffer)
    gzclose(fileNum)
  }

  return count_bytes
}

