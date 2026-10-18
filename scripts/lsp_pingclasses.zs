class LSP_Ping : Actor
{
    default {
        +NOGRAVITY
        +NOCLIP
        +NOINTERACTION
        //+MASTERNOSEE
        //+CAMFOLLOWSPLAYER
        Radius 0;
        Height 0;
    }

    int time;
    Actor targetActor;

    override void BeginPlay()
    {
        time = 35 * 5 * 2;
        Super.BeginPlay();
    }
    
    override void Tick()
    {
        if (time > 0) time--;
        else Destroy();

        if (targetActor) 
        {
            Vector3 heightOffset = (0, 0, targetActor.Height / 2);
            SetOrigin(targetActor.pos + heightOffset, true);
            //Console.printf("Target position set!");
        }

        Super.Tick();
    }
}