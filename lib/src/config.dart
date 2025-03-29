// This game will be 820 pixels wide and 1600 pixels high.
// The game area scales to fit the window in which it is displayed,
// but all the components added to the screen conform to this
// height and width.
const gameWidth = 820.0;
const gameHeight = 1600.0;

const ballRadius = gameWidth * 0.02;

const batWidth = gameWidth * 0.2;
const batHeight = ballRadius * 2;

// To interact with the ball in this game, the player can drag the
// bat with the mouse or finger, depending on the platform, or use
// the keyboard. The batStep constant configures how far the bat
// steps for each left or right arrow key press.
const batStep = gameWidth * 0.05;
