��������� �������
 ��� �������� �������� ����������� ������ ������������� (���� �������� �����)
 (Ctrl - ������) ������ �������������� ��� ��������� ���� ����� �� ������� ����������� ������
 F3 - ���������� �����
 ������ ������� �������� ������ �� Open � ������� (� ������� ������)

��� �������� ��������� �������� �-��
  dbgPrint(str) - ������ ���� � ������� ��������
  dbgBreak()    - ����� �� �������� ������


============================ ������������� Dll =================================================================
 ����������� �������� ����� geDebuger_Init(setupDebuger *st);
		���������� ���������
	typedef struct _setupDebuger
	{
	    HWND            mainWND;
	    unsigned long   flag; 
	    _gentee_init    ge_init;
	    _gentee_compile ge_compile;
	    _gentee_set     ge_set;
	    _gentee_ptr     ge_ptr;
	    _gentee_call    ge_call;
	}setupDebuger;
	��� 
	mainWND - ����� ���� �������� (NULL - ���� ���)
	flag - ����� ����������
		DEBUG_CHILD_WINDOWS - �������� ������������ ��� ������� (���� ������ mainWND)
		DEBUG_HIGE_FILELIST - ������ ������ ������ (���������)
		DEBUG_HIGE_DEBUGLOG - ������ ������� ���������
		DEBUG_SHOW_WINDOWS - ������� ����� ������� ���� ��������� (�� �����������)
	ge_init, ge_compile, ge_set, ge_ptr, ge_call - ��������� �� ��������������� ������� gentee (����� ��� ���������)

geDebuger_Destroy() - ���������� �������� (���� ���������)
geDebager_Show(BOOL isView) - ������\�������� ���� ���������
geDebuger_Move(int x, int y, int w, int h) - ��������� ������� � ������� ���� ���������
	x, y - ���������� ������� ����� ����� ���� ���������
        w,  h - ������, ������ ����

������� ������������� � exe.c � TestDll.rar

��������� ������� ����������
 - ���� ��������� (�� ����) �������� � ������ ����� (�� ��������� ������ ��� ������ geDebuger_Destroy())
 - ������ ������� ���� ������ �� ��������� ���� ��������� (������� �������).
 - �������� ������� ���� CMPL_THREAD.
 - ��������� ���� ��������� ������� �������� (������ �������� �������� ���������� ������)
 - ����������� ����� ����������� ����������� �� ������� ��������
 - �������� ��������� ������ � �������� gentee 3.0 �� 3.2 (�������� ������ ����� 3.3 (���������� �������� �������))

� �������� ���� �� ��������:
 - ����� �� ������
 - ����� ����� VM
 - ��������� �� �������
 - ������ ������ ���� (�� 3.1 ����� ����������� �� �������� ������ �����������)


