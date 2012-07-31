#include "stdafx.h"
#include <windows.h>
#include "GeClass.h"
#include "GeViewer.h"
#include "GeViewerDlg.h"
#include "GeParserData.h"



HTREEITEM SendToTreeType(GeClass *GeFile, int id, povmtype pType, CTreeCtrl* tree, HTREEITEM  NodeType)
{
	TV_INSERTSTRUCT root;
	root.hParent = NULL;
	root.hInsertAfter = TVI_SORT;
	root.item.iImage = 7 + 8 * GeFile->isDel(id);
	root.item.iSelectedImage = 7 + 8 * GeFile->isDel(id);
	root.item.mask = TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_TEXT | TVIF_PARAM;
	root.hParent = NodeType;
	root.item.lParam = (long)id;
	root.item.pszText = (char*)pType->vmo.name;
	HTREEITEM newType = tree->InsertItem(&root);

	root.item.iImage = 6 + 8 * GeFile->isDel(id);
	root.item.iSelectedImage = 6 + 8 * GeFile->isDel(id);
	root.hParent = newType;
    for(uint i = 0; i< pType->count; i++)
	{
        root.item.pszText = (char*)pType->children[i].name;
		root.item.lParam = (long)pType->children[i].type;
		if(pType->children[i].name)
		    tree->InsertItem(&root);
	}
    return newType;
}


void SendToTreeDefine(GeClass *GeFile, int id, povmdefine pDefine, CTreeCtrl* tree, HTREEITEM  NodeType)
{
	TV_INSERTSTRUCT root;
	root.hParent = NULL;
	root.hInsertAfter = TVI_SORT;
	root.item.iImage = 0 + 8 * GeFile->isDel(id);
	root.item.iSelectedImage = 0 + 8 * GeFile->isDel(id);
	root.item.mask = TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_TEXT | TVIF_PARAM;
	root.hParent = NodeType;
	root.item.lParam = (long)id;
	root.item.pszText = (char*)pDefine->vmo.name;

	HTREEITEM newType = NodeType;
	if(pDefine->vmo.name)
		newType = tree->InsertItem(&root);
	
	root.item.iImage = 4 + 8 * GeFile->isDel(id);
	root.item.iSelectedImage = 4 + 8 * GeFile->isDel(id);
	root.hParent = newType;
    for(uint i = 0; i< pDefine->count; i++)
	{
        root.item.pszText = (char*)pDefine->macros[i].name;
		root.item.lParam = id;//(long)&pDefine->macros[i].type;
		if(pDefine->macros[i].name)
			tree->InsertItem(&root);
	}
}


void SendToTreeGlobal(GeClass *GeFile, int id, povmglobal pGlobal, CTreeCtrl* tree, HTREEITEM  NodeType)
{
	TV_INSERTSTRUCT root;
	root.hParent = NULL;
	root.hInsertAfter = TVI_SORT;
	root.item.iImage = 6 + 8 * GeFile->isDel(id);
	root.item.iSelectedImage = 6 + 8 * GeFile->isDel(id);
	root.item.mask = TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_TEXT | TVIF_PARAM;
	root.hParent = NodeType;
	root.item.lParam = (long)id;
	root.item.pszText = (char*)pGlobal->vmo.name;
	tree->InsertItem(&root);
}


void SendToTreeByteCode(GeClass *GeFile, int id, povmbcode pByteCode, CTreeCtrl* tree, HTREEITEM  NodeType)
{
    char text[1000];
	TV_INSERTSTRUCT root;
	root.hParent = NULL;
	root.hInsertAfter = TVI_SORT;
	root.item.iImage = 5 + 8 * GeFile->isDel(id);
	root.item.iSelectedImage = 5 + 8 * GeFile->isDel(id);
	root.item.mask = TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_TEXT | TVIF_PARAM;
	root.hParent = NodeType;
	root.item.lParam = (long)id;
    if(pByteCode->vmf.vmo.name == NULL)
        root.item.pszText = "???";
    else if(pByteCode->vmf.vmo.flag&(GHBC_OPERATOR))
    {
        sprintf(text," %s %s %s",
            GeFile->GetVmObjName(pByteCode->vmf.ret->type),
            &pByteCode->vmf.vmo.name[1],
            GeFile->GetVmObjName(pByteCode->vmf.params[(pByteCode->vmf.parcount > 1)?1:0].type)
            );
        root.item.pszText = text;
    }else if(pByteCode->vmf.vmo.flag&(GHBC_METHOD))
    {
	    root.item.pszText = (char*)&pByteCode->vmf.vmo.name[1];
    }else
	    root.item.pszText = (char*)pByteCode->vmf.vmo.name;

	tree->InsertItem(&root);
}


