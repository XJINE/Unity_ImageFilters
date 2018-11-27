using UnityEngine;

public class BloomEffect : ImageEffectBase
{
    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //_material.SetFloat("_Threshold", _threshold);
        //_material.SetFloat("_Intensity", _intensity);
        //_material.SetTexture("_SourceTex", source);

        // 1pass

        RenderTexture bluredTex = RenderTexture.GetTemporary(source.descriptor);
 
        Graphics.Blit(source,      bluredTex, base.material, 0);
        
        Graphics.Blit(bluredTex, bluredTex, this.material, 1);

        base.material.SetTexture("_BluredTex", bluredTex);
        
        Graphics.Blit(source, destination, this.material, 2);

        RenderTexture.ReleaseTemporary(bluredTex);
    }
}