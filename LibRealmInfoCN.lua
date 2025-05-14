---------------------------------------------------------------------
-- LibRealmInfoCN
-- https://github.com/enderneko/LibRealmInfoCN
-- based on LibGetRealmInfo by Phanx
---------------------------------------------------------------------
local MAJOR, MINOR = "LibRealmInfoCN", 2
assert(LibStub, MAJOR .. " requires LibStub.")
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local realmData
local realmNameToID = {}
local Unpack

---------------------------------------------------------------------
-- current region
---------------------------------------------------------------------
-- local currentRegion
-- function lib.GetCurrentRegion()
--     if currentRegion then
--         return currentRegion
--     end

--     local guid = UnitGUID("player")
--     if guid then
--         local server = tonumber(strmatch(guid, "^Player%-(%d+)"))
--         local realm = realmData[server]
--         if realm then
--             currentRegion = realm.region
--             return currentRegion
--         end
--     end

--     print("|cffff7777[LibRealmInfoCN]|r.GetCurrentRegion: could not identify region based on player GUID", guid)
-- end

---------------------------------------------------------------------
-- current
---------------------------------------------------------------------
local currentRealmID, currentRealmName
local function UpdateCurrentRealm()
    if not (currentRealmID and currentRealmName) then
        currentRealmID = GetRealmID()
        currentRealmName = GetNormalizedRealmName()
    end
end

---------------------------------------------------------------------
-- unpack data
---------------------------------------------------------------------
local VERSION
if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    VERSION = "RETAIL"
elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
    VERSION = "CLASSIC"
elseif WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
    VERSION = "WRATH_CLASSIC"
elseif WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then
    VERSION = "CATACLYSM_CLASSIC"
end

function Unpack()
    UpdateCurrentRealm()
    local connectedRealms

    for id, data in pairs(realmData) do
        local name, region, flavor, connected = strsplit(",", data, 4)
        if flavor == VERSION then
            realmNameToID[name] = id

            connectedRealms = nil
            if connected then
                connectedRealms = {}
                connected = {strsplit(",", connected)}
                for _, connectedId in pairs(connected) do
                    tinsert(connectedRealms, tonumber(connectedId))
                end
            end

            realmData[id] = {
                name = name,
                connected = connectedRealms,
            }
        end
    end

    connectedRealms = nil
    Unpack = nil
    collectgarbage()
end

---------------------------------------------------------------------
-- IsConnectedRealm
---------------------------------------------------------------------
function lib.IsConnectedRealm(realmNameOrID)
    if Unpack then Unpack() end

    if realmNameOrID == currentRealmID or realmNameOrID == currentRealmName then
        return true
    end

    if realmNameOrID and type(realmNameOrID) == "string" then
        realmNameOrID = realmNameToID[realmNameOrID]
    end

    if realmNameOrID and realmData[currentRealmID] and realmData[currentRealmID]["connected"] then
        return tContains(realmData[currentRealmID]["connected"], realmNameOrID)
    end
end

---------------------------------------------------------------------
-- GetConnectedRealmID
---------------------------------------------------------------------
function lib.GetConnectedRealmID(realmNameOrID, unpackResult, currentRealmFirst)
    if Unpack then Unpack() end

    realmNameOrID = realmNameOrID or currentRealmID

    if realmNameOrID and type(realmNameOrID) == "string" then
        realmNameOrID = realmNameToID[realmNameOrID]
    end

    if realmNameOrID and realmData[realmNameOrID] and realmData[realmNameOrID]["connected"] then
        local result = {}
        for _, id in pairs(realmData[realmNameOrID]["connected"]) do
            if currentRealmFirst and id == currentRealmID then
                tinsert(result, 1, id)
            else
                tinsert(result, id)
            end
        end

        if unpackResult then
            return unpack(result)
        else
            return result
        end
    end
end

---------------------------------------------------------------------
-- GetConnectedRealmName
---------------------------------------------------------------------
function lib.GetConnectedRealmName(realmNameOrID, unpackResult, currentRealmFirst)
    if Unpack then Unpack() end

    realmNameOrID = realmNameOrID or currentRealmID

    if realmNameOrID and type(realmNameOrID) == "string" then
        realmNameOrID = realmNameToID[realmNameOrID]
    end

    if realmNameOrID and realmData[realmNameOrID] and realmData[realmNameOrID]["connected"] then
        local result = {}
        for _, id in pairs(realmData[realmNameOrID]["connected"]) do
            if currentRealmFirst and id == currentRealmID then
                tinsert(result, 1, realmData[id]["name"])
            else
                tinsert(result, realmData[id]["name"])
            end
        end

        if unpackResult then
            return unpack(result)
        else
            return result
        end
    end
end

---------------------------------------------------------------------
-- HasConnectedRealm
---------------------------------------------------------------------
function lib.HasConnectedRealm(realmNameOrID)
    if Unpack then Unpack() end

    realmNameOrID = realmNameOrID or currentRealmID

    if realmNameOrID and type(realmNameOrID) == "string" then
        realmNameOrID = realmNameToID[realmNameOrID]
    end

    if realmNameOrID and realmData[realmNameOrID] and realmData[realmNameOrID]["connected"] then
        return true
    else
        return false
    end
end

---------------------------------------------------------------------
-- GetRealmID
---------------------------------------------------------------------
function lib.GetRealmID(realmName)
    if Unpack then Unpack() end
    return realmName and realmNameToID[realmName]
end

---------------------------------------------------------------------
-- GetRealmName
---------------------------------------------------------------------
function lib.GetRealmName(realmID)
    if Unpack then Unpack() end
    return realmID and realmData[realmID] and realmData[realmID]["name"]
end