void SendToTreeExFunc(GeClass *GeFile, int id, povmfunc pExFunc, CTreeCtrl* tree, HTREEITEM  NodeType)
{
    char text[1000];
	TV_INSERTSTRUCT root;
	root.hParent = NULL;
	root.hInsertAfter = TVI_SORT;
	root.item.iImage = 5 + 8 * GeFile->isDel(id);
	root.item.iSelectedImage = 5 + 8 * GeFile->isDel(id);
	root.item.mask = TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_TEXT | TVIF_PARAM;
	root.hParent = NodeType;
	root.item.lParam = (long)id;

    if(pExFunc->vmf.vmo.flag&(GHBC_OPERATOR))
    {
        sprintf(text," %s %s %s",
            GeFile->GetVmObjName(pExFunc->vmf.ret->type),
            &pExFunc->vmf.vmo.name[1],
            GeFile->GetVmObjName(pExFunc->vmf.params[(pExFunc->vmf.parcount > 1)?1:0].type)
            );
        root.item.pszText = text;
    }else if(pExFunc->vmf.vmo.flag&(GHBC_METHOD))
    {
        root.item.pszText = (char*)&pExFunc->vmf.vmo.name[1];
    }else
	    root.item.pszText = (char*)pExFunc->vmf.vmo.name;
	tree->InsertItem(&root);
}

HTREEITEM SendToTreeImpotr(GeClass *GeFile, int id, povmimport pImport, CTreeCtrl* tree, HTREEITEM  NodeType)
{
	TV_INSERTSTRUCT root;
	root.hParent = NULL;
	root.hInsertAfter = TVI_SORT;
	root.item.iImage = 1 + 8 * GeFile->isDel(id);
	root.item.iSelectedImage = 1 + 8 * GeFile->isDel(id);
	root.item.mask = TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_TEXT | TVIF_PARAM;
	root.hParent = NodeType;
	root.item.lParam = (long)id;
	root.item.pszText = (char*)pImport->filename;
	return tree->InsertItem(&root);
}

void SendToTreeAlias(GeClass *GeFile, int id, povmalias pAlias, CTreeCtrl* tree, HTREEITEM  NodeType)
{
	TV_INSERTSTRUCT root;
	root.hParent = NULL;
	root.hInsertAfter = TVI_SORT;
	root.item.iImage = 5 + 8 * GeFile->isDel(id);
	root.item.iSelectedImage = 5 + 8 * GeFile->isDel(id);
	root.item.mask = TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_TEXT | TVIF_PARAM;
	root.hParent = NodeType;
	root.item.lParam = (long)id;
	root.item.pszText = (char*)pAlias->vmo.name;
	tree->InsertItem(&root);
}




