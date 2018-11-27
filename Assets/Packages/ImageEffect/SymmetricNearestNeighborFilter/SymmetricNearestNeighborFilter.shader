Shader "ImageEffect/SymmetricNearestNeighborFilter"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _HalfFilterSizePx ("Half Filter Size", Int) = 1
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
            int       _HalfFilterSizePx;

            fixed4 frag(v2f_img input) : SV_Target
            {
                return SymmetricNearestNeighborFilter
                       (_MainTex, _MainTex_TexelSize.xy, input.uv, _HalfFilterSizePx);
            }

            ENDCG
        }
    }
}