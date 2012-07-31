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
#include "c:\Docs\cab\include\fci.h"

#define MEDIA_SIZE			300000
#define FOLDER_THRESHOLD	900000

typedef struct _cabinfo
{
   ERF      erf;
   uint     lztype;
   
   uint     call;
   pubyte   pattern;      
//   cabinit  init
   uint     fnctempfile;
   uint     fncnotify;
   uint     fncsysnotify;
      
   uint     finish;    // 1 if finish for progress
   uint     cabsize;
   uint     filesize;
} cabinfo, * pcabinfo;

FNFCIALLOC(mem_alloc)
{
	return malloc(cb);
}

FNFCIFREE(mem_free)
{
	free(memory);
}

FNFCIOPEN(fci_open)
{
    int result;

    result = _open(pszFile, oflag, pmode);

    if (result == -1)
        *err = errno;

    return result;
}

FNFCIREAD(fci_read)
{
    unsigned int result;

    result = (unsigned int) _read(hf, memory, cb);

    if (result != cb)
        *err = errno;

    return result;
}

FNFCIWRITE(fci_write)
{
    unsigned int result;

    result = (unsigned int) _write(hf, memory, cb);

    if (result != cb)
        *err = errno;

    return result;
}

FNFCICLOSE(fci_close)
{
    int result;

    result = _close(hf);

    if (result != 0)
        *err = errno;

    return result;
}

FNFCISEEK(fci_seek)
{
    long result;

    result = _lseek(hf, dist, seektype);

    if (result == -1)
        *err = errno;

    return result;
}

FNFCIDELETE(fci_delete)
{
    int result;

//    result = remove(pszFile);
    result = DeleteFile( pszFile );

    if (result != 0)
        *err = errno;

    return result;
}

FNFCIFILEPLACED(file_placed)
{
	return 0;
}

FNFCIGETTEMPFILE(get_temp_file)
{
    uint    ret;
    
    pcabinfo pcabi = ( pcabinfo )pv;
    (( gentee_call )pcabi->call)( pcabi->fnctempfile, &ret, pszTempName, cbTempName, pv );
    return ret;
}

FNFCISTATUS(progress)
{
   pcabinfo pcabi = ( pcabinfo )pv;
   uint     ret;

	if (typeStatus == statusFile && !pcabi->finish && cb2 )
	{
      (( gentee_call )pcabi->call)( pcabi->fncnotify, &ret, FLN_PROGRESS, cb2, pv );
	}

	return 0;
}

FNFCIGETNEXTCABINET(get_next_cabinet)
{
	sprintf( pccab->szCab, (( pcabinfo )pv)->pattern, pccab->iCab  );
	return TRUE;
}

FNFCIGETOPENINFO( get_open_info )
{
	BY_HANDLE_FILE_INFORMATION	finfo;
	FILETIME	 filetime;
	HANDLE	 handle;
   int       hf;
   uint      ret;
   pcabinfo  pcabi = ( pcabinfo )pv;

again:
	handle = CreateFile(	pszName,	GENERIC_READ,	FILE_SHARE_READ, NULL,
       OPEN_EXISTING,	FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN,	NULL );
   
	if ( handle == INVALID_HANDLE_VALUE )
	{
      (( gentee_call )pcabi->call)( pcabi->fncsysnotify, &ret, FLN_ERROPEN, pszName, pv );
      if ( ret )
         goto again;
      else
		   return -1;
	}

	if ( !GetFileInformationByHandle( handle, &finfo ))
	{
		CloseHandle(handle);
		return -1;
	}
   
	FileTimeToLocalFileTime( &finfo.ftLastWriteTime, &filetime );
	FileTimeToDosDateTime( &filetime, pdate, ptime );
//   FileTimeToDosDateTime( &finfo.ftLastWriteTime, pdate, ptime );
   *pattribs = ( ushort )GetFileAttributes( pszName );
   pcabi->filesize = GetFileSize( handle, NULL );

   CloseHandle( handle );

	hf = _open( pszName, _O_RDONLY | _O_BINARY );

	if ( hf == -1 )
		return -1; 
   
	return hf;
}

HFCI STDCALL gcabe_create( PCCAB cab, uint param )
{
	return FCICreate(
	   (PERF)param, //must begin with ERF, &erf
		file_placed, mem_alloc,	mem_free,
      fci_open, fci_read, fci_write, fci_close, fci_seek, fci_delete,
		get_temp_file, cab, ( pvoid )param );
}

BOOL STDCALL gcabe_flushfolder( HFCI hfci )
{
   if ( !FCIFlushFolder( hfci, get_next_cabinet, progress ))
	{
      FCIDestroy( hfci );
		return FALSE;
	}
   return TRUE;
}

BOOL STDCALL gcabe_close( HFCI hfci )
{
   uint ret;

	ret = FCIFlushCabinet( hfci, FALSE,	get_next_cabinet,	progress );
   FCIDestroy( hfci );
   return ret;
}

BOOL STDCALL gcabe_addfile( HFCI hfci, pubyte fullname, pubyte filename,
                            pcabinfo pcabi )
{
	return FCIAddFile(
			hfci,
			fullname, filename,
			0, // exe
			get_next_cabinet,
			progress,
			get_open_info, ( ushort )pcabi->lztype );
}