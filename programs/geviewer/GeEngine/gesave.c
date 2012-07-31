#include "types.h"
#include "common.h"
#include "vm.h"
#include "gefile.h"
#include "bytecode.h"



void STDCALL gesave_addubyte( pvmEngine pThis, uint val )
{
   buf_appendch( pThis, pThis->gesave, ( ubyte )val );
}

void STDCALL gesave_adduint( pvmEngine pThis, uint val )
{
	buf_appenduint( pThis, pThis->gesave, val );
}

void STDCALL gesave_addushort( pvmEngine pThis, uint val )
{
	buf_appendushort( pThis, pThis->gesave, ( ushort )val );
}


void STDCALL gesave_addptr( pvmEngine pThis, pubyte data )
{
   buf_append( pThis, pThis->gesave, data, mem_len( pThis, data ) + 1 );
}

void STDCALL gesave_adddata( pvmEngine pThis, pubyte data, uint size )
{
   buf_append( pThis, pThis->gesave, data, size );
}

//--------------------------------------------------------------------------

uint  STDCALL gesave_bwd( pvmEngine pThis, uint val )
{
   if ( val <= 187 )
      gesave_addubyte( pThis, val );
   else
      if ( val < 16830 ) // 0xFF *( 253 - 188 ) + 0xFF
      {
         gesave_addubyte( pThis, 188 + val / 0xFF );
         gesave_addubyte( pThis, val % 0xFF );
      }
      else
         if ( val > MAX_USHORT )
         {
            gesave_addubyte( pThis, MAX_BYTE );
            gesave_adduint( pThis, val );
         }
         else
         {
            gesave_addubyte( pThis, MAX_BYTE - 1 );
            gesave_addushort( pThis, val );
         }
   return val;
}


void STDCALL gesave_head( pvmEngine pThis, uint type, pubyte name, uint flag )
{
   pThis->gesaveoff = buf_len( pThis, pThis->gesave );

   flag &= 0xFFFFFF;

   if ( name && name[0] )
      flag |= GHCOM_NAME;
   else
      flag &= ~GHCOM_NAME;

   flag |= GHCOM_PACK;

   gesave_addubyte( pThis, type );
   gesave_adduint( pThis, flag );
   // The size will be inserted in gesave_finish
   // Now add just one byte
   gesave_addubyte( pThis, 0 );

   if ( flag & GHCOM_NAME )
      gesave_addptr( pThis, name );
}

void STDCALL gesave_finish( pvmEngine pThis )
{
   buf  bt;
   pbuf pb = pThis->gesave;
   uint size = buf_len( pThis, pb ) - pThis->gesaveoff;

   if ( size <= 187 )
      *( pubyte )(( pubyte )buf_ptr( pThis, pThis->gesave ) + pThis->gesaveoff + 5 ) = ( ubyte )size;
   else
   {
      buf_init( pThis, &bt );
      pThis->gesave = &bt;
      if ( size < 16800 )
      {
         size++;
         gesave_bwd( pThis, size );
      }
      else
         if ( size < 0xFFF0 ) 
         {
            gesave_addubyte( pThis, 0xFE );
            size += 2;
            gesave_addushort( pThis, size );
         }
         else
         {
            gesave_addubyte( pThis, 0xFF );
            size += 4;
            gesave_adduint( pThis, size );
         }
      // Write the size
      // We have already had one byte, so -1
      buf_insert( pThis, pb, pThis->gesaveoff + 5, ( pubyte )&size /*any*/, buf_len( pThis, pThis->gesave ) - 1 );
      mem_copy( pThis, buf_ptr( pThis, pb ) + pThis->gesaveoff + 5, buf_ptr( pThis, pThis->gesave ), buf_len( pThis, pThis->gesave ));

      buf_delete( pThis, &bt );
      pThis->gesave = pb;
   }
}

