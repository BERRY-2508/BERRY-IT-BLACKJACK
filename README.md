# BERRY IT Blackjack

A free Blackjack game with virtual chips and BERRY IT branding.

## New: Windows desktop GUI

The graphical edition lives in [BERRY-IT-BLACKJACK-GUI.ps1](BERRY-IT-BLACKJACK-GUI.ps1). It opens a native Windows Forms window with card displays, Deal / Hit / Stand controls, adjustable bets, balance tracking, and a bankroll reset.

**Requirements:** Windows PowerShell 5.1 on Windows with a graphical desktop. The GUI does not run in the Linux PowerShell terminal.

### Run locally

Download the GUI script from this repository, then open Windows PowerShell in that folder:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\BERRY-IT-BLACKJACK-GUI.ps1
```

Only run scripts you trust and have reviewed. No administrator privileges are required.

The GUI is an initial version and has not yet been interactively tested on Windows. It implements the core Blackjack game (dealer stands on 17, natural Blackjack pays 3:2, draws push). It starts with 100 virtual chips and uses bets in multiples of five. **There is no real-money gambling.** The original terminal game includes its own loan feature; that feature has not yet been ported to the GUI.

## Original terminal version

The existing [BERRY-IT-BLACKJACK.ps1](BERRY-IT-BLACKJACK.ps1) is preserved, including its existing betting/loan game flow. The existing website launch command continues to use that version.
