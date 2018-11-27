#ifndef IMAGE_FILTER_LIBRARY_INCLUDED
#define IMAGE_FILTER_LIBRARY_INCLUDED

static const float PrewittFilterHorizontal[9] =
{ -1, 0, 1,
  -1, 0, 1,
  -1, 0, 1 };

static const float PrewittFilterVertical[9] =
{ -1, -1, -1,
   0,  0,  0,
   1,  1,  1 };

static const float SobelFilterHorizontal[9] =
{ -1, 0, 1,
  -2, 0, 2,
  -1, 0, 1 };

static const float SobelFilterVertical[9] =
{ -1, -2, -1,
   0,  0,  0,
   1,  2,  1 };

static const float Gaussian3FilterKernel[9] =
{ 0.0625, 0.1250, 0.0625,
  0.1250, 0.2500, 0.1250,
  0.0625, 0.1250, 0.0625 };

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

float4 PrewittFilter(sampler2D image, float2 pixelLength, float2 texCoord)
{
    float4 sumHorizontal = float4(0, 0, 0, 1);
    float4 sumVertical   = float4(0, 0, 0, 1);
    float2 coordinate;
    int    count = 0;

    for (int x = -1; x <= 1; x++)
    {
        for (int y = -1; y <= 1; y++)
        {
            coordinate = float2(texCoord.x + pixelLength.x * x, texCoord.y + pixelLength.y * y);
            sumHorizontal.rgb += tex2D(image, coordinate).rgb * PrewittFilterHorizontal[count];
            sumVertical.rgb   += tex2D(image, coordinate).rgb * PrewittFilterVertical[count];
            count++;
        }
    }

    return sqrt(sumHorizontal * sumHorizontal + sumVertical * sumVertical);
}

float4 SobelFilter(sampler2D image, float2 pixelLength, float2 texCoord)
{
    float4 sumHorizontal = float4(0, 0, 0, 1);
    float4 sumVertical   = float4(0, 0, 0, 1);
    float2 coordinate;
    int    count = 0;

    for (int x = -1; x <= 1; x++)
    {
        for (int y = -1; y <= 1; y++)
        {
            coordinate = float2(texCoord.x + pixelLength.x * x, texCoord.y + pixelLength.y * y);
            sumHorizontal.rgb += tex2D(image, coordinate).rgb * SobelFilterHorizontal[count];
            sumVertical.rgb   += tex2D(image, coordinate).rgb * SobelFilterVertical[count];
            count++;
        }
    }

    return sqrt(sumHorizontal * sumHorizontal + sumVertical * sumVertical);
}

float4 LaplacianFilter(sampler2D image, float2 pixelLength, float2 texCoord)
{
    float4 color = float4(0, 0, 0, 1);
    int count = 0;

    for (int x = -1; x <= 1; x++)
    {
        for (int y = -1; y <= 1; y++)
        {
            texCoord = float2(texCoord.x + pixelLength.x * x,
                              texCoord.y + pixelLength.y * y);
            color.rgb += tex2D(image, texCoord).rgb * LaplacianFilterKernel[count];
            count++;
        }
    }

    return color;
}

float4 MovingAverageFilter(sampler2D image, float2 pixelLength, float2 texCoord, int halfFilterSizePx)
{
    float4 color = float4(0, 0, 0, 1);
    float2 coordinate;

    for (int x = -halfFilterSizePx; x <= halfFilterSizePx; x++)
    {
        for (int y = -halfFilterSizePx; y <= halfFilterSizePx; y++)
        {
            color.rgb += tex2D(image, float2(texCoord.x + pixelLength.x * x,
                                              texCoord.y + pixelLength.y * y)).rgb;
        }
    }

    int filterSizePx = halfFilterSizePx * 2 + 1;

    color.rgb /= filterSizePx * filterSizePx;

    return color;
}

float4 Gaussian3Filter(sampler2D image, float2 pixelLength, float2 texCoord)
{
    float4 color = float4(0, 0, 0, 1);
    int count = 0;

    for (int x = -1; x <= 1; x++)
    {
        for (int y = -1; y <= 1; y++)
        {
            texCoord = float2(texCoord.x + pixelLength.x * x,
                              texCoord.y + pixelLength.y * y);
            color.rgb += tex2D(image, texCoord).rgb * Gaussian3FilterKernel[count];
            count++;
        }
    }

    return color;
}

float4 SymmetricNearestNeighbor
    (sampler2D image, float4 centerColor, float2 texCoord, float2 offset)
{
    float4 color0 = tex2D(image, texCoord + offset);
    float4 color1 = tex2D(image, texCoord - offset);
    float3 d0 = color0.rgb - centerColor.rgb;
    float3 d1 = color1.rgb - centerColor.rgb;

    return dot(d0, d0) < dot(d1, d1) ? color0 : color1;
}

float4 SymmetricNearestNeighborFilter
    (sampler2D image, float2 pixelLength, float2 texCoord, int halfFilterSizePx)
{
    // NOTE:
    // SymmetricNearestNeighborFilter algorithm compare the pixels with point symmetry.
    // So, the result of upper left side and lower right side shows same value.
    // This means the doubled upper left value is same as sum total.

    float  pixels = 1.0f;
    float4 centerColor = tex2D(image, texCoord);
    float4 outputColor = centerColor;

    for (int y = -halfFilterSizePx; y < 0; y++)
    {
        float offsetY = y * pixelLength.y;

        for (int x = -halfFilterSizePx; x <= halfFilterSizePx; x++)
        {
            float2 offset = float2(x * pixelLength.x, offsetY);

            outputColor += SymmetricNearestNeighbor
                (image, centerColor, texCoord, offset) * 2.0f;

            pixels += 2.0f;
        }
    }

    for (int x = -halfFilterSizePx; x < 0; x++)
    {
        float2 offset = float2(x * pixelLength.x, 0.0f);

        outputColor += SymmetricNearestNeighbor
            (image, centerColor, texCoord, offset) * 2.0f;

        pixels += 2.0f;
    }

    outputColor /= pixels;

    return outputColor;
}

float4 DitheringFilterDot(sampler2D image, int2 imageSize, float2 texCoord)
{
    // NOTE:
    // Use NTSC gray because it doesnt use division.

    float4 color = tex2D(image, texCoord);
    float  gray  = 0.298912f * color.r + 0.586611f * color.g + 0.114478f * color.b;

    int2 coordinatePx = int2(round((texCoord.x * imageSize.x) + 0.5) % 4,
                             round((texCoord.y * imageSize.y) + 0.5) % 4);

    #ifdef _DITHER_BAYER

    return DitherMatrixBayer[coordinatePx.x][coordinatePx.y] < gray ? float4(0, 0, 0, color.a) : float4(1, 1, 1, color.a);

    #else // _DITHER_DOT

    return DitherMatrixDot[coordinatePx.x][coordinatePx.y] < gray ? float4(0, 0, 0, color.a) : float4(1, 1, 1, color.a);

    #endif
}

#endif // IMAGE_FILTER_LIBRARY_INCLUDED