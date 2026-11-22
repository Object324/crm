<script language="javascript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="javascript" type="text/javascript" src="{$JSURL}include/js/modules/Home/Homestuff.js"></script>
<div style="display:flex;justify-content: space-between;width:100%;">
    <div id="country_div" class="retPro" style="width:33%;height:35px;line-height:35px;margin-left: 15px;padding: 4px 0 0 0;visibility:hidden;">
        <input class="createauto" type="button" value="{'RETURNCOUNTRY'|@getFixedLabel}"/>
    </div>
    <div style="width:33%;display: flex;justify-content: center">
        <div class="Module_Showselect" style="" id="Home_Map_Module_Showselect">
            {assign var=fldname value='Module_SmOwnerSearchScope'}
            <label>{'VIEWRANGE'|@getFixedLabel}</label>
            <select onchange="setScope(this.value)" id="Module_SmOwnerSearchScope" name="Module_SmOwnerSearchScope" class="Sel_Owner" style="display:none">
                {foreach key=User_Key item=User_value from=$AccountMergeSmowner}
                    {foreach key=User_id item=User_name from=$User_value}
                        {foreach key=User_name_key item=User_name_value from=$User_name}
                            {if $User_id eq $module_ownerScope}
                                {assign var=module_optText value=$User_name_key}
                                <option value="{$User_id}" selected="true">{$User_name_key}</option>
                            {else}
                                <option value="{$User_id}">{$User_name_key}</option>
                            {/if}

                        {/foreach}
                    {/foreach}
                {/foreach}
            </select>
            <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','Home_Map_Module_Showselect')">
                <a style="width:117px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','Home_Map_Module_Showselect')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}">
                    <input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0" name="cmb_span_optiontext_{$fldname}" onclick="cmb_picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}','Home_Map_Module_Showselect')" value="{$module_optText}">
                </a>
                <div style=" left:-9000px;width: 117px; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
                    <ul class="chzn-results" name="cmb_ul_{$fldname}">
                        {assign var="i" value=0}
                        {foreach key=User_Key item=User_value from=$AccountMergeSmowner }
                            {foreach key=User_id item=User_name from=$User_value name=foo}
                                {foreach key=User_name_key item=User_name_value from=$User_name }
                                    <li userid='{$User_id}' class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}','Home_Map_Module_Showselect')" onmouseover="cmb_limouseover(event,'{$fldname}','Home_Map_Module_Showselect')">{$User_name_key}</li>
                                    {if $User_id eq 'smowner_search_senior'}
                                        {assign var="show" value=1}
                                    {/if}
                                    {assign var="i" value=$i+1}
                                {/foreach}
                            {/foreach}
                        {/foreach}
                        <li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                    </ul>
                </div>
            </div>
            {if $show eq 1}
                <a class="icon-range" href="javascript:void(0);" title="{'VIEWRANGE'|@getFixedLabel}"  onclick="SmOwnerScopehightuser()"></a>
            {/if}
        </div>
    </div>
    <div style="width:33%;display:flex;justify-content:flex-end;z-index:18;">
        <div class="Module_Showselect">
            <label>{"MAPSWITCH"|@getFixedLabel}</label>
            <select id="changeMap" class="Sel_Owner" onchange="changeMap(this)">
                <option value="country" selected="true">{"CHINA"|@getFixedLabel}</option>
                <option value="world">{"GLOBAL"|@getFixedLabel}</option>
            </select>
        </div>
    </div>
</div>

<div class="Ncon_top">
    <form name="UnifiedScope" method="post" action="index.php?action=index&module=ChinaMap&scope=true">
        <input type="hidden" value="ChinaMap" id="module" name="module"  />
        <input type="hidden" value="" id="hiddenscope" name="hiddenscope"  />
        <input type="hidden" value="" id="selectuid" name="selectuid" value="{$SENIORUSERIDSS}" />
        <input type="hidden" id="homecontrol" name="homecontrol" value='{$HOMECONTROL}'/>
    </form>
</div>

