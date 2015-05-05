program thehundred_main;
uses
    SDL2, SDL2_image, SDL2_mixer, SDL2_ttf, menuopts, consts, music;
{Global}


procedure Init;
var IMGFLAGS: integer;
begin
    if SDL_Init( SDL_INIT_VIDEO or SDL_INIT_AUDIO ) < 0 then Halt(200);

    gWindow := SDL_CreateWindow( PROGRAMNAME, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREENWIDTH, SCREENHEIGHT, SDL_WINDOW_SHOWN );
    if gWindow = nil then begin
        writeln('SDL Error: ', SDL_GetError, ': Window can`t be created!');
        Halt(100);
    end;

    gRenderer := SDL_CreateRenderer(gWindow, -1, SDL_RENDERER_ACCELERATED or SDL_RENDERER_PRESENTVSYNC);
    if gRenderer = nil then begin
        writeln('SDL Error: ', SDL_GetError, ': Failed to create renderer!');
        Halt(101);
    end;

    IMGFLAGS:= IMG_INIT_PNG OR IMG_INIT_JPG;
    if IMG_Init(imgflags) and imgflags <> imgflags then begin
        writeln('SDL Error: ', SDL_GetError, ': Failed to load module IMG!');
        Halt(200);
    end;

    if TTF_Init < 0 then begin
        writeln('SDL Error: ', SDL_GetError, ': Failed to load module TTF!');
        halt(300);
    end;

    if MIX_OPENAUDIO(   AUDIO_FREQUENCY, MIX_DEFAULT_FORMAT,
                        AUDIO_CHANNELS, AUDIO_CHUNKSIZE )<>0 then begin
        writeln('SDL Error: ', SDL_GetError,': Failed to initialize audio!');
        halt(400);

    end;
    Chunk_Load;
end;

procedure Clean;
begin
    Chunk_Unload;
    MIX_CloseAudio;
    TTF_Quit;
    IMG_Quit;
    SDL_DestroyRenderer( gRenderer );
    SDL_DestroyWindow( gWindow );
    SDL_Quit;
end;

procedure Splash;
var Alpha: byte;
    SplashTexture: PSDL_texture;
    SplashPos: TSDL_Rect;
begin
    SDL_SetRenderDrawColor(gRenderer, 255, 255, 255, 255);
    SDL_RenderClear(gRenderer);
    SplashTexture:=IMG_LoadTexture(gRenderer, 'bmp/hundred.png');
    if SplashTexture = nil then begin
        writeln('SDL Error: ',SDL_GetError,' Texture failed to load!');
        Halt(200);
    end;
    SDL_QueryTexture(SplashTexture, nil, nil, @SplashPos.w, @SplashPos.h);
    SplashPos.x := (SCREENWIDTH   - SplashPos.w) div 2 + 46;
    SplashPos.y := (SCREENHEIGHT  - SplashPos.h) div 2;
    //linear fade in
    Alpha:=0;
    while Alpha<255 do begin
        SDL_RenderClear(gRenderer);
        inc(Alpha,15);
        SDL_SetTextureAlphaMod(SplashTexture, Alpha);
        SDL_RenderCopy(gRenderer, SplashTexture, nil, @SplashPos );
        SDL_RenderPresent(gRenderer);
        SDL_Delay(30);
    end;
    SDL_Delay(2000);
    //linear fade out
    Alpha:=255;
    while Alpha>0 do begin
        SDL_RenderClear(gRenderer);
        dec(Alpha,15);
        SDL_SetTextureAlphaMod(SplashTexture, Alpha);
        SDL_RenderCopy(gRenderer, SplashTexture, nil, @SplashPos );
        SDL_RenderPresent(gRenderer);
        SDL_Delay(30);
    end;
    SDL_DestroyTexture(SplashTexture);
end;

procedure MainMenu;
var
    Position: array [0..MENU_POSCOUNT] of TMyText;
    Exited, Chosen: boolean;
    Color1, Color2: TSDL_Color;
    HeaderTexture: PSDL_Texture;
    HeaderPos: TSDL_Rect;
    Alpha, Selection, i, j: byte;
    Event: PSDL_Event;
    MainFont: PTTF_Font;
