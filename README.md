WhatToCook is a simple sample app to experiment with a simplified version of TEA architecture.

<p>
<img src="https://github.com/coybit/WhatToCook/raw/master/Images/shots/menu.png" width="150">
<img src="https://github.com/coybit/WhatToCook/raw/master/Images/shots/search.png" width="150">
<img src="https://github.com/coybit/WhatToCook/raw/master/Images/shots/categories.png" width="150">
<img src="https://github.com/coybit/WhatToCook/raw/master/Images/shots/meals.png" width="150">
<img src="https://github.com/coybit/WhatToCook/raw/master/Images/shots/meal.png" width="150">
</p>

### Architecture
Instead of having one central store, we have a hierarchy of stores:

<img src="https://github.com/coybit/WhatToCook/raw/master/Images/hierarchy.png">

Each store comprises:
- a reducer method
- a side-effects handler method
- an immutable state object
- an environment object that carry dependencies around.

Navigator, the object that is responsible for
handling navigation is one example of dependencies we have. Each store has a custom navigator tailored based on
where user can navigate to from the part of the app the store is representing.
Each store is in charge of creating its child store.

<img src="https://github.com/coybit/WhatToCook/raw/master/Images/store.png">

The sequence diagram is quite simple:
1. The store received an event (Action) from somewhere (doesn't matter from where)
2. The store passes the event along with the current state to the reducer
3. The reducer returns a new state, plus side-effect if there is any
4. The store asks side-effect handler to handle each side-effect

<img src="https://github.com/coybit/WhatToCook/raw/master/Images/flow.png">
