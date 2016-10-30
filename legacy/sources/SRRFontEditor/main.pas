unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, XPMan, Menus, ExtCtrls, ActnList, ToolWin, ImgList, DIB,
  ExtDlgs, ClipBrd;

type
  TMainForm = class(TForm)
    CharsImage: TImage;
    CharImage: TImage;
    PaletteImage: TImage;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    StatusBar: TStatusBar;
    FileNewMenuItem: TMenuItem;
    FileOpenMenuItem: TMenuItem;
    FileSaveMenuItem: TMenuItem;
    FileSaveAsMenuItem: TMenuItem;
    FileSeparator: TMenuItem;
    FileExitMenuItem: TMenuItem;
    EditMenu: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    N1: TMenuItem;
    ClearCharacter1: TMenuItem;
    Copytobitmap1: TMenuItem;
    Pastefrombitmap1: TMenuItem;
    Saveasbitmap1: TMenuItem;
    LoadFromBitmap1: TMenuItem;
    N2: TMenuItem;
    ActionList: TActionList;
    FileNewAction: TAction;
    FileOpenAction: TAction;
    FileSaveAction: TAction;
    FileSaveAsAction: TAction;
    FileExitAction: TAction;
    EditCopyAction: TAction;
    EditPasteAction: TAction;
    EditClearAction: TAction;
    EditCopyToBitmapAction: TAction;
    EditPasteFromBitmapAction: TAction;
    EditSaveToBitmapAction: TAction;
    EditLoadFromBitmapAction: TAction;
    EditFlipHorisontalAction: TAction;
    EditFlipVerticalAction: TAction;
    EditMoveUpAction: TAction;
    EditMoveDownAction: TAction;
    EditMoveLeftAction: TAction;
    EditMoveRightAction: TAction;
    FlipHorisontal1: TMenuItem;
    FlipVertical1: TMenuItem;
    MoveUp1: TMenuItem;
    MoveDown1: TMenuItem;
    MoveLeft1: TMenuItem;
    MoveRight1: TMenuItem;
    N3: TMenuItem;
    EditInsertToRomAction: TAction;
    InsertToRom1: TMenuItem;
    PaletteMenu: TMenuItem;
    PaletteLoadAction: TAction;
    PaletteSaveAction: TAction;
    Load1: TMenuItem;
    Save1: TMenuItem;
    ImageList: TImageList;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ColorDialog: TColorDialog;
    ToolButton7: TToolButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    OpenRomDialog: TOpenDialog;
    SaveRomDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    OpenBmpDialog: TOpenPictureDialog;
    SaveBmpDialog: TSavePictureDialog;
    OpenActDialog: TOpenDialog;
    SaveActDialog: TSaveDialog;
    procedure PaletteSaveActionExecute(Sender: TObject);
    procedure FileOpenActionExecute(Sender: TObject);
    procedure FileSaveActionExecute(Sender: TObject);
    procedure FileSaveAsActionExecute(Sender: TObject);
    procedure FileExitActionExecute(Sender: TObject);
    procedure FileNewActionExecute(Sender: TObject);
    procedure PaletteLoadActionExecute(Sender: TObject);
    procedure EditCopyActionExecute(Sender: TObject);
    procedure EditPasteActionExecute(Sender: TObject);
    procedure EditClearActionExecute(Sender: TObject);
    procedure EditCopyToBitmapActionExecute(Sender: TObject);
    procedure EditPasteFromBitmapActionExecute(Sender: TObject);
    procedure EditSaveToBitmapActionExecute(Sender: TObject);
    procedure EditLoadFromBitmapActionExecute(Sender: TObject);
    procedure EditFlipHorisontalActionExecute(Sender: TObject);
    procedure EditFlipVerticalActionExecute(Sender: TObject);
    procedure EditMoveUpActionExecute(Sender: TObject);
    procedure EditMoveDownActionExecute(Sender: TObject);
    procedure EditMoveLeftActionExecute(Sender: TObject);
    procedure EditMoveRightActionExecute(Sender: TObject);
    procedure EditInsertToRomActionExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure PaletteImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaletteImageDblClick(Sender: TObject);
    procedure CharsImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CharImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CharImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormDestroy(Sender: TObject);
  private
    FFileName: String;
    FSaved: Boolean;
    Function GetNamed: Boolean;
    Procedure SetSaved(Value: Boolean);
  public
    function CheckSaved: Boolean;
    procedure DrawPalette;
    procedure DrawChars;
    procedure DrawChar;
    property Saved: Boolean read FSaved write SetSaved;
    property Named: Boolean read GetNamed;
    property FileName: String read FFileName write FFileName;
    procedure UpdateDIBPalette;
    procedure Open(const FileName: String);
  end;

