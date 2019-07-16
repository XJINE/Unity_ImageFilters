using UnityEngine;

public class MovingAverageFilterOptimized : ImageEffectBase
{
    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        RenderTexture renderTexture = RenderTexture.GetTemporary(source.descriptor);
        Graphics.Blit(source, renderTexture, base.material, 0);
        Graphics.Blit(renderTexture, destination, base.material, 1);
        RenderTexture.ReleaseTemporary(renderTexture);
    }
}