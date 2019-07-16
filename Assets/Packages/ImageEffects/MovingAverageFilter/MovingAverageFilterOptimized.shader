Shader "ImageEffect/MovingAverageFilterOptimized"
{
    Properties
    {
        [HideInInspector]
        _MainTex("Texture", 2D) = "white" {}
        _HalfFilterSize("Filter Size", Range(1, 50)) = 2
    }

    SubShader
    {
        CGINCLUDE

        #include "UnityCG.cginc"
        #include "Assets/Packages/Shaders/ImageFilters.cginc"

        sampler2D _MainTex;
        float4    _MainTex_TexelSize;
        int       _HalfFilterSize;

        // NOTE:
        // Should be calculated in vertex shader or passed from CPU.

        #define FULL_FILTER_SIZE (_HalfFilterSize * 2 + 1)
        #define FULL_FILTER_SIZE_RECIPROCAL 1.0 / FULL_FILTER_SIZE

        ENDCG

        Pass
        {
            CGPROGRAM

            #pragma vertex vert_img
            #pragma fragment frag

            fixed4 frag(v2f_img input) : SV_Target
            {
                return MovingAverageFilterV
                (_MainTex, input.uv, _MainTex_TexelSize.xy, _HalfFilterSize, FULL_FILTER_SIZE_RECIPROCAL);
            }

            ENDCG
        }
        Pass
        {
            CGPROGRAM

            #pragma vertex vert_img
            #pragma fragment frag

            fixed4 frag(v2f_img input) : SV_Target
            {
                return MovingAverageFilterH
                (_MainTex, input.uv, _MainTex_TexelSize.xy, _HalfFilterSize, FULL_FILTER_SIZE_RECIPROCAL);
            }

            ENDCG
        }
    }
}