Type
 TPalette = Array[0..15] of TColor;
 TTile = Array[0..15, 0..15] of Byte;
 TCharacter = Packed Record
  W: Byte;
  Ch: TTile;
 end;
 TChars = Array[Byte] of TCharacter;
 TRGBA = Packed Record
  R: Byte;
  G: Byte;
  B: Byte;
  A: Byte;
 end;
 TRGB = Packed Record
  R: Byte;
  G: Byte;
  B: Byte;
 end;

var
 MainForm: TMainForm;
 Palette: TPalette;
 BufChar: TCharacter;
 CurCol: Byte;
 CurChar: Byte;
 CharWidth, CharHeight: Byte;
 Chars: TChars;
 DataPos, PalPos, CodePos: Integer;
 DIB1, DIB2: TDIB;

implementation

Uses GbaUnit, HexUnit, SEF;

{$R *.dfm}

procedure TMainForm.PaletteSaveActionExecute(Sender: TObject);
Var F: File; I: Byte; Pal: Array[Byte] of TRGB;
begin
 If SaveActDialog.Execute then
 begin
  FillChar(Pal, SizeOf(Pal), 0);
  For I := 0 to 15 do
  begin
   Pal[I].R := TRGBA(Palette[I]).R;
   Pal[I].G := TRGBA(Palette[I]).G;
   Pal[I].B := TRGBA(Palette[I]).B;
  end;
  AssignFile(F, SaveActDialog.FileName);
  Rewrite(F, 1);
  BlockWrite(F, Pal, SizeOf(Pal));
  CloseFile(F);
 end;
end;

procedure TMainForm.FileOpenActionExecute(Sender: TObject);
begin
 If not CheckSaved then Exit;
 If OpenDialog.Execute then Open(OpenDialog.FileName);
end;

procedure TMainForm.FileSaveActionExecute(Sender: TObject);
Var F: File; DS: DWord;
begin
 If not Named then
 begin
  FileSaveAsActionExecute(Sender);
  Exit;
 end;
 AssignFile(F, FFileName);
 Rewrite(F, 1);
 DS := $544E4F46;
 BlockWrite(F, DS, 4);
 DS := 2;
 BlockWrite(F, DS, 1);
 BlockWrite(F, CharWidth, 1);
 BlockWrite(F, CharHeight, 1);
 BlockWrite(F, DataPos, 4);
 BlockWrite(F, CodePos, 4);
 BlockWrite(F, PalPos, 4);
 BlockWrite(F, Palette, SizeOf(Palette));
 BlockWrite(F, Chars, SizeOf(Chars));
 CloseFile(F);
 Saved := True;
end;

procedure TMainForm.FileSaveAsActionExecute(Sender: TObject);
begin
 SaveDialog.FileName := FFileName;
 If SaveDialog.Execute then
 begin
  FFileName := SaveDialog.FileName;
  FileSaveActionExecute(Sender);
 end;
end;

procedure TMainForm.FileExitActionExecute(Sender: TObject);
begin
 Close;
end;

