A hamburger menu button for the Emacs mode line.  Use instead of
`menu-bar-mode' to save vertical space.

## Installation

Add the [MELPA](https://melpa.org/) repository to Emacs.  Then run:

    M-x package-install hamburger-menu

Afterwards, configure as follows:

    M-x customize-set-variable RET global-hamburger-menu-mode RET y
    M-x customize-set-variable RET menu-bar-mode RET n
    M-x customize-save-customized
