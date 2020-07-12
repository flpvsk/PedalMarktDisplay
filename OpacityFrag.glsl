#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float fraction;

varying vec4 vertColor;

void main() {
  gl_FragColor = vec4(vertColor, 0.1);
}
