#include "stdafx.h"
#include "GeClass.h"


GeClass::GeClass()
{
    m_pEngine = new vmEngine;
    mem_zero( m_pEngine, m_pEngine, sizeof( vmEngine ));
    mem_init(m_pEngine);
    crc_init(m_pEngine);
    vm_init(m_pEngine);
    m_pFlagDel = NULL;
}


GeClass::~GeClass()
{
   vm_deinit(m_pEngine);
   mem_deinit(m_pEngine);
   delete(m_pEngine);
   if(m_pFlagDel != NULL)
       delete m_pFlagDel;
}

bool GeClass::LoadGe(char *nameFile)
{
    bool ret = ge_load(m_pEngine, nameFile) == 1;
    if(ret)
        AnalizDel();
    return ret;
}

bool GeClass::SaveGe(char *nameFile, bool delName)
{
    m_pEngine->isDelName = delName;
    return ge_save(m_pEngine, nameFile, m_pFlagDel) == 1;
}

uint GeClass::GetCountObj()
{
    return m_pEngine->_vm.count;
}

pvmobj GeClass::GetVmObj(uint index)
{
    if(index > m_pEngine->_vm.count)
        return NULL;
    return (pvmobj) *(( puint )m_pEngine->_vm.objtbl.data.data + index);
}

char* GeClass::GetVmObjName(uint index)
{
    char *ret = NULL;
    if(index < m_pEngine->_vm.count)
    {
        pvmobj obj = (pvmobj) *(( puint )m_pEngine->_vm.objtbl.data.data + index);
        switch(obj->type)
        {
            case OVM_STACKCMD:
            case OVM_PSEUDOCMD:
                ret = pCmpInfo[index].name;
                break;
            case OVM_BYTECODE:
            case OVM_EXFUNC:
            case OVM_TYPE:
            case OVM_GLOBAL:
            case OVM_ALIAS:
                ret = (char*)obj->name;
                break;
            case OVM_IMPORT:
                ret = (char*)((povmimport)obj)->filename;
                break;    
        }
    }
    if(ret == NULL)
        ret = "???";
    return ret;
}




void GeClass::AnalizDel()
{
    int count = m_pEngine->_vm.count;
    int i;
    bool analiz = false;
    m_pFlagDel = new char[count];
    memset(m_pFlagDel , 0, count);

    for(i = 0; i<count; i++)
    {
        pvmobj obj = (pvmobj) *(( puint )m_pEngine->_vm.objtbl.data.data + i);
        if(/*obj->type == OVM_TYPE     ||*/
           /*obj->type == OVM_GLOBAL   ||*/
           /*obj->type == OVM_ALIAS    ||*/
           obj->type == OVM_RESOURCE /*||
           obj->type == OVM_DEFINE   */)
        {
            m_pFlagDel[i] = GE_SAVE_OBJ|GE_ANALIZ_BYTECODE|GE_ANALIZ_VARS|GE_ANALIZ_TYPE;
            continue;
        }  
        if(obj->type == OVM_BYTECODE && obj->flag &(GHBC_MAIN|GHBC_ENTRY))
        {
            m_pFlagDel[i] = GE_SAVE_OBJ;
            analiz = true;
        }
    }
    while(true)
    {
        if(AnalizByteCod())
            continue;
        if(AnalizVarType())
            continue;
        if(AnalizType())
            continue;
        break;
    }
}

bool GeClass::isDel(int index)
{
    if(m_pFlagDel != NULL)
        return !((m_pFlagDel[index]&GE_SAVE_OBJ) == GE_SAVE_OBJ);
    return false;
}



bool GeClass::AnalizByteCod()
{
    int count = m_pEngine->_vm.count;
    bool analiz = false;
    for(int i = 0; i<count; i++)
    {
        if((m_pFlagDel[i]&GE_SAVE_OBJ) && !(m_pFlagDel[i]&GE_ANALIZ_BYTECODE))
        {
            analiz = true;
            povmbcode fun = (povmbcode) *(( puint )m_pEngine->_vm.objtbl.data.data + i);
            if(fun->vmf.vmo.type != OVM_BYTECODE)
            {
                if(fun->vmf.vmo.type == OVM_EXFUNC)
                    m_pFlagDel[((povmfunc)fun)->import] = GE_ANALIZ_BYTECODE | GE_SAVE_OBJ;
                m_pFlagDel[i] |= GE_ANALIZ_BYTECODE;
                continue;
            }
            int size  = fun->bcsize;
            uint* cod = (uint*)fun->vmf.func;
            for(int ii = 0; ii*4< size;)
            {
                pvmobj obj = GetVmObj(cod[ii]);
                switch(obj->type)
                {
                case OVM_STACKCMD:
                case OVM_PSEUDOCMD:
                    if(cod[ii] == CDwsload)
                    {
                        ii+= cod[ii+1]+1;
                    }else if(cod[ii] == CDatasize)
                    {
                        ii += (cod[ii+1]+3)>>2;
                        ii += 1;
                    }else if(cod[ii] == CSubpar || cod[ii] == CCmdcall)
                    {
                        ii++;
                    }else if(cod[ii] == CPtrglobal || cod[ii] == CResload || cod[ii] == CCmdload)
                    {
                        m_pFlagDel[cod[ii+1]] |= GE_SAVE_OBJ;
                    }
                    ii += ((povmstack)obj)->cmdshift;
                    break;
                case OVM_BYTECODE:
                case OVM_EXFUNC:
                    m_pFlagDel[cod[ii]] |= GE_SAVE_OBJ;
                    ii++;
                    break;
                default:
                    ii++;
                }
            }
            m_pFlagDel[i] |= GE_ANALIZ_BYTECODE;
        }
    }
    return analiz;
}


