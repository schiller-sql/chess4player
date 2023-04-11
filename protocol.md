# Web-socket protocol of chess4player v1.3.0

## Connection to the server

A client should be always connected to a server,
but it can also switch between different servers.

On the server the web-socket
does not have to be found on a specific path or port.
A chess4player endpoint is defined
by the complete url to the web-socket.

### Pings

The client can send regular pings to check,
if the connection is still active.
As an example, the flutter client sends
a ping every 300 milliseconds

## Generals to the protocol

This section details what the server and client handle,
but does not detail the concrete syntax of the protocol.

### Rooms

To be in a game, one first needs to be in a room,
max. 4 people can be in a room,
all these people could then be in a game.

Per default, when the connection is established,
the client is not in a room.
The client can then create a room and be its admin;
or join a room via a 6 character alpha-numeric code.
In a room the admin can start a 4 player chess game,
if there are (including the admin),
at least two people in the room.

The room can not be joined if:
- 4 people are already in the room
- the game has already started
- The room with the id provided by the client does not exist

Room operations overwrite game operations,
this means a room can be left, even if in a game.
However, to join a room,
the current has to be first left.

### Room admins

The room admin of a room is constant and cannot be changed,
if a room is left by the admin, the room disbands,
and all people will be kicked.

The room admin is the only person in the room,
that can start a game,
it is also the only person in the room that keeps track of
how many people are inside of the room,
which is necessary as the room can only be started,
if at least two people are in it.

