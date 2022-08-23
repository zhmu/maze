{$G+}
Program MazeOfDeath;

Uses Crt;

Const XMax       = 60;
      YMax       = 20;
      BorderChar = 'Û';
      HeroFace   = '';
      BadFace    = '';
      BulChar    = 'ú';
      MedChar    = '+';
      KeyChar    = '';
      AmmoChr    = '„';
      FakeChar   = '±';
      AshesChr   = '°';
      EmptyChr   = ' ';
      ExitChr1   = '®';
      ExitChr2   = '¯';
      DoorChar   = 'º';
      HidenCh1   = '#';
      HidenCh2   = #255;
      NitroChr   = '';
      SecrChar   = 'x';
      Tres1Chr   = 't';
      BadDelay       = 3000;
      BulDelay       =  500;
      MessageDelay   = 30000;

      KillGuyScore   = 50;
      Treasure1Scr   = 50;

Type  BadInfo = Record
             X,
             Y: Integer;
      CurDelay: Word;
         Alive: Boolean;
     End;

Var SecrArray: Array[1..XMax, 1..YMax] of Boolean;
    LevelArray: Array[1..XMax, 1..YMax] of Char;
        BadGuy: Array[1..50] of BadInfo;
             I,
             J,
        StartX,
        StartY,
             X,
             Y,
            BX,
            BY,
            BD: Integer;
            Ch: Char;
        Health,
         Level,
          Ammo,
       ScoreBL,
        AmmoBL,
        KeysBL,
         Score,
          Keys,
         Lives,
        NumBad,
      MsgDelay: Integer;
            LD: Char;
       SoundOn,
       Cheater,
            BV: Boolean;
             S,
       Message: String;
          Wait: LongInt;

Procedure GUY_HandleMan; Forward;
Procedure BAD_HandleMan (No: Integer); Forward;

Procedure CursOff; Assembler;
Asm
 MOV CX, $2000
 XOR BX, BX
 MOV AX, $0100
 INT $10
End;

Procedure CursOn; Assembler;
Asm
 MOV CX, $607
 XOR BX, BX
 MOV AX, $0100
 INT $10
End;

Procedure MAP_LoadMap (FN: String);
Var T: Text; S: String; N: Integer;
Begin;
 N := 1; NumBad := 0; X := -1; Y := -1;
 Assign (T, FN);
  Reset (T);
  For J := 1 to YMax do
  Begin;
   ReadLn (T, S);
   For I := 1 to XMax do
   Begin;
   If S[I] = HidenCh1 Then S[I] := HidenCh2;
   If S[I] = BadFace Then
   Begin;
    BadGuy[N].X := I;
    BadGuy[N].Y := J;
    BadGuy[N].Alive := True;
    Inc (N);
    Inc (NumBad);
   End;
   If S[I] = HeroFace Then
   Begin;
    StartX := I;
    StartY := J;
    X := I;
    Y := J;
   End;
   If (S[I] = SecrChar) Then
   Begin;
    SecrArray[I, J] := True;
    S[I] := BorderChar;
   End
   Else
    SecrArray[I, J] := False;
   If (S[I] <> BadFace) And (S[I] <> HeroFace) Then
    LevelArray[I, J] := S[I];
   End;
  End;
 Close (T);
 If (I = -1) Or (J = -1) Then
 Begin;
  I := 2;
  J := 2;
 End;
End;

Procedure MAP_DrawBorder;
Begin;
 For I := 1 to XMax do
  LevelArray[I, 1] := BorderChar;
 For I := 1 to YMax do
 Begin;
  LevelArray[1, I] := BorderChar;
  LevelArray[XMax, I] := BorderChar;
 End;
 For I := 1 to XMax do
  LevelArray[I, YMax] := BorderChar;
End;

Procedure MAP_DrawMap;
Begin;
 For I := 1 to XMax do
  For J := 1 to YMax do
  Begin;
   GotoXY (I, J);
   Write (LevelArray[I, J]);
  End;
 GotoXY (X, Y);
 Write (HeroFace);
End;

