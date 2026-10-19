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

        String cursor = CVar.GetCVar("vid_cursor").GetString();
        TextureID texture = TexMan.CheckForTexture(cursor);

        Screen.DrawTexture(
            texture,
            false,
            mousePosition.X,
            mousePosition.Y
        );
    }
}