// GeViewer.h : main header file for the GEVIEWER application
//

#if !defined(AFX_GEVIEWER_H__0C66EC79_D347_4C2C_B3FC_805719F3382A__INCLUDED_)
#define AFX_GEVIEWER_H__0C66EC79_D347_4C2C_B3FC_805719F3382A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CGeViewerApp:
// See GeViewer.cpp for the implementation of this class
//

class CGeViewerApp : public CWinApp
{
public:
	CGeViewerApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CGeViewerApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CGeViewerApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
extern CGeViewerApp theApp;

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_GEVIEWER_H__0C66EC79_D347_4C2C_B3FC_805719F3382A__INCLUDED_)
