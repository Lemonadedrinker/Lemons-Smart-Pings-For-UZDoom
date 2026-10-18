class LSP_EventHandler : EventHandler
{
    const MAX_LENGTH = 2048.0;
    ui Array<LSP_Ping> pingList;
    protected Le_GlScreen proj;

    ui int timer;
    ui bool incrementingTimer;
    ui int wheelKeyChar;
    ui bool renderingWheel;

    override void OnRegister()
    {
        proj = new("Le_GlScreen");
    }

    override void WorldLoaded(WorldEvent event)
    {
        EnableNetworking(true);
    }

    // Handles holding down the ping button
    override bool InputProcess(InputEvent event)
    {
        if (bindings.GetBinding(event.KeyScan) == "LSP_PingKey")
        {
            // Cache the keyChar for the UiProcess
            wheelKeyChar = event.KeyChar;
            //Console.printf("Caching wheelKeyChar: %i", wheelKeyChar);

            if (event.Type == InputEvent.Type_KeyDown)
            {
                //Console.printf("Ping pressed!");
                incrementingTimer = true;
            }
            else if (event.Type == InputEvent.Type_KeyUp)
            {
                Console.printf("Ping released!");
                SendNetworkEvent("LSP_WheelClosed");
                SendInterfaceEvent(ConsolePlayer, "LSP_Ping");
                incrementingTimer = false;
                timer = 0;
            }
        }
        return false;
    }

    override void UiTick()
    {
        if (incrementingTimer)
        {
            timer++;
        }

        if (timer == 10)
        {
            //Console.printf("One second!");
            renderingWheel = true;
            SendNetworkEvent("LSP_WheelOpened");
        }
    }

    override void NetworkProcess(ConsoleEvent event)
    {
        if(players[event.Player].mo == null) return;

        if (event.Name == "LSP_SpawnPing")
        {
            Vector3 position = (event.Args[0], event.Args[1], event.Args[2]);
            LSP_Ping ping = LSP_Ping(Actor.Spawn("LSP_Ping", position));

            SendInterfaceEvent(ConsolePlayer, "LSP_PingAdded", ping.GetNetworkID());
        }
        else if (event.Name == "LSP_SpawnActorPing")
        {
            Actor target = Actor(GetNetworkEntity(event.Args[0]));

            if (!target)
            {
                Console.printf("No target.");
                return;
            }

            LSP_Ping ping = LSP_Ping(Actor.Spawn("LSP_Ping", target.pos));
            ping.targetActor = target;

            SendInterfaceEvent(ConsolePlayer, "LSP_PingAdded", ping.GetNetworkID());
        }

        // Wheel handling
        else if (event.Name == "LSP_WheelOpened")
        {
            if (event.Player == ConsolePlayer)
            {
                self.IsUiProcessor = true;
                self.RequireMouse = true;
            }
        }
        else if (event.Name == "LSP_WheelClosed")
        {
            if (event.Player == ConsolePlayer)
            {
                self.IsUiProcessor = false;
                self.RequireMouse = false;
            }
        }
    }

    override bool UiProcess(UiEvent event)
    {
        //Console.printf("keychar: %i, %i", event.KeyChar, wheelKeyChar);
        //Console.printf("event.Type: %i", event.Type);
        // Cached ping key
        // 3 and 11 are hardcoded values for releasing the keys
        if (event.KeyChar == wheelKeyChar && (
            event.Type == 3 ||
            event.Type == 11
            ))
        {
            Console.printf("Key released!");
            // Ping key is released; wheel is closed
            renderingWheel = false;
            timer = 0;
            incrementingTimer = false;
            SendNetworkEvent("LSP_WheelClosed");
        }

        return false;
    }

    override void InterfaceProcess(ConsoleEvent event)
    {
        if (players[ConsolePlayer].mo == null) return;

        if (event.Name == "LSP_Ping")
        {
            //Console.printf("Ping!");

            let [coordinates, hitActor] = GetLookingAt();

            //Console.printf("X: %f, Y: %f, Z: %f", coordinates.X, coordinates.Y, coordinates.Z);
            
            if (hitActor)
            {
                SendNetworkEvent("LSP_SpawnActorPing", hitActor.GetNetworkID());
            }
            else
            {
                SendNetworkEvent("LSP_SpawnPing", coordinates.X, coordinates.Y, coordinates.Z);
            }
        }
        // Standard ping (no target)
        else if (event.Name == "LSP_PingAdded")
        {
            pingList.Push(LSP_Ping(GetNetworkEntity(event.Args[0])));
        }
    }

    ui Vector3, Actor GetLookingAt()
    {
        PlayerInfo player = players[ConsolePlayer];
        Vector3 hitPosition;

        LSP_LineTracer lineTracer = New("LSP_LineTracer");

        Vector3 direction = (Actor.AngleToVector(player.mo.angle, cos(player.mo.pitch)), -sin(player.mo.pitch));
        Vector3 start = (player.mo.pos.xy, player.viewz);
        
        lineTracer.Trace(start, player.mo.cursector, direction, MAX_LENGTH, 0, 0, false, player.mo);
        TraceResults results = lineTracer.Results;

        if (results.HitType == TRACE_HitActor)
        {
            //Console.printf("Hit an actor!!");
            hitPosition = results.HitActor.pos;
        }
        else
        {
            hitPosition = results.HitPos;
        }

        //Console.printf("Trace Hit: %i", results.HitType);

        return hitPosition, results.HitActor;
    }
}

class LSP_LineTracer : LineTracer
{
    override ETraceStatus TraceCallback()
    {
        return TRACE_Stop;
    }
}