using UnityEngine;

public class GaussianFilter : ImageEffectBase
{
    #region Field

    [Range(1, 10)]
    public int divisor = 3;

    [Range(1, 3)]
    public int iteration = 3;

    #endregion Field

    #region Method

    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        RenderTexture resizedTex1 = RenderTexture.GetTemporary(source.width  / this.divisor,
                                                               source.height / this.divisor,
                                                               source.depth,
                                                               source.format);
        RenderTexture resizedTex2 = RenderTexture.GetTemporary(resizedTex1.descriptor);

        Graphics.Blit(source, resizedTex1);

        for (int i = 0; i < this.iteration; i++)
        {
            Graphics.Blit(resizedTex1, resizedTex2, base.material, 0);
            Graphics.Blit(resizedTex2, resizedTex1, base.material, 1);
        }

        Graphics.Blit(resizedTex1, destination);

        RenderTexture.ReleaseTemporary(resizedTex1);
        RenderTexture.ReleaseTemporary(resizedTex2);
    }

    #endregion Method
}