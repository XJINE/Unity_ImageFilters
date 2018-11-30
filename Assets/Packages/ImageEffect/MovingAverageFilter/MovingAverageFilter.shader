Shader "ImageEffect/MovingAverageFilter"
{
    Properties
    {
        [HideInInspector]
        _MainTex("Texture", 2D) = "white" {}
        _FilterSizeH("Filter Size", Range(1, 50)) = 2
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"
            #include "Assets/Packages/ImageFilterLibrary/ImageFilterLibrary.cginc"
            #pragma vertex vert_img
            #pragma fragment frag

            sampler2D _MainTex;
            float4    _MainTex_TexelSize;
            int       _FilterSizeH;

            fixed4 frag(v2f_img input) : SV_Target
            {
                return MovingAverageFilter(_MainTex, input.uv, _MainTex_TexelSize.xy, _FilterSizeH);
            }

            ENDCG
        }
    }
}