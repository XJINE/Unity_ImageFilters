Shader "ImageEffect/MovingAverageFilter"
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
            int       _HalfFilterSizePx;

            fixed4 frag(v2f_img input) : SV_Target
            {
                return MovingAverageFilter(_MainTex, _ScreenParams.zw - 1, input.uv, _HalfFilterSizePx);
            }

            ENDCG
        }
    }
}