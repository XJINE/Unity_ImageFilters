Shader "ImageEffect/GaussianFilter"
{
    Properties
    {
        [HideInInspector]
        _MainTex("Texture", 2D) = "white" {}
        _SamplingFrequency ("Sampling Frequency", Range(1, 1.5)) = 1
    }
    SubShader
    {
        CGINCLUDE

        #include "UnityCG.cginc"
        #include "Assets/Packages/ImageFilterLibrary/ImageFilterLibrary.cginc"

        sampler2D _MainTex;
        float4    _MainTex_ST;
        float4    _MainTex_TexelSize;
        float     _SamplingFrequency;

        ENDCG

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_img
            #pragma fragment frag

            // NOTE:
            // "offset" Should be calculated in vertex shader or passed from CPU.

            float4 frag (v2f_img input) : SV_Target
            {
                float2 offset = _MainTex_TexelSize.xy * float2(1, 0) * _SamplingFrequency;
                return GaussianFilter(_MainTex, _MainTex_ST, input.uv, offset);
            }

            ENDCG
        }
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_img
            #pragma fragment frag

            float4 frag (v2f_img input) : SV_Target
            {
                float2 offset = _MainTex_TexelSize.xy * float2(0, 1) * _SamplingFrequency;
                return GaussianFilter(_MainTex, _MainTex_ST, input.uv, offset);
            }

            ENDCG
        }
    }
}