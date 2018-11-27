Shader "ImageEffect/BloomEffect"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        [KeywordEnum(ADDITIVE, SCREEN, DEBUG)]
        _BLOOM_TYPE("Bloom Type", Float) = 0
        _BrightnessThreshold("Brightness Threshold", Range(0, 1)) = 0.8
        _HalfFilterSizePx ("Half Filter Size", Range(0, 50)) = 1
        _Intensity("Intensity", Range(0, 5)) = 1
    }
    SubShader
    {
        // NTOE:
        // Get brightness image.

        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"
            #include "Assets/Packages/ImageFilterLibrary/ImageFilterLibrary.cginc"
            #pragma vertex vert_img
            #pragma fragment frag

            sampler2D _MainTex;
            float4    _MainTex_TexelSize;
            float     _BrightnessThreshold;

            fixed4 frag(v2f_img input) : SV_Target
            {
                float4 color = tex2D(_MainTex, input.uv);
                float brightness = (color.r + color.g + color.b) * 0.3333;

                return brightness > _BrightnessThreshold ? color : 0;
            }

            ENDCG
        }

        // NOTE:
        // Get blured brightness image.

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
                return MovingAverageFilter(_MainTex, _MainTex_TexelSize.xy, input.uv, _HalfFilterSizePx);
            }

            ENDCG
        }

        // NOTE:
        // Composite.

        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"
            #include "Assets/Packages/ImageFilterLibrary/ImageFilterLibrary.cginc"
            #pragma vertex vert_img
            #pragma fragment frag
            #pragma multi_compile _BLOOM_TYPE_ADDITIVE _BLOOM_TYPE_SCREEN _BLOOM_TYPE_DEBUG

            sampler2D _MainTex;
            sampler2D _BluredTex;
            float     _Intensity;

            fixed4 frag(v2f_img input) : SV_Target
            {
                float4 mainColor = tex2D(_MainTex, input.uv);
                float4 bluredColor = tex2D(_BluredTex, input.uv) * _Intensity;

                #ifdef _BLOOM_TYPE_SCREEN

                return mainColor + bluredColor - (mainColor * bluredColor);

                #elif _BLOOM_TYPE_ADDITIVE

                return mainColor + bluredColor;

                #else

                return bluredColor;

                #endif
            }

            ENDCG
        }
    }
}