Type
 TFontDataInfo = Packed Record
  Address: Integer;
  Unk1: Word;
  TilesCount: Word;
  MapWidth: Word;
  MapHeight: Word;
  ChrWidth: Word;
  ChrHeight: Word;
  Unk2: Word;
  Unk3: Word;
  PalIndex: Integer;
  Zero: Integer;
 end;
 TFontCodeInfo = Packed Record
  CharsAddress: Integer;
  LensAddress: Integer;
  CharsCount: Integer;
 end;
 TGbaTile = Array[0..7, 0..3] of Byte;
{
Const
 FontInfo: Array[False..True] of TFontInfo =
 (
 (Width: 1; Height: 1; ChrAddr1: $348D8; ChrAddr2: $4718C;
  LetCntAddr1: $348A4; LetCntAddr2: $47134;
  WidthTblAddr1: $348D4; WidthTblAddr2: $47188;
  LetTblAddr1: $348DC; LetTblAddr2: $47190),
 (Width: 2; Height: 2; ChrAddr1: $34A54; ChrAddr2: $470AC;
  LetCntAddr1: $34A20; LetCntAddr2: $47058;
  WidthTblAddr1: $34A50; WidthTblAddr2: $470A8;
  LetTblAddr1: $34A58; LetTblAddr2: $470B0)
 );     }

procedure TMainForm.FileNewActionExecute(Sender: TObject);
begin





//Chars[0].Ch[0,0]:=1;
{Var
 DP, CP, PP: Integer; F: TFileStream; Tiles: Array of TGbaTile;
 FDI: TFontDataInfo; FCI: TFontCodeInfo; TX, TY, MX, MY, X, Y, I: Integer;
 Letters: Array of Byte; Tile: ^TGbaTile;
 Lens: Array of Byte; PalX: Array[0..15] of Word;
Label BadData;
begin
 If not CheckSaved then Exit;
 WIth SeForm do
 begin
  If NewExecute('Data', 'Type in:', DataPos) then DP := ResultNumber Else Exit;
  If NewExecute('Code', 'Type in:', CodePos) then CP := ResultNumber Else Exit;
  If NewExecute('Palette', 'Type in:', PalPos) then PP := ResultNumber Else Exit;
 end;
 If OpenRomDialog.Execute then
 begin
  try
   F := TFileStream.Create(OpenRomDialog.FileName, fmOpenRead);
   F.Position := DP;
   If F.Read(FDI, SizeOf(FDI)) = SizeOf(FDI) then With FDI do
   begin
    Dec(Address, $08000000); If Address <= 0 then Goto BadData;
    F.Position := CP;
    If F.Read(FCI, SizeOf(FCI)) <> SizeOf(FCI) then Goto BadData;
    With FCI do
    begin
     Dec(CharsAddress, $08000000); If CharsAddress <= 0 then Goto BadData;
     Dec(LensAddress, $08000000); If LensAddress <= 0 then Goto BadData;
     If CharsCount <= 0 then Goto BadData;
     If (ChrWidth > 1) or (ChrHeight > 1) then
     begin
      CharWidth := 16;
      CharHeight := 16;
     end Else
     begin
      CharWidth := 8;
      CharHeight := 8;
     end;
     MapWidth := MapWidth div ChrWidth;
     MapHeight := MapHeight div ChrHeight;
     DIB1.Width := CharWidth * 16;
     DIB1.Height := CharHeight * 16;
     DIB2.Width := CharWidth;
     DIB2.Height := CharHeight;
     SetLength(Tiles, TilesCount);
     SetLength(Letters, CharsCount);
     SetLength(Lens, CharsCount);
     F.Position := Address;
     If F.Read(Tiles[0], TilesCount * SizeOf(TGbaTile)) <>
        TilesCount * SizeOf(TGbaTile) then Goto BadData;
     F.Position := CharsAddress;
     If F.Read(Letters[0], CharsCount) <> CharsCount then Goto BadData;
     F.Position := LensAddress;
     If F.Read(Lens[0], CharsCount) <> CharsCount then Goto BadData;
     I := 0;
     FillChar(Chars, SizeOf(Chars), 0);
     For MY := 0 to Integer(MapHeight) - 1 do
     begin
      For MX := 0 to Integer(MapWidth) - 1 do
      begin
       With Chars[Letters[I]] do
       begin
        W := Lens[I];
        For TY := 0 to Integer(ChrHeight) - 1 do
        begin
         Tile := Addr(Tiles[(MY * Integer(ChrHeight) + TY) *
         (MapWidth * Integer(ChrWidth)) + MX * Integer(ChrWidth)]);
         For TX := 0 to Integer(ChrWidth) - 1 do
         begin
          For Y := 0 to 7 do For X := 0 to 7 do If Odd(X) then
           Ch[TY shl 3 + Y, TX shl 3 + X] := Tile^[Y, X shr 1] shr 4 Else
           Ch[TY shl 3 + Y, TX shl 3 + X] := Tile^[Y, X shr 1] and 15;
          Inc(Tile);
         end;
        end;
       end;
       Inc(I);
       If I >= CharsCount then Break;
      end;
      If I >= CharsCount then Break;      
     end;
     DataPos := DP;
     CodePos := CP;
     PalPos := PP;
     F.Position := PP + (PalIndex - 1) * 8 + 4;
     F.Read(DP, 4);
     F.Position := DP - $08000000;
     F.Read(PalX, 32);
     GetGbaPalette(PalX, Palette, 16);
     UpdateDIBPalette;
     DrawPalette;
     FFileName := '';
     Saved := False;
    end;
   end Else BadData: ShowMessage('Bad data!');
   F.Free;
  except
   ShowMessage('Unable to open file!');
  end;
 end;}
