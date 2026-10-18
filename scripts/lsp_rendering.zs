extend class LSP_EventHandler
{
    ui Actor camera;

    override void RenderUnderlay(RenderEvent event)
    {
        camera = players[ConsolePlayer].Camera;

        // Setup:
        proj.CacheResolution();
        proj.CacheFov(players[ConsolePlayer].fov);
        proj.OrientForRenderUnderlay(event);
        proj.BeginProjection();

        int offsetX, offsetY, viewX, viewY;
        [offsetX, offsetY, viewX, viewY] = Screen.GetViewWindow();
        Vector2 origin = (offsetX, offsetY);
        Vector2 viewSize = (viewX, viewY);

        //Console.printf("viewY: %i", viewY);
        //Console.printf("origin: %i, %i", origin.X, origin.Y);

        let statusbar_height = (Screen.GetHeight() - Statusbar.GetTopOfStatusbar());

        int screenblocks = CVar.GetCVar("screenblocks").GetInt();
        int statusbarOffset = 0;
        //Console.printf("Screenblocks: %i", screenblocks);
        // Screenblocks less than 11 shows the entire statusbar
        if (screenblocks < 11)
        {
            //origin.Y -= statusbar_height;
            statusbarOffset = statusbar_height / 2;
        }
        viewSize.Y += statusbarOffset;

        // Parse through the pingList to check if it should still be there
        // Parse through backwards because we are deleting entries
        for (int i = pingList.Size() - 1; i >= 0; i--)
        {
            if (pingList[i] != null)
            {
                //DrawPingToScreen(pingList[i]);
                // Now you can project as much as you like, just like this:
                proj.ProjectWorldPos(pingList[i].pos);

                if(proj.IsInFront())
                {                    
                    let draw_pos = proj.ProjectToCustom(origin, viewSize);
                    draw_pos.Y -= statusbarOffset / 2;

                    TextureID texture = GetTexture(pingList[i]);
                    Vector2 clampedCoordinates = ClampToTexture(texture, draw_pos);

                    Color color = players[ConsolePlayer].GetColor() + 4278190080; 
                    
                    Screen.DrawTexture(
                        texture,
                        false,
                        clampedCoordinates.X,
                        clampedCoordinates.Y,
                        DTA_Alpha, 1,
                        DTA_Color, color
                    );

                    if (pingList[i].targetActor)
                    {
                        TextureID icon;
                        bool isMirrored;
                        [icon, isMirrored] = pingList[i].targetActor.spawnstate.GetSpriteTexture(0);
                        // Draw little sprite
                        Screen.DrawTexture(
                            icon,
                            false,
                            clampedCoordinates.X,
                            clampedCoordinates.Y
                        );
                    }
                }
            }
            else
            {
                pingList.Delete(i);
            }
        }
        
        // Render the wheel
        if (renderingWheel)
        {
            RenderWheel();
        }
    }

    ui TextureID GetTexture(LSP_Ping ping)
    {
        TextureID texture = TexMan.CheckForTexture("PING");

        if (!texture) Console.printf("Texture not found");

        return texture;
    }

    ui Vector2 ClampToTexture(TextureID texture, Vector2 draw_pos)
    {
        //Console.printf("X: %d, Y: %d", draw_pos.X, draw_pos.Y);
        Vector2 clampedCoordinates = draw_pos;

        int textureWidth, textureHeight = -1;
        [textureWidth, textureHeight] = TexMan.GetSize(texture);
        //Console.printf("Texture X: %i, Texture Y: %i", textureWidth, textureHeight);

        int offsetX, offsetY, viewX, viewY;
        [offsetX, offsetY, viewX, viewY] = Screen.GetViewWindow();
        
        if (draw_pos.X < textureWidth / 2 + offsetX) clampedCoordinates.X = textureWidth / 2 + offsetX;
        else if (draw_pos.X > viewX - textureWidth / 2 + offsetX) clampedCoordinates.X = viewX - textureWidth / 2 + offsetX;
        if (draw_pos.Y < textureHeight + offsetY) clampedCoordinates.Y = textureHeight + offsetY;
        else if (draw_pos.Y > viewY + offsetY) clampedCoordinates.Y = viewY + offsetY;

        //Console.printf("X: %d, Y: %d", clampedCoordinates.X, clampedCoordinates.Y);
        //console.printf("offsetX: %i", offsetX);

        return clampedCoordinates;
    }

    ui void RenderWheel()
    {
        Screen.DrawText(
            bigfont,
            Font.CR_UNTRANSLATED,
            Screen.GetWidth() / 2,
            Screen.GetHeight() / 2,
            "Wheel or something"
        );
    }
}