---------------------------------------------------------------------
-- realm data
---------------------------------------------------------------------
realmData = {
    [700] = "阿格拉玛,CN,RETAIL,700,788,1214,1223,1507,1517,1659,1793,2123",
    [703] = "艾苏恩,CN,RETAIL,703,891",
    [704] = "安威玛尔,CN,RETAIL,704,1695",
    [705] = "奥达曼,CN,RETAIL,705,835",
    [706] = "奥蕾莉亚,CN,RETAIL,706,922,925,1501",
    [707] = "白银之手,CN,RETAIL",
    [708] = "暴风祭坛,CN,RETAIL,708,753,822,867,1213,1815,1941",
    [709] = "藏宝海湾,CN,RETAIL,709,879,1201",
    [710] = "尘风峡谷,CN,RETAIL,710,743,790,1817",
    [711] = "达纳斯,CN,RETAIL,711,869,1662",
    [712] = "迪托马斯,CN,RETAIL,712,1940,2137",
    [714] = "国王之谷,CN,RETAIL",
    [715] = "黑龙军团,CN,RETAIL,715,1944",
    [716] = "黑石尖塔,CN,RETAIL,716,804,805,861,1818,1820",
    [717] = "红龙军团,CN,RETAIL,717,723,740,1231,1499",
    [718] = "回音山,CN,RETAIL,718,877,887,941",
    [719] = "基尔罗格,CN,RETAIL,719,1670,1945",
    [720] = "卡德罗斯,CN,RETAIL,720,803,932,1935",
    [721] = "卡扎克,CN,RETAIL,721,755,767,807,865,926,1203,1215",
    [723] = "库德兰,CN,RETAIL,717,723,740,1231,1499",
    [725] = "蓝龙军团,CN,RETAIL,725,837,949,959,1524,1681,1819",
    [726] = "雷霆之王,CN,RETAIL,726,742,840,1490",
    [727] = "烈焰峰,CN,RETAIL,727,1235",
    [729] = "罗宁,CN,RETAIL",
    [730] = "洛萨,CN,RETAIL,730,739,1482",
    [731] = "玛多兰,CN,RETAIL,731,841,856,889",
    [732] = "玛瑟里顿,CN,RETAIL,732,802,815,943",
    [734] = "奈萨里奥,CN,RETAIL,734,806,1204,1497,1500,1829",
    [736] = "诺莫瑞根,CN,RETAIL,736,843,847,855,1200,1666,1797,1803",
    [737] = "普瑞斯托,CN,RETAIL,737,1511,2119",
    [738] = "燃烧平原,CN,RETAIL,738,765",
    [739] = "萨格拉斯,CN,RETAIL,730,739,1482",
    [740] = "山丘之王,CN,RETAIL,717,723,740,1231,1499",
    [741] = "死亡之翼,CN,RETAIL",
    [742] = "索拉丁,CN,RETAIL,726,742,840,1490",
    [743] = "索瑞森,CN,RETAIL,710,743,790,1817",
    [744] = "铜龙军团,CN,RETAIL,744,827,2130",
    [745] = "图拉扬,CN,RETAIL,745,782,1202,1237",
    [746] = "伊瑟拉,CN,RETAIL,746,754,780,792",
    [748] = "阿迦玛甘,CN,RETAIL,748,845",
    [749] = "阿克蒙德,CN,RETAIL,749,1488,1663",
    [750] = "埃加洛尔,CN,RETAIL,750,920,1676,1798",
    [751] = "埃苏雷格,CN,RETAIL,751,863,1520,1657",
    [753] = "艾萨拉,CN,RETAIL,708,753,822,867,1213,1815,1941",
    [754] = "艾森娜,CN,RETAIL,746,754,780,792",
    [755] = "爱斯特纳,CN,RETAIL,721,755,767,807,865,926,1203,1215",
    [756] = "暗影之月,CN,RETAIL,756,916",
    [757] = "奥拉基尔,CN,RETAIL,757,859",
    [758] = "冰霜之刃,CN,RETAIL,758,2121",
    [760] = "达斯雷玛,CN,RETAIL,760,1211,1226,1694",
    [761] = "地狱咆哮,CN,RETAIL,761,1228,1932",
    [762] = "地狱之石,CN,RETAIL,762,770,872",
    [764] = "风暴之怒,CN,RETAIL,764,800,954,1238,1484,1503",
    [765] = "风行者,CN,RETAIL,738,765",
    [766] = "弗塞雷迦,CN,RETAIL,766,1198,1948",
    [767] = "戈古纳斯,CN,RETAIL,721,755,767,807,865,926,1203,1215",
    [768] = "海加尔,CN,RETAIL,768,1239,1505",
    [769] = "毁灭之锤,CN,RETAIL,769,2128",
    [770] = "火焰之树,CN,RETAIL,762,770,872",
    [771] = "卡德加,CN,RETAIL,771,814,1513",
    [772] = "拉文凯斯,CN,RETAIL,772,927,1493,1796,1808",
    [773] = "玛法里奥,CN,RETAIL,773,774,931,960,1205,1232,1508,1947,1970",
    [774] = "玛维·影歌,CN,RETAIL,773,774,931,960,1205,1232,1508,1947,1970",
    [775] = "梅尔加尼,CN,RETAIL,775,2127",
    [776] = "梦境之树,CN,RETAIL,776,787,826",
    [778] = "耐普图隆,CN,RETAIL,778,946,1199,1509",
    [780] = "轻风之语,CN,RETAIL,746,754,780,792",
    [781] = "夏维安,CN,RETAIL,781,944,1943",
    [782] = "塞纳留斯,CN,RETAIL,745,782,1202,1237",
    [784] = "闪电之刃,CN,RETAIL,784,1971",
    [786] = "石爪峰,CN,RETAIL,786,1483",
    [787] = "泰兰德,CN,RETAIL,776,787,826",
    [788] = "屠魔山谷,CN,RETAIL,700,788,1214,1223,1507,1517,1659,1793,2123",
    [790] = "伊利丹,CN,RETAIL,710,743,790,1817",
    [791] = "月光林地,CN,RETAIL,791,870",
    [792] = "月神殿,CN,RETAIL,746,754,780,792",
    [793] = "战歌,CN,RETAIL,793,1506,1682",
    [794] = "主宰之剑,CN,RETAIL,794,1955",
    [797] = "埃德萨拉,CN,RETAIL",
    [799] = "血环,CN,RETAIL,799,1828",
    [800] = "布莱克摩,CN,RETAIL,764,800,954,1238,1484,1503",
    [802] = "杜隆坦,CN,RETAIL,732,802,815,943",
    [803] = "符文图腾,CN,RETAIL,720,803,932,1935",
    [804] = "鬼雾峰,CN,RETAIL,716,804,805,861,1818,1820",
    [805] = "黑暗之矛,CN,RETAIL,716,804,805,861,1818,1820",
    [806] = "红龙女王,CN,RETAIL,734,806,1204,1497,1500,1829",
    [807] = "红云台地,CN,RETAIL,721,755,767,807,865,926,1203,1215",
    [808] = "黄金之路,CN,RETAIL,808,956,1832",
    [810] = "火羽山,CN,RETAIL,810,812,825,1827",
    [812] = "迦罗娜,CN,RETAIL,810,812,825,1827",
    [814] = "凯恩血蹄,CN,RETAIL,771,814,1513",
    [815] = "狂风峭壁,CN,RETAIL,732,802,815,943",
    [816] = "雷斧堡垒,CN,RETAIL",
    [817] = "雷克萨,CN,RETAIL,817,860,1664,1795",
    [818] = "雷霆号角,CN,RETAIL,818,953",
    [822] = "玛里苟斯,CN,RETAIL,708,753,822,867,1213,1815,1941",
    [825] = "纳沙塔尔,CN,RETAIL,810,812,825,1827",
    [826] = "诺兹多姆,CN,RETAIL,776,787,826",
    [827] = "普罗德摩,CN,RETAIL,744,827,2130",
    [828] = "千针石林,CN,RETAIL,828,1658,1936,1942",
    [829] = "燃烧之刃,CN,RETAIL,829,866,1222",
    [830] = "萨尔,CN,RETAIL,830,1502",
    [833] = "圣火神殿,CN,RETAIL,833,1212",
    [835] = "甜水绿洲,CN,RETAIL,705,835",
    [837] = "沃金,CN,RETAIL,725,837,949,959,1524,1681,1819",
    [838] = "熊猫酒仙,CN,RETAIL",
    [839] = "血牙魔王,CN,RETAIL,839,1496",
    [840] = "勇士岛,CN,RETAIL,726,742,840,1490",
    [841] = "羽月,CN,RETAIL,731,841,856,889",
    [842] = "蜘蛛王国,CN,RETAIL",
    [843] = "自由之风,CN,RETAIL,736,843,847,855,1200,1666,1797,1803",
    [844] = "阿尔萨斯,CN,RETAIL,844,1831",
    [845] = "阿拉索,CN,RETAIL,748,845",
    [846] = "埃雷达尔,CN,RETAIL,846,1236",
    [847] = "艾欧娜尔,CN,RETAIL,736,843,847,855,1200,1666,1797,1803",
    [848] = "安东尼达斯,CN,RETAIL",
    [849] = "暗影议会,CN,RETAIL,849,882",
    [850] = "奥特兰克,CN,RETAIL",
    [851] = "巴尔古恩,CN,RETAIL,851,1823",
    [852] = "冰风岗,CN,RETAIL",
    [855] = "达隆米尔,CN,RETAIL,736,843,847,855,1200,1666,1797,1803",
    [856] = "耳语海岸,CN,RETAIL,731,841,856,889",
    [857] = "古尔丹,CN,RETAIL,857,1487",
    [858] = "寒冰皇冠,CN,RETAIL,858,1693",
    [859] = "基尔加丹,CN,RETAIL,757,859",
    [860] = "激流堡,CN,RETAIL,817,860,1664,1795",
    [861] = "巨龙之吼,CN,RETAIL,716,804,805,861,1818,1820",
    [862] = "暗影裂口,CN,RETAIL,862,3755",
    [863] = "凯尔萨斯,CN,RETAIL,751,863,1520,1657",
    [864] = "克尔苏加德,CN,RETAIL,864,2120,2124",
    [865] = "拉格纳罗斯,CN,RETAIL,721,755,767,807,865,926,1203,1215",
    [866] = "埃霍恩,CN,RETAIL,829,866,1222",
    [867] = "利刃之拳,CN,RETAIL,708,753,822,867,1213,1815,1941",
    [869] = "玛诺洛斯,CN,RETAIL,711,869,1662",
    [870] = "麦迪文,CN,RETAIL,791,870",
    [872] = "耐奥祖,CN,RETAIL,762,770,872",
    [874] = "瑞文戴尔,CN,RETAIL,874,918",
    [876] = "霜狼,CN,RETAIL,876,1667",
    [877] = "霜之哀伤,CN,RETAIL,718,877,887,941",
    [878] = "斯坦索姆,CN,RETAIL,878,1234,1807,1813",
    [879] = "塔伦米尔,CN,RETAIL,709,879,1201",
    [882] = "提瑞斯法,CN,RETAIL,849,882",
    [883] = "通灵学院,CN,RETAIL,883,924",
    [885] = "希尔瓦娜斯,CN,RETAIL,885,930,1492",
    [886] = "血色十字军,CN,RETAIL",
    [887] = "遗忘海岸,CN,RETAIL,718,877,887,941",
    [888] = "银松森林,CN,RETAIL,888,1696",
    [889] = "银月,CN,RETAIL,731,841,856,889",
    [890] = "鹰巢山,CN,RETAIL,890,1233,1685,1938",
    [891] = "影牙要塞,CN,RETAIL,703,891",
    [915] = "狂热之刃,CN,RETAIL",
    [916] = "卡珊德拉,CN,RETAIL,756,916",
    [917] = "迅捷微风,CN,RETAIL,917,1969",
    [918] = "守护之剑,CN,RETAIL,874,918",
    [920] = "斩魔者,CN,RETAIL,750,920,1676,1798",
    [921] = "布兰卡德,CN,RETAIL",
    [922] = "世界之树,CN,RETAIL,706,922,925,1501",
    [924] = "恶魔之翼,CN,RETAIL,883,924",
    [925] = "万色星辰,CN,RETAIL,706,922,925,1501",
    [926] = "激流之傲,CN,RETAIL,721,755,767,807,865,926,1203,1215",
    [927] = "加兹鲁维,CN,RETAIL,772,927,1493,1796,1808",
    [929] = "苏塔恩,CN,RETAIL,929,1216",
    [930] = "大地之怒,CN,RETAIL,885,930,1492",
    [931] = "雏龙之翼,CN,RETAIL,773,774,931,960,1205,1232,1508,1947,1970",
    [932] = "黑暗魅影,CN,RETAIL,720,803,932,1935",
    [933] = "踏梦者,CN,RETAIL,933,1931",
    [938] = "密林游侠,CN,RETAIL,938,1486,1512",
    [940] = "伊森利恩,CN,RETAIL",
    [941] = "神圣之歌,CN,RETAIL,718,877,887,941",
    [943] = "暮色森林,CN,RETAIL,732,802,815,943",
    [944] = "元素之力,CN,RETAIL,781,944,1943",
    [946] = "日落沼泽,CN,RETAIL,778,946,1199,1509",
    [949] = "芬里斯,CN,RETAIL,725,837,949,959,1524,1681,1819",
    [951] = "伊萨里奥斯,CN,RETAIL,951,1830",
    [953] = "风暴之眼,CN,RETAIL,818,953",
    [954] = "提尔之手,CN,RETAIL,764,800,954,1238,1484,1503",
    [956] = "永夜港,CN,RETAIL,808,956,1832",
    [959] = "朵丹尼尔,CN,RETAIL,725,837,949,959,1524,1681,1819",
    [960] = "法拉希姆,CN,RETAIL,773,774,931,960,1205,1232,1508,1947,1970",
    [962] = "金色平原,CN,RETAIL",
    [1198] = "安其拉,CN,RETAIL,766,1198,1948",
    [1199] = "安纳塞隆,CN,RETAIL,778,946,1199,1509",
    [1200] = "阿努巴拉克,CN,RETAIL,736,843,847,855,1200,1666,1797,1803",
    [1201] = "阿拉希,CN,RETAIL,709,879,1201",
    [1202] = "瓦里玛萨斯,CN,RETAIL,745,782,1202,1237",
    [1203] = "巴纳扎尔,CN,RETAIL,721,755,767,807,865,926,1203,1215",
    [1204] = "黑手军团,CN,RETAIL,734,806,1204,1497,1500,1829",
    [1205] = "血羽,CN,RETAIL,773,774,931,960,1205,1232,1508,1947,1970",
    [1206] = "燃烧军团,CN,RETAIL,1206,1224,1504,1802",
    [1207] = "克洛玛古斯,CN,RETAIL,1207,1668",
    [1208] = "破碎岭,CN,RETAIL,1208,1229,1519,1660,1692",
    [1209] = "克苏恩,CN,RETAIL,1209,1494",
    [1210] = "阿纳克洛斯,CN,RETAIL,1210,2125",
    [1211] = "雷霆之怒,CN,RETAIL,760,1211,1226,1694",
    [1212] = "桑德兰,CN,RETAIL,833,1212",
    [1213] = "黑翼之巢,CN,RETAIL,708,753,822,867,1213,1815,1941",
    [1214] = "德拉诺,CN,RETAIL,700,788,1214,1223,1507,1517,1659,1793,2123",
    [1215] = "龙骨平原,CN,RETAIL,721,755,767,807,865,926,1203,1215",
    [1216] = "卡拉赞,CN,RETAIL,929,1216",
    [1221] = "熔火之心,CN,RETAIL,1221,2126",
    [1222] = "格瑞姆巴托,CN,RETAIL,829,866,1222",
    [1223] = "古拉巴什,CN,RETAIL,700,788,1214,1223,1507,1517,1659,1793,2123",
    [1224] = "哈卡,CN,RETAIL,1206,1224,1504,1802",
    [1225] = "海克泰尔,CN,RETAIL,1225,2129",
    [1226] = "库尔提拉斯,CN,RETAIL,760,1211,1226,1694",
    [1227] = "洛丹伦,CN,RETAIL,1227,1489",
    [1228] = "奈法利安,CN,RETAIL,761,1228,1932",
    [1229] = "奎尔萨拉斯,CN,RETAIL,1208,1229,1519,1660,1692",
    [1230] = "拉贾克斯,CN,RETAIL,1230,1510",
    [1231] = "拉文霍德,CN,RETAIL,717,723,740,1231,1499",
    [1232] = "森金,CN,RETAIL,773,774,931,960,1205,1232,1508,1947,1970",
    [1233] = "范达尔鹿盔,CN,RETAIL,890,1233,1685,1938",
    [1234] = "泰拉尔,CN,RETAIL,878,1234,1807,1813",
    [1235] = "瓦拉斯塔兹,CN,RETAIL,727,1235",
    [1236] = "永恒之井,CN,RETAIL,846,1236",
    [1237] = "海达希亚,CN,RETAIL,745,782,1202,1237",
    [1238] = "萨菲隆,CN,RETAIL,764,800,954,1238,1484,1503",
    [1239] = "纳克萨玛斯,CN,RETAIL,768,1239,1505",
    [1240] = "无尽之海,CN,RETAIL,1240,1672",
    [1241] = "莱索恩,CN,RETAIL,1241,2122",
    [1482] = "阿卡玛,CN,RETAIL,730,739,1482",
    [1483] = "阿扎达斯,CN,RETAIL,786,1483",
    [1484] = "灰谷,CN,RETAIL,764,800,954,1238,1484,1503",
    [1485] = "艾维娜,CN,RETAIL,1485,1812",
    [1486] = "巴瑟拉斯,CN,RETAIL,938,1486,1512",
    [1487] = "血顶,CN,RETAIL,857,1487",
    [1488] = "恐怖图腾,CN,RETAIL,749,1488,1663",
    [1489] = "古加尔,CN,RETAIL,1227,1489",
    [1490] = "达文格尔,CN,RETAIL,726,742,840,1490",
    [1491] = "黑铁,CN,RETAIL",
    [1492] = "恶魔之魂,CN,RETAIL,885,930,1492",
    [1493] = "迪瑟洛克,CN,RETAIL,772,927,1493,1796,1808",
    [1494] = "丹莫德,CN,RETAIL,1209,1494",
    [1495] = "艾莫莉丝,CN,RETAIL,1495,1937,1965",
    [1496] = "埃克索图斯,CN,RETAIL,839,1496",
    [1497] = "菲拉斯,CN,RETAIL,734,806,1204,1497,1500,1829",
    [1498] = "加基森,CN,RETAIL,1498,1516",
    [1499] = "加里索斯,CN,RETAIL,717,723,740,1231,1499",
    [1500] = "格雷迈恩,CN,RETAIL,734,806,1204,1497,1500,1829",
    [1501] = "布莱恩,CN,RETAIL,706,922,925,1501",
    [1502] = "伊莫塔尔,CN,RETAIL,830,1502",
    [1503] = "大漩涡,CN,RETAIL,764,800,954,1238,1484,1503",
    [1504] = "诺森德,CN,RETAIL,1206,1224,1504,1802",
    [1505] = "奥妮克希亚,CN,RETAIL,768,1239,1505",
    [1506] = "奥斯里安,CN,RETAIL,793,1506,1682",
    [1507] = "外域,CN,RETAIL,700,788,1214,1223,1507,1517,1659,1793,2123",
    [1508] = "天空之墙,CN,RETAIL,773,774,931,960,1205,1232,1508,1947,1970",
    [1509] = "风暴之鳞,CN,RETAIL,778,946,1199,1509",
    [1510] = "荆棘谷,CN,RETAIL,1230,1510",
    [1511] = "逐日者,CN,RETAIL,737,1511,2119",
    [1512] = "塔纳利斯,CN,RETAIL,938,1486,1512",
    [1513] = "瑟莱德丝,CN,RETAIL,771,814,1513",
    [1514] = "塞拉赞恩,CN,RETAIL,1514,1824",
    [1515] = "托塞德林,CN,RETAIL,1515,1794",
    [1516] = "黑暗虚空,CN,RETAIL,1498,1516",
    [1517] = "安戈洛,CN,RETAIL,700,788,1214,1223,1507,1517,1659,1793,2123",
    [1519] = "祖尔金,CN,RETAIL,1208,1229,1519,1660,1692",
    [1520] = "双子峰,CN,RETAIL,751,863,1520,1657",
    [1524] = "天谴之门,CN,RETAIL,725,837,949,959,1524,1681,1819",
    [1657] = "冰川之拳,CN,RETAIL,751,863,1520,1657",
    [1658] = "刺骨利刃,CN,RETAIL,828,1658,1936,1942",
    [1659] = "深渊之巢,CN,RETAIL,700,788,1214,1223,1507,1517,1659,1793,2123",
    [1660] = "埃基尔松,CN,RETAIL,1208,1229,1519,1660,1692",
    [1662] = "火烟之谷,CN,RETAIL,711,869,1662",
    [1663] = "伊兰尼库斯,CN,RETAIL,749,1488,1663",
    [1664] = "火喉,CN,RETAIL,817,860,1664,1795",
    [1666] = "冬寒,CN,RETAIL,736,843,847,855,1200,1666,1797,1803",
    [1667] = "迦玛兰,CN,RETAIL,876,1667",
    [1668] = "金度,CN,RETAIL,1207,1668",
    [1670] = "巫妖之王,CN,RETAIL,719,1670,1945",
    [1672] = "米奈希尔,CN,RETAIL,1240,1672",
    [1676] = "幽暗沼泽,CN,RETAIL,750,920,1676,1798",
    [1681] = "烈焰荆棘,CN,RETAIL,725,837,949,959,1524,1681,1819",
    [1682] = "夺灵者,CN,RETAIL,793,1506,1682",
    [1685] = "石锤,CN,RETAIL,890,1233,1685,1938",
    [1687] = "塞拉摩,CN,RETAIL,1687,1810,1821",
    [1692] = "厄祖玛特,CN,RETAIL,1208,1229,1519,1660,1692",
    [1693] = "冬泉谷,CN,RETAIL,858,1693",
    [1694] = "伊森德雷,CN,RETAIL,760,1211,1226,1694",
    [1695] = "扎拉赞恩,CN,RETAIL,704,1695",
    [1696] = "亚雷戈斯,CN,RETAIL,888,1696",
    [1793] = "深渊之喉,CN,RETAIL,700,788,1214,1223,1507,1517,1659,1793,2123",
    [1794] = "凤凰之神,CN,RETAIL,1515,1794",
    [1795] = "阿古斯,CN,RETAIL,817,860,1664,1795",
    [1796] = "奥金顿,CN,RETAIL,772,927,1493,1796,1808",
    [1797] = "刀塔,CN,RETAIL,736,843,847,855,1200,1666,1797,1803",
    [1798] = "鲜血熔炉,CN,RETAIL,750,920,1676,1798",
    [1801] = "黑暗之门,CN,RETAIL,1801,1946",
    [1802] = "死亡熔炉,CN,RETAIL,1206,1224,1504,1802",
    [1803] = "无底海渊,CN,RETAIL,736,843,847,855,1200,1666,1797,1803",
    [1807] = "格鲁尔,CN,RETAIL,878,1234,1807,1813",
    [1808] = "哈兰,CN,RETAIL,772,927,1493,1796,1808",
    [1809] = "军团要塞,CN,RETAIL,1809,1934",
    [1810] = "麦姆,CN,RETAIL,1687,1810,1821",
    [1812] = "艾露恩,CN,RETAIL,1485,1812",
    [1813] = "穆戈尔,CN,RETAIL,878,1234,1807,1813",
    [1815] = "摩摩尔,CN,RETAIL,708,753,822,867,1213,1815,1941",
    [1817] = "试炼之环,CN,RETAIL,710,743,790,1817",
    [1818] = "罗曼斯,CN,RETAIL,716,804,805,861,1818,1820",
    [1819] = "希雷诺斯,CN,RETAIL,725,837,949,959,1524,1681,1819",
    [1820] = "塞泰克,CN,RETAIL,716,804,805,861,1818,1820",
    [1821] = "暗影迷宫,CN,RETAIL,1687,1810,1821",
    [1823] = "托尔巴拉德,CN,RETAIL,851,1823",
    [1824] = "太阳之井,CN,RETAIL,1514,1824",
    [1827] = "末日祷告祭坛,CN,RETAIL,810,812,825,1827",
    [1828] = "范克里夫,CN,RETAIL,799,1828",
    [1829] = "瓦丝琪,CN,RETAIL,734,806,1204,1497,1500,1829",
    [1830] = "祖阿曼,CN,RETAIL,951,1830",
    [1831] = "祖达克,CN,RETAIL,844,1831",
    [1832] = "翡翠梦境,CN,RETAIL,808,956,1832",
    [1931] = "阿比迪斯,CN,RETAIL,933,1931",
    [1932] = "阿曼尼,CN,RETAIL,761,1228,1932",
    [1933] = "安苏,CN,RETAIL",
    [1934] = "生态船,CN,RETAIL,1809,1934",
    [1935] = "阿斯塔洛,CN,RETAIL,720,803,932,1935",
    [1936] = "白骨荒野,CN,RETAIL,828,1658,1936,1942",
    [1937] = "布鲁塔卢斯,CN,RETAIL,1495,1937,1965",
    [1938] = "达尔坎,CN,RETAIL,890,1233,1685,1938",
    [1939] = "末日行者,CN,RETAIL",
    [1940] = "达基萨斯,CN,RETAIL,712,1940,2137",
    [1941] = "熵魔,CN,RETAIL,708,753,822,867,1213,1815,1941",
    [1942] = "能源舰,CN,RETAIL,828,1658,1936,1942",
    [1943] = "菲米丝,CN,RETAIL,781,944,1943",
    [1944] = "加尔,CN,RETAIL,715,1944",
    [1945] = "迦顿,CN,RETAIL,719,1670,1945",
    [1946] = "血吼,CN,RETAIL,1801,1946",
    [1947] = "戈提克,CN,RETAIL,773,774,931,960,1205,1232,1508,1947,1970",
    [1948] = "盖斯,CN,RETAIL,766,1198,1948",
    [1949] = "壁炉谷,CN,RETAIL",
    [1950] = "贫瘠之地,CN,RETAIL",
    [1955] = "霍格,CN,RETAIL,794,1955",
    [1965] = "奎尔丹纳斯,CN,RETAIL,1495,1937,1965",
    [1969] = "萨洛拉丝,CN,RETAIL,917,1969",
    [1970] = "沙怒,CN,RETAIL,773,774,931,960,1205,1232,1508,1947,1970",
    [1971] = "嚎风峡湾,CN,RETAIL,784,1971",
    [1972] = "斯克提斯,CN,RETAIL",
    [2118] = "迦拉克隆,CN,RETAIL",
    [2119] = "奥杜尔,CN,RETAIL,737,1511,2119",
    [2120] = "奥尔加隆,CN,RETAIL,864,2120,2124",
    [2121] = "安格博达,CN,RETAIL,758,2121",
    [2122] = "安加萨,CN,RETAIL,1241,2122",
    [2123] = "织亡者,CN,RETAIL,700,788,1214,1223,1507,1517,1659,1793,2123",
    [2124] = "亡语者,CN,RETAIL,864,2120,2124",
    [2125] = "达克萨隆,CN,RETAIL,1210,2125",
    [2126] = "黑锋哨站,CN,RETAIL,1221,2126",
    [2127] = "古达克,CN,RETAIL,775,2127",
    [2128] = "兰娜瑟尔,CN,RETAIL,769,2128",
    [2129] = "洛肯,CN,RETAIL,1225,2129",
    [2130] = "玛洛加尔,CN,RETAIL,744,827,2130",
    [2133] = "影之哀伤,CN,RETAIL",
    [2134] = "风暴峭壁,CN,RETAIL",
    [2135] = "远古海滩,CN,RETAIL",
    [2136] = "瓦拉纳,CN,RETAIL",
    [2137] = "冬拥湖,CN,RETAIL,712,1940,2137",
    [3751] = "丽丽（四川）,CN,RETAIL",
    [3752] = "晴日峰（江苏）,CN,RETAIL",
    [3755] = "辛达苟萨,CN,RETAIL,862,3755",
    [3757] = "时光之穴,CN,RETAIL",
    [3941] = "苏拉玛,CN,RETAIL",
    [3944] = "瓦里安,CN,RETAIL",
    [3945] = "竞技场勇士CN,CN,RETAIL",
    [4497] = "碧玉矿洞,CN,WRATH_CLASSIC",
    [4498] = "寒脊山小径,CN,WRATH_CLASSIC",
    [4499] = "埃提耶什,CN,WRATH_CLASSIC",
    [4500] = "龙之召唤,CN,WRATH_CLASSIC",
    [4501] = "加丁,CN,WRATH_CLASSIC",
    [4509] = "哈霍兰,CN,WRATH_CLASSIC",
    [4510] = "奥罗,CN,WRATH_CLASSIC",
    [4511] = "沙尔图拉,CN,WRATH_CLASSIC",
    [4512] = "莫格莱尼,CN,WRATH_CLASSIC",
    [4513] = "希尔盖,CN,WRATH_CLASSIC",
    [4520] = "匕首岭,CN,WRATH_CLASSIC",
    [4521] = "厄运之槌,CN,WRATH_CLASSIC",
    [4522] = "雷霆之击,CN,WRATH_CLASSIC",
    [4523] = "法尔班克斯,CN,WRATH_CLASSIC",
    [4524] = "赫洛德,CN,WRATH_CLASSIC",
    [4531] = "布鲁,CN,WRATH_CLASSIC",
    [4532] = "范克瑞斯,CN,WRATH_CLASSIC",
    [4533] = "维希度斯,CN,WRATH_CLASSIC",
    [4534] = "帕奇维克,CN,WRATH_CLASSIC",
    [4535] = "比格沃斯,CN,WRATH_CLASSIC",
    [4608] = "CN史诗地下城,CN,RETAIL",
    [4675] = "辛迪加,CN,WRATH_CLASSIC",
    [4707] = "霜语,CN,WRATH_CLASSIC",
    [4708] = "水晶之牙,CN,WRATH_CLASSIC",
    [4709] = "维克洛尔,CN,WRATH_CLASSIC",
    [4710] = "维克尼拉斯,CN,WRATH_CLASSIC",
    [4711] = "巴罗夫,CN,WRATH_CLASSIC",
    [4712] = "比斯巨兽,CN,WRATH_CLASSIC",
    [4767] = "诺格弗格,CN,WRATH_CLASSIC",
    [4768] = "毁灭之刃,CN,WRATH_CLASSIC",
    [4769] = "黑曜石之锋,CN,WRATH_CLASSIC",
    [4770] = "萨弗拉斯,CN,WRATH_CLASSIC",
    [4771] = "伦鲁迪洛尔,CN,WRATH_CLASSIC",
    [4772] = "灰烬使者,CN,WRATH_CLASSIC",
    [4773] = "怀特迈恩,CN,WRATH_CLASSIC",
    [4774] = "奥金斧,CN,WRATH_CLASSIC",
    [4775] = "骨火,CN,WRATH_CLASSIC",
    [4776] = "末日之刃,CN,WRATH_CLASSIC",
    [4777] = "震地者,CN,WRATH_CLASSIC",
    [4778] = "祈福,CN,WRATH_CLASSIC",
    [4779] = "辛洛斯,CN,WRATH_CLASSIC",
    [4780] = "觅心者,CN,WRATH_CLASSIC",
    [4781] = "狮心,CN,WRATH_CLASSIC",
    [4782] = "审判,CN,WRATH_CLASSIC",
    [4783] = "无尽风暴,CN,WRATH_CLASSIC",
    [4784] = "巨龙追猎者,CN,WRATH_CLASSIC",
    [4785] = "灵风,CN,WRATH_CLASSIC",
    [4786] = "卓越,CN,WRATH_CLASSIC",
    [4787] = "狂野之刃,CN,WRATH_CLASSIC",
    [4788] = "巨人追猎者,CN,WRATH_CLASSIC",
    [4789] = "秩序之源,CN,WRATH_CLASSIC",
    [4790] = "奎尔塞拉,CN,WRATH_CLASSIC",
    [4791] = "碧空之歌,CN,WRATH_CLASSIC",
    [4818] = "艾隆纳亚,CN,WRATH_CLASSIC",
    [4819] = "席瓦莱恩,CN,WRATH_CLASSIC",
    [4820] = "火锤,CN,WRATH_CLASSIC",
    [4821] = "沙顶,CN,WRATH_CLASSIC",
    [4822] = "德姆塞卡尔,CN,WRATH_CLASSIC",
    [4824] = "怒炉,CN,WRATH_CLASSIC",
    [4827] = "无畏,CN,WRATH_CLASSIC",
    [4829] = "安娜丝塔丽,CN,WRATH_CLASSIC",
    [4832] = "雷德,CN,WRATH_CLASSIC",
    [4833] = "曼多基尔,CN,WRATH_CLASSIC",
    [4834] = "娅尔罗,CN,WRATH_CLASSIC",
    [4837] = "范沃森,CN,WRATH_CLASSIC",
    [4847] = "光芒,CN,WRATH_CLASSIC",
    [4913] = "寒冰之王,CN,WRATH_CLASSIC",
    [4920] = "龙牙,CN,WRATH_CLASSIC",
    [4924] = "法琳娜,CN,WRATH_CLASSIC",
    [4925] = "湖畔镇,CN,WRATH_CLASSIC",
    [4926] = "克罗米,CN,WRATH_CLASSIC",
    [4938] = "无敌,CN,WRATH_CLASSIC",
    [4939] = "冰封王座,CN,WRATH_CLASSIC",
    [4940] = "巫妖王,CN,WRATH_CLASSIC",
    [4941] = "银色北伐军,CN,WRATH_CLASSIC",
    [4942] = "吉安娜,CN,WRATH_CLASSIC",
    [4943] = "死亡猎手,CN,WRATH_CLASSIC",
    [4945] = "红玉圣殿,CN,WRATH_CLASSIC",
    [5303] = "硬汉,CN,CLASSIC",
    [5306] = "伊森迪奥斯,CN,CLASSIC,5306,5307,5314,5318,5328",
    [5307] = "克罗米,CN,CLASSIC",
    [5308] = "法琳娜,CN,CLASSIC,5308,5322,5376",
    [5310] = "龙牙,CN,CLASSIC,5310,5323,5360,5364,5371,5372",
    [5314] = "萨弗隆,CN,CLASSIC",
    [5315] = "光芒,CN,CLASSIC,5315,5317,5321,5377,5379",
    [5317] = "无畏,CN,CLASSIC,5315,5317,5321,5377,5379",
    [5318] = "乌洛克,CN,CLASSIC,5306,5307,5314,5318,5328",
    [5319] = "法拉克斯,CN,CLASSIC,5319,5380,5381",
    [5320] = "怒炉,CN,CLASSIC,5320,5324,5326,5361,5373",
    [5321] = "吉兹洛克,CN,CLASSIC",
    [5322] = "德姆塞卡尔,CN,CLASSIC,5308,5322,5376",
    [5323] = "沙顶,CN,CLASSIC",
    [5324] = "火锤,CN,CLASSIC,5320,5324,5326,5361,5373",
    [5325] = "席瓦莱恩,CN,CLASSIC,5325,5327,5330,5363",
    [5326] = "艾隆纳亚,CN,CLASSIC,5320,5324,5326,5361,5373",
    [5327] = "辛洛斯,CN,CLASSIC,5325,5327,5330,5363",
    [5328] = "祈福,CN,CLASSIC,5306,5307,5314,5318,5328",
    [5329] = "震地者,CN,CLASSIC,5329,5365,5374,5375",
    [5330] = "末日之刃,CN,CLASSIC,5325,5327,5330,5363",
    [5359] = "骨火,CN,CLASSIC,5359,5366,5367,5368,5369,5378",
    [5360] = "奥金斧,CN,CLASSIC,5310,5323,5360,5364,5371,5372",
    [5361] = "怀特迈恩,CN,CLASSIC,5320,5324,5326,5361,5373",
    [5362] = "灰烬使者,CN,CLASSIC",
    [5363] = "伦鲁迪洛尔,CN,CLASSIC,5325,5327,5330,5363",
    [5364] = "黑曜石之锋,CN,CLASSIC,5310,5323,5360,5364,5371,5372",
    [5365] = "毁灭之刃,CN,CLASSIC,5329,5365,5374,5375",
    [5366] = "诺格弗格,CN,CLASSIC,5359,5366,5367,5368,5369,5378",
    [5367] = "维克洛尔,CN,CLASSIC,5359,5366,5367,5368,5369,5378",
    [5368] = "水晶之牙,CN,CLASSIC",
    [5369] = "霜语,CN,CLASSIC,5359,5366,5367,5368,5369,5378",
    [5370] = "辛迪加,CN,CLASSIC",
    [5371] = "萨弗拉斯,CN,CLASSIC,5310,5323,5360,5364,5371,5372",
    [5372] = "希尔盖,CN,CLASSIC,5310,5323,5360,5364,5371,5372",
    [5373] = "莫格莱尼,CN,CLASSIC,5320,5324,5326,5361,5373",
    [5374] = "沙尔图拉,CN,CLASSIC,5329,5365,5374,5375",
    [5375] = "奥罗,CN,CLASSIC,5329,5365,5374,5375",
    [5376] = "哈霍兰,CN,CLASSIC,5308,5322,5376",
    [5377] = "加丁,CN,CLASSIC,5315,5317,5321,5377,5379",
    [5378] = "龙之召唤,CN,CLASSIC,5359,5366,5367,5368,5369,5378",
    [5379] = "埃提耶什,CN,CLASSIC,5315,5317,5321,5377,5379",
    [5380] = "寒脊山小径,CN,CLASSIC,5319,5380,5381",
    [5381] = "碧玉矿洞,CN,CLASSIC,5319,5380,5381",
    [5384] = "阿什坎迪,CN,CLASSIC,5384,5389,5390,5392,5393,5394,5409,5436,5440,5477",
    [5385] = "碧空之歌,CN,CLASSIC,5385,5457,5474,5475,5478",
    [5386] = "木喉要塞,CN,CLASSIC",
    [5387] = "比格沃斯,CN,CLASSIC,5387,5391,5398,5434,5444,5446,5473,5476,5500",
    [5388] = "帕奇维克,CN,CLASSIC,5388,5395,5396,5401,5402,5404",
    [5389] = "诺克赛恩,CN,CLASSIC",
    [5390] = "奎尔塞拉,CN,CLASSIC,5384,5389,5390,5392,5393,5394,5409,5436,5440,5477",
    [5391] = "秩序之源,CN,CLASSIC,5387,5391,5398,5434,5444,5446,5473,5476,5500",
    [5392] = "巨人追猎者,CN,CLASSIC,5384,5389,5390,5392,5393,5394,5409,5436,5440,5477",
    [5393] = "狂野之刃,CN,CLASSIC,5384,5389,5390,5392,5393,5394,5409,5436,5440,5477",
    [5394] = "卓越,CN,CLASSIC,5384,5389,5390,5392,5393,5394,5409,5436,5440,5477",
    [5395] = "灵风,CN,CLASSIC",
    [5396] = "巨龙追猎者,CN,CLASSIC,5388,5395,5396,5401,5402,5404",
    [5397] = "无尽风暴,CN,CLASSIC",
    [5398] = "审判,CN,CLASSIC,5387,5391,5398,5434,5444,5446,5473,5476,5500",
    [5399] = "狮心,CN,CLASSIC",
    [5400] = "觅心者,CN,CLASSIC,5397,5400,5403,5406,5407,5441,5472",
    [5401] = "比斯巨兽,CN,CLASSIC,5388,5395,5396,5401,5402,5404",
    [5402] = "巴罗夫,CN,CLASSIC",
    [5403] = "维克尼拉斯,CN,CLASSIC,5397,5400,5403,5406,5407,5441,5472",
    [5404] = "维希度斯,CN,CLASSIC,5388,5395,5396,5401,5402,5404",
    [5405] = "范克瑞斯,CN,CLASSIC,5405,5438,5439,5442,5443",
    [5406] = "布鲁,CN,CLASSIC,5397,5400,5403,5406,5407,5441,5472",
    [5407] = "赫洛德,CN,CLASSIC,5397,5400,5403,5406,5407,5441,5472",
    [5408] = "法尔班克斯,CN,CLASSIC,5399,5408,5435,5437,5448",
    [5409] = "雷霆之击,CN,CLASSIC,5384,5389,5390,5392,5393,5394,5409,5436,5440,5477",
    [5410] = "厄运之槌,CN,CLASSIC,5410,5411,5449",
    [5411] = "匕首岭,CN,CLASSIC,5410,5411,5449",
    [5434] = "拉姆斯登,CN,CLASSIC,5387,5391,5398,5434,5444,5446,5473,5476,5500",
    [5435] = "安娜丝塔丽,CN,CLASSIC,5399,5408,5435,5437,5448",
    [5436] = "塞雷布拉斯,CN,CLASSIC,5384,5389,5390,5392,5393,5394,5409,5436,5440,5477",
    [5437] = "雷德,CN,CLASSIC,5399,5408,5435,5437,5448",
    [5438] = "曼多基尔,CN,CLASSIC,5405,5438,5439,5442,5443",
    [5439] = "娅尔罗,CN,CLASSIC,5405,5438,5439,5442,5443",
    [5440] = "塞卡尔,CN,CLASSIC,5384,5389,5390,5392,5393,5394,5409,5436,5440,5477",
    [5441] = "迈克斯纳,CN,CLASSIC,5397,5400,5403,5406,5407,5441,5472",
    [5442] = "范沃森,CN,CLASSIC,5405,5438,5439,5442,5443",
    [5443] = "寒冰之王,CN,CLASSIC,5405,5438,5439,5442,5443",
    [5444] = "布劳缪克丝,CN,CLASSIC",
    [5446] = "阿鲁高,CN,CLASSIC,5387,5391,5398,5434,5444,5446,5473,5476,5500",
    [5448] = "弗莱拉斯,CN,CLASSIC",
    [5449] = "湖畔镇,CN,CLASSIC,5410,5411,5449",
    [5453] = "铁血,CN,CLASSIC",
    [5455] = "铁血II,CN,CLASSIC",
    [5457] = "维克托,CN,CLASSIC",
    [5472] = "巨龙沼泽,CN,CLASSIC,5397,5400,5403,5406,5407,5441,5472",
    [5473] = "黑石山,CN,CLASSIC,5387,5391,5398,5434,5444,5446,5473,5476,5500",
    [5474] = "圣光之愿,CN,CLASSIC,5385,5457,5474,5475,5478",
    [5475] = "神谕林地,CN,CLASSIC,5385,5457,5474,5475,5478",
    [5476] = "流沙岗哨,CN,CLASSIC,5387,5391,5398,5434,5444,5446,5473,5476,5500",
    [5477] = "祖尔格拉布,CN,CLASSIC",
    [5478] = "甲虫之墙,CN,CLASSIC,5385,5457,5474,5475,5478",
    [5500] = "阿拉希盆地,CN,CLASSIC,5387,5391,5398,5434,5444,5446,5473,5476,5500",
    [6118] = "无情,CN,CLASSIC",
}