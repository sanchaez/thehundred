unit music;
{$mode objfpc}
interface
uses SDL2, SDL2_mixer;
    procedure Music_Loadnplay(Path: PChar; Pos: integer; Count: integer = -1);
    procedure Music_Stop;
    procedure Music_Unload(Pos: integer);
    procedure Chunk_Play(Num: byte);
    procedure Chunk_Load;
    procedure Chunk_Unload;
implementation
uses Sysutils;
    var
        Wave: array of  PMIX_Music;
        Bits: array of  PMIX_Chunk;
        FreeSoundChannel: integer;

    procedure Music_Loadnplay(Path: PChar; Pos: integer; Count: integer = -1);
    begin
        SetLength(Wave, Pos+1);
        Wave[Pos]:=MIX_LoadMus(Path);
        if wave[Pos] = nil then begin
            writeln('MIX Error: ',MIX_GetError);
            halt(401);
        end;
        MIX_VolumeMusic(70);
        MIX_PlayMusic(Wave[Pos],Count);
    end;

    procedure Music_Stop;
    begin
        MIX_PauseMusic;
    end;

    procedure Music_Unload(Pos: integer);
    begin
        MIX_PauseMusic;
        MIX_FreeMusic(Wave[Pos]);
    end;

    procedure Chunk_Unload;
    var i: byte;
    begin
        for i:=1 to 11 do MIX_FreeChunk(Bits[i]);
    end;

    procedure Chunk_Load;
    const names: array [0..10] of ansistring =
        ('B1.wav','B2.wav','B3.wav','B4.wav',
        'B5.wav','B6.wav','B7.wav','B8.wav','B9.wav','B0.wav','B_enter.wav');
    var i: byte;

    begin
        SetLength(Bits, 11);
        for i:=0 to 10 do begin
            Bits[i]:=MIX_Loadwav(PAnsiChar('music/'+names[i]));
            if Bits[i] = nil then begin
                writeln('MIX Error: ', MIX_GetError);
                halt(401);
            end;
            MIX_VolumeChunk(Bits[i],70);
        end;
    end;

    procedure Chunk_Play(Num: byte);
    begin
        FreeSoundChannel:=MIX_PlayChannel(-1,Bits[Num],0);

    end;
end.
