{
  self,
  nixlib,
  nix-flake-tests,
  ...
}: pkgs:
with nixlib.lib;
  nix-flake-tests.lib.check {
    inherit pkgs;

    tests.testToLuaEmptyAttrs.expected = self.lib.emptyLuaConstTable;
    tests.testToLuaEmptyAttrs.expr = self.lib.toLua {};

    tests.testToLuaEmptyList.expected = self.lib.emptyLuaConstTable;
    tests.testToLuaEmptyList.expr = self.lib.toLua [];

    tests.testToLuaNumber.expected = "1";
    tests.testToLuaNumber.expr = self.lib.toLua 1;

    tests.testToLuaString.expected = ''"test"'';
    tests.testToLuaString.expr = self.lib.toLua "test";

    tests.testToLuaNestedAttrs.expr = self.lib.toLua {
      a.a = 1;
      a.b = [];
      a.c = "test";
      a.d = 0.42;
      b = {};
      c = 2;
      d = "string";
      e = [];
    };
    tests.testToLuaNestedAttrs.expected = self.lib.luaConstTable (
      concatStrings [
        ''{''
        ''['a']=${self.lib.luaConstTable (
            concatStrings [
              ''{''
              ''['a']=1,''
              ''['b']=${self.lib.emptyLuaConstTable},''
              ''['c']="test",''
              ''['d']=0.42''
              ''}''
            ]
          )},''
        ''['b']=${self.lib.emptyLuaConstTable},''
        ''['c']=2,''
        ''['d']="string",''
        ''['e']=${self.lib.emptyLuaConstTable}''
        ''}''
      ]
    );
  }
