# find-the-tetris-in-bitmap-mips
My first experience programming in a low-level language. (march 2017)

For the MIPS architechture I had to program in assembly to achieve the following.

A project in which I had to generate a 11x11 bitmap with the possibility to be more 0'esque or 1'esque but with randomness. 
* «1», in the bitmap, represents a piece or part of a piece
* «0» means nothing or emptiness

A piece could be like the ones from the Tetris game and were assigned by the teacher - I got an E without the middle trace, in a 2x3 bitmap would be like this:

<p align="center">
011<br>
010<br>
011
</p>

After generating the random bitmap I had to verify if my piece or the rotation of itself was present and print it to the console stating the result.

You can run the file by downloading the [MARS MIPS simulator](https://courses.missouristate.edu/KenVollmar/MARS/download.htm).


<h2 align="center"> Output </h3>
<p align="center">

  <img alt="mips application" src="https://github.com/fbkz/find-the-tetris-in-bitmap-mips/blob/master/found.png">
</p>
