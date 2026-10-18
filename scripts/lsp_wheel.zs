extend class LSP_EventHandler
{
    const WHEELSECTIONS = 5;
    
    ui void RenderWheel()
    {
        Screen.DrawText(
            bigfont,
            Font.CR_UNTRANSLATED,
            Screen.GetWidth() / 2,
            Screen.GetHeight() / 2,
            "Wheel or something"
        );

        TextureID texture = TexMan.CheckForTexture("PING");

        Screen.DrawTexture(
            texture,
            false,
            mousePosition.X,
            mousePosition.Y,
            DTA_Alpha, 1,
            DTA_Color, playerColor
        );
    }
}