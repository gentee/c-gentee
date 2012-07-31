// GeViewerDlg.cpp : implementation file
//

#include "stdafx.h"
#include "GeViewer.h"
#include "GeClass.h"
#include "GeViewerDlg.h"
#include "GeParserData.h"

bool file_dialog(char *fil2,bool tip){
	char im_f[300];
	char str_mask[100];
	OPENFILENAME ofn;
	UINT i,k;
	lstrcpy(fil2,"*.ge");
	lstrcpy(str_mask,fil2);
	im_f[0]='\0';
	i=lstrlen(str_mask);
	str_mask[i]=' ';
	str_mask[i+1]='\0';
	lstrcat(str_mask,fil2);
	k=lstrlen(str_mask);
	str_mask[i]='\0';
	str_mask[k+1]='\0';
	RtlZeroMemory(&ofn,sizeof(OPENFILENAME));
	ofn.lStructSize=sizeof(OPENFILENAME);
	ofn.lpstrFilter=(char*)&str_mask;
	ofn.nFilterIndex=1;
	ofn.hwndOwner=0;
	ofn.lpstrFile=fil2;
	ofn.nMaxFile=500;
	ofn.lpstrFileTitle=(char*)&im_f;
	ofn.nMaxFileTitle=500;
	ofn.Flags=OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
	if(tip){
		if(GetSaveFileName(&ofn))return true;
		else return false;
	}else{
		if(GetOpenFileName(&ofn))return true;
		else return false;
	}
}//===============================================================




#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CGeViewerDlg dialog

CGeViewerDlg::CGeViewerDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CGeViewerDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CGeViewerDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CGeViewerDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CGeViewerDlg)
		DDX_Control(pDX, IDC_GE_TREE, m_Tree);
		DDX_Control(pDX, IDC_EDIT, m_Edit);
		
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CGeViewerDlg, CDialog)
	//{{AFX_MSG_MAP(CGeViewerDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_NOTIFY(NM_CLICK, IDC_GE_TREE, OnClickTree1)
	ON_BN_CLICKED(IDC_BUTTON1, OnSaveAss)
	ON_BN_CLICKED(IDC_CHECK1, OnDeleteNames)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CGeViewerDlg message handlers

BOOL CGeViewerDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here
	
	m_TreeImage.Create( IDB_GETREEBITMAP, 16, 16, RGB(0,255,0) );
	m_Tree.SetImageList( &m_TreeImage, TVSIL_NORMAL );

	TV_INSERTSTRUCT root;
	root.hParent = NULL;
	root.hInsertAfter = TVI_SORT;
	root.item.iImage = 2;
	root.item.iSelectedImage = 3;
	root.item.mask = TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_TEXT;

	root.item.pszText = "Type";
	m_GeType = m_Tree.InsertItem(&root);
	root.item.pszText = "Global";
	m_GeGlobal = m_Tree.InsertItem(&root);
	root.item.pszText = "Define";
	m_GeDefine = m_Tree.InsertItem(&root);
	root.item.pszText = "Import";
	m_GeImport = m_Tree.InsertItem(&root);
	root.item.pszText = "Resource";
	m_GeResource = m_Tree.InsertItem(&root);
	root.item.pszText = "Alias";
	m_GeAlias = m_Tree.InsertItem(&root);
	root.item.pszText = "AllImport";
	m_GeExFunc = m_Tree.InsertItem(&root);
	root.item.pszText = "ByteCode";
	m_GeByteCode = m_Tree.InsertItem(&root);

	char namef[300];
    namef[0] = 0;
    isDeleteName = false;
    lstrcpy(namef, theApp.m_lpCmdLine);
    if(namef[0] != 0 || file_dialog(namef,false)){
       if(m_GeFile.LoadGe(namef))
	    parseGeFile(&m_GeFile, this);
       SetWindowText(namef);
	}
	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CGeViewerDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CGeViewerDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CGeViewerDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

void CGeViewerDlg::OnClickTree1(NMHDR* pNMHDR, LRESULT* pResult) 
{
	// TODO: Add your control notification handler code here
	CPoint pt;
	GetCursorPos(&pt);
	m_Tree.ScreenToClient(&pt);
	UINT nFlags;
	HTREEITEM hItem = m_Tree.HitTest(pt, &nFlags);
    if(hItem)
	{
		m_Tree.SelectItem(hItem); 
        HTREEITEM root = m_Tree.GetParentItem(hItem);
		DWORD id = m_Tree.GetItemData(hItem);
        parseVmObjId(&m_GeFile, this, id);
	}
	*pResult = 0;
}

BOOL CGeViewerDlg::DestroyWindow() 
{
	// TODO: Add your specialized code here and/or call the base class

	return CDialog::DestroyWindow();
}

void CGeViewerDlg::OnSaveAss() 
{
    char namef[300];
    namef[0] = 0;
    if(file_dialog(namef, true))
	    m_GeFile.SaveGe(namef, isDeleteName);	
}

void CGeViewerDlg::OnDeleteNames() 
{
	// TODO: Add your control notification handler code here
	isDeleteName = !isDeleteName;
}