To start a game, the room admin can provide a duration,
for the time of each player,
this can however be rejected by the server,
as the server sends the time to everybody
and can send a different one [(see: games)](#games).
No standardized rules exist on the time,
but servers should probably implement time limits.

Other settings may also be added in the future.

### Games

#### Start

After the admin has sent the start command,
to all players (including the admin),
the start event is given, this includes the player order
and time.

The player order gives all names in a list,
to show where the players are located clockwise.
The first player is located at the start of the list.

After the client receives this event,
the game should be considered as started,
as the time for the first player is now running.

This means it is the turn of the first player.
If it is a players turn,
they have to issue a move command, or resign.

#### Game update event

After a players turn,
the server issues a game update event,
which contains:

- if any players have lost, as a list of lost players
- if the game has ended
- the remaining time of the player whose turn has ended,
  to sync the time of server and clients
- the move of the player if the player has moved a piece.

If the players time has run out the remaining time will be 0,
they will made no move,
they will be in the list of lost players
and depending on if they were the second last player,
the game will have ended.

If a person resigns (or leaves the room) while its their turn,
the remaining time will be the time
when they have resigned (from the servers perspective),

All people after the player that have gone checkmate,
will also be put into the lost players list.

Because web-socket events always arrive in order,
the server expects the client to always know whose turn it is
after a game event.

If the game has ended after a game event,
all players still in the game are considered winners.

#### Resignation out of turn

If somebody resigns (or leaves the room),
while its not their turn,
a separate event will be sent detailing only this resign.

If however this resign causes a game end,
because the player that resigned was the second last,
a game update event will be sent,
detailing the remaining time of the player whose turn it is,
the game end cause
and the resigning player in the lost players list.

If the resigning player was not the last however,
their resign does not count after the current turn is ended.

Example:
- player A, B, C, and D are in a game.
- it is player A's turn
- C resigns while it is still player A's turn
- player A can still not move their pawn, as it blocks 


#### Draw requesting and accepting

A player can also request a draw,
which will be sent to all players,
with the name of the player that has requested.

However no requesting is necessary to draw the game,
if all players remaining in the game,
have at some point accepted the accepted the draw,
the game ends.
A person that has requested has already accepted a draw.

Draw requests are only sent to players who have not lost.

#### Invalid moves

If a move is invalid because it violates chess rules,
the player will be disconnected and resigns for all other player.

If the player makes a move while it is not his turn,
this is just ignored,
this can happen if client and server out not in sync from their time.
This means the client cannot rely on their move actually be accepted by the server.
Another way the server might ignore a clients move
if a draw or game end happened shortly before.

### Chessboard and rules

A standard 4 player chess board,
with the king always on the right side from each players perspective.
The first player is at the bottom.
The coordinates system has 0|0 at the top right,
between the second and third player,
and 13|13 and the bottom left,
between the first and fourth player.

The coordinates given to the players are all the same,
which means they have to be rotated around by the players clients,
to display the chess board from their perspective.

A promotion happens after a pawn crossed over the middle,
the command with which the player moves the pawn,
has to also contain the promotion.

If a chess game ends and who has won,
is not standardized instead the server
can give any message on a game end,
instead the server can give any message on a game end.

### Names

A name can only be suggested by the client.
It is up to the server to give each client a unique name
and to enforce naming rules.
There are no standardized naming rules,
which means they can vary from server to server.

### Code

The code is six long and is given to the creator of the room,
it is their responsibility to give this code other people,
so they can join.

The code is alpha-numeric and case insensitive.

### Errors

Non-expected errors of the client
(such as an invalid chess move) can
result in a disconnection by the server,
non-expected errors will not be explained to client via protocol.

Example of an expected error, would a joining room exception.

## General syntax

This section details the exact syntax of the protocol.

The protocol consists of a json object sent as text in as
per [web-socket rfc](https://www.rfc-editor.org/rfc/rfc6455#section-5.6).

This json object always contains four keys for server events and three for client commands:

| For client commands | key              | json-type        | description                                                                                                                                                                                                 |
|:--------------------|------------------|------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ❌                   | `control-number` | integer (number) | The number of which event by the server this is, the first number is 0. Should be used against package loss, if one number is skipped, the client should disconnect itself, as it is not completely update. |
| ☑️                  | `type`           | string           | Which type of command/event, can either be `"room"` or `"game"`                                                                                                                                             |
| ☑️                  | `subtype`        | string           | Which subtype command/event, the full list is to be found below.                                                                                                                                            |
| ☑️                  | `content`        | json-object      | The content which is unique to the type and subtype.                                                                                                                                                        |

## Commands:

# `room`

### `join`

Join a room via code.

Content: 

| Key    | Type   | Description                                                                                |
|--------|--------|--------------------------------------------------------------------------------------------|
| `code` | string | A code provided by the client, does not have to be 6 long, but all valid codes are 6 long. |
| `name` | string | Name suggestion to the server in the room.                                                 |

### `create`

Create a room and be its admin.

Content:

| Key    | Type   | Description                                                                                |
|--------|--------|--------------------------------------------------------------------------------------------|
| `name` | string | Name suggestion to the server in the room.                                                 |

### `leave`

Leave a room. Can only be done, when the client is in a room.
Because of latency however,
this will not disconnect if a client is not a room.

Content: -

# `game`

### `start`

Start the game, can only be done if admin
and there are at least two people in the room.

Content:

| Key    | Type    | Description                                                              |
|--------|---------|--------------------------------------------------------------------------|
| `time` | integer | A suggestion to the server how long the time should be, in milliseconds. |

### `move`

Move a piece with optional promotion or castle in a game.
Invalid moves will result in a disconnect,
a move done by a player that is not on their turn is ignored.

Content:

| Key         | Type                         | Description                                                                                                                          |
|-------------|------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| `move`      | Array of int with four items | Contains the coordinates for the chess move in the format `[fromX, fromY, toX, toY]`                                                 |
| `promotion` | string?                      | If the move requires a promotion, this has to be given here. `"n"` for knight, `"q"` for queen, `"b"` for bishop and `"r"` for rook. |

### `resign`

Resign in a game.

| Key         | Type                         | Description                                                                                                                          |
|-------------|------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| `move`      | Array of int with four items | Contains the coordinates for the chess move in the format `[fromX, fromY, toX, toY]`                                                 |

### `draw-request`

Ask all players for a [draw-accept](#draw-accept)
and submit a [draw-accept](#draw-accept) yourself.

If the player is already out, this will be ignored.

Content: -

### `draw-accept`

Accept the draw,
if a player is already out,
this is ignored.

Content: -

## Events:

# `room`

### `joined`

When the player has joined a room and is not the admin.

Content:

| Key    | Type   | Description                                                                                     |
|--------|--------|-------------------------------------------------------------------------------------------------|
| `name` | string | The unique name given to the player, over which he is now identified in the room and its games. |

### `join-failed`

When the player could not join a room and what the reason was.

Content:

| Key      | Type   | Description                                                                                          |
|----------|--------|------------------------------------------------------------------------------------------------------|
| `reason` | string | The reason why the room could not be joined. Can be either: `"full"`, `"started"`, or `"not found"`. |

### `created`

When the player has created and joined a room and is the admin.

Content:

| Key    | Type   | Description                                                                                         |
|--------|--------|-----------------------------------------------------------------------------------------------------|
| `name` | string | The unique name given to the player, over which they are now identified in the room and its games.  |
| `code` | string | The unique code given to the newly created room, over which the room is identifiable and join-able. |

### `left`

The client has successfully left a room and can now join a different one.

Content: -

### `disbanded`

When the room the participant is currently in, has been left by the admin, and is disbanded.

Content: -

### `participants-count-update`

Only sent to the room creator, the admin.

The number of people in the room has changed,
will not be sent after the admin joins the room,
as when the admin joins the room, the number of people will always be 1,
as he is the creator. Will also be sent while in a game, if somebody leaves the room. This

Content:

| Key                  | Type     | Description                                     |
|----------------------|----------|-------------------------------------------------|
| `participants-count` | integer  | The current number of participants in the game. |

# `game`

### `started`

The game has started and the time is running for the first player.

Content

| Key            | Type                                      | Description                                                                                                     |
|----------------|-------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| `time`         | integer                                   | The current number of participants in the game.                                                                 |
| `participants` | Array of string? (always has length of 4) | The player names in order, from lower, left, top, and right position, if no player is at a position it is null. |

### `draw-requested`

If somebody has requested a draw [(see: draw-request)](#draw-request).

Content:

| Key         | Type   | Description                           |
|-------------|--------|---------------------------------------|
| `requester` | string | The person that has requested a draw. |

### `player-resigned`

If a player (including the client) has resigned while not in turn.
Also given if a player leaves the room while not in turn.

Content:

| Key           | Type   | Description                                                                            |
|---------------|--------|----------------------------------------------------------------------------------------|
| `participant` | string | The name of the participant, who has resigned and maybe disconnected or left the room. |

### `game-update`

End of a turn and possible game end.

Content:

| Key        | Type           | Description                                                                                                          |
|------------|----------------|----------------------------------------------------------------------------------------------------------------------|
| `game-end` | string?        | If the game has not ended: `null`. If the game has ended a string containing the reason why the game was ended.      |
| `turns`    | Array of turns | All turns that have happened in the order of the participants (always at least one, can be multiple with pre-moves). |

Turn:

| Key                 | Type                               | Description                                                                                                                                                                 |
|---------------------|------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `remaining-time`    | integer                            | The remaining time of the participant whose turn it is, in milliseconds.                                                                                                    |
| `move`              | Move or null                       | The move of a player can be null, if the player did not have a chance to make a move before the game ended.                                                                 |
| `lost-participants` | Object with string keys and values | All participants that have lost as keys, important to whose turn it is now. As the value is why the player has lost, can be either `remi`, `checkmate`, `resign`, or `time` |

Move:

| Key         | Type                         | Description                                                                                                                          |
|-------------|------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| `move`      | Array of int with four items | Contains the coordinates for the chess move in the format `[fromX, fromY, toX, toY]`                                                 |
| `promotion` | string?                      | If the move requires a promotion, this has to be given here. `"n"` for knight, `"q"` for queen, `"b"` for bishop and `"r"` for rook. |
