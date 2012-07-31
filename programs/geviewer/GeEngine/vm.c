#include "types.h"
#include "common.h"

#include "vm.h"
#include "gefile.h"
#include "bytecode.h"



/*-----------------------------------------------------------------------------
* Summary: Append a string to resource
-----------------------------------------------------------------------------*/

uint  STDCALL  vmres_addstr( pvmEngine pThis, pubyte ptr )
{
   collect_addptr( pThis, &pThis->_vm.resource, ptr );

   return collect_count( pThis, &pThis->_vm.resource ) - 1;
}

/*-----------------------------------------------------------------------------
* Summary: Get a string from resource
-----------------------------------------------------------------------------*/

pstr  STDCALL  vmres_getstr( pvmEngine pThis, uint index )
{
   return *( pstr* )collect_index( pThis, &pThis->_vm.resource, index );
}





/*-----------------------------------------------------------------------------
* Summary: Initialize the virtual machine.
-----------------------------------------------------------------------------*/

void  STDCALL vm_deinit( pvmEngine pThis )// pvm _pvm )
{
   // Destroy all objects
   vmmng_destroy(pThis);
   arr_delete( pThis, &pThis->_vm.objtbl );
   hash_delete( pThis, &pThis->_vm.objname );
   collect_delete( pThis, &pThis->_vm.resource );
   buf_delete( pThis, &pThis->_vm.resource.data );

}

/*-----------------------------------------------------------------------------
* Summary: Initialize the virtual machine.
-----------------------------------------------------------------------------*/

void  STDCALL vm_init( pvmEngine pThis  )
{
   uint       i, id, k, len;
   int        topshift, cmdshift;
   pubyte     emb, ptr = ( pubyte )&embtypes;
   ubyte      input[64];
   pvmfunc    pfunc;

   mem_zero( pThis, &pThis->_vm, sizeof( vm ));
   pThis->_vm.loadmode = 1;
   // Initialize the array of objects
   arr_init( pThis, &pThis->_vm.objtbl, sizeof( uint ));
   arr_step( pThis, &pThis->_vm.objtbl, 1024 );
   buf_init( pThis, &pThis->_vm.resource.data );

   // Initialize the hash of object names
   hash_init( pThis, &pThis->_vm.objname, sizeof( uint ));
   vmmng_new(pThis);

   // Add zero command
   load_stack( pThis, 0, 0, NULL )->type = OVM_NONE;

   // Loading kernel objects into VM
   for ( i = TInt; i <= TFordata; i++ )
   {
      load_type( pThis, &ptr );
   }
   // Loading kernel objects into VM
   for ( i = 0; i < STACK_COUNT; i++ )
   {
      topshift = 0;
      cmdshift = 0;
      switch ( shifts[i] )
      {
         case SHN3_1: topshift--;
         case SHN2_1: topshift--;
         case SHN1_1: topshift--;
            cmdshift = 1;
            break;
         case SHN1_2: topshift--;
            cmdshift = 2;
            break;
         case SH0_2:  cmdshift++;
         case SH0_1:  cmdshift++;
            break;
         case SH1_3:  cmdshift++;
         case SH1_2:  cmdshift++;
         case SH1_1:  cmdshift++;
            topshift = 1;
            break;
         case SH2_1:
            topshift = 2;
            cmdshift = 1;
            break;
         case SH2_3:
            topshift = 2;
            cmdshift = 3;
            break;
      }
      id = pThis->_vm.count;
      load_stack( pThis, topshift, cmdshift, NULL );
   }
   emb = ( pubyte )&embfuncs;
   for ( i = 0; i < FUNCCOUNT; i++ )
   {
      ptr = ( pubyte )&input;
      *ptr++ = OVM_EXFUNC;
      *(( puint )ptr)++ = GHCOM_NAME | GHCOM_PACK;
      *ptr++ = 0;
      len = mem_copyuntilzero( pThis, ptr, emb );
      ptr += len;
      emb += len;
      id = *emb++;
      *ptr++ = ( id & 0x80 ? *emb++ : 0 );
      *ptr++ = 0;
      id &= 0x7f;
      *ptr++ = ( ubyte )id;
      for ( k = 0; k < id; k++ )
      {
         *ptr++ = *emb++;
         *ptr++ = 0;
      }
      input[ 5 ] = ( ubyte )( ptr - ( pubyte )&input );
      ptr = ( pubyte )&input;

      pfunc = ( pvmfunc )load_exfunc( pThis, &ptr, 0 );
      pfunc->func = NULL;
   }
   // Loading reserved empty commands
   while ( pThis->_vm.count < KERNEL_COUNT )
      load_stack( pThis, 0, 0, NULL )->type = OVM_NONE;

   pThis->_vm.countinit = 0;//KERNEL_COUNT;

}





/*-----------------------------------------------------------------------------
* Summary: Create a new vmmanager
-----------------------------------------------------------------------------*/

pvmmanager STDCALL vmmng_new( pvmEngine pThis )
{
   pvmmanager  pmng = mem_alloc( pThis, sizeof( vmmanager ));
   mem_zero(pThis, pmng, sizeof( vmmanager ));
   pmng->next = pThis->_vm.pmng;
   pThis->_vm.pmng = pmng;
   pmng->ptr = mem_alloc( pThis, 0x100000 );
   pmng->top = pmng->ptr;
   pmng->end = ( pubyte )pmng->ptr + 0xFFF00;

   return pmng;
}

/*-----------------------------------------------------------------------------
* Summary: Destroy all vm managers
-----------------------------------------------------------------------------*/

void STDCALL vmmng_destroy( pvmEngine pThis )
{
   pvmmanager pmng;

   while ( pThis->_vm.pmng )
   {
      pmng = pThis->_vm.pmng;

      mem_free( pThis, pmng->ptr );
      pThis->_vm.pmng = pmng->next;
      mem_free( pThis, pmng );
   }
}

/*-----------------------------------------------------------------------------
* Summary: Get a pointer for object
-----------------------------------------------------------------------------*/

pubyte STDCALL vmmng_begin( pvmEngine pThis, uint size )
{
   pvmmanager  pmng = pThis->_vm.pmng;

   if ( ( pmng->top + 2 * size ) > pmng->end )
   {
      pmng = vmmng_new(pThis);
      if ( size + 0xFFFF > 0x100000 )
      {
         mem_free( pThis, pmng->ptr );
         pmng->ptr = mem_alloc( pThis, size + 0xFFFF );
         pmng->top = pmng->ptr;
         pmng->end = ( pubyte )pmng->ptr + size + 0xFF00;
      }
   }
   return pmng->top;
}

/*-----------------------------------------------------------------------------
* Summary: The end of the object
-----------------------------------------------------------------------------*/

uint STDCALL vmmng_end( pvmEngine pThis, pubyte end )
{
   uint  ret = end - pThis->_vm.pmng->top;

   (( pvmobj )pThis->_vm.pmng->top)->size = ret;

   pThis->_vm.pmng->top = end;
   return ret;
}
