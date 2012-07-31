// GeViewerDlg.h : header file
//

#if !defined(AFX_GEVIEWERDLG_H__12E7D9FA_3F66_40E9_A340_A19FC370196F__INCLUDED_)
#define AFX_GEVIEWERDLG_H__12E7D9FA_3F66_40E9_A340_A19FC370196F__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CGeViewerDlg dialog

class CGeViewerDlg : public CDialog
{
// Construction
public:
	CGeViewerDlg(CWnd* pParent = NULL);	// standard constructor

    CTreeCtrl  m_Tree;;
	CEdit      m_Edit;
	CImageList m_TreeImage; 
    HTREEITEM  m_GeType;
    HTREEITEM  m_GeGlobal;
    HTREEITEM  m_GeDefine;
    HTREEITEM  m_GeImport;
    HTREEITEM  m_GeResource;
    HTREEITEM  m_GeAlias;
    HTREEITEM  m_GeExFunc;
	HTREEITEM  m_GeByteCode;
// Dialog Data
	//{{AFX_DATA(CGeViewerDlg)
	enum { IDD = IDD_GEVIEWER_DIALOG };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CGeViewerDlg)
	public:
	virtual BOOL DestroyWindow();
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;
    GeClass m_GeFile;
    bool isDeleteName;
	// Generated message map functions
	//{{AFX_MSG(CGeViewerDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnClickTree1(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnSaveAss();
	afx_msg void OnDeleteNames();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_GEVIEWERDLG_H__12E7D9FA_3F66_40E9_A340_A19FC370196F__INCLUDED_)
