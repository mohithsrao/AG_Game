# Manual Testing Checklist: Player Double Jump

This document covers testing scenarios that cannot be fully automated.

## 1. Game Feel & Floatiness (Human Review)
- [ ] Verify if the transition velocity feels natural or if it requires tweaking the gravity.
- [ ] Verify that double jumping at the peak of a regular jump versus on the descent gives appropriate control.

## 2. Visual VFX Verification
- [ ] Verify that the dust particle effect spawns exactly at the feet position during the second jump frame.
- [ ] Check if particle count, color, and lifetime mesh well with the game's overall aesthetic.

## 3. Audio SFX Verification
- [ ] Listen to the swoosh audio level. Ensure it's not louder than the primary jump audio.
- [ ] Check if the audio pitch shifts slightly upwards to differentiate it from a normal jump.
