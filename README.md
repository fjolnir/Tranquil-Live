# Tranquil
*Tranquil* is a LiveCoding environment for Mac. It uses Ruby as it's language (MacRuby to be precise). It is still in **extremely** early development and at this stage will not be anything more amusing to anyone except those who want to help with it's development.

### Example 
If you want to try it out you can test the following code:

```ruby
@scene.clear # Deletes all objects in the scene when the script is run
b = buildCube # Creates a cube primitive and adds it to the scene
everyFrame do # Runs the passed block after redraw
  withState b.state do # Sets the block's state object as the current on
    rotate(0.05, vec3(0,1,0)) # Applies a rotation to the transform of the current state
  end
end
```

And press ⌘+R. You should end up with a rotating cube (You can spin it around by dragging the mouse).
			

The inspiration for this project was a fantastic tool called [Fluxus](http://www.pawfal.org/fluxus/).