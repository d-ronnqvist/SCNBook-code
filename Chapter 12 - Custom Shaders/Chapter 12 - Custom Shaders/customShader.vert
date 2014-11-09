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


uniform mat4 modelViewProjection;
uniform mat4 normalTransform;
uniform mat4 modelView;

uniform float time;

// input
attribute vec3 position;
attribute vec3 normal;

// output
varying vec4 viewSpaceNormal;
varying vec4 viewSpacePosition;

// a function that creates a rotation transform matrix around X
mat4 rotationAroundX(float angle)
{
    return mat4(1.0,    0.0,         0.0,        0.0,
                0.0,    cos(angle), -sin(angle), 0.0,
                0.0,    sin(angle),  cos(angle), 0.0,
                0.0,    0.0,         0.0,        1.0);
}


void main(void)
{
    // create a rotation based on the x position
    // so that the object looks like it is twisted
    mat4 rot = rotationAroundX(position.x*6.0 * sin(time));
    
    
    viewSpaceNormal   = normalTransform * rot * vec4(normal, 1.0);
    viewSpacePosition = modelView       * rot * vec4(position, 1.0);
    
    gl_Position = modelViewProjection   * rot * vec4(position, 1.0);
}
