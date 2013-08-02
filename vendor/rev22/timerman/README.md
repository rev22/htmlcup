timerman
========

Simple Javascript timers manager.

Simple usage:
```coffeescript
tmm = timerman(window)
window.setTimeout(myfunction, delay)
window.setInterval(myfunction, delay)
tmm.clearAllTimeouts()
tmm.clearAllIntervals()
```

```timerman``` was coded for you by Michele Bini; you can read MIT-LICENSE for licensing details and about the absence of a warranty.
