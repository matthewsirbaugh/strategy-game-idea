# Bugs

Bryson's bug reports that haven't been fixed yet. An entry leaves this file when its fix is
committed. A bug an agent finds is fixed on the spot, or explained to Bryson, who decides whether
it's filed here.

### B1. The camera gets stuck on the last unit to move (2026-10-28)

- Happens: since the drone and the dog could be deployed, the camera stays where the last unit
  moved and won't move at all. The next unit to act has to be clicked where it sits in that frame,
  and it can only move to tiles visible from there.
- Should: each turn, the camera goes to the unit whose turn it is, and the player can always pan.
- Notes: not reproduced yet. Scripted runs on the facility yard deployed the drone and the dog
  through the menu and played six turns; the camera followed each move and drags and keys panned.
  Needs Bryson's steps.