end;

procedure TMainForm.PaletteLoadActionExecute(Sender: TObject);
Type
 TPalX = Array[0..15] of TRGB;
Var F: File; PalX: TPalX; TX: Integer; R: DWord; Col: TRGBA;
begin
 If OpenActDialog.Execute then
 begin
  AssignFile(F, OpenActDialog.FileName);
  Reset(F, 1);
  BlockRead(F, PalX, SizeOf(TPalX), R);
  For TX := 0 to 15 do With PalX[TX] do
  begin
   Col.R := R;
   Col.G := G;
   Col.B := B;
   Col.A := 0;
   Palette[TX] := TColor(Col);
  end;
  Saved := False;
  UpdateDIBPalette;
  DrawPalette;
 end;
end;

procedure TMainForm.EditCopyActionExecute(Sender: TObject);
begin
 BufChar := Chars[CurChar];
end;

procedure TMainForm.EditPasteActionExecute(Sender: TObject);
begin
 Chars[CurChar] := BufChar;
 DrawChars;
 DrawChar;
 Saved := False;
end;

procedure TMainForm.EditClearActionExecute(Sender: TObject);
begin
 FillChar(Chars[CurChar], SizeOf(TCharacter), 0);
 DrawChars;
 DrawChar;
 Saved := False;  
end;

procedure TMainForm.EditCopyToBitmapActionExecute(Sender: TObject);
Var
 AFormat: Word;
 AData: Cardinal;
 APalette: HPALETTE;
begin
 Clipboard.Open;
 try
  DIB2.SaveToClipboardFormat(AFormat, AData, APalette);
  Clipboard.SetAsHandle(AFormat, AData);
 finally
  Clipboard.Close;
 end;
end;

procedure TMainForm.EditPasteFromBitmapActionExecute(Sender: TObject);
Var Bitmap: TDIB; Y, H, W: Integer; B: ^Byte;
begin
 Bitmap := TDIB.Create;
 Clipboard.Open;
 try
  Bitmap.LoadFromClipboardFormat(CF_DIB, Clipboard.GetAsHandle(CF_DIB), 0);
  DIB2.Fill8bit(0);
  DIB2.Canvas.Draw(0, 0, Bitmap);
  With DIB2 do
  begin
   B := Addr(Chars[CurChar].Ch);
   H := CharHeight; If H > Height then H := Height;
   W := CharWidth;  If W > Width then W := Width;
   If H > 16 then H := 16;
   If W > 16 then W := 16;
   For Y := 0 to H - 1 do
   begin
    Move(ScanLine[Y]^, B^, W);
    Inc(B, 16);
   end;
  end;
  Chars[CurChar].W := CharWidth;
  DrawChars;
  DrawChar;
  Saved := False;
 finally
  Clipboard.Close;
 end;
 Bitmap.Free;