bool GeClass::AnalizVarType()
{
    bool analiz = false;
    int count = m_pEngine->_vm.count;
    for(int i = 0; i<count; i++)
    {
        if((m_pFlagDel[i]&GE_SAVE_OBJ) && !(m_pFlagDel[i]&GE_ANALIZ_VARS))
        {
            analiz = true;
            povmbcode fun = (povmbcode) *(( puint )m_pEngine->_vm.objtbl.data.data + i);
            if(fun->vmf.vmo.type != OVM_BYTECODE)
            {
                if(fun->vmf.vmo.type == OVM_GLOBAL)
                {
                    m_pFlagDel[(( povmglobal )fun)->type->type] |= GE_SAVE_OBJ;

                }
                if(fun->vmf.vmo.type == OVM_EXFUNC)
                {
                    for(int ii = 0; ii < fun->vmf.parcount; ii++)
                        m_pFlagDel[fun->vmf.params->type] |= GE_SAVE_OBJ;
                    m_pFlagDel[((povmfunc)fun)->import] |= GE_ANALIZ_VARS;
                }
                m_pFlagDel[i] |= GE_ANALIZ_VARS;
                continue;
            }
            int ii, countVar = 0;
            for(ii = 0; ii < fun->vmf.parcount; ii++)
                m_pFlagDel[fun->vmf.params->type] |= GE_SAVE_OBJ;
            for(ii = 0; ii < fun->setcount; ii++)
                countVar += fun->sets[ii].count;
            for(ii = 0; ii < countVar; ii++)
                m_pFlagDel[fun->vars[ii].type] |= GE_SAVE_OBJ;
            m_pFlagDel[i] |= GE_ANALIZ_VARS;
        }
    }
    return analiz;
}



bool GeClass::AnalizType()
{
    bool analiz = false;
    int count = m_pEngine->_vm.count;
    for(int i = 0; i<count; i++)
    {
        if((m_pFlagDel[i]&GE_SAVE_OBJ) && !(m_pFlagDel[i]&GE_ANALIZ_TYPE))
        {
            analiz = true;
            povmtype typ = (povmtype) *(( puint )m_pEngine->_vm.objtbl.data.data + i);
            if(typ->vmo.type != OVM_TYPE)
            {
                m_pFlagDel[i] |= GE_ANALIZ_TYPE;
                continue;
            }

            for(int ii = 0; ii<typ->count; ii++)
                m_pFlagDel[typ->children[ii].type] |= GE_SAVE_OBJ;

            uint flag = typ->vmo.flag;
            
            if ( flag & GHTY_INHERIT )
                m_pFlagDel[typ->inherit] |= GE_SAVE_OBJ;
            
            if ( flag & GHTY_INDEX )
            {
                m_pFlagDel[typ->index.type] |= GE_SAVE_OBJ;
                m_pFlagDel[typ->index.oftype] |= GE_SAVE_OBJ;
            }
            if ( flag & GHTY_INITDEL )
            {
                m_pFlagDel[typ->ftype[ FTYPE_INIT ]] |= GE_SAVE_OBJ;
                m_pFlagDel[typ->ftype[ FTYPE_DELETE ]] |= GE_SAVE_OBJ;
            }
            if ( flag & GHTY_EXTFUNC )
            {
                m_pFlagDel[typ->ftype[ FTYPE_OFTYPE ]] |= GE_SAVE_OBJ;
                m_pFlagDel[typ->ftype[ FTYPE_COLLECTION]] |= GE_SAVE_OBJ;
            }
            if ( flag & GHTY_ARRAY )
            {
                int ii = 0;
                while ( typ->ftype[ FTYPE_ARRAY + ii ] )
                    ii++;
                m_pFlagDel[ii == 1 ? typ->ftype[ FTYPE_ARRAY ]:ii] |= GE_SAVE_OBJ;
                if ( ii > 1 )
                    for (int k = 0; k < ii; k++ )
                        m_pFlagDel[typ->ftype[ FTYPE_ARRAY + k ]] |= GE_SAVE_OBJ;
            }
            m_pFlagDel[i] |= GE_ANALIZ_TYPE;
        }
    }
    return analiz;
}








