# chess4player

## IDEA

## SERVER

## CLIENT

## PROTOCOL

### ROOM EVENTS

| event  | client                                                                                   | server                                                                                                      | description                     |
|--------|------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|---------------------------------|
| create | {"type": "room",   "subtype": "create",   "content": {"name": "user"}}                   | {"type": "room",   "subtype": "created",                     "content": {"code": "3UQBYM", "name": "user"}} | if name is empty ...            |
| join   | {"type": "room",   "subtype": "join",     "content": {"code": "3UQBYM", "name": "user"}} | {"type": "room",   "subtype": "joined",                      "content": {"name": "user"}}                   | if name is empty ...            |
|        |                                                                                          | {"type": "room",   "subtype": "participants-count-update",   "content": {"participants-count": 2}}          | only to the admin               |
|        |                                                                                          | {"type": "room",   "subtype": "join-failed",                 "content": {"reason": "not found"}}            | if there is no room to the code |
|        |                                                                                          | {"type": "room",   "subtype": "join-failed",                 "content": {"reason": "full"}}                 | if the room is already full     |
|        |                                                                                          | {"type": "room",   "subtype": "join-failed",                 "content": {"reason": "started"}}              | if the game has already started |
| leave  | {"type": "room","subtype": "leave", "content": {}}                                       | {"type": "room",   "subtype": "left",                        "content": {}}                                 | if participant left's           |
|        |                                                                                          | {"type": "room",   "subtype": "disbanded",                   "content": {}}                                 | if admin left's ...             |

### GAME EVENTS

| event        | client                                                                                                    | server                                                                                                                                                                                 | description |
|--------------|-----------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| start        | {"type": "game",   "subtype": "start",          "content": {"time": 60000}}                               | {"type": "game",   "subtype": "started",          "content": {"participants": ["p1", "p2", "p3", "p4"], "time": 59600}}                                                                |             |
| move         | {"type": "game",   "subtype": "move",           "content": {"move": [14, 15, 14, 16], "promotion?": "q"}} | {"type": "game",   "subtype": "moved",            "content": {"move": [14, 15, 14, 16], "promotion?": "q", "next-participant": "name", "remaining-time": 4734}}                        |             |
|              |                                                                                                           | {"type": "game",   "subtype": "move-accepted",    "content": {"remaining-time": 6534, "next-participant": "name"}}                                                                     |             |
| resign       | {"type": "game",   "subtype": "resign",         "content": {}}                                            | {"type": "game",   "subtype": "player-lost",      "content": {"participant": "name", "reason": "checkmate;resign"}}                                                                    |             |
|              |                                                                                                           | {"type": "game",   "subtype": "end",              "content": {"reason": "checkmate;stalemate;50move-rule ;out-of-time;remi;insufficient-material;resignation;draw", "winner": ["p1"]}} |             |
| draw-request | {"type": "game",   "subtype": "draw-request",   "content": {}}                                            | {"type": "game",   "subtype": "draw-requested",   "content": {"requester": "name"}}                                                                                                    |             |
| draw-accept  | {"type": "game",   "subtype": "draw-accept",    "content": {}}                                            |                                                                                                                                                                                        |             |