void parseGeFile(GeClass *GeFile, CGeViewerDlg *dlg)
{
    uint endFor = GeFile->GetCountObj();

    for(uint i = 0; i< endFor; i++)
    {
        pvmobj obj = GeFile->GetVmObj(i);
        switch ( obj->type )
        {
            case OVM_NONE:// Not defined command
                break;
            case OVM_BYTECODE:// Byte-code
                {
                    if(!(obj->flag&(GHBC_OPERATOR|GHBC_METHOD)))
                        SendToTreeByteCode(GeFile, i, (povmbcode)obj, &dlg->m_Tree, dlg->m_GeByteCode);
                }break;
            case OVM_EXFUNC:// Executable function.
                {
                    if(!(obj->flag&(GHBC_OPERATOR|GHBC_METHOD)))
                        SendToTreeExFunc(GeFile, i, (povmfunc)obj, &dlg->m_Tree, dlg->m_GeExFunc);
                }break;
            case OVM_TYPE:// Type
                {
                    HTREEITEM item = SendToTreeType(GeFile, i, (povmtype)obj, &dlg->m_Tree, dlg->m_GeType);
                    for(uint ii = 0; ii< endFor; ii++)
                    {
                        pvmobj _obj = GeFile->GetVmObj(ii);
                        if(_obj->type == OVM_BYTECODE)
                        {
                            if((_obj->flag&(GHBC_OPERATOR|GHBC_METHOD))&&((povmbcode)_obj)->vmf.params[0].type == i)
                                SendToTreeByteCode(GeFile, ii, (povmbcode)_obj, &dlg->m_Tree, item);
                        }else if(_obj->type == OVM_EXFUNC)
                        {
                            if((_obj->flag&(GHBC_OPERATOR|GHBC_METHOD))&&((povmfunc)_obj)->vmf.params[0].type == i)
                                SendToTreeExFunc(GeFile, ii, (povmfunc)_obj, &dlg->m_Tree, item);
                        }
                    }
                }break;
            case OVM_GLOBAL:// Global variable
                {
                    SendToTreeGlobal(GeFile, i, (povmglobal)obj, &dlg->m_Tree, dlg->m_GeGlobal);
                }break;
            case OVM_DEFINE:// Macros definitions
                {
                    SendToTreeDefine(GeFile, i, (povmdefine)obj, &dlg->m_Tree, dlg->m_GeDefine);
                }break;
            case OVM_IMPORT:// Import functions from external files
                {
                    HTREEITEM item = SendToTreeImpotr(GeFile, i, (povmimport)obj, &dlg->m_Tree, dlg->m_GeImport);
                    for(uint ii = KERNEL_COUNT; ii< endFor; ii++)
                    {
                        pvmobj _obj = GeFile->GetVmObj(ii);
                        if(_obj->type == OVM_EXFUNC)
                            if(obj->id == ((povmfunc)_obj)->import)
                            SendToTreeExFunc(GeFile, ii, (povmfunc)_obj, &dlg->m_Tree, item);
                    }
                }break;
            case OVM_RESOURCE:// Resources !!! must be realized in GE!
                break;
            case OVM_ALIAS:// Alias (link) object
                {
                    SendToTreeAlias(GeFile, i, (povmalias)obj, &dlg->m_Tree, dlg->m_GeAlias);
                }break;
        }
    }
}




void GeParserType(GeClass *GeFile, povmtype pType, CEdit *Edit)
{
	char text[1000], tmp[100];
	sprintf(text,"type %s \r\n {\r\n",pType->vmo.name);
	for(uint i = 0; i< pType->count; i++){
		if(pType->children[i].name)
		{
            sprintf(tmp, "    %s %s;\r\n", GeFile->GetVmObjName(pType->children[i].type), pType->children[i].name);
			lstrcatA(text,tmp);
		}
	}
    lstrcatA(text," };");
	Edit->SetWindowText(text);
}

