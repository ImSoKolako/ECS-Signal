--!optimize 2
--!strict
local module = {};
--No more automatized job :sob:
export type Signal<T...> = {
	Connect : (Signal<T...>,callback : (T...)->())->Connection;
	Fire : (Signal<T...>,T...)->();
	StaticConnect : (Signal<T...>,callback : (T...)->())->();
	NativeFire : (Signal<T...>,T...)->();
}
export type Connection = typeof({Disconnect = function(self : Connection) return nil end})

--An ECS basis
local cons : {{Connection}} = {};
local funcs  : {{()->()}}= {};


module.__index = module;


--A basic thread reusing. Pretty much more than enough for most games (unless you're making something unintendally hard)
local freethr : thread? = nil;
local function Run(f,... : any)
	local thr = freethr;
	freethr = nil
	xpcall(f,warn,...)
	freethr = thr
end

local function NewHandler()
	freethr = coroutine.running()
	while true do
		Run(coroutine.yield())
	end
end

local cons = {}
cons.__index = cons

--Disconnects a connection.
function cons.Disconnect(self)
	local i = self[1]
	local at = self[2][1]
	local funcs = funcs[at]
	local cons = cons[at]
	local deletedcon = table.remove(cons) :: {number}
	local deletedfu = table.remove(funcs)
	if deletedcon~=self then
		funcs[i] = deletedfu
		cons[i] = deletedcon
		deletedcon[1]=i
	end
end

--registers a connection and returns it.
function module.Connect(self,callback : (...any)->()) : Connection
	local i = self[1]
	local at = #funcs+1
	funcs[i][at] = callback
	local con = setmetatable({at,self},cons)
	cons[i][#cons+1] = con
	return con :: Connection
end

--Does not register connection, meaning you would not be able to disconnect it, this making it around 3x times faster than regular connect.
function module.StaticConnect(self, callback : (...any)->())
	local funcs = funcs[self[1]]
	table.insert(funcs,callback)
end

--Fires all binded functions to signal.
function module.Fire(self,...:any)
	local func = funcs[self[1]]
	for id,callback in func do
		if not freethr then
			coroutine.resume(coroutine.create(NewHandler))
		end
		coroutine.resume(freethr :: thread,callback,...)
	end
end

--Fires all binded functions to signal.
--It assumes that no functions linked to signal have a yielding code. And it can grant up to 7x speed boost if used correctly.
function module.NativeFire(self,...)
	local func = funcs[self[1]]
	for id,callback in func do
		xpcall(callback,warn,...)
	end
end

--For types you should type them explicitly as example:
--local SignalObject : ECSSignal.Signal<type> = ECSSignal()
return function(sizeAlloc : number?) : Signal<...any>
	local i = #cons+1
	local s = setmetatable({i},module) :: Signal<...any>

	cons[i]=table.create(sizeAlloc or 1)
	funcs[i]=table.create(sizeAlloc or 1) :: {()->()}

	return s

end
