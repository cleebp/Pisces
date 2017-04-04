# Pisces

![header](https://github.com/cleebp/Pisces/blob/master/resources/pisces_screen.png)

Pisces is a generative art piece built in [Processing](https://processing.org/). Pisces combines multiple artificial intelligence (AI) path-finding algorithms such as wandering, flocking, and seeking, to produce a procedurally generated AI simulation that is unique each time. 

The setting is the ocean, and there are three different kinds of AI agents: a school of fish, a shark, and dolphins. When the simulation begins, a number of fish are created in varying shades of blue, and of these fish some are chosen to be leader fish. Leader fish wander the screen with no goal, while the remaining fish flock to the nearest leader. Every 20 seconds the leader fish become regular fish, and new leader fish are chosen. Additionally, the simulation begins with a single red shark, Bruce, who chases leader fish. Because Bruce is slower than fish he will never catch one, but all fish must stay away from him, though some are braver than others. Every 20 seconds Bruce follows a new leader. Once Bruce has been alive for 2 minutes, a group of pink dolphins enter the ocean and scare Bruce away. Once Bruce has been away for 2 minutes he returns, and our simulation continues as such forever.

## Display requirements

Pisces is designed and coded to be displayed on the [Hunt Library display walls]((https://github.com/NCSU-Libraries/visualization_templates/blob/master/HuntLibraryVideoWallGuide.md) (commons, art wall, and immersion). As such if you run Pisces on a different display the sketch will most likely display incorrectly. There is a running condition that is designed to run on a MacBook display (1440x900), this is the default condition for displays that do not have the same display width as the library walls.

## Software requirements and how to run

Pisces is built in [Processing 3](https://processing.org/), the main sketch file is `source.pde`, open this in Processing and the helper classes should be opened as well. 

To run Pisces on Windows/Mac simply run the `source.exe`, or `source.app` located inside the respective application folders. 

Additionally, if you create new executable versions of Pisces, make sure to include the banner images `info_*.png` in the root application directory or the application will not run.

## Code+Art

Pisces was built as a submission entry to the [2017 NCSU Code+Art Visualization contest](https://www.lib.ncsu.edu/codeart).

## License

This code is protected under the MIT Open Source License, see LICENSE.md for more information.
