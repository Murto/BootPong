# Bong

Bong is a simple 2 player pong game written entirely in x86 assembly using the NASM instruction set.

Bong is designed to be run in real mode from the bootsector of a drive. It includes padding and a valid boot signature so it requires no action from the user apart from building, (optionally) installing an emulator capable of booting into bong and getting someone else to play with you (this is not necessary but is advised).

To build bong you will need to have [NASM](http://www.nasm.us/) installed.


#### Building Bong

*Linux*
~~~
nasm -f bin -o bong bong.asm
~~~

To run bong you will need to store it on a drive or use an emulator. I suggest [QEMU](http://wiki.qemu.org/Main_Page), as it is what I used when developing bong.


#### Running in QEMU

~~~
qemu-system-i386 bong
~~~


#### Playing Bong

*Instructions*

Bong starts as soon as it is boot into. The ball with start on the left and bounce off to the right to start with. Move the your bat in front of the ball to deflect it back at your opponent. As the ball is deflected off of the bats it will move faster and faster; this is to prevent stalemates because of slow ball speed (or skilled participants).


*Win condition*

The winner is whoever does not let the ball go past his bat. When the ball goes past the bat the game ends with text displayed to indicate the winner.


*Control Scheme*

left bat up		-	w
left bat down	-	s

right bat up	-	i
right bat down	-	k


#### Future Development

In the future the following may be implemented depending on free time
- Make screen update only when a change has happened
- Make ball move in more ways than diagonally
- Add score instead of instant win/lose

#### License

Bong uses the MIT License.

See [LICENSE](https://gitgud.io/MurtoTheRay/bong/blob/master/LICENSE) or [this](https://opensource.org/licenses/MIT) for more information.