<div id="main">
    <div style="width:100%;margin:0 auto;position:absolute;text-align:center;top: 50px;left:10px;z-index:333;" id="map_bill_state">
        <div style="margin:0 auto;position:absolute;text-align:center;left:10px;"><span style="background: #65a5e6;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
            {'thattheprovincehascustomers'|@getFixedLabel}</div>
        {if $LANGUAGETYPE eq 'zh'}
            <div style="margin:20px auto;position:absolute;text-align:center;left:10px;"><span style="background: #D0D0D0;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
                {'indicatesthattheprovincehasnocustomers'|@getFixedLabel}</div>
        {else}
            <div style="margin:20px auto;position:absolute;text-align:center;left:10px;"><span style="background: #D0D0D0;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
                {'indicatesthattheprovincehasnocustomers'|@getFixedLabel}</div>
        {/if}
    </div>
    <div id="map" style="width:100%;margin:0 auto;display: block;"></div>
</div>
<script type="text/javascript">
    var myChart;
    var option;
    var type = "country";
    var selectProe = "中国";
    // 传参使用的变量
    var world = "world";
    var bill_country = "中国";
    var bill_state = "";
    var bill_city = "";
    {literal}
    var Module_SmOwnerSearchScope;
    if(document.getElementById('Module_SmOwnerSearchScope') != undefined){
        Module_SmOwnerSearchScope = document.getElementById('Module_SmOwnerSearchScope').value;
    }
    // 国家翻译
    var nameMap = {
        Afghanistan: '阿富汗',
        Singapore: '新加坡',
        Angola: '安哥拉',
        Albania: '阿尔巴尼亚',
        'United Arab Emirates': '阿联酋',
        Argentina: '阿根廷',
        Armenia: '亚美尼亚',
        'French Southern and Antarctic Lands':
            '法属南半球和南极领地',
        Australia: '澳大利亚',
        Austria: '奥地利',
        Azerbaijan: '阿塞拜疆',
        Burundi: '布隆迪',
        Belgium: '比利时',
        Benin: '贝宁',
        'Burkina Faso': '布基纳法索',
        Bangladesh: '孟加拉国',
        Bulgaria: '保加利亚',
        'The Bahamas': '巴哈马',
        'Bosnia and Herzegovina': '波斯尼亚和黑塞哥维那',
        Belarus: '白俄罗斯',
        Belize: '伯利兹',
        Bermuda: '百慕大',
        Bolivia: '玻利维亚',
        Brazil: '巴西',
        Brunei: '文莱',
        Bhutan: '不丹',
        Botswana: '博茨瓦纳',
        'Central African Republic': '中非共和国',
        Canada: '加拿大',
        Switzerland: '瑞士',
        Chile: '智利',
        China: '中国',
        'Ivory Coast': '象牙海岸',
        Cameroon: '喀麦隆',
        'Dem. Rep. Congo': '刚果民主共和国',
        'Republic of the Congo': '刚果共和国',
        Colombia: '哥伦比亚',
        'Costa Rica': '哥斯达黎加',
        Cuba: '古巴',
        'Northern Cyprus': '北塞浦路斯',
        Cyprus: '塞浦路斯',
        'Czech Republic': '捷克共和国',
        Germany: '德国',
        Djibouti: '吉布提',
        Denmark: '丹麦',
        'Dominican Republic': '多明尼加共和国',
        Algeria: '阿尔及利亚',
        Ecuador: '厄瓜多尔',
        Egypt: '埃及',
        Eritrea: '厄立特里亚',
        Spain: '西班牙',
        Estonia: '爱沙尼亚',
        Ethiopia: '埃塞俄比亚',
        Finland: '芬兰',
        Fiji: '斐',
        'Falkland Islands': '福克兰群岛',
        France: '法国',
        Gabon: '加蓬',
        'United Kingdom': '英国',
        Georgia: '格鲁吉亚',
        Ghana: '加纳',
        Guinea: '几内亚',
        Gambia: '冈比亚',
        'Guinea Bissau': '几内亚比绍',
        Greece: '希腊',
        Greenland: '格陵兰',
        Guatemala: '危地马拉',
        'French Guiana': '法属圭亚那',
        Guyana: '圭亚那',
        Honduras: '洪都拉斯',
        Croatia: '克罗地亚',
        Haiti: '海地',
        Hungary: '匈牙利',
        Indonesia: '印度尼西亚',
        India: '印度',
        Ireland: '爱尔兰',
        Iran: '伊朗',
        Iraq: '伊拉克',
        Iceland: '冰岛',
        Israel: '以色列',
        Italy: '意大利',
        Jamaica: '牙买加',
        Jordan: '约旦',
        Japan: '日本',
        Kazakhstan: '哈萨克斯坦',
        Kenya: '肯尼亚',
        Kyrgyzstan: '吉尔吉斯斯坦',
        Cambodia: '柬埔寨',
        Kosovo: '科索沃',
        Kuwait: '科威特',
        Laos: '老挝',
        Lebanon: '黎巴嫩',
        Liberia: '利比里亚',
        Libya: '利比亚',
        'Sri Lanka': '斯里兰卡',
        Lesotho: '莱索托',
        Lithuania: '立陶宛',
        Luxembourg: '卢森堡',
        Latvia: '拉脱维亚',
        Morocco: '摩洛哥',
        Moldova: '摩尔多瓦',
        Madagascar: '马达加斯加',
        Mexico: '墨西哥',
        Macedonia: '马其顿',
        Mali: '马里',
        Myanmar: '缅甸',
        Montenegro: '黑山',
        Mongolia: '蒙古',
        Mozambique: '莫桑比克',
        Mauritania: '毛里塔尼亚',
        Malawi: '马拉维',
        Malaysia: '马来西亚',
        Namibia: '纳米比亚',
        'New Caledonia': '新喀里多尼亚',
        Niger: '尼日尔',
        Nigeria: '尼日利亚',
        Nicaragua: '尼加拉瓜',
        Netherlands: '荷兰',
        Norway: '挪威',
        Nepal: '尼泊尔',
        'New Zealand': '新西兰',
        Oman: '阿曼',
        Pakistan: '巴基斯坦',
        Panama: '巴拿马',
        Peru: '秘鲁',
        Philippines: '菲律宾',
        'Papua New Guinea': '巴布亚新几内亚',
        Poland: '波兰',
        'Puerto Rico': '波多黎各',
        'North Korea': '北朝鲜',
        Portugal: '葡萄牙',
        Paraguay: '巴拉圭',
        Qatar: '卡塔尔',
        Romania: '罗马尼亚',
        Russia: '俄罗斯',
        Rwanda: '卢旺达',
        'Western Sahara': '西撒哈拉',
        'Saudi Arabia': '沙特阿拉伯',
        Sudan: '苏丹',
        'S. Sudan': '南苏丹',
        Senegal: '塞内加尔',
        'Solomon Islands': '所罗门群岛',
        'Sierra Leone': '塞拉利昂',
        'El Salvador': '萨尔瓦多',
        Somaliland: '索马里兰',
        Somalia: '索马里',
        'Republic of Serbia': '塞尔维亚',
        Suriname: '苏里南',
        Slovakia: '斯洛伐克',
        Slovenia: '斯洛文尼亚',
        Sweden: '瑞典',
        Swaziland: '斯威士兰',
        Syria: '叙利亚',
        Chad: '乍得',
        Togo: '多哥',
        Thailand: '泰国',
        Tajikistan: '塔吉克斯坦',
        Turkmenistan: '土库曼斯坦',
        'East Timor': '东帝汶',
        'Trinidad and Tobago': '特里尼达和多巴哥',
        Tunisia: '突尼斯',
        Turkey: '土耳其',
        'United Republic of Tanzania': '坦桑尼亚',
        Uganda: '乌干达',
        Ukraine: '乌克兰',
        Uruguay: '乌拉圭',
        'United States': '美国',
        Uzbekistan: '乌兹别克斯坦',
        Venezuela: '委内瑞拉',
        Vietnam: '越南',
        Vanuatu: '瓦努阿图',
        'West Bank': '西岸',
        Yemen: '也门',
        'South Africa': '南非',
        Zambia: '赞比亚',
        Korea: '韩国',
        Tanzania: '坦桑尼亚',
        Zimbabwe: '津巴布韦',
        Congo: '刚果',
        'Central African Rep.': '中非',
        Serbia: '塞尔维亚',
        'Bosnia and Herz.': '波黑',
        'Czech Rep.': '捷克',
        'W. Sahara': '西撒哈拉',
        'Lao PDR': '老挝',
        'Dem. Rep. Korea': '朝鲜',
        'Falkland Is.': '福克兰群岛',
        'Timor-Leste': '东帝汶',
        'Solomon Is.': '所罗门群岛',
        Palestine: '巴勒斯坦',
        'N. Cyprus': '北塞浦路斯',
        Aland: '奥兰群岛',
        'Fr. S. Antarctic Lands': '法属南半球和南极陆地',
        Mauritius: '毛里求斯',
        Comoros: '科摩罗',
        'Eq. Guinea': '赤道几内亚',
        'Guinea-Bissau': '几内亚比绍',
        'Dominican Rep.': '多米尼加',
        'Saint Lucia': '圣卢西亚',
        Dominica: '多米尼克',
        'Antigua and Barb.': '安提瓜和巴布达',
        'U.S. Virgin Is.': '美国原始岛屿',
        Montserrat: '蒙塞拉特',
        Grenada: '格林纳达',
        Barbados: '巴巴多斯',
        Samoa: '萨摩亚',
        Bahamas: '巴哈马',
        'Cayman Is.': '开曼群岛',
        'Faeroe Is.': '法罗群岛',
        'IsIe of Man': '马恩岛',
        Malta: '马耳他共和国',
        Jersey: '泽西',
        'Cape Verde': '佛得角共和国',
        'Turks and Caicos Is.': '特克斯和凯科斯群岛',
        'St. Vin. and Gren.': '圣文森特和格林纳丁斯'
    };
    var country = [
        {name: '阿富汗',},
        {name: '新加坡',},
        {name: '安哥拉',},
        {name: '阿尔巴尼亚',},
        {name: '阿联酋',},
        {name: '阿根廷',},
        {name: '亚美尼亚',},
        {name: '法属南半球和南极领地',},
        {name: '澳大利亚',},
        {name: '奥地利',},
        {name: '阿塞拜疆',},
        {name: '布隆迪',},
        {name: '比利时',},
        {name: '贝宁',},
        {name: '布基纳法索',},
        {name: '孟加拉国',},
        {name: '保加利亚',},
        {name: '巴哈马',},
        {name: '波斯尼亚和黑塞哥}维那',},
        {name: '白俄罗斯',},
        {name: '伯利兹',},
        {name: '百慕大',},
        {name: '玻利维亚',},
        {
            name: '巴西',
        },
        {
            name: '文莱',
        },
        {
            name: '不丹',
        },
        {
            name: '博茨瓦纳',
        },
        {
            name: '中非共和国',
        },
        {
            name: '加拿大',
        },
        {
            name: '瑞士',
        },
        {
            name: '智利',
        },
        {
            name: '中国',
        },
        {
            name: '象牙海岸',
        },
        {
            name: '喀麦隆',
        },
        {
            name: '刚果民主共和国',
        },
        {
            name: '刚果共和国',
        },
        {
            name: '哥伦比亚',
        },
        {
            name: '哥斯达黎加',
        },
        {
            name: '古巴',
        },
        {
            name: '北塞浦路斯',
        },
        {
            name: '塞浦路斯',
        },
        {
            name: '捷克共和国',
        },
        {
            name: '德国',
        },
        {
            name: '吉布提',
        },
        {
            name: '丹麦',
        },
        {
            name: '多明尼加共和国',
        },
        {
            name: '阿尔及利亚',
        },
        {
            name: '厄瓜多尔',
        },
        {
            name: '埃及',
        },
        {
            name: '厄立特里亚',
        },
        {
            name: '西班牙',
        },
        {
            name: '爱沙尼亚',
        },
        {
            name: '埃塞俄比亚',
        },
        {
            name: '芬兰',
        },
        {
            name: '斐',
        },
        {
            name: '福克兰群岛',
        },
        {
            name: '法国',
        },
        {
            name: '加蓬',
        },
        {
            name: '英国',
        },
        {
            name: '格鲁吉亚',
        },
        {
            name: '加纳',
        },
        {
            name: '几内亚',
        },
        {
            name: '冈比亚',
        },
        {
            name: '几内亚比绍',
        },
        {
            name: '希腊',
        },
        {
            name: '格陵兰',
        },
        {
            name: '危地马拉',
        },
        {
            name: '法属圭亚那',
        },
        {
            name: '圭亚那',
        },
        {
            name: '洪都拉斯',
        },
        {
            name: '克罗地亚',
        },
        {
            name: '海地',
        },
        {
            name: '匈牙利',
        },
        {
            name: '印度尼西亚',
        },
        {
            name: '印度',
        },
        {
            name: '爱尔兰',
        },
        {
            name: '伊朗',
        },
        {
            name: '伊拉克',
        },
        {
            name: '冰岛',
        },
        {
            name: '以色列',
        },
        {
            name: '意大利',
        },
        {
            name: '牙买加',
        },
        {
            name: '约旦',
        },
        {
            name: '日本',
        },
        {
            name: '哈萨克斯坦',
        },
        {
            name: '肯尼亚',
        },
        {
            name: '吉尔吉斯斯坦',
        },
        {
            name: '柬埔寨',
        },
        {
            name: '科索沃',
        },
        {
            name: '科威特',
        },
        {
            name: '老挝',
        },
        {
            name: '黎巴嫩',
        },
        {
            name: '利比里亚',
        },
        {
            name: '利比亚',
        },
        {
            name: '斯里兰卡',
        },
        {
            name: '莱索托',
        },
        {
            name: '立陶宛',
        },
        {
            name: '卢森堡',
        },
        {
            name: '拉脱维亚',
        },
        {
            name: '摩洛哥',
        },
        {
            name: '摩尔多瓦',
        },
        {
            name: '马达加斯加',
        },
        {
            name: '墨西哥',
        },
        {
            name: '马其顿',
        },
        {
            name: '马里',
        },
        {
            name: '缅甸',
        },
        {
            name: '黑山',
        },
        {
            name: '蒙古',
        },
        {
            name: '莫桑比克',
        },
        {
            name: '毛里塔尼亚',
        },
        {
            name: '马拉维',
        },
        {
            name: '马来西亚',
        },
        {
            name: '纳米比亚',
        },
        {
            name: '新喀里多尼亚',
        },
        {
            name: '尼日尔',
        },
        {
            name: '尼日利亚',
        },
        {
            name: '尼加拉瓜',
        },
        {
            name: '荷兰',
        },
        {
            name: '挪威',
        },
        {
            name: '尼泊尔',
        },
        {
            name: '新西兰',
        },
        {
            name: '阿曼',
        },
        {
            name: '巴基斯坦',
        },
        {
            name: '巴拿马',
        },
        {
            name: '秘鲁',
        },
        {
            name: '菲律宾',
        },
        {
            name: '巴布亚新几内亚',
        },
        {
            name: '波兰',
        },
        {
            name: '波多黎各',
        },
        {
            name: '北朝鲜',
        },
        {
            name: '葡萄牙',
        },
        {
            name: '巴拉圭',
        },
        {
            name: '卡塔尔',
        },
        {
            name: '罗马尼亚',
        },
        {
            name: '俄罗斯',
        },
        {
            name: '卢旺达',
        },
        {
            name: '西撒哈拉',
        },
        {
            name: '沙特阿拉伯',
        },
        {
            name: '苏丹',
        },
        {
            name: '南苏丹',
        },
        {
            name: '塞内加尔',
        },
        {
            name: '所罗门群岛',
        },
        {
            name: '塞拉利昂',
        },
        {
            name: '萨尔瓦多',
        },
        {
            name: '索马里兰',
        },
        {
            name: '索马里',
        },
        {
            name: '塞尔维亚',
        },
        {
            name: '苏里南',
        },
        {
            name: '斯洛伐克',
        },
        {
            name: '斯洛文尼亚',
        },
        {
            name: '瑞典',
        },
        {
            name: '斯威士兰',
        },
        {
            name: '叙利亚',
        },
        {
            name: '乍得',
        },
        {
            name: '多哥',
        },
        {
            name: '泰国',
        },
        {
            name: '塔吉克斯坦',
        },
        {
            name: '土库曼斯坦',
        },
        {
            name: '东帝汶',
        },
        {
            name: '特里尼达和多巴哥',
        },
        {
            name: '突尼斯',
        },
        {
            name: '土耳其',
        },
        {
            name: '坦桑尼亚',
        },
        {
            name: '乌干达',
        },
        {
            name: '乌克兰',
        },
        {
            name: '乌拉圭',
        },
        {
            name: '美国',
        },
        {
            name: '乌兹别克斯坦',
        },
        {
            name: '委内瑞拉',
        },
        {
            name: '越南',
        },
        {
            name: '瓦努阿图',
        },
        {
            name: '西岸',
        },
        {
            name: '也门',
        },
        {
            name: '南非',
        },
        {
            name: '赞比亚',
        },
        {
            name: '韩国',
        },
        {
            name: '坦桑尼亚',
        },
        {
            name: '津巴布韦',
        },
        {
            name: '刚果',
        },
        {
            name: '中非',
        },
        {
            name: '塞尔维亚',
        },
        {
            name: '波黑',
        },
        {
            name: '捷克',
        },
        {
            name: '西撒哈拉',
        },
        {
            name: '老挝',
        },
        {
            name: '朝鲜',
        },
        {
            name: '福克兰群岛',
        },
        {
            name: '东帝汶',
        },
        {
            name: '所罗门群岛',
        },
        {
            name: '巴勒斯坦',
        },
        {
            name: '北塞浦路斯',
        },
        {
            name: '奥兰群岛',
        },   {name: '法属南半球和南极陆地',},
        {
            name: '毛里求斯',
        },
        {
            name: '科摩罗',
        },
        {
            name: '赤道几内亚',
        },
        {
            name: '几内亚比绍',
        },
        {
            name: '多米尼加',
        },
        {
            name: '圣卢西亚',
        },
        {
            name: '多米尼克',
        },
        {
            name: '安提瓜和巴布达',
        },
        {
            name: '美国原始岛屿',
        },
        {
            name: '蒙塞拉特',
        },
        {
            name: '格林纳达',
        },
        {
            name: '巴巴多斯',
        },
        {
            name: '萨摩亚',
        },
        {
            name: '巴哈马',
        },
        {
            name: '开曼群岛',
        },
        {
            name: '法罗群岛',
        },
        {
            name: '马恩岛',
        },
        {
            name: '马耳他共和国',
        },
        {
            name: '泽西',
        },
        {
            name: '佛得角共和国',
        },
        {
            name: '特克斯和凯科斯群岛',
        },
        {
            name: '圣文森特和格林纳丁斯'
        }
        ];
    var province = [
        {name:"上海"},
        {name:"云南"},
        {name:"内蒙古"},
        {name:"北京"},
        {name:"台湾"},
        {name:"吉林"},
        {name:"四川"},
        {name:"天津"},
        {name:"宁夏"},
        {name:"安徽"},
        {name:"山东"},
        {name:"山西"},
        {name:"广东"},
        {name:"广西"},
        {name:"新疆"},
        {name:"江苏"},
        {name:"江西"},
        {name:"河北"},
        {name:"河南"},
        {name:"浙江"},
        {name:"海南"},
        {name:"湖北"},
        {name:"湖南"},
        {name:"澳门"},
        {name:"甘肃"},
        {name:"福建"},
        {name:"西藏"},
        {name:"贵州"},
        {name:"辽宁"},
        {name:"重庆"},
        {name:"陕西"},
        {name:"青海"},
        {name:"香港"},
        {name:"黑龙江"},
    ]
    ld().ready(function(){
        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
        {
            //通讯录(pc端企业微信)
            cls_wxOpenDataobj.bindAllOpenData();
        }
        var _clientHeight = window.screen.availHeight;
        var _clientWidth  = window.screen.availWidth;
        _clientHeight = _clientHeight - 50-37-25-50-35;
        if(_clientHeight > 0){
            var china_map_height = _clientHeight-10;
            ld("#map").height(china_map_height+"px");
        }
        ld("#map").width(_clientWidth-5+"px");

        /*echarts*/
        // 先看是否有缓存
        let storageType = localStorage.getItem('customMapType');

        let storageSelectProe = localStorage.getItem('customSelectProe')
        if(storageType && storageSelectProe) {
            type = storageType;
            selectProe = storageSelectProe;
            if(storageType == "world"){
                ld('#changeMap').val("world");
            }else{
                ld('#changeMap').val("country");
            }
            if(storageType == "proe"){
                ld('#country_div').css('visibility','visible')
            }else{
                ld('#country_div').css('visibility','hidden')
            }
        }
        getAjaxData(type,selectProe);

    });

    /**
     *全球-中国地图切换
     * @param obj
     */
    function changeMap(obj)
    {
        let type = ld(obj).val();
        let type_arr = {
            country:"中国",
            world:"全球"
        };
        if(type == "country"){
            bill_country = "中国";
        }else{
            bill_country = "";
        }
        ld('#country_div').css('visibility','hidden');
        getAjaxData(type,type_arr[type]);
    }

    /**
     * 地图点击事件
     * @param myChart
     * @param type
     * @param selectProe
     */
    function childClick(myChart,type,selectProe)
    {
        myChart.on("click",function(res){
            let selectName = res.name;
            if(selectName==""||selectName==undefined){
                return;
            }
            if(selectName == '昌吉'){
                selectName = '昌吉回族自治州';
            }
            if(selectName == '阿克苏'){
                selectName = '阿克苏地区';
            }
            if(selectName == '阿勒区'){
                selectName = '阿勒泰地区';
            }
            if(selectName == '伊犁'){
                selectName = '伊犁哈萨克自治州';
            }
            switch(type){
                case "world":type="country";break;
                case "country":type="proe";break;
                case "proe":type="city";break;
            }
            // 世界地图 国家地图 省份地图 则需要请求Ajax数据
            if(type == "world" || type == "country"|| type == "proe"){
                getAjaxData(type,selectName);
            }else{
                //城市 则跳转列表页面
                jumpToAccount(type,selectName,selectProe)
            }
            if((type == "country" && selectProe== "全球")||type=="proe"||type == "city"){
                ld('#changeMap').val("country");
            }else{
                ld('#changeMap').val("world");
            }
            if(type == "proe"){
                setTimeout(function () {
                    ld('#country_div').css('visibility','visible');
                }, 500);
                ld('#country_div').unbind('click').on('click',function(){
                    getAjaxData("country","中国");
                    ld('#country_div').css('visibility','hidden');
                });
            }
        });
    }

    /**
     * 地图点击之后 符合跳转页面条件的跳转方法 比如点击城市
     * @param type
     * @param selectName
     * @param selectProe
     */
    function jumpToAccount(type,selectName,selectProe)
    {
        //zkt 20231013 XUQIU1001341 SQL注入
        var urlsting = "index.php?module=Users&action=UsersAjax&file=ChinaMap&bill_state="+encodeURIComponent(selectProe)+"&bill_city="+encodeURIComponent(selectName)+"&SearchScope="+Module_SmOwnerSearchScope;
        urlstring= cls_encryptyurl.Puyoung_Encryptyurl(urlstring,'');
        ld.ajax(urlsting)
            .done(function(){
            let addurl = encodeURIComponent('&query_session=1');
            let url = 'index.php?pageto_module=Accounts&pageto_action=ListView&page_addurl='+addurl;
            url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
            window.open(url);
        })
    }

    /**
     * 渲染地图方法
     * @param data
     * @param type
     * @param selectProe
     */
    function renderChart(data,type,selectProe)
    {
        myChart = echarts.init(document.getElementById('map'));
        myChart.showLoading();
        let jsonUrl = '';
        let map_name = '';
        if(type == "world"){
            map_name = "world";
            jsonUrl = 'chinamap/json/'+type+'.json';
        }else if(type == "country"){
            map_name = selectProe;
            jsonUrl = 'chinamap/json/'+selectProe+'.json';
        }else{
            map_name = selectProe;
            jsonUrl = 'chinamap/json/'+selectProe+'/'+selectProe+'.json';
        }
        ld.get(jsonUrl, function (mapJson) {
            myChart.hideLoading();
            echarts.registerMap(map_name, mapJson);
            myChart.setOption(option = {
                title:{
                    text:selectProe+arrJsPopLabel['DATASCREENING'],
                    x:'center',
                    y:'top',
                    top:20,
                    textAlign:'left'
                },
                tooltip: {
                    trigger: 'item',
                    backgroundColor:"#000",//提示标签背景颜色
                    textStyle:{color:"#fff"}, //提示标签字体颜色
                    formatter: function (result){//回调函数，参数params具体格式参加官方API
                        if(!isNaN(result.value)){
                            return result.name+'<br />客户数:'+result.value;
                        }else{
                            return result.name;
                        }
                    }
                },
                toolbox: {
                    show: true,
                    orient: 'vertical',
                    left: 'right',
                    top: 'center',
                    feature: {
                        dataView: {readOnly: false},
                        restore: {},
                        saveAsImage: {}
                    }
                },
                // visualMap: {
                //     min: 1,
                //     text:['高','低'],
                //     realtime: false,
                //     calculable: true,
                //     inRange: {
                //         color: ['lightskyblue', 'yellow', 'orangered']
                //     }
                // },
                dataRange:{
                    min:0,
                    max:50,
                    splitNumber:0,
                    text:['高','低'],
                    calculable:true,
                    selectedMode:false,
                    realtime:false,
                    show:false,
                    itemWidth:10,
                    itemHeight:60,
                    color:['lightskyblue','#65a5e6']
                },
                series: [
                    {
                        type: 'map',
                        map: map_name, // 自定义扩展图表类型
                        roam:true,
                        top:90,
                        scaleLimit: { min: 1.2, max: 3.9 },    //缩放
                        mapLocation:{
                            x : 'left',
                            y : 'left'
                        },
                        itemSytle:{
                            normal: {
                                borderWidth: .5,//区域边框宽度
                                borderColor: '#009fe8',//区域边框颜色
                                areaColor:"#ffefd5",//区域颜色
                            },
                            emphasis: {
                                borderWidth: .5,
                                borderColor: '#4b0082',
                                areaColor:"#ffdead",
                            }
                        },
                        label: {
                            emphasis: {//对应的鼠标悬浮效果
                                show: true,
                                textStyle:{color:"#800080"}
                            }
                        },
                        data: data,
                        // 自定义名称映射
                        nameMap: nameMap
                    }
                ]
            });
        });

        myChart.off('click');
        // 仅世界地图 中国地图 中国省份地图支持下钻
        if(type=="world"||(selectProe=="中国")||type=="proe"){
            //需要再判断  世界地图的话有数据的国家才可下钻
            childClick(myChart,type,selectProe);
        }
    }

    /**
     * ajax获取地图的数据
     * @param type
     * @param selectProe
     */
    function getAjaxData(type,selectProe)
    {
        if(type == "world"){
            bill_country = "";
            bill_state = "";
            bill_city = "";
        }else if(type == "country"){
            bill_country = selectProe;
            bill_state = "";
            bill_city = "";
        }else if(type == "proe"){
            bill_state = selectProe;
            bill_city = "";
        }

        localStorage.setItem('customMapType',type);
        localStorage.setItem('customSelectProe',selectProe);
        let where = "&bill_country="+bill_country+"&bill_state="+bill_state;
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxHtmlNoProgress("index.php?module=Users&action=UsersAjax&file=ChinaMap&getCountry=true&SearchScope="+Module_SmOwnerSearchScope+"&type="+type+"&selectProe="+encodeURIComponent(selectProe)+where,'',function(res){
            renderChart(res,type,selectProe)
        });

    }
    function SmOwnerScopehightuser()
    {
        var fldname = 'Module_SmOwnerSearchScope';
        if(document.getElementById(fldname) != undefined){
            var objoption=document.getElementById(fldname);
            var optiontext='';
            picklist=true;
            if(objoption.length != undefined){
                for(var i=0;i<objoption.length;i++)
                {
                    if(objoption[i].value=='smowner_search_senior')
                    {
                        objoption[i].selected=true;
                        optiontext=objoption[i].text;
                        document.getElementById(fldname).options[i].selected=true;

                        document.getElementById(fldname).selectedIndex=i;
                        document.getElementById(fldname).options[i].value='smowner_search_senior';
                        if(typeof document.getElementById(fldname).onchange=='function')
                            document.getElementById(fldname).onchange();
                        if(typeof(fielddepend)!='undefined'&&fielddepend!=undefined)
                        {
                            var sourcename = objoption.name;
                            var sourcevalue = objoption.value;
                            //fielddepend.fieldValueChange(sourcename, sourcevalue);
                        }
                        break;
                    }
                }
                document.getElementById('cmb_span_optiontext_'+fldname).innerHTML=optiontext;
            }
        }
        //ld("#SmOwnerSearchScope").change();
    }
    {/literal}
</script>