end;

procedure TMainForm.EditSaveToBitmapActionExecute(Sender: TObject);
begin
 If SaveBmpDialog.Execute then
  DIB2.SaveToFile(SaveBmpDialog.FileName);
end;

procedure TMainForm.EditLoadFromBitmapActionExecute(Sender: TObject);
Var Y, H, W: Integer; B: ^Byte; Bmp: TDIB;
begin
 If OpenBmpDialog.Execute then
 begin
  Bmp := TDIB.Create;
  Bmp.LoadFromFile(OpenBmpDialog.FileName);
  DIB2.Fill8bit(0);
  DIB2.Canvas.Draw(0, 0, Bmp);
  Bmp.Free;
  With DIB2 do
  begin
   B := Addr(Chars[CurChar].Ch);
   H := CharHeight; If H > Height then H := Height;
   W := CharWidth;  If W > Width then W := Width;
   If H > 16 then H := 16;
   If W > 16 then W := 16;
   For Y := 0 to H - 1 do
   begin
    Move(ScanLine[Y]^, B^, W);
    Inc(B, 16);
   end;
  end;
  Chars[CurChar].W := CharWidth;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditFlipHorisontalActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With Chars[CurChar] do
 begin
  WW := W - 1; If WW > CharWidth - 1 then WW := CharWidth - 1;
  If WW < 1 then Exit;
  Move(Ch, Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
   For X := 0 to WW do
    Ch[Y, WW - X] := Tile[Y, X];
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditFlipVerticalActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With Chars[CurChar] do
 begin
  WW := W - 1; If WW > CharWidth - 1 then WW := CharWidth - 1;
  If WW < 1 then Exit;
  Move(Ch, Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
   For X := 0 to WW do
    Ch[(CharWidth - 1) - Y, X] := Tile[Y, X];
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditMoveUpActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With Chars[CurChar] do
 begin
  Move(Ch, Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
  begin
   WW := Y - 1; If WW < 0 then WW := CharHeight - 1;
   For X := 0 to CharWidth - 1 do
    Ch[WW, X] := Tile[Y, X];
  end;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditMoveDownActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With Chars[CurChar] do
 begin
  Move(Ch, Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
  begin
   WW := Y + 1; If WW = CharHeight then WW := 0;
   For X := 0 to CharWidth - 1 do
    Ch[WW, X] := Tile[Y, X];
  end;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditMoveLeftActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With Chars[CurChar] do
 begin
  Move(Ch, Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
   For X := 0 to CharWidth - 1 do
   begin
    WW := X - 1; If WW < 0 then WW := CharWidth - 1;
    Ch[Y, WW] := Tile[Y, X];
  end;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditMoveRightActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With Chars[CurChar] do
 begin
  Move(Ch, Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
   For X := 0 to CharWidth - 1 do
   begin
    WW := X + 1; If WW = CharWidth then WW := 0;
    Ch[Y, WW] := Tile[Y, X];
  end;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

Var InsertPos: Integer = 0;

procedure TMainForm.EditInsertToRomActionExecute(Sender: TObject);
{Var
 F: TFileStream; I, Cnt, XX, YY, D: Integer;
 Tiles: Array of TGbaTile; Tile: ^TGbaTile;
 Letters: Array of Byte; Y, X: Integer;
 Widths: Array of Int64; CTiles: Pointer;    }
begin
{ If SaveRomDialog.Execute then
 begin
  try
   F := TFileStream.Create(SaveRomDialog.FileName, fmOpenWrite);
   If SeForm.NewExecute('Position', 'Type in', InsertPos) then
   With FontInfo[BigFont] do
   begin
    InsertPos := SeForm.ResultNumber;
    D := InsertPos;
    Cnt := 0;
    For I := 0 to 255 do With Chars[I] do
    begin
     If W > 0 then
     begin
      Inc(Cnt);
      SetLength(Letters, Cnt);
      SetLength(Tiles, Cnt * (Width * Height));
      SetLength(Widths, Cnt);
      Widths[Cnt - 1] := W;
      Letters[Cnt - 1] := I;
      Tile := Addr(Tiles[(Cnt - 1) * (Width * Height)]);
      For YY := 0 to Height - 1 do
       For XX := 0 to Width - 1 do
       begin
        For Y := 0 to 7 do For X := 0 to 7 do If not Odd(X) then
         Tile^[Y, X shr 1] := Ch[YY shl 3 + Y, XX shl 3 + X] and 15 Else
         Tile^[Y, X shr 1] := Tile^[Y, X shr 1] or
         ((Ch[YY shl 3 + Y, XX shl 3 + X] and 15) shl 4);
        Inc(Tile);
       end;
     end;
    end;
    GetMem(CTiles, Length(Tiles) * SizeOf(TGbaTile) * 2);
    F.Position := ChrAddr1;
    F.Write(D, 3);
    F.Position := ChrAddr2;
    F.Write(D, 3);
    F.Position := D;
    F.Write(CTiles^, LZ77Compress(Tiles[0], CTiles^,
                     Length(Tiles) * SizeOf(TGbaTile), True));
    D := F.Position;
    While D mod 4 > 0 do Inc(D);
    FreeMem(CTiles);
    F.Position := LetCntAddr1;
    F.Write(Cnt, 1);
    F.Position := LetCntAddr2;
    F.Write(Cnt, 1);
    F.Position := LetTblAddr1;
    F.Write(D, 3);
    F.Position := LetTblAddr2;
    F.Write(D, 3);
    F.Position := D;
    F.Write(Letters[0], Cnt);
    I := 0;
    F.Write(I, 1);
    D := F.Position;
    While D mod 4 > 0 do Inc(D);
    F.Position := WidthTblAddr1;
    F.Write(D, 3);
    F.Position := WidthTblAddr2;
    F.Write(D, 3);
    F.Position := D;
    F.Write(Widths[0], Cnt * 8);
    I := $8008;
    F.Position := $34C62;
    F.Write(I, 2);
    I := $8804;
    F.Position := $391F6;
    F.Write(I, 2);
    I := $8802;
    F.Position := $21814;
    F.Write(I, 2);
    F.Position := $219B0;
    F.Write(I, 2);
    F.Position := $21B76;
    F.Write(I, 2);
    F.Position := $21BA8;
    F.Write(I, 2);
    F.Position := $20C04;
    F.Write(I, 2);
    Dec(I);
    F.Position := $219A8;
    F.Write(I, 2);
    F.Position := $21B6E;
    F.Write(I, 2);
    F.Position := $20C0E;
    F.Write(I, 2);
    F.Position := $20C3C;
    F.Write(I, 2);
    ShowMessage('Done!');
   end;
   F.Free;
  except
   ShowMessage('Cannot open file for write!');
  end;
 end;  }
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose := CheckSaved;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
 FSaved := True;
 CharWidth := 8;
 CharHeight := 8;
 Palette[1] := clWhite;
 Palette[2] := clGray;
 Palette[3] := $404040;
 DIB1 := TDIB.Create;
 DIB1.PixelFormat := MakeDIBPixelFormat(8, 8, 8);
 DIB1.BitCount := 8;
 DIB1.Width := CharWidth * 16;
 DIB1.Height := CharHeight * 16;
 DIB1.Fill8bit(0);
 DIB2 := TDIB.Create;
 DIB2.PixelFormat := DIB1.PixelFormat;
 DIB2.BitCount := 8;
 DIB2.Width := CharWidth;
 DIB2.Height := CharHeight;
 UpdateDIBPalette;
 DrawPalette;
 If (ParamCount > 0) and FileExists(ParamStr(1)) then Open(ParamStr(1));
end;

procedure TMainForm.DrawPalette;
Var I: Integer; PM: TPenMode;
begin
 With PaletteImage.Canvas do
 begin
  PM := Pen.Mode;
  For I := 0 to 15 do
  begin
   Brush.Color := Palette[I];
   FillRect(Bounds(0, I * 16, 16, 16));
   If I = CurCol then
   begin
    Brush.Style := bsClear;
    Pen.Color := Palette[0];
    Pen.Mode := pmNot;
    Pen.Width := 3;
    Rectangle(Bounds(0, I * 16, 16, 16));
    Pen.Width := 1;
    Pen.Mode := PM;
    Brush.Style := bsSolid;
   end;
  end;
 end;
end;

procedure TMainForm.DrawChars;
Var I, YY, XX, Y, ZX, ZY: Integer; B, BB: ^Byte; PM: TPenMode;
begin
 With DIB1 do
 begin
  I := 0; ZX := 0; ZY := 0;
  For YY := 0 to 15 do
  begin
   B := ScanLine[YY * CharHeight];
   For XX := 0 to 15 do With Chars[I] do
   begin
    BB := Addr(B^);
    Inc(BB, XX * CharWidth);
    For Y := 0 to Integer(CharHeight) - 1 do
    begin
     Move(Ch[Y, 0], BB^, CharWidth);
     Dec(BB, WidthBytes);
    end;
    If I = CurChar then
    begin
     ZX := XX * 16;
     ZY := YY * 16;
    end;
    Inc(I);
   end;
  end;
 end;
 With CharsImage.Canvas do
 begin
  StretchDraw(ClipRect, DIB1);
  PM := Pen.Mode;
  Brush.Style := bsClear;
  Pen.Color := $FFFFFF;
  Pen.Mode := pmCopy;
  Pen.Width := 1;
  Rectangle(Bounds(ZX, ZY, 16, 16));
  Pen.Width := 1;
  Pen.Mode := PM;
  Brush.Style := bsSolid;
 end;
 StatusBar.Panels[0].Text := Char(CurChar);
 StatusBar.Panels[1].Text := '$' + IntToHex(CurChar, 2);
 StatusBar.Panels[2].Text := '#' + IntToStr(CurChar);
end;

procedure TMainForm.DrawChar;
Var Y, H, W, WW: Integer; B: ^Byte; PM: TPenMode;
begin
 With DIB2 do
 begin
  B := Addr(Chars[CurChar].Ch);
  H := CharHeight; If H > Height then H := Height;
  W := CharWidth;  If W > Width then W := Width;
  If H > 16 then H := 16;
  If W > 16 then W := 16;
  For Y := 0 to H - 1 do
  begin
   Move(B^, ScanLine[Y]^, W);
   Inc(B, 16);
  end;
 end;
 With CharImage.Canvas, Chars[CurChar] do
 begin
  StretchDraw(ClipRect, DIB2);
  PM := Pen.Mode;
  Pen.Color := $FF00FF;
  Pen.Mode := pmMaskPenNot;
  Pen.Width := 2;
  WW := (256 div CharWidth);
  Rectangle(Bounds(W * WW, 0, WW, 256));
  Pen.Mode := PM;
 end;
end;

Function TMainForm.GetNamed: Boolean;
begin
 Result := FFileName <> '';
end;

Procedure TMainForm.SetSaved(Value: Boolean);
Const
 SavedConst: Array[False..True] of String = ('*', '');
begin
 FSaved := Value;
 If Named then
  Caption := Format('%s - [%s]%s',
    [Application.Title, ExtractFileName(FFileName), SavedConst[Value]]) Else
  Caption := Application.Title;
end;

procedure TMainForm.PaletteImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 If Button = mbLeft then
 begin
  CurCol := Y div 16;
  DrawPalette;
 end;
end;

procedure TMainForm.PaletteImageDblClick(Sender: TObject);
begin
 ColorDialog.Color := Palette[CurCol];
 If ColorDialog.Execute then
 begin
  Palette[CurCol] := ColorDialog.Color;
  UpdateDIBPalette;
  DrawChars;
  DrawChar;
  DrawPalette;
  Saved := False;
 end;
end;

procedure TMainForm.UpdateDIBPalette;
Var CT: TRGBQuads; I: Integer;
begin
 FillChar(CT, 1024, 0);
 For I := 0 to 15 do With TRGBA(Palette[I]), CT[I] do
 begin
  rgbRed := R;
  rgbGreen := G;
  rgbBlue := B;
  rgbReserved := A;
 end;
 With DIB1 do
 begin
  ColorTable := CT;
  UpdatePalette;
 end;
 With DIB2 do
 begin
  ColorTable := CT;
  UpdatePalette;
 end;
 DrawChars;
 DrawChar;
end;

procedure TMainForm.CharsImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 If Button = mbLeft then
 begin
  X := X div 16;
  Y := Y div 16;
  CurChar := Y * 16 + X;
  DrawChars;
  DrawChar;
 end;
end;

procedure TMainForm.CharImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 If ssCtrl in Shift then With Chars[CurChar] do
 begin
  If X > 256 - 8 then
   W := CharWidth Else
   W := X div (256 div CharWidth);
  DrawChar;
  DrawChars;
  Saved := False;
 end Else If Button = mbRight then
 begin
  If X < 0 then Exit;
  If Y < 0 then Exit;
  If X >= CharImage.Width then Exit;
  If Y >= CharImage.Height then Exit;
  X := X div (256 div CharWidth); Y := Y div (256 div CharWidth);
  With Chars[CurChar] do CurCol := Ch[Y, X];
  DrawPalette;
 end Else CharImageMouseMove(Sender, Shift, X, Y);
end;

procedure TMainForm.CharImageMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
 If not (ssLeft in Shift) then Exit;
 If (ssCtrl in Shift) or (ssShift in Shift) then Exit;
 If X < 0 then Exit;
 If Y < 0 then Exit;
 If X >= CharImage.Width then Exit;
 If Y >= CharImage.Height then Exit;
  X := X div (256 div CharWidth); Y := Y div (256 div CharWidth);
 With Chars[CurChar] do Ch[Y, X] := CurCol;
 DrawChar;
 DrawChars;
 Saved := False;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
 DIB1.Free;
 DIB2.Free;
end;

function TMainForm.CheckSaved: Boolean;
begin
 Result := True;
 If not Saved then
 begin
  Case MessageDlg('Font has been modified. Save it?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
   mrYes: FileSaveActionExecute(NIL);
   mrCancel: Result := False;
  end;
 end;
end;

procedure TMainForm.Open(const FileName: String);
Var F: File; DS: Cardinal; B: Byte; R: Integer;
begin
 AssignFile(F, FileName);
 Reset(F, 1);
 BlockRead(F, DS, 4, R);
 BlockRead(F, B, 1, R);
 If (DS = $544E4F46) and (B = 2) then
 begin
  BlockRead(F, CharWidth, 1, R);
  BlockRead(F, CharHeight, 1, R);
  BlockRead(F, DataPos, 4, R);
  BlockRead(F, CodePos, 4, R);
  BlockRead(F, PalPos, 4, R);
  BlockRead(F, Palette, SizeOf(Palette), R);
  BlockRead(F, Chars, SizeOf(Chars), R);
  DIB1.Width := CharWidth * 16;
  DIB1.Height := CharHeight * 16;
  DIB2.Width := CharWidth;
  DIB2.Height := CharHeight;
  UpdateDIBPalette;
  DrawPalette;
  FFileName := FileName;
  Saved := True;
 end;
 CloseFile(F);
end;

end.