void STDCALL gesave_var( pvmEngine pThis, pvartype var )
{
   uint      i;
   povmtype  ptype;
   pubyte    ptr;

   gesave_bwd( pThis, ((pvmobj)PCMD(var->type))->id );
   gesave_addubyte( pThis, var->flag );

   if ( var->flag & VAR_NAME )
      gesave_addptr( pThis, var->name );
   if ( var->flag & VAR_OFTYPE )
      gesave_bwd( pThis, ((pvmobj)PCMD(var->oftype))->id);

   if ( var->flag & VAR_DIM )
   {
      gesave_addubyte( pThis, var->dim );
      for ( i = 0; i < var->dim; i++ )
         gesave_bwd( pThis, var->ptr[i] );
   }
   if ( var->flag & VAR_DATA )
   {
      ptr = ( pubyte )( var->ptr + var->dim );
      ptype = ( povmtype )PCMD( var->type );
      if ( ptype->vmo.flag & GHTY_STACK )
         i = ptype->size;
      else
         if ( var->type == TStr )
            i = mem_len( pThis, ptr ) + 1;
         else
         {
            i = *( puint )ptr;
            ptr += sizeof( uint );
            gesave_bwd( pThis, i );   // save data size as bwd
         }
      gesave_adddata( pThis, ptr, i );
   }
}

void STDCALL gesave_varlist( pvmEngine pThis, pvartype pvar, uint count )
{
   uint i;

   gesave_bwd( pThis, count );
   for ( i = 0; i < count; i++ )
      gesave_var( pThis, pvar++ );
}

void STDCALL gesave_resource( pvmEngine pThis )
{
   uint     i, count;
   pcollect pres;

   pres = &pThis->_vm.resource;

   gesave_head( pThis, OVM_RESOURCE, "", 0 );
   
   count = collect_count( pThis, pres );
   gesave_bwd( pThis, count );
   for ( i = 0; i < count; i++ )
   {
      gesave_bwd( pThis, collect_gettype( pThis, pres, i ));
      gesave_addptr( pThis, str_ptr( vmres_getstr( pThis, i )) );
   }
   gesave_finish(pThis);
}

void STDCALL gesave_bytecode( pvmEngine pThis, povmbcode bcode )
{
   pvartype  pvar;
   uint      i, count = 0, cmd, val;
   puint     end, ptr;

   gesave_var( pThis, bcode->vmf.ret );
   gesave_varlist( pThis, bcode->vmf.params, bcode->vmf.parcount );

   gesave_bwd( pThis, bcode->setcount );
   for ( i = 0; i < bcode->setcount; i++ )
   {
      gesave_bwd( pThis, bcode->sets[i].count );
      count += bcode->sets[i].count;
   }
   pvar = bcode->vars;
   for ( i = 0; i < count; i++ )
      gesave_var( pThis, pvar++ );

   ptr = ( puint )bcode->vmf.func;
   if ( ptr )
   {
      end = ( puint )( ( pubyte )ptr + bcode->bcsize );
      while ( ptr < end )
      {
         if(*ptr>KERNEL_COUNT)
             *ptr = ((pvmobj)PCMD(*ptr))->id;
         cmd = gesave_bwd( pThis, *ptr++ );
         if ( cmd >= CNop && cmd < CNop + STACK_COUNT )
            switch ( cmd  )
            {
               case CPtrglobal:
               case CResload:
               case CCmdload:
                   cmd = gesave_bwd( pThis, ((pvmobj)PCMD(*ptr++))->id );
                   break;
               case CQwload:
                  gesave_adduint( pThis, *ptr++ );
                  gesave_adduint( pThis, *ptr++ );
                  break;
               case CDwload:
                  val = *ptr++;
                  if ( val <= 0xFF )
                  {
                     buf_ptr( pThis, pThis->gesave )[ buf_len( pThis, pThis->gesave ) - 1 ] = CByload;
                     gesave_addubyte( pThis, val );
                  }
                  else
                     if ( val <= 0xFFFF )
                     {
                        buf_ptr( pThis, pThis->gesave )[ buf_len( pThis, pThis->gesave ) - 1 ] = CShload;
                        gesave_addushort( pThis, val );
                     }
                     else
                        gesave_adduint( pThis, val );
                  break;
               case CDwsload:
                  i = gesave_bwd( pThis, *ptr++ );
                  gesave_adddata( pThis, ( pubyte )ptr, i << 2 );
                  ptr += i;
                  break;
               case CDatasize:
                  i = gesave_bwd( pThis, *ptr++ );
                  gesave_adddata( pThis, ( pubyte )ptr, i );
                  ptr += ( i >> 2 ) + ( i & 3 ? 1 : 0 );
                  break;
               default:
                  switch ( shifts[ cmd - CNop ] )
                  {
                     case SH1_3:
                     case SH2_3:
                        cmd = gesave_bwd( pThis, *ptr++ );
                     case SHN1_2:
                     case SH0_2:
                     case SH1_2:
                        cmd = gesave_bwd( pThis, *ptr++ );
                        break;
                  }
         }
      }
   }
}