Procedure Box (X2, Y2, X3, Y3: Integer; Shadow: Boolean);
Var TxtAttr: Word;
Begin;
 GotoXY (X2, Y2);
 Write ('É');
 For I := X2 to X3 - 2 Do
  Write ('Í');
 Write ('»');
 For I := Y2 + 1 to Y3 - 1 Do
 Begin;
  GotoXY (X2, I);
  Write ('º');
  For J := X2 to X3 - 2 Do
   Write (EmptyChr);
  Write ('º');
 End;
 GotoXY (X2, Y3);
 Write ('È');
 For I := X2 to X3 - 2 Do
  Write ('Í');
 Write ('¼');
 If Shadow Then
 Begin;
  TxtAttr := TextAttr;
  TextAttr := 00;
  For I := Y2 + 1 to Y3 do
  Begin;
   GotoXY (X3 + 1, I);
   Write ('Û');
  End;
  GotoXY (X2 + 1, Y3 + 1);
  For I := X2 to X3 do
   Write ('Û');
  TextAttr := txtAttr;
 End;
End;

Procedure ShowScore (Rebuild: Boolean);
Begin;
 If Rebuild Then Box (XMax + 1, 1, 80, 20, False);
 GotoXY (XMax + 6, 3);
 TextColor (Red);
 Write ('   MAZE ');
 GotoXY (XMax + 6, 4);
 Write ('    OF  ');
 GotoXY (XMax + 6, 5);
 Write ('   DEATH');
 TextColor (Yellow);
 If Rebuild Then Box (1, YMax + 1, 80, 24, False);
 GotoXY (XMax + 3, 7);
 Write ('                ');
 GotoXY (XMax + 3, 7);
 Write ('Score   : ');
 Write (Score);
 GotoXY (XMax + 3, 8);
 Write ('Health  : ');
 Write (Health);
 Write ('%  ');
 GotoXY (XMax + 3, 9);
 Write ('Ammo    : ');
 Write (Ammo);
 GotoXY (XMax + 3, 10);
 Write ('Lives   : ');
 Write (Lives);
 GotoXY (XMax + 3, 11);
 Write ('Keys    : ');
 Write (Keys);
 MsgDelay := 0;
 For I := 2 to 79 do
 Begin;
  GotoXY (I, YMax + 2);
  Write (EmptyChr);
 End;
 GotoXY (3, YMax + 2);
 If Message <> '' Then
  Write (Message)
 Else
  Write ('No messages');
End;

Procedure NextLevel;
Begin;
 X := 2; Y := 2; ScoreBL := Score;
 AmmoBL := 5;
 StartX := 2; StartY := 2;
 LD := 'M';
 MAP_LoadMap ('MAZE.000');
 MAP_DrawBorder;
 MAP_DrawMap;
 ShowScore (False);
End;

Procedure HitWallSound;
Begin;
 If SoundOn Then
 Begin;
  Sound (50);
  Delay (100);
  NoSound;
 End;
End;

Procedure TreasureSound;
Begin;
 If SoundOn Then
 Begin;
  Sound (750);
  Delay (100);
  NoSound;
 End;
End;

Procedure HealSound;
Begin;
 If SoundOn Then
 Begin;
  Sound (590);
  Delay (100);
  NoSound;
 End;
End;

Procedure BadDieSound;
Begin;
 If SoundOn Then
 Begin;
  Sound (290);
  Delay (100);
  NoSound;
 End;
End;

Procedure BadHitMeSound;
Begin;
 If SoundOn Then
 Begin;
  Sound (20);
  Delay (100);
  NoSound;
 End;
End;

Procedure AmmoSound;
Begin;
 If SoundOn Then
 Begin;
  Sound (100);
  Delay (100);
  NoSound;
 End;
End;

Procedure GetKeySound;
Begin;
 If SoundOn Then
 Begin;
  Sound (900);
  Delay (100);
  NoSound;
 End;
End;

Function BUL_CheckForBadGuys: Boolean;
Begin;
 BUL_CheckForBadGuys := False;
 For I := 1 to NumBad do
  If BadGuy[I].Alive = True Then
   If (BX = BadGuy[I].X) And (BY = BadGuy[I].Y) Then
   Begin;
    BadDieSound;
    BadGuy[I].Alive := False;
    BV := False;
    BUL_CheckForBadGuys := True;
    GotoXY (BX, BY); Write (EmptyChr);
    Inc (Score, KillGuyScore);
    Message := 'Guy killed';
    ShowScore (False);
  End;
