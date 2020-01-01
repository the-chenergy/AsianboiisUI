
# Asianboii's (Extraordinary) UI


The latest version released: v4.0, T 12/31/19

Website for work logs: https://docs.google.com/document/d/16oO3_emKCy5HxPa0xN1-1jzKjLSycNQnF9eaEBX04Yk/edit?usp=sharing

*I created the 4.0 version in honor of earning my first 4.0 semester-GPA at the U (and to better prepare for the coming semesters, of course). This version is a complete rewrite of the previous 3.x versions; the goals of rewriting were mainly for the project's maintainability and for the difficulty of bringing in new features.*

***
### Background

In the world we live in, there exist many horrible things that we use as our daily tools. We don't change them because we know "they've always been like that," and improving requires us to learn the new ways and to reteach our offsprings, at which we're too lazy. These sub-optimal tools include the computer keyboard we're using today, which is still based on typewriters invented and used more than a century ago. It has an inefficient letter layout (the Qwerty layout), a cramped punctuation layout, and a ridiculous setup of modifier keys. These factors make typing and general uses of a keyboard unnecessarily difficult and tiring. Even though nowadays, people have invented things like mechanical key-switches and ergonomic keyboards with weird shapes, it still doesn't solve the fundamental problems brought by the layout of the keys.

Asianboii's UI is a compilation of a superior layout for letters and punctuation, along with numerous keyboard/mouse macros. It's aimed to enhance our regular PC keyboard layout, making it more comfortable and convenient to use. The program is designed to be portable and can run on most Windows machines. It can also be easily "toggled-off" when using the PC in collaboration with other people who are ordinary enough to only know the regular layouts.

***
### Keyboard Layout

![The default Asianboii's UI layout](https://github.com/asianboii-chen/AsianboiisUI/blob/master/4.0/Layout-4.0-Default.png)

The letter layout of the Asianboii's UI is mostly based on the [Simplified Dvorak Layout](https://en.wikipedia.org/wiki/Dvorak_keyboard_layout) with one major modification: the locations of the 'I' and 'U' keys are swapped. I've been using Dvorak since as early as I started learning English (I came to the US as a high school sophomore in fall 2015), and for the most part, I've never been inconvenienced by using a different layout than everyone else. I've loved it since I first knew of it and learned it. The swapped 'I' and 'U' keys took me a while to relearn and getting used to, but after the learning curve, I noticed a significant improvement in comfort when typing.

I also put plenty of time and effort into designing the punctuation layout. Inspired by the [Programmer Dvorak Layout](https://www.kaufmann.no/roland/dvorak/) and that punctuation marks are more often used in programming, I designed my layout with the most used punctuation marks taking over the number row, which are better reached by longer fingers (fingers other than pinkies).

Keyboard shortcuts are very commonly used during programming, and it requires using the modifier keys (Ctrl, Alt, etc.). Using the modifiers on a regular keyboard is a nightmare in that one must keep the modifiers held while reaching out for another key to produce a "key-chord." This feature usually cramps one's hands into uncomfortable shapes, causing fatigue overtime. To solve this issue, I made the functionality of "sticky modifier keys" and included it in the 4.0 version. It gives me the option to press a keyboard shortcut by tapping keys in a sequence, which is much more comfortable to do. I also relocated some modifiers, such as the Ctrl and Shift keys. The Shift key is the most used modifier, so it deserved to be pressed by the strongest fingers—the thumbs. The Ctrl keys are moved to locations easier for pinkies to reach, and they're out of the way for the newly added Fn keys, which are more suited as palm-keys. Moreover, the Asianboii's UI automatically switches back to the Qwerty layout when any modifiers (other than Shift) are held down since all keyboard shortcuts are designed assuming a Qwerty layout, which is easier to use then they are on Dvorak.

![The "toggled" layout (activated by holding down Tab key or by using toggle-lock/suspension key)](https://github.com/asianboii-chen/AsianboiisUI/blob/master/4.0/Layout-4.0-Toggled.png)

***
### Keyboard and Mouse Macros

![](https://github.com/asianboii-chen/AsianboiisUI/blob/master/4.0/Layout-4.0-Functions.png)
![](https://github.com/asianboii-chen/AsianboiisUI/blob/master/4.0/Layout-4.0-SpecChars.png)

Keyboard and mouse macros make up another crucial part of the Asianboii's UI. The keyboard macros are generally aimed to reduce hand movements while focused on typing, such as the onboard arrow keys and mouse function keys. These keyboard macros are triggered by holding down either of the Asianboii-introduced Fn keys, which are located on or near the bottom corners of the keyboard. I designed the Fn keys to be directly under my pinky-side palms while typing, so I can easily hold them using my palms. These keyboard macros can also be automatically converted into emacs/vim shortcuts, which can provide convenient support while programming in PuTTY.

The mouse macros come in the form of gestures, which are drawn while holding down the right button. Similar to the goals of the keyboard macros, the mouse gestures are created to help reduce hand movements while using only the mouse, by providing shortcuts of some of the most commonly used navigating and editing functions. They're so intuitive and simple that I'm amazed that the operating system doesn't include them natively already.

***
### Configuration Settings File

Since the Asianboii's UI was made to be portable, it should be easily set up to fit keyboards with different physical layouts. For example, when using the Asianboii's UI on a MacBook running Boot Camp, it would be useful to be able to swap the Alt and Command keys, making it more similar to a Windows layout. The physical layout near the bottom-right corner might also be different depending on the keyboard and whether it's on a laptop. The configuration file provides the option to relocate some virtual modifier keys, such as Control and Fn on the right-half of the keyboard.

I also made it possible to turn some features on or off while the Asianboii's UI is running. For example, it might be helpful to turn off the scroll-acceleration feature while gaming or using programs like Photoshop. It would also be very handy to have a way to temporarily suspend the Asianboii's UI during pair-programming. These customizations of functions can be accessed via the tray menu or some simple Fn-shortcuts.

***
### Publishing

It's fairly challenging to introduce the Asianboii's UI to the Internet given that the program was purely designed by and *for* me. So far, none of my friends have tried using it for longer than two minutes. As I mentioned, the world is lazy to have something changed, especially when that "something" means breaking a tradition and rewriting history. However, with all of that said, I've thought of ways of bringing the Asianboii's UI .to the public: maybe make a Qwerty version of the Asianboii's UI, or maybe make a graphical designer of the layouts and macros. These are two of the things that may compromise with people's laziness when forced to learn new things, and I'll consider making a step towards that direction if given more free time than just a short winter break.

*If you're a true fan who read through the whole thing and is still here, go ahead and shoot me an email with the word "Orange," or send me a message on any social media or whatever. Also if you'd like to, give me an idea of how you're doing, how I'm doing, and what you want to see me do next. Thanks!*

Qianlang
