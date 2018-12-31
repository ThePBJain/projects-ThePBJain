#  Model Vision
This is Model Vision. 
Run on two devices, First device that starts will be master, any lines it draws should be shown on secondary device.


## Environment to Run
1. Make sure to have 2 devices that can run ARKit on iOS 12 or later
1. Runs better in a bright environment (with tables and chairs to see occlusion and physics)
1. Make sure the devices are on the same wifi network (or both on no network) and bluetooth is on
1. You may have to change the signing certificate for the app as I used a weird one.

## Actions to Do
- Move device around to map surroundings to generate planes (flat surfaces) on both devices
- Map floor as well
- When share button is enabled, press it (should see message on top left when successfully shared)
- Tap on a plane (any flat surface on screen) and you should see a red box appear (should also appear on other device if pressed share button before)
- Should also see boxes move around and fall if not on a plane/surface. (May see boxes "fall out of the world" if you haven't fully mapped area)
-  Hold on the draw button. If previously shared, red lines should show up on both devices in the appropriate area
-  Press the "Use Other" button. Now when you tap on screen it will load an X-wing model from the internet, paint it red and let it slowly float down away. This will occur in the direction of when you first run the app as loading models through the internet did not work properly as normal objects did. 
- The button should now say "Use Box", if you press on that, it will go back to placing red boxes around the playing field.
- Look around with the lines and the boxes. You'll see that at the right angle, the boxes and lines get hidden by the planes (which represents the surface under it) because of occlusion


## Notes:
- Once objects are placed, their physics is independent of devices. I.e each device processes the physics that happens on the object by itself. Therefore it is possible for objects to drift away or even diappear on certain devices.
