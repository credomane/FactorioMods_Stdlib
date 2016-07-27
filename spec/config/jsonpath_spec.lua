require 'stdlib/config/jsonpath'

--[[ The table to be duplicated for all tests. ]]--
_G.config_template = {
    a = 1,
    b = false,
    c = "",
    d = 100,
    e = {},
    f = nil,
    g = {
        a = true,
        b = false,
        c = "",
        d = 100,
        e = {},
        f = nil,
        g = {
            a = true,
            b = false,
            c = "",
            d = 100,
            e = {},
            f = nil,
            g = {
                a = true,
                b = false,
                c = "",
                d = 100,
                e = {},
                f = nil,
                g = {
                    a = true,
                    b = false,
                    c = "",
                    d = 100,
                    e = {},
                    f = nil,
                    g = {}
                }
            }
        }
    }
}
--[[ the table to be check for corruption. ]]--
_G.config_template2 = table.deepcopy(config_template)

describe('Config', function()
    describe('.new', function()
        before_each( function()
            _G.config_table = table.deepcopy(_G.config_template)
            assert.same(_G.config_template, _G.config_template2)
            assert.same(_G.config_template, _G.config_table)
        end)

        it('Creates a new Config passing different parameters', function()
            assert.no.errors(function() Config_JsonPath.new({}) end)
            assert.no.errors(function() Config_JsonPath.new(config_table) end)

            assert.has.errors(function() Config_JsonPath.new(true) end)
            assert.has.errors(function() Config_JsonPath.new(false) end)
            assert.has.errors(function() Config_JsonPath.new(nil) end)
            assert.has.errors(function() Config_JsonPath.new("") end)
            assert.has.errors(function() Config_JsonPath.new("{}") end)
            assert.has.errors(function() Config_JsonPath.new(Config_JsonPath.new({})) end)
        end)
    end)

    describe('.get', function()
        before_each( function()
            _G.config_table = table.deepcopy(_G.config_template)
            assert.same(_G.config_template, _G.config_template2)
            assert.same(_G.config_template, _G.config_table)
        end)

        it('Reserved characters', function()
            local cfg = Config_JsonPath.new(config_table);
            local reservedCharacters = '`~!@#$%^&*+=|;:/\\\'",?()[]{}<>'

            reservedCharacters:gsub(".", function(c)
                assert.has.errors(function() cfg.get("g" .. c .. "g") end)
            end)
        end)

        it('Round 1/3: Getting data from valid paths without errors', function()
            local cfg = Config_JsonPath.new(config_table);
            assert.no.errors(function() cfg.get("a") end)
            assert.no.errors(function() cfg.get("b") end)
            assert.no.errors(function() cfg.get("c") end)
            assert.no.errors(function() cfg.get("d") end)
            assert.no.errors(function() cfg.get("e") end)
            assert.no.errors(function() cfg.get("f") end)
            assert.no.errors(function() cfg.get("g") end)
            assert.no.errors(function() cfg.get("g.a") end)
            assert.no.errors(function() cfg.get("g.g.a") end)
            assert.no.errors(function() cfg.get("g.g.g.a") end)
            assert.no.errors(function() cfg.get("g.g.g.g.a") end)
        end)

        it('Round 2/3: Verifying data from valid paths', function()
            local cfg = Config_JsonPath.new(config_table);
            assert.same({{path="a",value=config_table.a}}, cfg.get("a"))
            assert.same({{path="b",value=config_table.b}}, cfg.get("b"))
            assert.same({{path="c",value=config_table.c}}, cfg.get("c"))
            assert.same({{path="d",value=config_table.d}}, cfg.get("d"))
            assert.same({{path="e",value=config_table.e}}, cfg.get("e"))
            assert.same(nil, cfg.get("f"))
            assert.same({{path="g",value=config_table.g}}, cfg.get("g"))
            assert.same({{path="g.a",value=config_table.g.a}}, cfg.get("g.a"))
            assert.same({{path="g.g.a",value=config_table.g.g.a}}, cfg.get("g.g.a"))
            assert.same({{path="g.g.g.a",value=config_table.g.g.g.a}}, cfg.get("g.g.g.a"))
            assert.same({{path="g.g.g.g.a",value=config_table.g.g.g.g.a}}, cfg.get("g.g.g.g.a"))
        end)

        it('Round 3/3: Getting data from invalid paths', function()
            local cfg = Config_JsonPath.new(config_table);

            assert.has.errors(function() cfg.get(true) end)
            assert.has.errors(function() cfg.get(false) end)
            assert.has.errors(function() cfg.get(nil) end)
            assert.has.errors(function() cfg.get({}) end)
            assert.has.errors(function() cfg.get("") end)

            assert.no.errors(function() cfg.get("a.a") end)
            assert.no.errors(function() cfg.get("b.a") end)
            assert.no.errors(function() cfg.get("c.a") end)
            assert.no.errors(function() cfg.get("d.a") end)
            assert.no.errors(function() cfg.get("e.a") end)
            assert.no.errors(function() cfg.get("f.a") end)
            assert.no.errors(function() cfg.get("g.z") end)
            end)
    end)

    describe('.set', function()
        before_each( function()
            _G.config_table = table.deepcopy(_G.config_template)
            assert.same(_G.config_template, _G.config_template2)
            assert.same(_G.config_template, _G.config_table)
        end)

        it('Reserved characters', function()
            local cfg = Config_JsonPath.new(config_table);
            local reservedCharacters = '`~!@#$%^&*+=|;:/\\\'",?()[]{}<>'

            reservedCharacters:gsub(".", function(c)
                assert.has.errors(function() cfg.set("g" .. c .. "g") end)
            end)
        end)

        it('Round 1/3: Setting data from valid paths without errors', function()
            local cfg = Config_JsonPath.new(config_table);
            cfg.set("g.g.g.g.a", 1337)
            assert.no.errors(function() cfg.set("g.g.g.g.a", 1337) end)
            assert.no.errors(function() cfg.set("g.g.g.a", 1337) end)
            assert.no.errors(function() cfg.set("g.g.a", 1337) end)
            assert.no.errors(function() cfg.set("g.a", 1337) end)
            assert.no.errors(function() cfg.set("g.g", 1337) end)
            assert.no.errors(function() cfg.set("g", 1337) end)
        end)

        it('Round 2/3: Verifying data from valid paths', function()
            local cfg = Config_JsonPath.new(config_table);
            local tempNum = 1000

            tempNum = tempNum + 1
            assert.same(1, cfg.set("a", tempNum))
            assert.same(tempNum, config_table.a)

            tempNum = tempNum + 1
            assert.same(1, cfg.set("b", tempNum))
            assert.same(tempNum, config_table.b)

            tempNum = tempNum + 1
            assert.same(1, cfg.set("c", tempNum))
            assert.same(tempNum, config_table.c)

            tempNum = tempNum + 1
            assert.same(1, cfg.set("d", tempNum))
            assert.same(tempNum, config_table.d)

            tempNum = tempNum + 1
            assert.same(1, cfg.set("e", tempNum))
            assert.same(tempNum, config_table.e)

            -- This test fails but shouldn't. Jsonpath can't find nil values. :/
            tempNum = tempNum + 1
            assert.same(1, cfg.set("f", tempNum))
            assert.same(tempNum, config_table.f)

            -- This test fails but shouldn't. Jsonpath can't find "nil". :/
            tempNum = tempNum + 1
            assert.same(1, cfg.set("g", tempNum))
            assert.same(tempNum, config_table.g)

            assert.same(1, cfg.set("g.a", nil))
            assert.same(nil, config_table.g.a)

            tempNum = tempNum + 1
            assert.same(1, cfg.set("g.g.a", tempNum))
            assert.same(tempNum, config_table.g.g.a)

            tempNum = tempNum + 1
            assert.same(1, cfg.set("g.g.g.a", tempNum))
            assert.same(tempNum, config_table.g.g.g.a)

            tempNum = tempNum + 1
            assert.same(1, cfg.set("g.g.g.g.a", tempNum))
            assert.same(tempNum, config_table.g.g.g.g.a)
        end)

        it('Round 3/3: Setting data from invalid paths', function()
            local cfg = Config_JsonPath.new(config_table);
            local config_table2 = table.deepcopy(_G.config_template)

            assert.has.errors(function() cfg.set(true) end)
            assert.has.errors(function() cfg.set(false) end)
            assert.has.errors(function() cfg.set(nil) end)
            assert.has.errors(function() cfg.set({}) end)
            assert.has.errors(function() cfg.set("") end)

            --[[ This whole test section fails due to being unable to find nil values but is shouldn't ]]--
            config_table2.a={a=1337}
            assert.no.errors(function() cfg.set("a.a", 1337) end)
            assert.same(config_table2, config_table)

            config_table2.b={a=1337}
            assert.no.errors(function() cfg.set("b.a", 1337) end)
            assert.same(config_table2, config_table)

            config_table2.c={a=1337}
            assert.no.errors(function() cfg.set("c.a", 1337) end)
            assert.same(config_table2, config_table)

            config_table2.d={a=1337}
            assert.no.errors(function() cfg.set("d.a", 1337) end)
            assert.same(config_table2, config_table)

            config_table2.e={a=1337}
            assert.no.errors(function() cfg.set("e.a", 1337) end)
            assert.same(config_table2, config_table)

            config_table2.f={a=1337}
            assert.no.errors(function() cfg.set("f.a", 1337) end)
            assert.same(config_table2, config_table)

            config_table2.g.z=1337
            assert.no.errors(function() cfg.set("g.z", 1337) end)
            assert.same(config_table2, config_table)
        end)
   end)

    describe('.delete', function()
        before_each( function()
            _G.config_table = table.deepcopy(_G.config_template)
            assert.same(_G.config_template, _G.config_template2)
            assert.same(_G.config_template, _G.config_table)
        end)

        it('Reserved characters', function()
            local cfg = Config_JsonPath.new(config_table);
            local reservedCharacters = '`~!@#$%^&*+=|;:/\\\'",?()[]{}<>'

            reservedCharacters:gsub(".", function(c)
                assert.has.errors(function() cfg.delete("g" .. c .. "g") end)
            end)
        end)

        it('Round 1/3: Deleting data from valid paths without errors', function()
            local cfg = Config_JsonPath.new(config_table);
            assert.no.errors(function() cfg.delete("g.g.g.g.g") end)

            assert.no.errors(function() cfg.delete("g.g.g.a") end)
            assert.no.errors(function() cfg.delete("g.g.a") end)
            assert.no.errors(function() cfg.delete("g.a") end)
            assert.no.errors(function() cfg.delete("a") end)
            assert.no.errors(function() cfg.delete("b") end)
            assert.no.errors(function() cfg.delete("c") end)
            assert.no.errors(function() cfg.delete("d") end)
            assert.no.errors(function() cfg.delete("e") end)
            assert.no.errors(function() cfg.delete("f") end)
            assert.no.errors(function() cfg.delete("g") end)
        end)

        it('Round 2/3: Verifying data from valid paths', function()
            local cfg = Config_JsonPath.new(config_table);
            assert.same(1, cfg.delete("g.g.g.g.a"))
            assert.same(nil, config_table.g.g.g.g.a)

            assert.same(1, cfg.delete("g.g.g.a"))
            assert.same(nil, config_table.g.g.g.a)
            assert.same(config_template.g.g.g.b, config_table.g.g.g.b) --Make sure we didn't delete too much

            assert.same(1, cfg.delete("g.g.a"))
            assert.same(nil, config_table.g.g.a)

            assert.same(1, cfg.delete("g.a"))
            assert.same(nil, config_table.g.a)

            assert.same(1, cfg.delete("a"))
            assert.same(nil, config_table.a)

            assert.same(1, cfg.delete("b"))
            assert.same(nil, config_table.b)

            assert.same(1, cfg.delete("c"))
            assert.same(nil, config_table.c)

            assert.same(1, cfg.delete("d"))
            assert.same(nil, config_table.d)

            assert.same(1, cfg.delete("e"))
            assert.same(nil, config_table.e)

            --It is a nil already so it should return 0
            assert.same(0, cfg.delete("f"))
            assert.same(nil, config_table.f)

            assert.same(1, cfg.delete("g"))
            assert.same(nil, config_table.g)

        end)

        it('Round 3/3: Deleting data from invalid paths', function()
            local cfg = Config_JsonPath.new(config_table);

            assert.has.errors(function() cfg.delete(true) end)
            assert.has.errors(function() cfg.delete(false) end)
            assert.has.errors(function() cfg.delete(nil) end)
            assert.has.errors(function() cfg.delete({}) end)
            assert.has.errors(function() cfg.delete("") end)

            assert.no.errors(function() cfg.delete("a.a") end)
            assert.same(config_template, config_table)

            assert.no.errors(function() cfg.delete("b.a") end)
            assert.same(config_template, config_table)

            assert.no.errors(function() cfg.delete("c.a") end)
            assert.same(config_template, config_table)

            assert.no.errors(function() cfg.delete("d.a") end)
            assert.same(config_template, config_table)

            assert.no.errors(function() cfg.delete("e.a") end)
            assert.same(config_template, config_table)

            assert.no.errors(function() cfg.delete("f.a") end)
            assert.same(config_template, config_table)

            assert.no.errors(function() cfg.delete("g.z") end)
            assert.same(config_template, config_table)
        end)
    end)

    describe('.is_set', function()
        before_each( function()
            _G.config_table = table.deepcopy(_G.config_template)
            assert.same(_G.config_template, _G.config_template2)
            assert.same(_G.config_template, _G.config_table)
        end)

        it('Reserved characters', function()
            local cfg = Config_JsonPath.new(config_table);
            local reservedCharacters = '`~!@#$%^&*+=|;:/\\\'",?()[]{}<>'

            reservedCharacters:gsub(".", function(c)
                assert.has.errors(function() cfg.is_set("g" .. c .. "g") end)
            end)
        end)

        it('Round 1/3: is data set from valid paths without errors?', function()
            local cfg = Config_JsonPath.new(config_table);
            assert.no.errors(function() cfg.is_set("a") end)
            assert.no.errors(function() cfg.is_set("b") end)
            assert.no.errors(function() cfg.is_set("c") end)
            assert.no.errors(function() cfg.is_set("d") end)
            assert.no.errors(function() cfg.is_set("e") end)
            assert.no.errors(function() cfg.is_set("f") end)
            assert.no.errors(function() cfg.is_set("g") end)
            assert.no.errors(function() cfg.is_set("g.a") end)
            assert.no.errors(function() cfg.is_set("g.g.a") end)
            assert.no.errors(function() cfg.is_set("g.g.g.a") end)
            assert.no.errors(function() cfg.is_set("g.g.g.g.a") end)
        end)

        it('Round 2/3: Verifying is_set from valid paths', function()
            local cfg = Config_JsonPath.new(config_table);
            assert.same(1, cfg.is_set("a"))
            assert.same(1, cfg.is_set("b"))
            assert.same(1, cfg.is_set("c"))
            assert.same(1, cfg.is_set("d"))
            assert.same(1, cfg.is_set("e"))
            assert.same(0, cfg.is_set("f"))
            assert.same(1, cfg.is_set("g"))
            assert.same(1, cfg.is_set("g.a"))
            assert.same(1, cfg.is_set("g.g.a"))
            assert.same(1, cfg.is_set("g.g.g.a"))
            assert.same(1, cfg.is_set("g.g.g.g.a"))
        end)

        it('Round 3/3: Verifying is_set from invalid paths', function()
            local cfg = Config_JsonPath.new(config_table);
            assert.same(0, cfg.is_set("a.a"))
            assert.same(0, cfg.is_set("b.a"))
            assert.same(0, cfg.is_set("c.a"))
            assert.same(0, cfg.is_set("d.a"))
            assert.same(0, cfg.is_set("e.a"))
            assert.same(0, cfg.is_set("f.a"))
            assert.same(0, cfg.is_set("g.z"))
        end)
    end)
end)
