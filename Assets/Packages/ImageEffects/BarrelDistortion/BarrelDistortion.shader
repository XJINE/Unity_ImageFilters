Shader "ImageEffect/BarrelDistortion"
{
    Properties
    {
        [HideInInspector]
        _MainTex("Texture", 2D) = "white" {}
        _Strength("Strength(k1, k2, -, -)", Vector) = (0.2, 0.01, 0, 0)
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
            float4    _Strength;

            fixed4 frag(v2f_img input) : SV_Target
            {
                float2 distortedCoord = BarrelDistortion(input.uv, _Strength.x, _Strength.y);

                bool outOfRange = distortedCoord.x < 0 || 1 < distortedCoord.x ||
                                  distortedCoord.y < 0 || 1 < distortedCoord.y;

                return outOfRange ? 0 : tex2D(_MainTex, distortedCoord);
            }

            ENDCG
        }
    }
}