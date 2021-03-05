# love3d
So, I need to improve performance

One dumb idea is to:

1) somehow pass 3D triangles as image data
2) project them in a shader
3) somehow return the 2D triangles as image data
4) draw image on seperate canvas
5) read color values of that canvas as 2D triangles
6) draw those triangles on screen

This is somehow faster??