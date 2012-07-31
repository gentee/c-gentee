#ifndef _GE_CLASS_H_
#define _GE_CLASS_H_
#include "./GeEngine/common.h"
#include "./GeEngine/vm.h"
#include "./GeEngine/gefile.h"


#define GE_SAVE_OBJ        1
#define GE_ANALIZ_BYTECODE 2
#define GE_ANALIZ_VARS     4
#define GE_ANALIZ_TYPE     8


class GeClass
{
public:
    GeClass();
    ~GeClass();
    bool LoadGe(char *nameFile);
    bool SaveGe(char *nameFile, bool delName);
    uint GetCountObj();
    pvmobj GetVmObj(uint index);
    char*  GetVmObjName(uint index);
    bool   isDel(int index);
private:
    pvmEngine m_pEngine;
    void AnalizDel();

    bool AnalizByteCod();
    bool AnalizVarType();
    bool AnalizType();
    char *m_pFlagDel;

};

#endif //_GE_CLASS_H_