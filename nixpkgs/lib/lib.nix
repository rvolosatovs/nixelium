let
  luaConstTableIndex = ''function(_,k) error("attempt to get '"..k.."'") end'';
  luaConstTableNewIndex = ''function(_,k,v) error("attempt to set '"..k.."' to '"..v.."'") end'';
in
lib: rec {
  luaConstTable = t: "setmetatable(${t},{__index=${luaConstTableIndex}, __newindex=${luaConstTableNewIndex}})";

  emptyLuaConstTable = luaConstTable "{}";

  toLua = with builtins; with lib; v:
    if isAttrs v then
      luaConstTable ''{${concatStringsSep "," (mapAttrsToList (sk: sv: "['${sk}']=${ toLua sv }") v)}}''
    else if isList v then
      if length v == 0 then
        emptyLuaConstTable
      else
        throw "non-empty lists are not supported"
    else
      toJSON v;
}
