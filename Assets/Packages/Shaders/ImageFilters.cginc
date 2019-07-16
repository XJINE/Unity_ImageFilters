#ifndef IMAGE_FILTERS_INCLUDED
#define IMAGE_FILTERS_INCLUDED

static const float PrewittFilterKernelH[9] =
{ -1, 0, 1,
  -1, 0, 1,
  -1, 0, 1 };

static const float PrewittFilterKernelV[9] =
{ -1, -1, -1,
   0,  0,  0,
   1,  1,  1 };

static const float SobelFilterKernelH[9] =
{ -1, 0, 1,
  -2, 0, 2,
  -1, 0, 1 };

static const float SobelFilterKernelV[9] =
{ -1, -2, -1,
   0,  0,  0,
   1,  2,  1 };

// NOTE:
// This means 7x7 filter.

static const float4 GaussianFilterKernel[7] =
{
    float4(0.0205, 0.0205, 0.0205, 0),
    float4(0.0855, 0.0855, 0.0855, 0),
    float4(0.232,  0.232,  0.232,  0),
    float4(0.324,  0.324,  0.324,  1),
    float4(0.232,  0.232,  0.232,  0),
    float4(0.0855, 0.0855, 0.0855, 0),
    float4(0.0205, 0.0205, 0.0205, 0)
};

static const float LaplacianFilterKernel[9] =
{ -1, -1, -1,
  -1,  8, -1,
  -1, -1, -1 };

static const float4x4 DitherMatrixDot =
{ 0.74, 0.27, 0.40, 0.60,
  0.80, 0.00, 0.13, 0.94,
  0.47, 0.54, 0.67, 0.34,
  0.20, 1.00, 0.87, 0.07 };

static const float4x4 DitherMatrixBayer =
{ 0.000, 0.500, 0.125, 0.625,
  0.750, 0.250, 0.875, 0.375,
  0.187, 0.687, 0.062, 0.562,
  0.937, 0.437, 0.812, 0.312 };

float4 PrewittFilter(sampler2D tex, float2 texCoord, float2 texelSize)
{
    float4 sumHorizontal = float4(0, 0, 0, 1);
    float4 sumVertical   = float4(0, 0, 0, 1);
    float2 coordinate;
    int    count = 0;

    for (int x = -1; x <= 1; x++)
    {
        for (int y = -1; y <= 1; y++)
        {
            coordinate = float2(texCoord.x + texelSize.x * x, texCoord.y + texelSize.y * y);
            sumHorizontal.rgb += tex2D(tex, coordinate).rgb * PrewittFilterKernelH[count];
            sumVertical.rgb   += tex2D(tex, coordinate).rgb * PrewittFilterKernelV[count];
            count++;
        }
    }

    return sqrt(sumHorizontal * sumHorizontal + sumVertical * sumVertical);
}

float4 SobelFilter(sampler2D tex, float2 texCoord, float2 texelSize)
{
    float4 sumHorizontal = float4(0, 0, 0, 1);
    float4 sumVertical   = float4(0, 0, 0, 1);
    float2 coordinate;
    int    count = 0;

    for (int x = -1; x <= 1; x++)
    {
        for (int y = -1; y <= 1; y++)
        {
            coordinate = float2(texCoord.x + texelSize.x * x, texCoord.y + texelSize.y * y);
            sumHorizontal.rgb += tex2D(tex, coordinate).rgb * SobelFilterKernelH[count];
            sumVertical.rgb   += tex2D(tex, coordinate).rgb * SobelFilterKernelV[count];
            count++;
        }
    }

    return sqrt(sumHorizontal * sumHorizontal + sumVertical * sumVertical);
}

float4 LaplacianFilter(sampler2D tex, float2 texCoord, float2 texelSize)
{
    float4 color = float4(0, 0, 0, 1);
    int count = 0;

    for (int x = -1; x <= 1; x++)
    {
        for (int y = -1; y <= 1; y++)
        {
            texCoord = float2(texCoord.x + texelSize.x * x,
                              texCoord.y + texelSize.y * y);
            color.rgb += tex2D(tex, texCoord).rgb * LaplacianFilterKernel[count];
            count++;
        }
    }

    return color;
}

float4 MovingAverageFilter(sampler2D tex, float2 texCoord, float2 texelSize, int halfFilterSize)
{
    float4 color = float4(0, 0, 0, 1);

    for (int x = -halfFilterSize; x <= halfFilterSize; x++)
    {
        for (int y = -halfFilterSize; y <= halfFilterSize; y++)
        {
            color.rgb += tex2D(tex, float2(texCoord.x + texelSize.x * x,
                                            texCoord.y + texelSize.y * y)).rgb;
        }
    }

    color.rgb /= pow(halfFilterSize * 2 + 1, 2);

    return color;
}

