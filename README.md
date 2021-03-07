# love3d
Proof of concept exploring the third dimension and the marching cubes algorithm. 

## Controls 

W A S D - to move camera in X and Z

ARROW KEYS - to rotate camera in X and Y

## On the horizon:
So, I need to improve performance

One dumb idea is to:

1) somehow pass 3D triangles as image data
2) project them in a shader
3) somehow return the 2D triangles as image data
4) draw image on seperate canvas
5) read color values of that canvas as 2D triangles
6) draw those triangles on screen

This is somehow faster??

I would also like to add some kind of pill to tringle collision

and a way to remove and place terrain