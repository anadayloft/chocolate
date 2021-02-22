# Chocolate

A game about trying to eat your favourite chocolates from a shared box

by @anadayloft for #LoveJam2021


## Gameplay

- Eat lots of chocolates.

- Some chocolates are preferred (simulated palate!)

- If you eat no favourites, your score will be 0. This is bad.

- Try to get a big score!

## Some of my highscores, so you can beat them too

- 60 Chocolate Box: 63496

- 32 Chocolate Box: 22320

- 24 Chocolate Box: 13410

- 16 Chocolate Box: 5219

- 8 Chocolate Box: 463

## Tips

- More points for eating a chocolate of your favourite color if you have already eaten
more of that color.

- Your favourite filling will give points based on how many chocolates have been eaten so far.

- Decorations lose appeal as you eat more chocolates.

- I'm sorry, but you will not get the last chocolate.

## Controls


### While playing: 

- Left mouse click on a chocolate to eat it.

- Wait for your turn.

### While scoring:

- Press "enter" to continue to a new box.

- If scoring hasn't finished yet, some score may be carried over to a new box by pressing
enter. However, scoring that hasn't finished is not eligible for high scores.

### Any time:

- Press "b" to start a new box of chocolates, discarding the previous (randomly generated)
- Press "p" to reset your palate, potentially changing your favourites (randomly generated)

## Todo:

- ~~Occasional invalid sorting function error~~

- ~~Score sorting fuzz lines bug~~

- ~~box generation symmetry~~

- ~~add scorable component for eaten chocolates~~
- ~~display score in top left corner~~

- ~~limit chocolate combos, no milk with peanut butter, etc, for visual reasons~~
- ~~chocolates need names!~~

- ~~save and display highscores for boxes of similar size~~

- ~~add a few more fillings and decos~~

- ~~revist scoring~~

- ~~bonuses for trying every color, all fillings, many of one type, every shape of a color~~

- package and ship an alpha version!

## Planned:

- ~~Randomly generate boxes of chocolates, of different sizes and with different types.~~

- ~~Learn about a chocolate type's name and scoring only after completing a box that~~
~~contained one of it's type.~~

- ~~3x3 chocolate box intro/tutorial~~, ~~with three types is randomly selected to be the~~
~~player's favourite.~~

- Layered boxes, with second layer obscured until first is finished, etc

- replace random opponent selection with another palate to base selection on
- switch opponents/palates between boxes

- ~~Modular chocolates: shape, filling, deco can be recombined, each have some scoring~~
~~effects, but filling is most important (and least visible!)~~

### Chocolates
- White chocolate cranberry
- Milk chocolate orange
- Espresso bean
- Raspberry

## Notes:

### Theme: Chocolate

- Chocolates come in boxes with chocolate shaped divisions and a diagram underneath
which lets you know what's what.

- ~~All chocolates should always be eaten, but—*obviously*—there's a strategy involved~~
~~in how one selects the chocolate they'll eat next. What happens when you don't eat them~~
~~by an optimal strategy? Well, someone else probably gets some. Maybe you don't get any of~~
~~some type. Maybe you miss out on your favourite.~~

- ~~Everyone has a favourite chocolate, which is worth more to them than most other chocolates.~~

- Sometimes, your favourite might change. It happens. What can you do.

- ~~Not getting your favourite is definitely a loss. But eating it too soon is definitely~~
~~sub-optimal too. They should be savoured, and appreciated by comparison to as many other~~
~~types as possible.~~

- Strategy may change depending on how many people are sharing a box of chocolates.

### Design:

- ~~Is multiplayer too hard to do for a game jam? Yes, yes it is.~~

- ~~Going to try [Concord](https://github.com/Tjakka5/Concord) as an ECS, because I want~~
~~to learn about ECS for other projects.~~

- ~~I need to make the assets, so let's keep them simple. Probably no animations.~~

- ~~Scoring should be excessively complex~~, ~~and—ideally—visually performed for the player~~
~~so that they can get a feel for it.~~