float4 MovingAverageFilterV(sampler2D tex, float2 texCoord, float2 texelSize, int halfFilterSize, float fullFilterSizeReciprocal)
{
    float4 color = float4(0, 0, 0, 1);

    for (int y = -halfFilterSize; y <= halfFilterSize; y++)
    {
        color.rgb += tex2D(tex, float2(texCoord.x, texCoord.y + texelSize.y * y)).rgb;
    }

    color.rgb *= fullFilterSizeReciprocal;

    return color;
}

float4 MovingAverageFilterH(sampler2D tex, float2 texCoord, float2 texelSize, int halfFilterSize, float fullFilterSizeReciprocal)
{
    float4 color = float4(0, 0, 0, 1);

    for (int x = -halfFilterSize; x <= halfFilterSize; x++)
    {
        color.rgb += tex2D(tex, float2(texCoord.x + texelSize.x * x, texCoord.y)).rgb;
    }

    color.rgb *= fullFilterSizeReciprocal;

    return color;
}

float4 GaussianFilter(sampler2D tex, float4 texST, float2 texCoord, float2 offset)
{
    float4 color  = 0;

    texCoord = texCoord - offset * 3;

    for(int i = 0; i < 7; i++)
    {
        color += tex2D(tex, UnityStereoScreenSpaceUVAdjust(texCoord, texST))
               * GaussianFilterKernel[i];

        texCoord += offset;
    }

    return color;
}

float4 SymmetricNearestNeighbor
    (float4 centerColor, sampler2D tex, float2 texCoord, float2 texCoordOffset)
{
    float4 color0 = tex2D(tex, texCoord + texCoordOffset);
    float4 color1 = tex2D(tex, texCoord - texCoordOffset);
    float3 d0 = color0.rgb - centerColor.rgb;
    float3 d1 = color1.rgb - centerColor.rgb;

    return dot(d0, d0) < dot(d1, d1) ? color0 : color1;
}

float4 SymmetricNearestNeighborFilter
    (sampler2D tex, float2 texCoord, float2 texelSize, int halfFilterSize)
{
    // NOTE:
    // SymmetricNearestNeighborFilter algorithm compare the pixels with point symmetry.
    // So, the result of upper left side and lower right side shows same value.
    // This means the doubled upper left value is same as sum total.

    float  pixels = 1.0f;
    float4 centerColor = tex2D(tex, texCoord);
    float4 outputColor = centerColor;

    for (int y = -halfFilterSize; y < 0; y++)
    {
        float texCoordOffsetY = y * texelSize.y;

        for (int x = -halfFilterSize; x <= halfFilterSize; x++)
        {
            float2 texCoordOffset = float2(x * texelSize.x, texCoordOffsetY);

            outputColor += SymmetricNearestNeighbor
                (centerColor, tex, texCoord, texCoordOffset) * 2.0f;

            pixels += 2.0f;
        }
    }

    for (int x = -halfFilterSize; x < 0; x++)
    {
        float2 texCoordOffset = float2(x * texelSize.x, 0.0f);

        outputColor += SymmetricNearestNeighbor
            (centerColor, tex, texCoord, texCoordOffset) * 2.0f;

        pixels += 2.0f;
    }

    outputColor /= pixels;

    return outputColor;
}

float4 DitheringFilterDot(sampler2D tex, float2 texCoord, int2 texSize)
{
    // NOTE:
    // Use NTSC gray because it doesnt use division.

    float4 color = tex2D(tex, texCoord);
    float  gray  = 0.298912f * color.r + 0.586611f * color.g + 0.114478f * color.b;

    int2 texCoordPx = int2(round((texCoord.x * texSize.x) + 0.5) % 4,
                           round((texCoord.y * texSize.y) + 0.5) % 4);

    #ifdef _DITHER_BAYER

    return DitherMatrixBayer[texCoordPx.x][texCoordPx.y] < gray ? float4(0, 0, 0, color.a) : float4(1, 1, 1, color.a);

    #else // _DITHER_DOT

    return DitherMatrixDot[texCoordPx.x][texCoordPx.y] < gray ? float4(0, 0, 0, color.a) : float4(1, 1, 1, color.a);

    #endif
}

float2 BarrelDistortion(float2 texCoord, float k1, float k2)
{
    // NOTE:
    // k1, k2 means strength. 
    // Popular values are k1:0.2 k2:0.01.

    float2 distortedCoord;
    float2 centerOriginCoord = texCoord - 0.5;

    float rr = centerOriginCoord.x * centerOriginCoord.x
             + centerOriginCoord.y * centerOriginCoord.y;
    float rrrr = rr * rr;
    float distortion = 1 + k1 * rr + k2 * rrrr;

    distortedCoord = centerOriginCoord * distortion;
    distortedCoord += 0.5;

    // CAUTION:
    // Somtimes return under 0 or over 1 value.

    return distortedCoord;
}

#endif // IMAGE_FILTERS_INCLUDED