void GeParserByteCode(GeClass *GeFile, povmbcode pByteCode, char *text)
{
    char tmp[100];
    int i = 1;
    if(pByteCode->vmf.vmo.name == NULL)
    {
        lstrcatA(text,"??? ( ");
    }else if(pByteCode->vmf.vmo.name[0] == '#')
    {
        if(pByteCode->vmf.ret->type == 0)
            sprintf(text,"operator %s ( ", &pByteCode->vmf.vmo.name[1]);
        else
            sprintf(text,"operator %s %s ( ",GeFile->GetVmObjName(pByteCode->vmf.ret->type), &pByteCode->vmf.vmo.name[1]);
    }else if(pByteCode->vmf.vmo.name[0] == '@'){
        if(pByteCode->vmf.ret->type == 0)
            sprintf(text,"method %s.%s( ", GeFile->GetVmObjName(pByteCode->vmf.params[0].type), pByteCode->vmf.vmo.name+1);
        else
            sprintf(text,"method %s %s.%s( ",GeFile->GetVmObjName(pByteCode->vmf.ret->type),
                    GeFile->GetVmObjName(pByteCode->vmf.params[0].type), pByteCode->vmf.vmo.name+1);
    }else{
        if(pByteCode->vmf.ret->type == 0)
            sprintf(text,"func %s( ", pByteCode->vmf.vmo.name);
        else
            sprintf(text,"func %s %s( ",GeFile->GetVmObjName(pByteCode->vmf.ret->type), pByteCode->vmf.vmo.name);
        i = 0;
    }
    bool zp = false;
	for(; i< pByteCode->vmf.parcount; i++){
        if(zp)lstrcatA(text,", "); else zp = true;
        sprintf(tmp, "%s", GeFile->GetVmObjName(pByteCode->vmf.params[i].type));
		lstrcatA(text,tmp);
    }
    lstrcatA(text," )\r\n\r\n======DizAsm=======\r\n");
}



void GeParserDefine(GeClass *GeFile, pvartype pDefine, CEdit *Edit)
{
    char text[1000], tmp[100];
    sprintf(text, "define %s = ",pDefine->name);
    sprintf(tmp, "???");
    switch(pDefine->type)
    {
      case TInt:sprintf(tmp, "%i",pDefine->ptr);break;
      case TUint:sprintf(tmp, "%d",pDefine->ptr);break;
      case TByte:sprintf(tmp, "%i",pDefine->ptr);break;
      case TUbyte:sprintf(tmp, "%i",pDefine->ptr);break;
      case TShort:sprintf(tmp, "%i",pDefine->ptr);break;
      case TUshort:sprintf(tmp, "%i",pDefine->ptr);break;
      case TFloat:sprintf(tmp, "%f",pDefine->ptr);break;
      case TStr:sprintf(tmp, "\"%s\"",pDefine->ptr);break;
    }
    lstrcatA(text,tmp);
        Edit->SetWindowText(text);
}


void GeParserExFunc(GeClass *GeFile, povmfunc pExFunc, CEdit *Edit)
{
    char text[1000], tmp[100];
    povmimport dll = (povmimport)GeFile->GetVmObj(pExFunc->import);
    char *name = (dll->filename?(char*)dll->filename:"");
    int i = 1, ni = 1;
    sprintf(text, "import \"%s\" {\r\n   ", name);

    if(pExFunc->vmf.vmo.name[0] == '#')
    {
        if(pExFunc->vmf.ret->type == 0)
            sprintf(tmp,"operator %s ( ", &pExFunc->vmf.vmo.name[1]);
        else
            sprintf(tmp,"operator %s %s ( ",GeFile->GetVmObjName(pExFunc->vmf.ret->type), &pExFunc->vmf.vmo.name[1]);
    }else if(pExFunc->vmf.vmo.name[0] == '@'){
        if(pExFunc->vmf.ret->type == 0)
            sprintf(tmp,"method %s.%s( ", GeFile->GetVmObjName(pExFunc->vmf.params[0].type), pExFunc->vmf.vmo.name+1);
        else
            sprintf(tmp,"method %s %s.%s( ",GeFile->GetVmObjName(pExFunc->vmf.ret->type),
            GeFile->GetVmObjName(pExFunc->vmf.params[0].type), pExFunc->vmf.vmo.name+1);
    }else{
        if(pExFunc->vmf.ret->type == 0)
            sprintf(tmp,"func %s( ", pExFunc->vmf.vmo.name);
        else
            sprintf(tmp,"func %s %s( ",GeFile->GetVmObjName(pExFunc->vmf.ret->type), pExFunc->vmf.vmo.name);
        i = 0;
        ni = 0;
    }

    lstrcatA(text,tmp);
    for(; i< pExFunc->vmf.parcount; i++){
        if(i>ni)lstrcatA(text,", ");
        sprintf(tmp, "%s", GeFile->GetVmObjName(pExFunc->vmf.params[i].type));
        lstrcatA(text,tmp);
    }
    lstrcatA(text," )\r\n}");
    Edit->SetWindowText(text);
}



