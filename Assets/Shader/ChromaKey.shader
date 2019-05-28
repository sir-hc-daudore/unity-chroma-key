Shader "Unlit/ChromaKey"
{
    Properties
    {
		// The texture to remove the Chroma color
        _MainTex ("Texture", 2D) = "white" {}
		// The Chroma color, by default is some kind of green
		_Chroma ("Chroma", Color) = (0.07058823529, 0.59607843137, 0.15294117647)
		// Tolerance of the subsistution. Larger values means other colors (like shades of the same color) are considered transparent
		_Tolerance ("Tolerance", Range(0.0, 1.0)) = 0.15
    }
    SubShader
    {
		// Unity needs to know this shader will render transparent geometry, so it is properly rendered in the according order
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Pass
        {
			// Also, Unity needs to know how to blend the fragment colors of this shader and the background's colors.
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			// These variables are assigned by Unity with the properties declared eariler.
			float4 _Chroma;
			float _Tolerance;

			// Vertex program. 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

			// Fragment program.
            fixed4 frag (v2f i) : SV_Target
            {
                // Get the original colors from the texture according to the UVs of the fragment.
                fixed4 col = tex2D(_MainTex, i.uv);

				// We calculate the "distance" between the Chroma color and the fragment
				float dist = distance(col.rgb, _Chroma.rgb);
                
				// Then, we calculate the color's alpha value by subtracting the Tolerance to the "distance", so areas below the _Tolerance will be transparent.
				// We use the clamp function so it the alpha value is between 0 and 1.
				col.a = clamp( round(dist - _Tolerance), 0.0, 1.0);

				// Return the fragment's final color
                return col;
            }
            ENDCG
        }
    }
}
