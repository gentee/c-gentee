/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

#include "cab2g.h"
#include "c:\Docs\cab\include\fdi.h"

typedef struct _decabinfo 
{
   ERF            erf;
   FDICABINETINFO fdic;
   uint           call;
   uint           islist;
   uint           fncnotify;
   uint           fncsysnotify;
   int            hf;
   pubyte         destfile;
} decabinfo, * pdecabinfo;

pdecabinfo _decab = NULL;

FNALLOC(dmem_alloc)
{
	return malloc(cb);
}

FNFREE(dmem_free)
{
	free(pv);
}

FNOPEN(file_open)
{
	return _open(pszFile, oflag, pmode);
}

FNREAD(file_read)
{
	return _read(hf, pv, cb);
}

FNWRITE(file_write)
{
   int write, ret;

	write = _write(hf, pv, cb);
   if ( _decab && hf == _decab->hf )
   {
      (( gentee_call )_decab->call)( _decab->fncnotify, &ret, FLN_PROGRESS, 
                                    cb, _decab );
   }
   return write;
}

FNCLOSE(file_close)
{
	return _close(hf);
}

FNSEEK(file_seek)
{
	return _lseek(hf, dist, seektype);
}

//---------------------------------------------------------------------

FNFDINOTIFY( decab_notify )
{
   pdecabinfo decab = ( pdecabinfo )pfdin->pv;
   uint       ret;

	switch ( fdint )
	{
		case fdintCABINET_INFO: 
         (( gentee_call )decab->call)( decab->fncsysnotify, &ret, 
                                           FLN_NEXTVOLUME, pfdin, decab );
         return 0;
		case fdintPARTIAL_FILE:	
         return 0;
      case fdintCOPY_FILE:
		{
         (( gentee_call )decab->call)( decab->fncsysnotify, &ret, 
                                           FLN_FILEBEGIN, pfdin, decab );
         if ( !ret )
            return 0;
         _decab = decab;
			decab->hf = file_open( decab->destfile,
					_O_BINARY | _O_CREAT | _O_WRONLY | _O_SEQUENTIAL,
					 0x0400 | 0x0200 /* _S_IREAD | _S_IWRITE*/ );
         return decab->hf;
		}

		case fdintCLOSE_FILE_INFO:
      {
         _decab->hf = 0;
         _decab = NULL; 
         file_close( pfdin->hf );
         (( gentee_call )decab->call)( decab->fncsysnotify, &ret, 
                                           FLN_FILEEND, pfdin, decab );
    		return TRUE;
      }
		case fdintNEXT_CABINET:	
			return 0;
	}

	return 0;
}

HFDI STDCALL gcabd_create( pdecabinfo pdecab )
{
   return FDICreate(	dmem_alloc, dmem_free, file_open, file_read,
		               file_write,	file_close,	file_seek, cpu80386, &pdecab->erf );
}

void STDCALL gcabd_destroy( HFDI hfdi )
{
   FDIDestroy( hfdi );
}

uint STDCALL gcabd_iscabinet( HFDI hfdi, pubyte cabfile, pdecabinfo pdecab )
{
   int    hf;
   uint   ret;

again:
   hf = file_open( cabfile, _O_BINARY | _O_RDONLY | _O_SEQUENTIAL, 0	);

	if ( hf == -1 )
   { 
      (( gentee_call )pdecab->call)( pdecab->fncsysnotify, &ret, FLN_ERROPEN,
                                       cabfile, pdecab );
      if ( ret )
         goto again;
		return 0;
   }
   ret = FDIIsCabinet( hfdi,	hf, &pdecab->fdic );
   file_close( hf );
   return ret;
}

uint STDCALL gcabd_copy( HFDI hfdi, pubyte name, pubyte path, pdecabinfo pdecab )
{
   return FDICopy( hfdi, name, path, 0, decab_notify,	NULL,	( pvoid )pdecab );
}