void parseVmObjId(GeClass *GeFile, CGeViewerDlg *dlg, int id)
{
    if(id == 0)
        return;
    pvmobj obj = GeFile->GetVmObj(id);
    if(obj == NULL)
        return;
    switch ( obj->type )
    {
        case OVM_NONE:// Not defined command
            break;
        case OVM_BYTECODE:// Byte-code
              //  GeParserByteCode(GeFile, (povmbcode)obj, &dlg->m_Edit);
                dizAsm(GeFile, id, &dlg->m_Edit);
            break;
        case OVM_EXFUNC:// Executable function.
                GeParserExFunc(GeFile, (povmfunc)obj, &dlg->m_Edit);
            break;
        case OVM_TYPE:// Type
                GeParserType(GeFile, (povmtype)obj, &dlg->m_Edit);
            break;
        case OVM_GLOBAL:// Global variable
            dlg->m_Edit.SetWindowText("?????????");
            break;
        case OVM_DEFINE:// Macros definitions
                GeParserDefine(GeFile, (pvartype)obj, &dlg->m_Edit);
            break;
        case OVM_IMPORT:// Import functions from external files
            dlg->m_Edit.SetWindowText("");
            break;
        case OVM_RESOURCE:// Resources !!! must be realized in GE!
            dlg->m_Edit.SetWindowText("?????????");
            break;
        case OVM_ALIAS:// Alias (link) object
            dlg->m_Edit.SetWindowText("?????????");
            break;
    }
}



void dizGetName(GeClass *GeFile, int id, char *txt)
{
    char tmp[100];
    pvmobj obj = GeFile->GetVmObj(id);
    if(obj->type == OVM_BYTECODE)
    {
        int i = 1;
        povmbcode pByteCode = (povmbcode)obj;
        if(pByteCode->vmf.vmo.name == NULL)
        {
            lstrcatA(txt, "???");
        }else if(pByteCode->vmf.vmo.name[0] == '#')
        {
            if(pByteCode->vmf.ret->type == 0)
                sprintf(txt,"operator %s ( ", &pByteCode->vmf.vmo.name[1]);
            else
                sprintf(txt,"operator %s %s ( ",GeFile->GetVmObjName(pByteCode->vmf.ret->type), &pByteCode->vmf.vmo.name[1]);
        }else if(pByteCode->vmf.vmo.name[0] == '@'){
            if(pByteCode->vmf.ret->type == 0)
                sprintf(txt,"method %s.%s( ", GeFile->GetVmObjName(pByteCode->vmf.params[0].type), pByteCode->vmf.vmo.name+1);
            else
                sprintf(txt,"method %s %s.%s( ",GeFile->GetVmObjName(pByteCode->vmf.ret->type),
                GeFile->GetVmObjName(pByteCode->vmf.params[0].type), pByteCode->vmf.vmo.name+1);
        }else{
            if(pByteCode->vmf.ret->type == 0)
                sprintf(txt,"func %s( ", pByteCode->vmf.vmo.name);
            else
                sprintf(txt,"func %s %s( ",GeFile->GetVmObjName(pByteCode->vmf.ret->type), pByteCode->vmf.vmo.name);
            i = 0;
        }
        bool zp = false;
        for(; i< pByteCode->vmf.parcount; i++){
            if(zp)lstrcatA(txt,", "); else zp = true;
            sprintf(tmp, "%s", GeFile->GetVmObjName(pByteCode->vmf.params[i].type));
            lstrcatA(txt,tmp);
        }
        lstrcatA(txt," )");

    }else if(obj->type == OVM_EXFUNC){
        int i = 1, ni = 1;
        povmfunc pExFunc = (povmfunc)obj;

        if(pExFunc->vmf.vmo.name == 0)
        {
            lstrcatA(txt,"???");
        }else if(pExFunc->vmf.vmo.name[0] == '#')
        {
            if(pExFunc->vmf.ret->type == 0)
                sprintf(txt,"operator %s ( ", &pExFunc->vmf.vmo.name[1]);
            else
                sprintf(txt,"operator %s %s ( ",GeFile->GetVmObjName(pExFunc->vmf.ret->type), &pExFunc->vmf.vmo.name[1]);
        }else if(pExFunc->vmf.vmo.name[0] == '@'){
            if(pExFunc->vmf.ret->type == 0)
                sprintf(txt,"method %s.%s( ", GeFile->GetVmObjName(pExFunc->vmf.params[0].type), pExFunc->vmf.vmo.name+1);
            else
                sprintf(txt,"method %s %s.%s( ",GeFile->GetVmObjName(pExFunc->vmf.ret->type),
                GeFile->GetVmObjName(pExFunc->vmf.params[0].type), pExFunc->vmf.vmo.name+1);
        }else{
            if(pExFunc->vmf.ret->type == 0)
                sprintf(txt,"func %s( ", pExFunc->vmf.vmo.name);
            else
                sprintf(txt,"func %s %s( ",GeFile->GetVmObjName(pExFunc->vmf.ret->type), pExFunc->vmf.vmo.name);
            i = 0;
            ni = 0;
        }
        for(; i< pExFunc->vmf.parcount; i++){
            if(i>ni)lstrcatA(txt,", ");
            sprintf(tmp, "%s", GeFile->GetVmObjName(pExFunc->vmf.params[i].type));
            lstrcatA(txt,tmp);
        }
        lstrcatA(txt," )");
    }

}