End;

Procedure GUY_CheckForDie;
Begin;
 If Health = 0 Then
 Begin;
  Dec (Lives);
  If Lives = -1 Then
  Begin;
   CursOn;
   TextAttr := $07;
   ClrScr;
   WriteLn ('Maze of Death Version 1.0 - (c) 1996 R. Springer');
   WriteLn;
   WriteLn ('You died!');
   If Cheater = True Then
   Begin;
    WriteLn;
    WriteLn ('It''s a bad day to cheat!');
   End;
   Halt (0);
  End;
  ClrScr;
  Health := 100;
  Ammo := AmmoBL;
  Keys := KeysBL;
  ShowScore (True);
  MAP_LoadMap ('MAZE.000');
  X := StartX; Y := StartY;
  MAP_DrawMap;
  Score := ScoreBL;
  Ch := #0;
 End;
End;

Procedure Explosion (PosX, PosY: Integer);
Var C: Integer;
Begin;
 C := TextAttr;
 TextColor (Red);
 GotoXY (PosX + 3, PosY - 2);
 LevelArray[PosX + 3, PosY - 2] := AshesChr;
 Write ('²');
 GotoXY (PosX + 2, PosY - 1);
 For I := PosX + 2 to PosX + 4 do
  LevelArray[I, PosY - 1] := AshesChr;
 Write ('°±°');
 GotoXY (PosX + 1, PosY);
 For I := PosX + 1 to PosX + 5 do
  LevelArray[I, PosY] := AshesChr;
 Write ('²±°±²');
 GotoXY (PosX + 2, PosY + 1);
 For I := PosX + 2 to PosX + 4 do
  LevelArray[I, PosY + 1] := AshesChr;
 Write ('°±°');
 GotoXY (PosX + 3, PosY + 2);
 LevelArray[PosX + 3, PosY + 2] := AshesChr;
 Write ('²');
 TextAttr := C;
 Message := 'Boom!';
 ShowScore (False);
 Delay (500);
 GotoXY (PosX + 3, PosY - 2);
 Write (AshesChr);
 GotoXY (PosX + 2, PosY - 1);
 Write (AshesChr + AshesChr + AshesChr);
 GotoXY (PosX + 1, PosY);
 Write (AshesChr + AshesChr + AshesChr + AshesChr + AshesChr);
 GotoXY (PosX + 2, PosY + 1);
 Write (AshesChr + AshesChr + AshesChr);
 GotoXY (PosX + 3, PosY + 2);
 Write (AshesChr);
 GotoXY (70, 5);
 If LevelArray[X, Y] = AshesChr Then
 Begin;
  Health := 0;
  GUY_CheckForDie;
  ShowScore (False);
 End;
 For I := 1 to 3 do
 Begin;
  If (LevelArray[BadGuy[I].X, BadGuy[I].Y]) = AshesChr Then
  Begin;
   BadDieSound;
   BadGuy[I].Alive := False;
  End;
 End;
End;

