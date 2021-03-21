-- Licensed under the Academic Free License version 3.0
-- See license.txt for more details on terms of use

local RunService = game:GetService('RunService');

local Connection = { };
Connection.__index = Connection;

function Connection.Disconnect(self)
	table.remove(self._event, table.find(self._event, self._callback));
end;

local Signal = { };
Signal.__index = Signal;

function Signal.Connect(self, callback)
	table.insert(self, callback);
	
	return setmetatable({ _event = self, _callback = callback }, Connection);
end;

function Signal.Dispose(self)
	while #self > 0 do
		table.remove(self, 1);
	end;
end;

function Signal.Fire(self, ...)
	for index = 1, #self do
		coroutine.resume(coroutine.create(self[index]), ...);
	end;
	
	self._lastFire = os.clock();
end;

function Signal.Wait(self)
	local init = os.clock();
	
	repeat
		local delta = os.clock() - self._lastFire;
		local beat = (os.clock() - init) + RunService.Heartbeat:Wait();
	until delta < beat;
	
	return os.clock() - init;
end;

function Signal.new()
	return setmetatable({ _lastFire = 0; }, Signal);
end;

return Signal;
