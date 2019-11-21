Shader "Lit/Altreasure"
{
	Properties
	{
		// _MainTex ("Texture", 2D) = "white" {}
		_Scale("CellScale", float) = 1.0
		_Freq("MapScale", float) = 1.0
		_Height("MaxHeight", float) = 1.0
	}
  SubShader
  {
    Pass
    {
      Tags { "LightMode"="ForwardBase"}
			// Cull Off

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
			#pragma geometry geom

      #include "UnityCG.cginc"
      #include "Lighting.cginc"
			#include "PerlinLib.cginc" // パーリンノイズ生成器

      struct appdata
      {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float2 uv : TEXCOORD0;
      };

			struct v2g
			{
				float4 vertex : POSITION;
 				float3 normal : NORMAL;
 				float2 uv : TEXCOORD0;
			};
			struct g2f
			{
				float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
        // float3 worldNormal : NORMAL;
				float light: TEXCOORD1;
				float noise: TEXCOORD2;
				float noise2: TEXCOORD3;
			};

			float _Scale;
			float _Freq;
			float _Height;

      // sampler2D _MainTex;
      // float4 _MainTex_ST;

      void vert (in appdata v, out v2g o)
      {
        // o.vertex = UnityObjectToClipPos(v.vertex);
        // o.worldNormal = UnityObjectToWorldNormal(v.normal);
        // // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				// o.uv = v.uv;
				o.vertex = v.vertex;
				o.normal = v.normal;
				o.uv = v.uv;
      }

			[maxvertexcount(24)]
			void geom(point v2g input[1], inout TriangleStream<g2f> outStream)
			{
					// base
					float4 world_pos = mul(UNITY_MATRIX_M, input[0].vertex); // 世界原点とした座標
					float4 view_pos = mul(UNITY_MATRIX_V, world_pos); // カメラ原点とした座標
					float4 org = input[0].vertex;
					float dist = _Scale;
					float non = 0.0;

					// noise
					float2 xz = world_pos.xz * _Freq;
					// xz = floor(xz * 2)/2;
					float n = cnoise(float3(xz,0));
					float h = (n * 0.5 + 0.5);
					// h = floor(h*6) / 6;
					org.y += h * _Height;

					// create cube
					float4 v0 = float4(-dist,dist,-dist,non)  + org;
					float4 v1 = float4(dist,dist,-dist,non)   + org;
					float4 v2 = float4(-dist,-dist,-dist,non) + org;
					float4 v3 = float4(dist,-dist,-dist,non)  + org;

					float4 v4 = float4(dist,dist,-dist,non) + org;
					float4 v5 = float4(dist,-dist,dist,non) + org;
					float4 v6 = float4(dist,dist,dist,non)  + org;

					float4 v7 = float4(-dist,dist,dist,non)  +org;
					float4 v8 = float4(dist,-dist,dist,non)  +org;
					float4 v9 = float4(-dist,-dist,dist,non) +org;

					float4 v10 = float4(-dist,dist,dist,non)+org;
					float4 v11 = float4(-dist,-dist,-dist,non)+org;
					float4 v12 = float4(-dist,dist,-dist,non)+org;

					v0 = mul(UNITY_MATRIX_M, v0);
					v1 = mul(UNITY_MATRIX_M, v1);
					v2 = mul(UNITY_MATRIX_M, v2);
					v3 = mul(UNITY_MATRIX_M, v3);
					v4 = mul(UNITY_MATRIX_M, v4);
					v5 = mul(UNITY_MATRIX_M, v5);
					v6 = mul(UNITY_MATRIX_M, v6);
					v7 = mul(UNITY_MATRIX_M, v7);
					v8 = mul(UNITY_MATRIX_M, v8);
					v9 = mul(UNITY_MATRIX_M, v9);
					v10 = mul(UNITY_MATRIX_M, v10);
					v11 = mul(UNITY_MATRIX_M, v11);
					v12 = mul(UNITY_MATRIX_M, v12);


					g2f o;
					o.uv = input[0].uv;
					o.noise = n;
					o.noise2 = cnoise(float3(xz,1));
					// o.worldNormal = UnityObjectToWorldNormal(input[0].normal);

					float3 vecA = v1 - v0;
					float3 vecB = v2 - v0;
					float3 normal = cross(vecA, vecB);
					normal = normalize(mul(normal, (float3x3) unity_WorldToObject));
					float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
					o.light = max(0., dot(normal, lightDir));
					o.vertex = mul(UNITY_MATRIX_VP,v0);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v1);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v2);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v3);
					outStream.Append(o);
					outStream.RestartStrip();

					vecA = v4 - v3;
					vecB = v5 - v3;
					normal = cross(vecA, vecB);
					normal = normalize(mul(normal, (float3x3) unity_WorldToObject));
					lightDir = normalize(_WorldSpaceLightPos0.xyz);
					o.light = max(0., dot(normal, lightDir));
					o.vertex = mul(UNITY_MATRIX_VP,v3);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v4);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v5);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v6);
					outStream.Append(o);
					outStream.RestartStrip();

					vecA = v7 - v6;
					vecB = v8 - v6;
					normal = cross(vecA, vecB);
					normal = normalize(mul(normal, (float3x3) unity_WorldToObject));
					lightDir = normalize(_WorldSpaceLightPos0.xyz);
					o.light = max(0., dot(normal, lightDir));
					o.vertex = mul(UNITY_MATRIX_VP,v6);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v7);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v8);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v9);
					outStream.Append(o);
					outStream.RestartStrip();

					vecA = v10 - v9;
					vecB = v11 - v9;
					normal = cross(vecA, vecB);
					normal = normalize(mul(normal, (float3x3) unity_WorldToObject));
					lightDir = normalize(_WorldSpaceLightPos0.xyz);
					o.light = max(0., dot(normal, lightDir));
					o.vertex = mul(UNITY_MATRIX_VP,v9);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v10);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v11);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v12);
					outStream.Append(o);
					outStream.RestartStrip();

					vecA = v0 - v1;
					vecB = v6 - v1;
					normal = cross(vecA, vecB);
					normal = normalize(mul(normal, (float3x3) unity_WorldToObject));
					lightDir = normalize(_WorldSpaceLightPos0.xyz);
					o.light = max(0., dot(normal, lightDir));
					o.vertex = mul(UNITY_MATRIX_VP,v1);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v0);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v6);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v7);
					outStream.Append(o);
					outStream.RestartStrip();

					vecA = v3 - v2;
					vecB = v9 - v2;
					normal = cross(vecA, vecB);
					normal = normalize(mul(normal, (float3x3) unity_WorldToObject));
					lightDir = normalize(_WorldSpaceLightPos0.xyz);
					o.light = max(0., dot(normal, lightDir));
					o.vertex = mul(UNITY_MATRIX_VP,v2);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v3);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v9);
					outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_VP,v8);
					outStream.Append(o);
					outStream.RestartStrip();
			}

      void frag (in g2f i, out fixed4 col : SV_Target)
      {
				float n = i.noise * 0.5 + 0.5;
				
        fixed4 baseColor = fixed4(0.2, 0.7, 0.2, 1.0);
				if(n < 0.3){
					baseColor = fixed4(0.2,0.2,0.7,1.0);
				}
				if(n > 0.7){
					baseColor = fixed4(0.8,0.5,0.2,1.0);
				}

				float m = i.noise2 * 0.5 + 0.5;
				if(m > 0.9){
					baseColor = fixed4(1.0,1.0,0.1,1.0);
				}

        // float3 lightDir = _WorldSpaceLightPos0.xyz;
        // float3 normal = normalize(i.worldNormal);
        // float NL = dot(normal, lightDir);

        // float3 lightColor = _LightColor0;
				
        // col = fixed4(baseColor * lightColor * max(NL, 0), 0);
				// col = fixed4(baseColor, 1.0);
				i.light += 0.05;

				col = i.light * baseColor;
      }
      ENDCG
    }
  }
}