Procedure BUL_HandleIt;
Var T, BDirX, BDirY: Integer;
Begin;
 If BV Then
 Begin;
  Inc (BD);
  If BD = BulDelay + Wait Then
  Begin;
   BD := 0;
   BDirX := 0;
   BDirY := 0;
   Case LD of
    'P': BDirY := 1;
    'H': BDirY := -1;
    'M': BDirX := 1;
    'K': BDirX := -1;
   End;
   If BUL_CheckForBadGuys Then Exit;
   If LevelArray[BX + BDirX, BY + BDirY] = DoorChar Then
   Begin;
    GotoXY (BX, BY); Write (EmptyChr);
    BV := False;
    Exit;
   End;
   If LevelArray[BX + BDirX, BY + BDirY] = ExitChr2 Then
   Begin;
    GotoXY (BX, BY); Write (EmptyChr);
    BV := False;
    Exit;
   End;
   If LevelArray[BX + BDirX, BY + BDirY] = NitroChr Then
   Begin;
    GotoXY (BX, BY); Write (EmptyChr);
    If BDirX = 1 Then
     Explosion (BX - 2, BY + BDirY)
    Else
     Explosion (BX - 4, BY + BDirY);
    BV := False;
    Exit;
   End;
   If LevelArray[BX + BDirX, BY + BDirY] = HidenCh2 Then
   Begin;
    GotoXY (BX, BY); Write (EmptyChr);
    BV := False;
    Exit;
   End;
   If LevelArray[BX + BDirX, BY + BDirY] = FakeChar Then
   Begin;
    Message := 'Fake wall blown up';
    ShowScore (False);
    LevelArray[BX + BDirX, BY + BDirY] := EmptyChr;
    GotoXY (BX + BDirX, BY + BDirY); Write (EmptyChr);
    BV := False;
    GotoXY (BX, BY); Write (EmptyChr);
    Exit;
   End;
   If LevelArray[BX + BDirX, BY + BDirY] = AmmoChr Then
   Begin;
    GotoXY (BX, BY); Write (EmptyChr);
    BV := False;
    Exit;
   End;
   If LevelArray[BX + BDirX, BY + BDirY] = KeyChar Then
   Begin;
    GotoXY (BX, BY); Write (EmptyChr);
    BV := False;
    Exit;
   End;
   If LevelArray[BX + BDirX, BY + BDirY] = MedChar Then
   Begin;
    GotoXY (BX, BY); Write (EmptyChr);
    BV := False;
    Exit;
   End;
   If LevelArray[BX + BDirX, BY + BDirY] = Tres1Chr Then
   Begin;
    GotoXY (BX, BY); Write (EmptyChr);
    BV := False;
    Exit;
   End;
   If LevelArray[BX + BDirX, BY + BDirY] <> BorderChar Then
   Begin;
    GotoXY (BX, BY);
    If (BX <> X) Or (BY <> Y) Then Write (EmptyChr) else Write (HeroFace);
    BX := BX + BDirX;
    BY := BY + BDirY;
    GotoXY (BX, BY); Write (BulChar);
    BDirX := 0;
    BDirY := 0;
   End
   Else
   Begin;
    GotoXY (BX, BY); Write (EmptyChr);
    BV := False;
   End;
  End;
 End;
End;

Procedure GUY_CheckForBadGuys;
Begin;
 {ERROR2}
 For I := 1 to NumBad do
  If (X = BadGuy[I].X) And (Y = BadGuy[I].Y) And (BadGuy[I].Alive = True) Then
  Begin;
   BadHitMeSound;
   If Health > 9 Then Dec (Health, 10);
   If Health < 9 Then Health := 0;
   If Health = 9 Then Health := 0;
   If Health = 0 Then
   Begin;
    GUY_CheckForDie;
    Health := 100;
    ShowScore (False);
    BAD_HandleMan (1);
    GUY_CheckForBadGuys;
    Exit;
   End;
   GotoXY (XMax + 3, 8);
   Write ('Health  : ');
   Write (Health);
   Write ('%  ');
   Message := 'Ouch!';
  End;
End;

