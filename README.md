# Tranquil
*Tranquil* is a Live Coding environment for the Macintosh. It uses Lua as it's language. It is still in **extremely** early development and at this stage will not be anything more than amusing to anyone except those who want to help with it's development.

### Example 
If you want to try it out you can test the following code:

```lua
scene:clear() -- Deletes all objects in the scene when the script is run
c = buildCube() -- Creates a cube primitive and adds it to the scene
everyFrame(function() -- Runs the passed block after redraw
  withPrimitive(c, function() -- Sets the active primitive to c
    rotate(0.05, vec3(0.3,1,0)) -- Applies a rotation to the transform of the current state
  end)
end)
```

And press ⌘+R. You should end up with a rotating cube (You can spin it around by dragging the mouse).

I also post occasional videos/screenshots to [http://fjolnir.asgeirsson.is/tranquil/](http://fjolnir.asgeirsson.is/tranquil/) which, due to the nature of the application also include the source code for themselves.

### Plugins

Tranquil is implemented as a tiny core application which then relies on plugin to provide all it's functionality. Currently the following are included:

* Graphics – Provides methods to draw primitive 3 dimensional shapes.
* Audio – A spectral analyzer.
* MIDI – A MIDI clock that synchronizes with an external clock source.


The inspiration for this project was a fantastic application called [Fluxus](http://www.pawfal.org/fluxus/).