void STDCALL gesave_exfunc( pvmEngine pThis, povmfunc exfunc )
{
   gesave_var( pThis, exfunc->vmf.ret );
   gesave_varlist( pThis, exfunc->vmf.params, exfunc->vmf.parcount );
   
   if ( exfunc->vmf.vmo.flag & GHEX_IMPORT )
   {
      gesave_bwd( pThis, exfunc->import );
      gesave_addptr( pThis, exfunc->original );
   }
}

void STDCALL gesave_import( pvmEngine pThis, povmimport import )
{
   gesave_addptr( pThis, import->filename );
   if ( import->vmo.flag & GHIMP_LINK )
   {
      gesave_adduint( pThis, import->size );
      gesave_adddata( pThis, import->data, import->size );
   }
}

void STDCALL gesave_type( pvmEngine pThis, povmtype ptype )
{
   uint      i, k;
   uint      flag = ptype->vmo.flag;

   if ( flag & GHTY_INHERIT )
      gesave_bwd( pThis, ((pvmobj)PCMD(ptype->inherit))->id );

   if ( flag & GHTY_INDEX )
   {
      gesave_bwd( pThis, ((pvmobj)PCMD(ptype->index.type))->id );
      gesave_bwd( pThis, ((pvmobj)PCMD(ptype->index.oftype))->id );
   }
   if ( flag & GHTY_INITDEL )
   {
      gesave_bwd( pThis, ((pvmobj)PCMD(ptype->ftype[ FTYPE_INIT ]))->id );
      gesave_bwd( pThis, ((pvmobj)PCMD(ptype->ftype[ FTYPE_DELETE ]))->id );
   }
   if ( flag & GHTY_EXTFUNC )
   {
      gesave_bwd( pThis, ((pvmobj)PCMD(ptype->ftype[ FTYPE_OFTYPE ]))->id );
      gesave_bwd( pThis, ((pvmobj)PCMD(ptype->ftype[ FTYPE_COLLECTION]))->id );
   }
   if ( flag & GHTY_ARRAY )
   {
      i = 0;
      while ( ptype->ftype[ FTYPE_ARRAY + i ] )
         i++;
      gesave_bwd( pThis, i == 1 ? ((pvmobj)PCMD(ptype->ftype[ FTYPE_ARRAY ]))->id : i );
      if ( i > 1 )
         for ( k = 0; k < i; k++ )
            gesave_bwd( pThis, ((pvmobj)PCMD(ptype->ftype[ FTYPE_ARRAY + k ]))->id );
   }
   gesave_varlist( pThis, ptype->children, ptype->count );
}

void STDCALL gesave_define( pvmEngine pThis, povmdefine pdefine )
{
   gesave_varlist( pThis, pdefine->macros, pdefine->count );
}

