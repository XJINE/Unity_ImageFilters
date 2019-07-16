Shader "ImageEffect/SymmetricNearestNeighborFilter"
{
    Properties
    {
        [HideInInspector]
        _MainTex("Texture", 2D) = "white" {}
        _HalfFilterSizePx("Half Filter Size", Int) = 1
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

            sampler2D _MainTex;
            float4    _MainTex_TexelSize;
            int       _HalfFilterSizePx;

            fixed4 frag(v2f_img input) : SV_Target
            {
                return SymmetricNearestNeighborFilter
                       (_MainTex, input.uv, _MainTex_TexelSize.xy, _HalfFilterSizePx);
            }

            ENDCG
        }
    }
}