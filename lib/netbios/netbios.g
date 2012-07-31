/******************************************************************************
*
* Copyright (C) 2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

define
{
   NCBNAMSZ    =  16    // absolute length of a net name           
   MAX_LANA    =  254   // lana's in range 0 to MAX_LANA inclusive
   
   NCBRESET    = 0x32   // NCB RESET
   NCBASTAT    = 0x33   // NCB ADAPTER STATUS                 
   NCBENUM     = 0x37   // NCB ENUMERATE LANA NUMBERS         
}

type NCB {
    ubyte   ncb_command            // command code                   
    ubyte   ncb_retcode            // return code                    
    ubyte   ncb_lsn                // local session number           
    ubyte   ncb_num                // number of our network name     
    uint    ncb_buffer             // address of message buffer      
    ushort  ncb_length             // size of message buffer         
    reserved   ncb_callname[ $NCBNAMSZ] // blank-padded name of remote    
    reserved   ncb_name[ $NCBNAMSZ]     // our blank-padded netname       
    ubyte   ncb_rto                // rcv timeout/retry count        
    ubyte   ncb_sto                // send timeout/sys timeout       
    uint    ncb_post               // POST routine address        
    ubyte   ncb_lana_num           // lana (adapter) number          
    ubyte   ncb_cmd_cplt           // 0xff => commmand pending       
    reserved ncb_reserve[10]       // reserved, used by BIOS
    uint     ncb_event      // HANDLE to Win32 event which will be set to the
                            // signalled state when an ASYNCH command completes
}

type ADAPTER_STATUS {
    reserved   adapter_address[6]
    ubyte   rev_major
    ubyte   reserved0
    ubyte   adapter_type
    ubyte   rev_minor
    ushort    duration
    ushort    frmr_recv
    ushort    frmr_xmit

    ushort    iframe_recv_err

    ushort    xmit_aborts
    uint      xmit_success
    uint      recv_success

    ushort    iframe_xmit_err

    ushort    recv_buff_unavail
    ushort    t1_timeouts
    ushort    ti_timeouts
    uint      reserved1
    ushort    free_ncbs
    ushort    max_cfg_ncbs
    ushort    max_ncbs
    ushort    xmit_buf_unavail
    ushort    max_dgram_size
    ushort    pending_sess
    ushort    max_cfg_sess
    ushort    max_sess
    ushort    max_sess_pkt_size
    ushort    name_count
}

type NAME_BUFFER {
    reserved name[ $NCBNAMSZ ]
    ubyte    name_num
    ubyte    name_flags
}

type LANA_ENUM {
    ubyte    length          //  Number of valid entries in lana[]
    reserved lana[ $MAX_LANA+1 ]
}

type adapter
{    
    ADAPTER_STATUS adapt
    reserved       NameBuff[ 540 ] // 30 * NAME_BUFFER
}

import "netapi32.dll"
{
   ubyte Netbios( NCB )
}

func uint nb_getmac( arr mac )
{
   uint ret ok
   NCB  ncb
   adapter   ad
   LANA_ENUM lenum
 
   mac.clear()  
   ncb.ncb_command = $NCBENUM
   ncb.ncb_buffer = &lenum
   ncb.ncb_length = sizeof( LANA_ENUM )
   if ok = Netbios( ncb ) : return 0
   mzero( &ncb, sizeof( NCB ))   
      
   ncb.ncb_command = $NCBRESET
   ncb.ncb_lana_num = lenum.lana[0]
   if ok = Netbios( ncb ) : return 0
   mzero( &ncb, sizeof( NCB ))   
   ncb.ncb_command = $NCBASTAT
   ncb.ncb_lana_num = lenum.lana[0]    
   mcopy( &ncb.ncb_callname, "*               ".ptr(), 16 )
   ncb.ncb_buffer = &ad 
	ncb.ncb_length = sizeof( adapter )
   if !Netbios( ncb )
	{
      mac.expand( 6 )
      fornum ok = 0, 6
      { 
         mac[ ok ] = ad.adapt.adapter_address[ ok ]
      }  
	}
   return 1
}