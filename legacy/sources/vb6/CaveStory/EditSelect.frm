VERSION 5.00
Begin VB.Form EditSelect 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "����� ������ ��������������"
   ClientHeight    =   2175
   ClientLeft      =   5670
   ClientTop       =   4620
   ClientWidth     =   4680
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2175
   ScaleWidth      =   4680
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Command3 
      Caption         =   "��������� �� ������, �� �������� ��� ���� ����� ��������� (���� �� ��������)."
      Enabled         =   0   'False
      Height          =   495
      Left            =   120
      TabIndex        =   2
      Top             =   1560
      Width           =   4455
   End
   Begin VB.CommandButton Command2 
      Caption         =   "��������� �� ������ (�������������)"
      Height          =   495
      Left            =   120
      TabIndex        =   1
      Top             =   840
      Width           =   4455
   End
   Begin VB.CommandButton Command1 
      Caption         =   "��������� �������"
      Height          =   495
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   4455
   End
End
Attribute VB_Name = "EditSelect"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
Form1.NewList.Visible = False
Form1.List.Move Form1.List.Left, Form1.List.Top, Form1.List.Width + 6600
EditType = False
Form1.Show
Me.Hide
End Sub

Private Sub Command2_Click()
EditType = True
Form1.Show
Me.Hide
End Sub
