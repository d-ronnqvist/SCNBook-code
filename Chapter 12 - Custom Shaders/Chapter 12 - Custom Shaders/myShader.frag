//  Copyright (c) 2014 David Rönnqvist.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in the
// Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#version 120

// Colors
uniform vec3 ambientColor  = vec3(0.1);
uniform vec3 diffuseColor  = vec3(0.4);
uniform vec3 specularColor = vec3(0.75);

uniform float shininess = 25.0;

// Direction of the light
uniform vec3 lightDirection = normalize(vec3(0.0, -1.0, -3.0));

uniform bool shouldUseTexture = false;
uniform sampler2D checkerboardTexture;

// Interpolated normal and positions
varying vec4 viewSpaceNormal;
varying vec4 viewSpacePosition;
varying vec2 varyingTextureCoordinate;


void main(void)
{
    // Turn the normal into a normalized vec3.
    vec3 normal = normalize(vec3(viewSpaceNormal));
    // Calculate the direction from the surface to the camera
    vec3 cameraDirection = normalize(vec3(-viewSpacePosition));
    
    
    // Calculate the amount of diffuse lighting
    float diffuseAmount  = 0.0;
    diffuseAmount = dot(-lightDirection, normal);
    diffuseAmount = max(diffuseAmount, 0.0); // no "negative" amounts
    

    float specularAmount = 0.0;
    
    // Reflect and normalize the light vector in the surface
    vec3 reflectedLight = reflect(lightDirection, normal);
    reflectedLight = normalize(reflectedLight);
    
    // Calculate the amount of specular lighting
    specularAmount = dot(reflectedLight, cameraDirection);
    specularAmount = max(specularAmount, 0.0);       // no "negative amounts"
    specularAmount = pow(specularAmount, shininess); // faster falloff
    
    
    
    vec3 color = diffuseColor;
    
    if (shouldUseTexture) {
        // Ignore the diffuseColor and use the color from the texture instead
        
        vec2 textureCoordinate = varyingTextureCoordinate;
        // repeat the texture by multiplying U and V with two scalars
        textureCoordinate *= vec2(14.0, 8.0);
         // and only use the fractional part of that number
        textureCoordinate = fract(textureCoordinate);
        
        // read the color from the texture
        color = texture2D(checkerboardTexture, textureCoordinate).rgb;
    }
        
    // The color of the fragment is the sum of the ambient color, diffuse color and specular color
    gl_FragColor = vec4(  ambientColor
                        + color * diffuseAmount
                        + specularColor * specularAmount,
                        1.0); // color is opaque
}