begin
    //Loop if still not exited the program
    Exited:=false;
    while not Exited do begin
        Music_Loadnplay('music/main.wav',0);
        //Clearing screen
        SDL_SetRenderDrawColor(gRenderer, 255, 255, 255, 255);
        SDL_RenderClear(gRenderer);

        //Setting up colors in RGBA
        with Color1 do begin
            r:=0;
            g:=0;
            b:=0;
            a:=255;
        end;
        with Color2 do begin
            r:=255;
            g:=0;
            b:=0;
            a:=255;
        end;
        //loading texture
        HeaderTexture:=IMG_LoadTexture(gRenderer, 'bmp/hundred.png');
        if HeaderTexture = nil then begin
            writeln('SDL Error: ',SDL_GetError,' Texture failed to load!');
            Halt(200);
        end;

        //getting dimmensions
        SDL_QueryTexture(HeaderTexture, nil, nil, @HeaderPos.w, @HeaderPos.h);
        HeaderPos.x:=( SCREENWIDTH - HeaderPos.w ) div 2 + 46;
        HeaderPos.y:=50;
        Alpha:=0;
        while Alpha<255 do begin
            SDL_RenderClear(gRenderer);
            inc(Alpha,15);
            SDL_SetTextureAlphaMod(HeaderTexture, Alpha);
            SDL_RenderCopy(gRenderer, HeaderTexture, nil, @HeaderPos );
            SDL_RenderPresent(gRenderer);
            SDL_Delay(30);
        end;

        //Loading Font
        MainFont:=TTF_OpenFont('font/main.ttf', 32);
        if MainFont = nil then begin
            writeln('TTF Error:', SDL_GetError);
            Halt(310);
        end;

        //creating menu
        for i:=0 to MENU_POSCOUNT do begin
                Position[i].Font:=MainFont;
                Position[i].Render(gRenderer, MENU_NAMES[i], @Color1);
                Position[i].Pos.x:=100;
                Position[i].Pos.y:=i*50+250;

                //fade in
                Alpha:=0;
                while Alpha<255 do begin
                    inc(Alpha,17*3);
                    SDL_SetTextureAlphaMod( Position[i].Texture, Alpha );
                    SDL_RenderCopy(gRenderer, Position[i].Texture, nil, @Position[i].Pos);
                    SDL_RenderPresent(gRenderer);
                    SDL_Delay(20);
                end;
        end;
        //highlighting first position
        SDL_RenderClear(gRenderer);
        SDL_RenderCopy(gRenderer, HeaderTexture, nil, @HeaderPos );
        Position[0].Render(gRenderer, pansichar('! '+ ansistring(MENU_NAMES[0])), @Color2);
        SDL_RenderCopy(gRenderer, Position[0].Texture, nil, @Position[0].Pos);
        for i:=1 to MENU_POSCOUNT do begin
            Position[i].Render(gRenderer, MENU_NAMES[i], @Color1);
            SDL_RenderCopy(gRenderer, Position[i].Texture, nil, @Position[i].Pos);
        end;

        SDL_RenderPresent(gRenderer);
        Selection:=0;
        Chosen:=false;
        new(Event);

        while (not Chosen) and (not Exited) do begin
            // Check for all events
            if SDL_WaitEvent(Event) = 1 then begin
                // Check for QUIT event
                if Event^.type_ = SDL_QUITEV then begin
                    Exited := true;
                    break;
                end;
                // Check for KEYDOWN event
                if Event^.type_ = SDL_KEYDOWN then begin
                    // Getting key information
                    case Event^.key.keysym.sym of
                    SDLK_Escape:
                        // Quit on ESC
                        Exited := true;
                    SDLK_Down:
                        // Redraws screen and moves down
                        if Selection<MENU_POSCOUNT then begin
                            Chunk_Play(0);
                            SDL_RenderClear(gRenderer); //clear screen
                            SDL_RenderCopy(gRenderer, HeaderTexture, nil, @HeaderPos); //draw header
                            {Render non-highlighted positions}
                            j:=0;
                            while j<Selection do begin
                                SDL_DestroyTexture(Position[j].Texture);
                                Position[j].Render(gRenderer, MENU_NAMES[j], @Color1);
                                Position[j].Pos.x:=100;
                                Position[j].Pos.y:=j*50+250;
                                SDL_RenderCopy(gRenderer, Position[j].Texture, nil, @Position[j].Pos);
                                inc(j);
                            end;
                            {Deselect previous selection}
                            SDL_DestroyTexture(Position[Selection].Texture);
                            Position[Selection].Render(gRenderer, MENU_NAMES[Selection], @Color1);
                            Position[Selection].Pos.x:=100;
                            Position[Selection].Pos.y:=Selection*50+250;
                            SDL_RenderCopy(gRenderer, Position[Selection].Texture, nil, @Position[Selection].Pos);//copies to renderer
                            inc(Selection);
                            {Select next}
                            SDL_DestroyTexture(Position[Selection].Texture);
                            Position[Selection].Render(gRenderer, pansichar('! '+ansistring(MENU_NAMES[Selection])), @Color2);
                            Position[Selection].Pos.x:=100;
                            Position[Selection].Pos.y:=Selection*50+250;
                            SDL_RenderCopy(gRenderer, Position[Selection].Texture, nil, @Position[Selection].Pos);//copies to renderer
                            j:=MENU_POSCOUNT;
                            while j>Selection do begin
                                SDL_DestroyTexture(Position[j].Texture);
                                Position[j].Render(gRenderer, MENU_NAMES[j], @Color1);
                                Position[j].Pos.x:=100;
                                Position[j].Pos.y:=j*50+250;
                                SDL_RenderCopy(gRenderer, Position[j].Texture, nil, @Position[j].Pos);
                                dec(j);
                            end;
                            SDL_RenderPresent(gRenderer);
                        end
                            else Chunk_Play(7);
                    SDLK_Up:
                        {&E Redraws screen and moves up
                        * Same as previous}
                        if Selection>0 then begin
                            Chunk_play(0);
                            SDL_RenderClear(gRenderer);
                            SDL_RenderCopy(gRenderer, HeaderTexture, nil, @HeaderPos);
                            j:=MENU_POSCOUNT;
                            while j>Selection do begin
                                SDL_DestroyTexture(Position[j].Texture);
                                Position[j].Render(gRenderer, MENU_NAMES[j], @Color1);
                                Position[j].Pos.x:=100;
                                Position[j].Pos.y:=j*50+250;
                                SDL_RenderCopy(gRenderer, Position[j].Texture, nil, @Position[j].Pos);
                                dec(j);
                            end;
                            SDL_DestroyTexture(Position[Selection].Texture);
                            Position[Selection].Render(gRenderer, MENU_NAMES[Selection], @Color1);
                            Position[Selection].Pos.x:=100;
                            Position[Selection].Pos.y:=Selection*50+250;
                            SDL_RenderCopy(gRenderer, Position[Selection].Texture, nil, @Position[Selection].Pos);
                            dec(Selection);
                            SDL_DestroyTexture(Position[Selection].Texture);
                            Position[Selection].Render(gRenderer, pansichar('! '+ansistring(MENU_NAMES[Selection])), @Color2);
                            Position[Selection].Pos.x:=100;
                            Position[Selection].Pos.y:=Selection*50+250;
                            SDL_RenderCopy(gRenderer, Position[Selection].Texture, nil, @Position[Selection].Pos);
                            j:=0;
                            while j<Selection do begin
                                SDL_DestroyTexture(Position[j].Texture);
                                Position[j].Render(gRenderer, MENU_NAMES[j], @Color1);
                                Position[j].Pos.x:=100;
                                Position[j].Pos.y:=j*50+250;
                                SDL_RenderCopy(gRenderer, Position[j].Texture, nil, @Position[j].Pos);
                                inc(j);
                            end;
                            SDL_RenderPresent(gRenderer);
                        end
                            else Chunk_Play(7);
                    {Menu choice}
                    SDLK_RETURN:
                        begin
                            Chosen:=true;
                            Chunk_play(10);
                            sdl_delay(200);
                        end;
                    SDLK_KP_ENTER:
                        begin
                            Chosen:=true;
                            Chunk_play(10);
                            sdl_delay(200);
                        end;
                    end;
                end;

            end;
        end;
        MIX_PauseMusic;
        if Chosen then
            case Selection of
            0: Game(false);
            1: Game(true);
            2: HowToPlay;
            3: Exited:=True;
            end;
    end;

    //Disposal of resources
    Music_Unload(0);
    Dispose(Event);
    SDL_DestroyTexture(HeaderTexture);
    for i:=1 to MENU_POSCOUNT do SDL_DestroyTexture(Position[i].Texture);
    TTF_CloseFont( MainFont );
end;


begin
    Init;
    Splash;
    MainMenu;
    Clean;
end.
