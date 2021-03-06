library DNULL;

uses
  ShareMem,
  Needs in '..\Needs.pas';

{$E .kpl}

resourcestring
 SKPLDescription = 'NULL';

Var
 ROM: PBytes = NIL;
 RomSize: Integer = 0;
 EndsRoot: PTableItem = NIL;
 MaxCodes: Integer = 0;
 Align: Integer = 1;

Function Description: String; stdcall;
begin
 Result := SKPLDescription;
end;

Function NeedEnd: Boolean; stdcall;
begin
 Result := True;
end;

Function GetMethod: TMethod; stdcall;
begin
 Result := tmNone;
end;

Type TBPointer = Packed Record
  Null1, Ptr, FF, Null2: DWord;
end;

Procedure SetVariables(X: PBytes; Sz: Integer; ER: PTableItem; MC, AL: Integer); stdcall;
begin
 ROM := X;
 RomSize := Sz;
 EndsRoot := ER;
 MaxCodes := MC;
 Align := AL;
end;

Function GetData(TextStrings: PTextStrings): String; stdcall;
Var R: PTextString;
begin
 Result := '';
 If TextStrings = NIL then Exit;
 With TextStrings^ do
 begin
  R := Root;
  While R <> NIL do
  begin
   Result := Result + R^.Str + #0#0;
   R := R^.Next;
  end;
 end;
end;

Function GetStrings(X, Sz: Integer): PTextStrings; stdcall;
Var {P: PChar; }Len: Integer; W: ^Word;
begin
 Result := NIL;
 If (X >= RomSize) or (X < 0) then Exit;
 New(Result, Init);
 With Result^.Add^ do
 begin
  Len:=0;
  W:=Addr(ROM^[X]);
  While W^<>0 do
  begin
    Inc(Len,2);
    Inc(W);
  end;
  SetLength(Str,Len);
  Move(ROM^[X],Str[1],Len);

  //P := Addr(ROM^[X]);
  //Str := P;
 end;
end;

exports
 GetMethod,
 SetVariables,
 GetData,
 GetStrings,
 DisposeStrings,
 NeedEnd,
 Description;

end.