Procedure GUY_HandleMan;
Var DirX, DirY: Integer;
Begin;
  DirX := 0;
  DirY := 0;
  If BV = False Then
  Begin;
   If Ch = 'P' Then LD := 'P';
   If Ch = 'H' Then LD := 'H';
   If Ch = 'M' Then LD := 'M';
   If Ch = 'K' Then LD := 'K';
  End;
  Case Ch of
   'P': DirY := 1;
   'H': DirY := -1;
   'M': DirX := 1;
   'K': DirX := -1;
   ' ': If Ammo > 0 Then
         If BV = False Then
         Begin;
          BV := True;
          BX := X; BY := Y;
          Dec (Ammo);
          ShowScore (False);
          BUL_HandleIt;
         End;
   '': Begin;
         Health := 100;
         Message := 'Health cheat';
         ShowScore (False);
         Cheater := True;
        End;
   '': Begin;
         Inc (Ammo, 10);
         Message := 'Ammo cheat';
         ShowScore (False);
         Cheater := True;
        End;
   '': Begin;
         S := Message;
         Message := 'Game Paused';
         ShowScore (False);
         Ch := #0;
         Repeat
          While KeyPressed Do Ch := ReadKey;
         Until Ch <> #0;
         Ch := #0;
         Message := S;
         ShowScore (False);
        End;
   ';': Begin;
         Box (5, 3, XMax + 5, YMax + 2, True);
         GotoXY (7, 3);
         Write ('¹ Help Ì');
         GotoXY (7, 5);
         Write ('Explanation of the characters:');
         GotoXY (7, 7);
         Write (HeroFace, '   = You, the tough guy!');
         GotoXY (7, 8);
         Write (BadFace, '   = The bad guys, watch out!');
         GotoXY (7, 9);
         Write (BorderChar, '   = Walls. They DO really hurt. Some don''t...');
         GotoXY (7, 10);
         Write (AmmoChr, '   = Ammo. Handy in this place.');
         GotoXY (7, 11);
         Write (NitroChr, '   = Nitroglycerin. VERY explosive.');
         GotoXY (7, 12);
         Write (Tres1Chr, '   = Treasures. Get these for extra points!');
         GotoXY (7, 13);
         Write (KeyChar, '   = Keys. They open doors.');
         GotoXY (7, 14);
         Write (DoorChar, '   = Doors. Require keys to open.');
         GotoXY (7, 15);
         Write (MedChar, '   = Medkit. To restore lost health (10%).');
         GotoXY (7, 16);
         Write (FakeChar, '   = Destroyable walls. Painfull as normal walls.');
         GotoXY (7, 17);
         Write (ExitChr1, ',', ExitChr2, ' = Exit signs. Touch to go to the next level.');
         GotoXY (7, 18);
         Write ('    = Invisible wall. Even invisible as painfull.');
         GotoXY (7, 19);
         Write (AshesChr, '   = Ashes for an explosion. Don''t do anything.');
         GotoXY (7, 22);
         WriteLn ('<Space> for next page, <ESC> to cancel.');
         Ch := #0;
         Repeat
          While KeyPressed Do Ch := ReadKey;
         Until Ch <> #0;
         If Ch = #27 Then
         Begin;
          Ch := #0;
          MAP_DrawBorder;
          MAP_DrawMap;
          ShowScore (True);
          Exit;
         End;
         Box (5, 3, XMax + 5, YMax + 2, True);
         GotoXY (7, 3);
         Write ('¹ Help Ì');
         GotoXY (7, 5);
         Write ('Controls:');
         GotoXY (7, 7);
         WriteLn (#26, #27, ' to move, <Space> to shoot.');
         GotoXY (7, 9);
         Write ('Special actions:');
         GotoXY (7, 10);
         Write ('<Ctrl-P> = Pause');
         GotoXY (7, 12);
         Write ('<ESC>    = Quit');
         GotoXY (7, YMax + 1);
         Write ('Cheat keys are secret.');
         GotoXY (7, 22);
         WriteLn ('<Any key to return to the game>');
         Ch := #0;
         Repeat
          While KeyPressed Do Ch := ReadKey;
         Until Ch <> #0;
         Ch := #0;
         MAP_DrawBorder;
         MAP_DrawMap;
         ShowScore (True);
       End;
   '': Begin;
         Inc (Keys, 1);
         Message := 'Key cheat';
         ShowScore (False);
         Cheater := True;
        End;
   '': Begin;
         Inc (Lives, 1);
         Message := 'Lives cheat';
         ShowScore (False);
         Cheater := True;
        End;
  End;
  If (DirY = 0) And (DirX = 0) Then Exit;
  If LevelArray[X + DirX, Y + DirY] = NitroChr Then
  Begin;
   If DirX = 1 Then
    Explosion (X - 2, Y + DirY)
   Else
    Explosion (X - 4, Y + DirY);
   Exit;
  End;
  If LevelArray[X + DirX, Y + DirY] = AmmoChr Then
  Begin;
   Inc (Ammo, 5);
   LevelArray[X + DirX, Y + DirY] := EmptyChr;
   AmmoSound;
   Message := 'Picked up 5 bullets';
   ShowScore (False);
  End;
  If LevelArray[X + DirX, Y + DirY] = KeyChar Then
  Begin;
   GetKeySound;
   Inc (Keys);
   LevelArray[X + DirX, Y + DirY] := EmptyChr;
   Message := 'Picked up: Key';
   ShowScore (False);
  End;
  If LevelArray[X + DirX, Y + DirY] = Tres1Chr Then
  Begin;
   Inc (Score, Treasure1Scr);
   LevelArray[X + DirX, Y + DirY] := EmptyChr;
   TreasureSound;
   Message := 'Picked up: Treasure';
   ShowScore (False);
  End;
  If LevelArray[X + DirX, Y + DirY] = MedChar Then
  Begin;
   If Health < 90 Then Inc (Health, 10) else Health := 100;
   LevelArray[X + DirX, Y + DirY] := EmptyChr;
   HealSound;
   Message := 'Medkit';
   ShowScore (False);
  End;
  If LevelArray[X + DirX, Y + DirY] = FakeChar Then
  Begin;
   HitWallSound;
   Dec (Health);
   GUY_CheckForDie;
   Message := 'Ouch!';
   ShowScore (False);
   Exit;
  End;
  If LevelArray[X + DirX, Y + DirY] = HidenCh2 Then
  Begin;
   HitWallSound;
   Dec (Health);
   GUY_CheckForDie;
   Message := 'Where did THAT came from???';
   ShowScore (False);
   Exit;
  End;
  If LevelArray[X + DirX, Y + DirY] = ExitChr1 Then
  Begin;
   NextLevel;
   Exit;
  End;
  If LevelArray[X + DirX, Y + DirY] = ExitChr2 Then
  Begin;
   NextLevel;
   Exit;
  End;
  If LevelArray[X + DirX, Y + DirY] = DoorChar Then
  Begin;
   If Keys = 0 Then
   Begin;
    HitWallSound;
    Dec (Health);
    GUY_CheckForDie;
    Message := 'Haven''t got the key';
    ShowScore (False);
    Exit;
   End
   Else
   Begin
    Dec (Keys);
    LevelArray[X + DirX, Y + DirY] := EmptyChr;
    Message := 'Opening door';
    ShowScore (False);
   End;
  End;
  If (SecrArray[X + DirX, Y + DirY] = True) Then
  Begin;
   GotoXY (X, Y); Write (EmptyChr);
   X := X + DirX; Y := Y + DirY;
   GotoXY (X, Y); Write (HeroFace);
   Message := 'A secret passage';
   ShowScore (False);
   Exit;
  End;
  If LevelArray[X + DirX, Y + DirY] <> BorderChar Then
  Begin;
   GotoXY (X, Y); Write (EmptyChr);
   X := X + DirX; Y := Y + DirY;
   GotoXY (X, Y); Write (HeroFace);
  End
  Else
  Begin;
   HitWallSound;
   Dec (Health);
   GUY_CheckForDie;
   Message := 'Ouch!';
   ShowScore (False);
  End;
End;

Procedure BAD_HandleMan (No: Integer);
Var Temp, A, B, BDirX, BDirY: Integer;
Begin;
 If BadGuy[No].Alive = False Then Exit;
 Inc (BadGuy[No].CurDelay);
 If BadGuy[No].CurDelay = (BadDelay + Wait) Then
 Begin;
  BadGuy[No].CurDelay := 0;
  BDirX := 0;
  BDirY := 0;
  Temp := 0;
  Temp := Random (5);
  Case Temp of
   1: BDirY := 1;
   2: BDirY := -1;
   3: BDirX := 1;
   4: BDirX := -1;
  End;
  If LevelArray[BadGuy[No].X + BDirX, BadGuy[No].Y + BDirY] = NitroChr Then
  Begin;
   A := BDirX - 3;
   B := BDirY;
   Explosion (BadGuy[No].X + A, BadGuy[No].Y + B);
   BadGuy[No].Alive := False;
   Exit;
  End;
  If LevelArray[BadGuy[No].X + BDirX, BadGuy[No].Y + BDirY] = Tres1Chr Then
   Exit;
  If LevelArray[BadGuy[No].X + BDirX, BadGuy[No].Y + BDirY] = HidenCh2 Then
   Exit;
  If LevelArray[BadGuy[No].X + BDirX, BadGuy[No].Y + BDirY] = ExitChr1 Then
   Exit;
  If LevelArray[BadGuy[No].X + BDirX, BadGuy[No].Y + BDirY] = ExitChr2 Then
   Exit;
  If LevelArray[BadGuy[No].X + BDirX, BadGuy[No].Y + BDirY] = DoorChar Then
   Exit;
  If LevelArray[BadGuy[No].X + BDirX, BadGuy[No].Y + BDirY] = FakeChar Then
   Exit;
  If LevelArray[BadGuy[No].X + BDirX, BadGuy[No].Y + BDirY] = KeyChar Then
   Exit;
  If LevelArray[BadGuy[No].X + BDirX, BadGuy[No].Y + BDirY] = AmmoChr Then
   Exit;
  If LevelArray[BadGuy[No].X + BDirX, BadGuy[No].Y + BDirY] = MedChar Then
   Exit;
  If LevelArray[BadGuy[No].X + BDirX, BadGuy[No].Y + BDirY] <> BorderChar Then
  Begin;
   GotoXY (BadGuy[No].X, BadGuy[No].Y); Write (EmptyChr);
   BadGuy[No].X := BadGuy[No].X + BDirX;
   BadGuy[No].Y := BadGuy[No].Y + BDirY;
   GotoXY (BadGuy[No].X, BadGuy[No].Y); Write (BadFace);
   BDirX := 0;
   BDirY := 0;
   Temp := 0;
   GUY_CheckForBadGuys;
  End;
 End;
End;


Procedure DoMenu;
Const  TITLEPIC: Array [1..2000] of Char = (
    'Ú','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä',
    'Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä',
    'Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä',
    'Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä',
    'Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','¿','³',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ','³','³',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ','³','³',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ','Ü','Ü','Ü','Ü','Ü','Ü','Ü',' ','Ü',
    'Ü','Ü','Ü','Ü','Ü','Ü',' ','Ü','Ü','Ü','Ü','Ü','Ü','Ü',' ','Ü','Ü',
    'Ü','Ü','Ü','Ü','Ü',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','³','³',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ','Û',' ','Ü',' ','Ü',' ','Û',' ','Û',' ','Ü','Ü','Ü',' ',
    'Û',' ','Û','Ü','Ü','Ü',' ','Ü','Û',' ','Û',' ','Ü','Ü','Ü','Ü','Û',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ','³','³',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','Û',' ',
    'Û',' ','Û',' ','Û',' ','Û',' ','Ü','Ü','Ü',' ','Û',' ','Ü','Û','ß',
    'Ü','Û','Û','Ü',' ','Û',' ','Ü','Ü','Ü','Û','Ü',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ','³','³',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','Û','Ü','Û','ß','Û','Ü','Û',
    ' ','Û','Ü','Û',' ','Û','Ü','Û',' ','Û','Ü','Ü','Ü','Ü','Ü','Û',' ',
    'Û','Ü','Ü','Ü','Ü','Ü','Û',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','³','³',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','³','³',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','O',' ',' ',
    ' ','F',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ','³','³',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    '³','³',' ',' ',' ',' ',' ',' ',' ',' ',' ','Ü','Û','Û','Û','Û','Û',
    'Û','Û','Û','Ü',' ',' ','Ü','Û','Û','Û','Û','Û','Û','Û','Û','Û','Ü',
    ' ',' ','Ü','Û','Û','Û','Û','Û','Û','Û','Ü',' ',' ','Ü','Û','Û','Û',
    'Û','Û','Û','Û','Û','Û','Û','Ü',' ',' ','Ü','Û','Û',' ',' ',' ','Û',
    'Û','Ü',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','³','³',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ','Û','Û','Û','Û',' ',' ',' ','ß','Û','Û','Û',
    ' ','Û','Û','Û','Û',' ',' ',' ',' ','ß','ß','ß',' ','Û','Û','Û','Û',
    'ß','ß','ß','Û','Û','Û','Û',' ','ß','ß','ß','ß','Û','Û','Û','Û','ß',
    'ß','ß','ß',' ','Û','Û','Û','Û',' ',' ',' ','Û','Û','Û','Û',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ','³','³',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ','Û','Û','Û','Û',' ',' ',' ',' ','Û','Û','Û',' ','Û','Û','Û','Û',
    'Ü','Ü','Ü','Ü','Ü',' ',' ',' ','Û','Û','Û','Û','Ü','Ü','Ü','Û','Û',
    'Û','Û',' ',' ',' ',' ',' ','Û','Û','Û','Û',' ',' ',' ',' ',' ','Û',
    'Û','Û','Û','Û','Û','Û','Û','Û','Û','Û',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ','³','³',' ',' ',' ',' ',' ',' ',' ',' ',' ','Û','Û','Û','Û',
    ' ',' ',' ',' ','Û','Û','Û',' ','Û','Û','Û','Û','ß','ß','ß','ß','ß',
    ' ',' ',' ','Û','Û','Û','Û','Û','Û','Û','Û','Û','Û','Û',' ',' ',' ',
    ' ',' ','Û','Û','Û','Û',' ',' ',' ',' ',' ','Û','Û','Û','Û','ß','ß',
    'ß','Û','Û','Û','Û',' ',' ',' ',' ',' ',' ',' ',' ',' ','³','³',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ','Û','Û','Û','Û','Ü','Ü','Ü','Û','Û',
    'Û','ß',' ','Û','Û','Û','Û',' ',' ',' ',' ','Ü','Ü','Ü',' ','Û','Û',
    'Û','Û',' ',' ',' ','Û','Û','Û','Û',' ',' ',' ',' ',' ','Û','Û','Û',
    'Û',' ',' ',' ',' ',' ','Û','Û','Û','Û',' ',' ',' ','Û','Û','Û','Û',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ','³','³',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ','ß','Û','Û','Û','Û','Û','Û','Û','ß',' ',' ',' ','ß','Û',
    'Û','Û','Û','Û','Û','Û','Û','Û','ß',' ','ß','Û','Û','ß',' ',' ',' ',
    'ß','Û','Û','ß',' ',' ',' ',' ',' ','ß','Û','Û','ß',' ',' ',' ',' ',
    ' ',' ','ß','Û','Û',' ',' ',' ','Û','Û','ß',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ','³','³',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','³',
    '³',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','³','³',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ','³','³',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ','³','³',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','³','³',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ','³','³',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ','³','³',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','³','À',
    'Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä',
    'Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä',' ','(','C',')',' ','1','9','9',
    '6',' ','R','.',' ','S','p','r','i','n','g','e','r',' ','Ä','Ä','Ä',
    'Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä',
    'Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ä','Ù');
Var T: Text;
Begin;
 For I := 1 to 1999 do
  Write (TitlePic[I]);
 Ch := #0;
 Repeat
  While KeyPressed Do Ch := ReadKey;
 Until Ch <> #0;
 Ch := #0;
End;

Begin;
 Wait := 0;
 If (ParamStr (1) = 'DELAY') Then
 Begin;
  Write ('Wait state: ');
  ReadLn (Wait);
 End;
 If (ParamStr (1) = 'delay') Then
 Begin;
  Write ('Wait state: ');
  ReadLn (Wait);
 End;
 If (ParamStr (2) = 'DELAY') Then
 Begin;
  Write ('Wait state: ');
  ReadLn (Wait);
 End;
 If (ParamStr (2) = 'delay') Then
 Begin;
  Write ('Wait state: ');
  ReadLn (Wait);
 End;
 Randomize;
 TextAttr := $1E;
 ClrScr;
 CursOff;
 If (ParamStr (1) <> 'NOWAIT') And
    (ParamStr (1) <> 'nowait') And
    (ParamStr (2) <> 'NOWAIT') And
    (ParamStr (2) <> 'nowait') Then DoMenu;
 ClrScr;
 SoundOn := True;
 X := 2; Y := 2; Health := 100; Ammo := 5; Lives := 3; ScoreBL := 0;
 AmmoBL := 5; KeysBL := 0;
 LD := 'M';
 MAP_LoadMap ('MAZE.000');
 MAP_DrawBorder;
 MAP_DrawMap;
 Ch := #0;
 ShowScore (True);
 Repeat
  Inc (MsgDelay);
  If (MsgDelay = MessageDelay + Wait) And (Message <> '') Then
  Begin;
   Message := '';
   ShowScore (False);
   MsgDelay := 0;
  End;
  While KeyPressed Do Ch := ReadKey;
  For I := 1 to NumBad Do
   BAD_HandleMan (I);
  BUL_HandleIt;
  GUY_HandleMan;
  GotoXY (1, 1);
  Write ('');
  If Ch <> #27 Then Ch := #0;
 Until Ch = #27;
 CursOn;
 TextAttr := $07;
 ClrScr;
 WriteLn ('Maze of Death Version 1.0 - (c) 1996 R. Springer');
 If Cheater = True Then
 Begin;
  WriteLn;
  WriteLn ('It''s a good day to cheat!');
 End;
End.
