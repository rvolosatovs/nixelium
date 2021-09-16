# nix-instantiate --eval --strict test.nix

let
  lib = (import <nixpkgs> {}).lib;
in
  with import ./lib.nix lib;
  lib.runTests {
    testToLuaString = {
      expr = toLua "test";
      expected = ''"test"'';
    };

    testToLuaNumber = {
      expr = toLua 1;
      expected = "1";
    };

    testToLuaEmptyAttrs = {
      expr = toLua {};
      expected = emptyLuaConstTable;
    };

    testToLuaEmptyList = {
      expr = toLua [];
      expected = emptyLuaConstTable;
    };

    testToLuaNestedAttrs = {
      expr = toLua {
        a = {
          a = 1;
          b = [];
          c = "test";
          d = 0.42;
        };
        b = {};
        c = 2;
        d = "string";
        e = [];
      };
      expected = luaConstTable (
        lib.concatStrings [
          ''{''
          ''['a']=${luaConstTable (
            lib.concatStrings [
              ''{''
              ''['a']=1,''
              ''['b']=${emptyLuaConstTable},''
              ''['c']="test",''
              ''['d']=0.42''
              ''}''
            ]
          )},''
          ''['b']=${emptyLuaConstTable},''
          ''['c']=2,''
          ''['d']="string",''
          ''['e']=${emptyLuaConstTable}''
          ''}''
        ]
      );
    };
  }
