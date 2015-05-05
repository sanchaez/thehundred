unit consts;

interface
uses SDL2;
    const
        PROGRAMNAME     = 'the HUNDRED v0.2';
        SCREENWIDTH     = 800;
        SCREENHEIGHT    = 600;
        MENU_POSCOUNT   = 3;
        MENU_NAMES: array [0..MENU_POSCOUNT] of PChar =
            ('new game', 'continue game', 'how to play','quit');
        AUDIO_FREQUENCY=44100;
        AUDIO_FORMAT:WORD=AUDIO_U16SYS;
        AUDIO_CHANNELS=2;
        AUDIO_CHUNKSIZE=256;
    var gWindow: PSDL_Window;
        gRenderer: PSDL_Renderer;

implementation

end.
