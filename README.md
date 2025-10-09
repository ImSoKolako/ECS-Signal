# ECS-Signal
A relatively quick Signal "library".
It is not intended for public use and mainly shows my point of view on Signal pseudo class.
The code explained by commentaries (I think).

Contains:
# Signal object :
Connect : (callback) -> Connection --Links a callback to a Signal. Returns connection object.

Fire : (...:any) -> () --Fires a signal, running every linked callback.

NativeFire : (...any) -> () --Fires every linked callback in synchronous way: yield functions will make it less efficient.

StaticConnect : (callback) -> () --Links a callback to a Signal. This callback can not be disconnected.

# Connection object:
Disconnect : () -> () --Disconnects a connection.

# Pros:
Quick thread pool;

Quick Fire and Connect functions;

Uses arrays and ECS;

# Cons:
Works badly with yielding functions (task.wait, wait and coroutine.yield);

This is very basic Signal template;

Memory consumption might be heavy;

Will not give you types in callback functions.
