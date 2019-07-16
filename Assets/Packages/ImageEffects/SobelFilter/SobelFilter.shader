Shader "ImageEffect/SobelFilter"
{
    Properties
    {
        [HideInInspector]
        _MainTex("Texture", 2D) = "white" {}
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

            fixed4 frag(v2f_img input) : SV_Target
            {
                return SobelFilter(_MainTex, input.uv, _MainTex_TexelSize.xy);
            }

            ENDCG
        }
    }
}