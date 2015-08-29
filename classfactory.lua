local Class = {}


--[[
  Class.new = function ([class])
  this function will either create a new class as a base class (not extending
  any class) or if the class argument is passed in, will create a new class
  extending the passed.
  
  IMPORTANT: The object created does not inherit any relations to the Class
    library. The class created will be all on it's own and only inherit from
    othe classes which are specified in the creation herein.
]]
function Class.new(base, name)
  name = name or ''
	-- If base does not supplied, create an empty object (Table)
	base = base or {
    construct = function(self) end, -- Create a default constructor
    __isFactory = true, -- Set the Class definition as a Factory (not an instance of)
    __mixins = {},
  }
  
  print('Class.new ' .. name .. ' - ' .. tostring(base.__isFactory))
  
  if not base.__isFactory then
    error("Class may only extend a Class Definition, not an Object Instance")
  end
  
  -- Create empty Object to be new Class definition
  local obj = {}
  
  -- Load the base class into the field __parent of this new Class
  obj.__parent = base;
  
  -- Set the metatable of obj to base. Should the metatable be mt?
	setmetatable(obj, obj.__parent)
  
  -- Set the index field of base to itself
	obj.__parent.__index = base
  obj.parent = obj.__parent
  
  -- Create an object factory for this Class
  obj.new = function (self, ...)
    local new = {}
    setmetatable(new, self)
    self.__index = self
    new.__isFactory = false
    new:construct(...)
    
    return new
  end
  
  --[[
    Create a function to mix a table (traits) into this Class
    in an optional namespace ]]
  obj.mixin = function (self, t, namespace)
    
    -- Set the default mixin location to the root of the table
    local handle = self
    
    -- Get the table to mix 't' into
    if namespace ~= nil and type(namespace) == 'string' then
      if self[namespace] ~= nil and type(self[namespace]) ~= 'table' then
        error('Class unable to mix into \'' .. namespace .. '\' already in use and not a table.')
      end
      
      self[namespace] = self[namespace] or {}
      handle = self[namespace]
    end
    
    for pos, val in pairs(t) do
      if type(val) == "function" then
        --print(tostring(pos) .. ': ' .. tostring(val))
        handle[pos] = val
      end
    end
  end
  
  obj.hasMixin = function (self, t, namespace)
    
    local handle = self
    
    -- check if the namespace is supplied and if so, check if it exists
    if namespace ~= nil and type(namespace) == 'string' then
      if self[namespace] == nil or type(self[namespace]) ~= 'table' then
        return false
      end
      
      handle = self[namespace]
    end
    
    -- Loop each function and check if self contains class
    for pos, val in pairs(t) do
      if type(val) == "function" then
        if handle[pos] ~= val then
          return false
        end
      end
    end
    
    return true
  end
  
  -- Loop all of the metatables of parents to check for a match to t
  obj.isSubclassOf = function (self, t)
    local meta = getmetatable(self)
    
    while meta ~= nil do
      if meta == t then
        return true
      end
      
      inst = inst.parent
      meta = getmetatable(inst)
    end
    
    return false
  end
  
  -- Loop all of the parent instances checking if it matches t
  obj.isInstanceOf = function (self, t)
    local inst = self
    
    while inst ~= nil do
      if inst == t then
        return true
      end
      
      inst = inst.parent
    end
    
    return false
  end
  
  
  return obj
end



return Class