uint STDCALL ge_save( pvmEngine pThis, char* fileName, char* isSave)
{
    gehead   head;
    pgehead  phead;
    uint     i, ii, count;
    pvmobj   pvmo;
    buf       out;
    str  filename;
    if ( setjmp( pThis->stack_state) == -1 ) 
        return 0;

    str_init( pThis, &filename );
    str_copyzero( pThis, &filename, fileName );
    buf_init( pThis, &out );

    pThis->gesave = &out;
    buf_reserve( pThis, &out, 0x1ffff );

   *( puint )&head.idname = GE_STRING;//0x00004547;   // строка GE
   head.flags = 0;
   head.crc = 0;
   head.headsize = sizeof( gehead );
   head.size = 0;
   head.vermajor = GEVER_MAJOR; 
   head.verminor = GEVER_MINOR; 
   
   buf_append( pThis, &out, ( pubyte )&head, sizeof( gehead ));
   // Save resources at the first !
   gesave_resource(pThis);

   count = arr_count( pThis, &pThis->_vm.objtbl );
   for ( i = KERNEL_COUNT; i < count ; i++ )
   {
      if(isSave && isSave[i] == 0)
      {
         /* gesave_addubyte( pThis, OVM_NONE );
          gesave_adduint( pThis, GHCOM_PACK);
          gesave_bwd( pThis, 6 );*/
          pThis->popravka ++;
          continue;
      }

      pvmo = ( pvmobj )PCMD( i );
      pvmo->id -= pThis->popravka;
      //@init @delete @array @oftype @index -не удалять имена
      if(pThis->isDelName&&(pvmo->flag&GHCOM_NAME)&&pvmo->name&&lstrcmpA("@init",pvmo->name)&&
          lstrcmpA("@delete",pvmo->name)&&lstrcmpA("@array",pvmo->name)&&
          lstrcmpA("@oftype",pvmo->name)&&lstrcmpA("@index",pvmo->name))
      {
          pvmo->flag &= ~GHCOM_NAME;
      }else
          if(pvmo->name)
             pvmo->flag |= ~GHCOM_NAME;

      gesave_head( pThis, pvmo->type, pvmo->flag & GHCOM_NAME ? 
          pvmo->name : NULL, pvmo->flag );
      
      switch ( pvmo->type )
      {
         case OVM_NONE:
            break;
         case OVM_BYTECODE:
            gesave_bytecode( pThis, ( povmbcode )pvmo );
            break;
         case OVM_EXFUNC:
            ((povmfunc)pvmo)->import = ((pvmobj)PCMD(((povmfunc)pvmo)->import))->id;
            gesave_exfunc( pThis, ( povmfunc )pvmo );
            break;
         case OVM_TYPE:
             {
                for(ii = 0; ii<((povmtype)pvmo)->count; ii++)
                {
                    if(pThis->isDelName)
                        ((povmtype)pvmo)->children[ii].flag &=~GHCOM_NAME;
                    else if(((povmtype)pvmo)->children[ii].name)
                        ((povmtype)pvmo)->children[ii].flag |=GHCOM_NAME;
                }
                gesave_type( pThis, ( povmtype )pvmo );
             }break;
         case OVM_GLOBAL:
            gesave_var( pThis, (( povmglobal )pvmo)->type );
            break;
         case OVM_DEFINE:
            gesave_define( pThis, ( povmdefine )pvmo );
            break;
         case OVM_IMPORT:
            gesave_import( pThis, ( povmimport )pvmo );
            break;
         case OVM_ALIAS:
            gesave_bwd( pThis, (( povmalias )pvmo)->idlink );
            break;
      }
      gesave_finish(pThis);
   }
   // Specify the full size and crc
   phead = ( pgehead )buf_ptr( pThis, &out );
   phead->size = buf_len( pThis, &out );
   phead->crc = crc( pThis, ( pubyte )phead + 12, phead->size - 12, 0xFFFFFFFF );
   buf2file( pThis, &filename, &out );
   buf_delete( pThis, &out );
   str_delete( pThis, &filename );
   return 1;
}