void dizAsm(GeClass *GeFile, int id, CEdit *Edit)
{
    char text[100000], tmp[1000];
    text[0] =0;
    povmbcode fun = (povmbcode)GeFile->GetVmObj(id);
    GeParserByteCode(GeFile, fun, text);
    int size  = fun->bcsize;
    uint* cod = (uint*)fun->vmf.func;
    for(int i = 0; i*4< size;)
    {
        pvmobj obj = GeFile->GetVmObj(cod[i]);
        switch(obj->type)
        {
            case OVM_STACKCMD:
            case OVM_PSEUDOCMD:
                lstrcatA(text, GeFile->GetVmObjName(cod[i]));
                if(cod[i] == CDwload)
                {
                    wsprintf(tmp," { %i }", cod[i+1]);
                    lstrcatA(text, tmp);
                }else if(cod[i] == CDwsload)
                {
                    wsprintf(tmp," %i{", cod[i+1]);
                    lstrcatA(text, tmp);
                    for(int ii = 0; ii< cod[i+1]; ii++)
                    {
                        if(ii == 0)
                            wsprintf(tmp, " %i", cod[i+1+ii]);
                        else
                            wsprintf(tmp, ", %i", cod[i+1+ii]);
                    }
                    lstrcatA(text, tmp);
                    lstrcatA(text, " }");
                    i+= cod[i+1]+1;
                }else if(cod[i] == CDatasize)
                {
                    memcpy(tmp, &cod[i+2],cod[i+1]);
                    for(int ii = 0; ii<cod[i+1]; ii++)
                    {
                        if(tmp[ii] < 20)
                            tmp[ii] = ' ';
                    }
                    tmp[cod[i+1]] = 0;
                    i += (cod[i+1]+3)>>2;
                    lstrcatA(text, " { ");
                    lstrcatA(text, tmp);
                    lstrcatA(text, " }");
                    i += 1;
                }else if(cod[i] == CSubpar || cod[i] == CCmdcall)
                {
                    i++;
                }
                i += ((povmstack)obj)->cmdshift;
                break;
            case OVM_BYTECODE:
            case OVM_EXFUNC:
                lstrcatA(text, "_Call_ ");
                dizGetName(GeFile, cod[i], tmp);
                lstrcatA(text, tmp);
                i++;
                break;
            case OVM_TYPE:
                lstrcatA(text, GeFile->GetVmObjName(cod[i]));
                i += ((povmtype)obj)->size;
                break;
            default:
                i++;
        }
        lstrcatA(text, "\r\n");
    }


    Edit->SetWindowText(text);
}


















