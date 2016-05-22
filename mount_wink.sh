#!/bin/sh

# Mount wink drives

#staff - winkops1:/export/home6/staff
mount winkops1:/export/home6/staff /staff

# dagobah/projects - winkops1:/export/home7/eng
mount winkops1:/export/home7/eng /dagobah/projects

# mount chewie (for some people's staff dirs)
mount chewie:/kenobi /rn/chewie/kenobi
mount chewie:/tools /rn/chewie/tools
mount chewie:/chewie /rn/chewie/chewie
mount chewie:/cartman /rn/chewie/cartman

# NOTE: can not mount chewie like this and the above directories!!
#mount chewie:/ /rn/chewie

