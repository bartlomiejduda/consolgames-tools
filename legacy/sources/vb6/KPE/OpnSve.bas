Attribute VB_Name = "OpnSve"
Public fil() As Byte
Public Declare Function GetOpenFileName Lib "comdlg32.dll" Alias "GetOpenFileNameA" (pOpenfilename As OPENFILENAME) As Long ' ���������� �������
Public Declare Function GetSaveFileName Lib "comdlg32.dll" Alias "GetSaveFileNameA" (pOpenfilename As OPENFILENAME) As Long
Public OFName           As OPENFILENAME
Public Type OPENFILENAME
    lStructSize         As Long
    hwndOwner           As Long
    hInstance           As Long
    lpstrFilter         As String
    lpstrCustomFilter   As String
    nMaxCustFilter      As Long
    nFilterIndex        As Long
    lpstrFile           As String
    nMaxFile            As Long
    lpstrFileTitle      As String
    nMaxFileTitle       As Long
    lpstrInitialDir     As String
    lpstrTitle          As String
    flags               As Long
    nFileOffset         As Integer
    nFileExtension      As Integer
    lpstrDefExt         As String
    lCustData           As Long
    lpfnHook            As Long
    lpTemplateName      As String
End Type
Public Dial             As DIALOG
Public Type DIALOG                              '
    Form                As Long                 ' �����, ��������� ������
    Filter              As String               ' ������
    Title               As String               ' ���������
    Dir                 As String               ' ��������� ����������
    Backup              As String
    file                As String
End Type

Public Function ShowOpen() As String '������������. ����������� ����� ���� ����� � ����� ����
    OFName.lStructSize = Len(OFName)
    OFName.hwndOwner = FormIndex
    OFName.hInstance = App.hInstance
    OFName.lpstrFilter = Dial.Filter '������
    OFName.lpstrFile = Space$(254)
    OFName.nMaxFile = 255
    OFName.lpstrFileTitle = Space$(254)
    OFName.nMaxFileTitle = 255
    OFName.lpstrInitialDir = Dial.Dir '��������� ����������
    OFName.lpstrTitle = Dial.Title
    OFName.flags = 0

    If GetOpenFileName(OFName) Then '���� ���� ������ ������ ������ ��� �������� ������, �� � ���������� ShowOpen ������������  "" , ����� ���� � �����
        ShowOpen = Trim$(OFName.lpstrFile)
    Else
        ShowOpen = ""
    End If
End Function

'Private
Public Function ShowSave() As String ' ����� �� ����������
    OFName.lStructSize = Len(OFName)
    OFName.hwndOwner = FormIndex
    OFName.hInstance = App.hInstance
    OFName.lpstrFilter = Dial.Filter
    OFName.lpstrFile = Space$(254)
    OFName.nMaxFile = 255
    OFName.lpstrFileTitle = Space$(254)
    OFName.nMaxFileTitle = 255
    OFName.lpstrInitialDir = Dial.Dir
    OFName.lpstrTitle = Dial.Title
    OFName.flags = 0

    If GetSaveFileName(OFName) Then
        ShowSave = Trim$(OFName.lpstrFile)
    Else
        ShowSave = ""
    End If
End Function





