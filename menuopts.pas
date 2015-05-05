unit MenuOpts;
//Contains procedures for every menu option
interface
uses SDL2, SDL2_ttf,SDL2_image, SDL2_mixer;
     type TMyText = object
        private
            Text: PChar;
            Surface: PSDL_Surface;
        public
            Texture: PSDL_Texture;
            Pos: TSDL_Rect;
            Font: PTTF_Font;
            procedure Render(fRenderer:PSDL_Renderer; fText: PChar; fColor: PSDL_Color);
    end;

    procedure Game(ReadFromSave: boolean);
    procedure HowToPlay;

implementation
uses Sysutils, consts, music;
    //renders text to texture
    procedure TMyText.Render(fRenderer:PSDL_Renderer; fText: PChar; fColor: PSDL_Color);
    begin
        Text:=fText;
        Surface:=TTF_RenderText_Solid( Font, fText, fColor^);
        if Surface = nil then writeln(SDL_GetError);
        Texture:=SDL_CreateTextureFromSurface( fRenderer, Surface );
        Pos.w:=Surface^.w;
        Pos.h:=Surface^.h;
        SDL_FreeSurface( Surface );
    end;

    //Game
    procedure Game(ReadFromSave: boolean);
    const
        FontSize_Score = 90;
        FontSize_All = 72;
        WinnerIsBlue = 1;
        WinnerIsRed = 0;
    type
        TSaveGame = record
            RedPoints, BluePoints, MatchesLeft: integer;
            Turn: byte;
        end;
    TSaveFile = file of TSaveGame;

    var
        SaveFile: TSaveFile;
        Save: TSaveGame;
        IsWinner, QuitToMenu: boolean;
        RectTop: PSDL_Rect;
        ColorMain, ColorGray, ColorRed, ColorBlue: TSDL_Color;
        ColorAll,Color1,Color2: PSDL_Color;
        RedScore, BlueScore, CurrentTurn, AllScore, Winner, PressKey, Esc: TMyText;
        Event: PSDL_Event;
        GameFont, ScoreFont: PTTF_Font;
        CurrentPts, Alpha: byte;

    // Сreates save.dat
    procedure CreateSave;
    begin
        CreateDir('save');
        assign(SaveFile, 'save/save.dat');
        Rewrite(SaveFile);
        With Save do begin
            RedPoints:=0;
            BluePoints:=0;
            MatchesLeft:=100;
            Turn:=0;
        end;
        write(SaveFile, Save);
    end;
    //reads save from save.dat
    procedure ReadSave;
    begin
        if not FileExists('save/save.dat') then begin
            CreateSave;
            exit;
        end
            else begin
                assign(SaveFile, 'save/save.dat');
                reset(SaveFile);
                read(SaveFile, Save);
            end;
    end;
    //saves save.dat
    procedure SaveSave;
    begin
        Rewrite(SaveFile);
        write(SaveFile, Save);
    end;

    begin
        if ReadFromSave then ReadSave
            else CreateSave;
        //init music
        Music_Unload(0);
        Music_Loadnplay('music/game.wav',1);

        //inti colors
        with ColorGray do begin
            r:=128;
            g:=128;
            b:=128;
        end;
        with ColorRed do begin
            r:=255;
            g:=0;
            b:=0;
        end;
        with ColorBlue do begin
            r:=0;
            g:=0;
            b:=255;
        end;
        with ColorMain do begin
            r:=0;
            g:=0;
            b:=0;
            a:=255;
        end;
        New(RectTop);
        with RectTop^ do begin
            w:=trunc(SCREENWIDTH*(1-(100-Save.MatchesLeft)/100));
            h:=200;
            x:=0;
            y:=(SCREENHEIGHT-h) div 2;
        end;
        //checking saved turn
        if Save.Turn=0 then begin
            Color1:=@ColorGray;
            Color2:=@ColorBlue;
        end
            else begin
                Color1:=@ColorRed;
                Color2:=@ColorGray;
            end;
        ColorAll:=@ColorMain;
        QuitToMenu:=false;
        IsWinner:=false;

        //init fonts
        GameFont:=TTF_OpenFont('font/main.ttf', 32);
        ScoreFont:=TTF_OpenFont('font/main.ttf', FontSize_Score);
        RedScore.Font:=ScoreFont;
        BlueScore.Font:=ScoreFont;
        AllScore.Font:=ScoreFont;
        CurrentTurn.Font:=TTF_OpenFont('font/main.ttf', 48);
        PressKey.Font:=GameFont;
        Esc.Font:=TTF_OpenFont('font/main.ttf', 28);


        Esc.Render(gRenderer, '[ESC]', @ColorMain);
        Esc.Pos.x:=10;
        Esc.Pos.y:=SCREENHEIGHT-Esc.Pos.h-10;

        //drawing
        New(Event);
        CurrentPts:=0;
        while not QuitToMenu and not IsWinner do begin
        //draw screen every frame
            sdl_delay(20);

            SDL_SetRenderDrawColor( gRenderer, 255, 255, 255, 255 );
            SDL_RenderClear(gRenderer);

            if (RectTop^.w/SCREENWIDTH)*100>20 then SDL_SetRenderDrawColor( gRenderer, 255, 222, 0, 255 )
                else SDL_SetRenderDrawColor( gRenderer, 255, 100, 0, 255 );
            SDL_RenderFillRect( gRenderer, RectTop );

            RedScore.Render(gRenderer, pansichar(inttostr(Save.RedPoints)), Color1);
            RedScore.Pos.x:=40;
            RedScore.Pos.y:=20;

            BlueScore.Render(gRenderer, pansichar(inttostr(Save.BluePoints)), Color2);
            BlueScore.Pos.x:=SCREENWIDTH-BlueScore.Pos.w-40;
            BlueScore.Pos.y:=20;

            AllScore.Render(gRenderer, pansichar(inttostr(Save.MatchesLeft)), ColorAll);
            AllScore.Pos.x:=(SCREENWIDTH-Allscore.Pos.w) div 2;
            AllScore.Pos.y:=(SCREENHEIGHT-Allscore.Pos.h) div 2;

            if Save.Turn=0 then CurrentTurn.Render(gRenderer, pansichar(ansistring('player blue: '+IntToStr(CurrentPts))),@ColorBlue)
                else CurrentTurn.Render(gRenderer, pansichar(ansistring('player red: '+IntToStr(CurrentPts))), @ColorRed);
            CurrentTurn.Pos.x:=(SCREENWIDTH-CurrentTurn.Pos.w) div 2 -25;
            CurrentTurn.Pos.y:=(SCREENHEIGHT-CurrentTurn.Pos.h) div 2 + 200;

            SDL_RenderCopy(gRenderer, CurrentTurn.Texture, nil, @CurrentTurn.Pos);
            SDL_RenderCopy(gRenderer, RedScore.Texture, nil, @RedScore.Pos);
            SDL_RenderCopy(gRenderer, BlueScore.Texture, nil, @BlueScore.Pos);
            SDL_RenderCopy(gRenderer, AllScore.Texture, nil, @AllScore.Pos);
            SDL_RenderCopy(gRenderer, Esc.Texture, nil, @Esc.Pos);
            SDL_RenderPresent(gRenderer);

            // Check for all events
            if SDL_WaitEvent(Event) = 1 then begin
                // Check for quitting
                if Event^.type_ = SDL_QUITEV then begin
                    QuitToMenu := true;
                    break;
                end;
                if Event^.type_ = SDL_KEYDOWN then begin
                //hanlding keypresses
                    case Event^.key.keysym.sym of
                    SDLK_ESCAPE: QuitToMenu:=true;
                    SDLK_KP_0: CurrentPts:=10;
                    SDLK_KP_1: CurrentPts:=1;
                    SDLK_KP_2: CurrentPts:=2;
                    SDLK_KP_3: CurrentPts:=3;
                    SDLK_KP_4: CurrentPts:=4;
                    SDLK_KP_5: CurrentPts:=5;
                    SDLK_KP_6: CurrentPts:=6;
                    SDLK_KP_7: CurrentPts:=7;
                    SDLK_KP_8: CurrentPts:=8;
                    SDLK_KP_9: CurrentPts:=9;
                    SDLK_KP_Enter:
                        begin
                            if CurrentPts<>0 then begin
                                Chunk_Play(10);
                                if Save.Turn=0 then begin
                                    inc(Save.BluePoints,CurrentPts);
                                    dec(Save.MatchesLeft,CurrentPts);
                                    dec(RectTop^.w,trunc((CurrentPts/100)*SCREENWIDTH));
                                    CurrentPts:=0;
                                    Save.Turn:=1;
                                    SaveSave;
                                    Color1:=@ColorRed;
                                    Color2:=@ColorGray;
                                end
                                    else begin
                                        inc(Save.RedPoints,CurrentPts);
                                        dec(Save.MatchesLeft,CurrentPts);
                                        dec(RectTop^.w,trunc((CurrentPts/100)*SCREENWIDTH));
                                        CurrentPts:=0;
                                        Save.Turn:=0;
                                        SaveSave;
                                        Color1:=@ColorGray;
                                        Color2:=@ColorBlue;
                                    end;
                            end;
                        end;
                    SDLK_Return:
                        begin
                            if CurrentPts<>0 then begin
                                Chunk_Play(10);
                                if Save.Turn=0 then begin
                                    inc(Save.BluePoints,CurrentPts);
                                    dec(Save.MatchesLeft,CurrentPts);
                                    dec(RectTop^.w,trunc((CurrentPts/100)*SCREENWIDTH));
                                    CurrentPts:=0;
                                    Save.Turn:=1;
                                    SaveSave;
                                    Color1:=@ColorRed;
                                    Color2:=@ColorGray;
                                end
                                    else begin
                                        inc(Save.RedPoints,CurrentPts);
                                        dec(Save.MatchesLeft,CurrentPts);
                                        dec(RectTop^.w,trunc((CurrentPts/100)*SCREENWIDTH));
                                        CurrentPts:=0;
                                        Save.Turn:=0;
                                        SaveSave;
                                        Color1:=@ColorGray;
                                        Color2:=@ColorBlue;
                                    end;
                            end;
                        end;
                    end;
                    if CurrentPts>0 then Chunk_Play(CurrentPts-1);
                    //check the game to end
                    if (Save.MatchesLeft<=0) then begin
                        Save.MatchesLeft:=0;
                        IsWinner:=true;
                    end;
                    SDL_DestroyTexture(RedScore.Texture);
                    SDL_DestroyTexture(BlueScore.Texture);
                    SDL_DestroyTexture(AllScore.Texture);
                    SDL_DestroyTexture(CurrentTurn.Texture);
                end;
            end;
        end;
        SDL_DestroyTexture(Esc.Texture);
        //rendering winner screen
        SDL_SetRenderDrawColor( gRenderer, 255, 255, 255, 255 );
        SDL_RenderClear( gRenderer );
        Music_Unload(1);
        if IsWinner then begin
            Alpha:=0;
            Winner.Font:=ScoreFont;
            if Save.Turn = WinnerIsBlue then begin
                Music_Loadnplay('music/win.wav',2,0);
                Winner.Render(gRenderer, 'Blue wins!', @ColorBlue);
                PressKey.Render(gRenderer, '[Press any key]', @ColorMain );
                with Winner.Pos do begin
                    x:=(SCREENWIDTH - w) div 2;
                    y:=(SCREENHEIGHT - h) div 2;
                end;
                with PressKey.Pos do begin
                        x:=(SCREENWIDTH - w) div 2;
                        y:=(SCREENHEIGHT - h) div 2 + 70;
                end;
                while Alpha<255 do begin
                    inc(Alpha,17);
                    SDL_SetTextureAlphaMod( Winner.Texture, Alpha );
                    SDL_RenderCopy(gRenderer, Winner.Texture, nil, @Winner.Pos);
                    SDL_RenderPresent(gRenderer);
                    SDL_Delay(20);
                end;
                SDL_RenderCopy(gRenderer, PressKey.Texture, nil, @PressKey.Pos);
                SDL_RenderPresent( gRenderer );
                repeat
                    SDL_WaitEvent(Event);
                until Event^.type_=SDL_KEYDOWN;
                SDL_DestroyTexture(Winner.Texture);
                SDL_DestroyTexture(PressKey.Texture);
                Music_Unload(2);
            end
                else begin
                    Music_Loadnplay('music/win.wav',2,0);
                    Winner.Render(gRenderer, 'Red wins!', @ColorRed);
                    PressKey.Render(gRenderer, '[Press any key]', @ColorMain );
                    with Winner.Pos do begin
                        x:=(SCREENWIDTH - w) div 2;
                        y:=(SCREENHEIGHT - h) div 2;
                    end;
                    with PressKey.Pos do begin
                        x:=(SCREENWIDTH - w) div 2;
                        y:=(SCREENHEIGHT - h) div 2 + 70;
                    end;
                    while Alpha<255 do begin
                        inc(Alpha,17);
                        SDL_SetTextureAlphaMod( Winner.Texture, Alpha );
                        SDL_RenderCopy(gRenderer, Winner.Texture, nil, @Winner.Pos);
                        SDL_RenderPresent(gRenderer);
                        SDL_Delay(20);
                    end;
                    SDL_RenderCopy(gRenderer, PressKey.Texture, nil, @PressKey.Pos);
                    SDL_RenderPresent( gRenderer );
                    repeat
                        SDL_WaitEvent(Event);
                    until Event^.type_=SDL_KEYDOWN;
                    SDL_DestroyTexture(Winner.Texture);
                    SDL_DestroyTexture(PressKey.Texture);
                    Music_Unload(2);
                end;
                DeleteFile('save/save.dat');
            end;
        //freeing resources
        Dispose(RectTop);
        Close(SaveFile);
    end;

    procedure HowToPlay;
    var Bmp: PSDL_Texture;
        Event: PSDL_Event;
    begin
        MIX_PauseMusic;
        Bmp:=IMG_LoadTexture(gRenderer, 'bmp/howtoplay.bmp');
        if bmp = nil then begin
            writeln('SDL Error: ',SDL_GetError,' Texture failed to load!');
            Halt(200);
        end;
        SDL_RenderClear( gRenderer );
        SDL_RenderCopy(gRenderer, bmp, nil, nil );
        SDL_RenderPresent( gRenderer );
        new(event);
        repeat
            SDL_WaitEvent(Event);
        until Event^.type_=SDL_KEYDOWN;
        dispose(Event);
        SDL_DestroyTexture(bmp);
    end;
end.
