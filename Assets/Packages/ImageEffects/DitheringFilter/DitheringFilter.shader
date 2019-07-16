Shader "ImageEffect/DitheringFilter"
{
    Properties
    {
        [HideInInspector]
        _MainTex("Texture", 2D) = "white" {}
        [KeywordEnum(DOT, BAYER)]
        _DITHER("Dither Type", Float) = 0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"
            #include "Assets/Packages/Shaders/ImageFilters.cginc"
            #pragma vertex vert_img
            #pragma fragment frag
            #pragma multi_compile _DITHER_DOT _DITHER_BAYER

            sampler2D _MainTex;
            float4    _MainTex_TexelSize;

            fixed4 frag(v2f_img input) : SV_Target
            {
                return DitheringFilterDot(_MainTex, input.uv, _MainTex_TexelSize.zw);
            }

            ENDCG
        }
    }
}