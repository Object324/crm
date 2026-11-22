<script language="javascript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/tiledsearch.js"></script>
<script>
	var is_admin = '{$is_admin}';//管理员才有保存条件按钮
	//zkt 20220527 52051（https://81mis.com/kfbtest）客户管理》客户地图》查询字段创建人    选择条件没有当前用户选项
	var Listpagepopupobj=new CrmPopup();
	Listpagepopupobj.type=ListPagePopup.type;
	Listpagepopupobj.divid='pagecontent1';
	Listpagepopupobj.searchtype="";//基本查询和高级查询，32156: 单据列表：设置高级查询后，切换查看范围时，不清空高级查询条件
	Listpagepopupobj.module='{$MODULE}';
	CrmPopup.global_listPopupObj.push(Listpagepopupobj);
	Listpagepopupobj.pagetype=ListPagePopup.pagetype;
	var editviewinfojsonobj=JSON.stringify({$FIELDINFOJSON});
	if(editviewinfojsonobj!=null&&editviewinfojsonobj!=undefined&&editviewinfojsonobj!=''){
		var fieldinfoobjs=  eval('('+ editviewinfojsonobj +')')?eval('('+ editviewinfojsonobj +')'):JSON.parse(editviewinfojsonobj);
	}
	Listpagepopupobj.fields=fieldinfoobjs;
	var i
	var autohideafterfinding = '{$autohideafterfinding}';
	function goBackChinaMap(){
		//	window.location.href='index.php?module=ChinaMap&action=index';
		var urlstring="index.php?module=ChinaMap&file=index&action=ChinaMapAjax";
		ldAjaxHtml(urlstring,{},function(data){
			listcontentobj.html(data);
			DelProgressObjs();
		});
	}
	//zkt 20220401 50769: (https://www.51mis.com/hy/GDBPW/index.php [^] ) BPW客户 — 客户地图模块，进入该模块时，“平铺查找”根据上一次启用时决定是否展开
	function LocalTiledSearchstatus()
	{
		//获取浏览器记住的客户地图打开关闭状态
		var current_userid = CURRENT_USER_ID;
		var key = current_userid+'_chinamap_tiledsearchdivstatus';
		var showstatus = localStorage.getItem(key);
		if(showstatus == 'show'&&ld('#tiledSearch').is(":hidden"))
		{
			TiledSearchShow('init');
		}
		else if(showstatus == 'hidden'&&!ld('#tiledSearch').is(":hidden"))
		{
			TiledSearchShow('init');
		}
	}
	//平铺查找点击 zxm 2021-1015
	function TiledSearchShow(type) {
		if(type=="init"){
			//搜索div展示
			ld('#tiledSearch').toggle();
		}
		var current_userid = CURRENT_USER_ID;
		var key = current_userid+'_chinamap_tiledsearchdivstatus';
		//重置列表区域高度
		if(ld('#tiledSearch').is(":hidden")){
			chang_content_table_divid_height('hidden');
			// ld('#main #map_bill_state').css('top','50px');
			// ld('#main #china_map').css('top','120px');
			// ld('#main #proe_map').css('top','120px');
			localStorage.setItem(key,'hidden');
		}else{
			chang_content_table_divid_height('show');
			// ld('#main #map_bill_state').css('top',ld('#tiledSearch').get(0).clientHeight+55+'px');
			// ld('#main #china_map').css('top',ld('#tiledSearch').get(0).clientHeight+125+'px');
			// ld('#main #proe_map').css('top',ld('#tiledSearch').get(0).clientHeight+125+'px');
			localStorage.setItem(key,'show');
		}
	}
	//保存查询条件 仅管理员有这个操作
	function saveMapSearch(){
		var urlstring = getUrlString('Tiled');
		if(urlstring==false){
			return false;
		}
		var url = 'index.php?module=ChinaMap&action=ChinaMapAjax&file=SearchHistory&mode=save';
		ldAjax(url,urlstring,function(data){
			var msg;
			if(data.code==1){
				msg = arrJsPopLabel['SAVE']+arrJsPopLabel['SUCCESS'];
			}else{
				msg = arrJsPopLabel['SAVE']+arrJsPopLabel['LOSE'];
			}
			//wym 240110 BUG20240109-24 客户地图-平铺查找-点击保存条件，保存成功的提示信息图片样式错误
			MessagePopup.TipOne_success(msg);
			DelProgressObjs();
		});
	}
	function callMapSearch(status){
		if (status === 'no'){
			TiledSearchShow('init');
		}
		var searchlevel = ld('#searchlevel').val();
		if(searchlevel=='proe'){
			if(status == 'no' || status == 'yes'){
				status = ld('#searchmapproe').val();
			}
			renderProe(status);
		}else if(searchlevel=='city'){

		}else{
			renderChina(status);
		}
	}

	function getUrlString(searchtype)
	{
		var Module_SmOwnerSearchScope;	//查看范围
		if(document.getElementById('Module_SmOwnerSearchScope') != undefined){
			Module_SmOwnerSearchScope = document.getElementById('Module_SmOwnerSearchScope').value;
		}
		var module = '{$MODULE}';
		var urlstring = '';
		if(!tiled_checkAdvancedFilter()) return false;
		var tiledsearch_criteria = $('tiledsearch_criteria').value;
		var tiledsearch_criteria_groups = $('tiledsearch_criteria_groups').value;
		urlstring += '&advft_criteria='+encodeURIComponent(tiledsearch_criteria)+'&advft_criteria_groups='+tiledsearch_criteria_groups+'&';
		urlstring=urlstring+'SearchScope='+Module_SmOwnerSearchScope+'&';
		urlstring += 'searchtype=TiledSearch';
		return urlstring;
	}
</script>
{*//wym 230505 客户地图高级查找添加搜索功能*}
<div id="ListViewContents" >
<div style="display:none;">
    <form name="UnifiedScope" method="post" action="index.php?action=index&module=ChinaMap&scope=true">
		<input type="hidden" value="ChinaMap" id="module" name="module"  />
		<input type="hidden" value="" id="hiddenscope" name="hiddenscope"  />
        <input type="hidden" value="" id="selectuid" name="selectuid" value="{$SENIORUSERIDSS}" />
		<input type="hidden" id="homecontrol" name="homecontrol" value='{$HOMECONTROL}'/>
		<input type="hidden" id="searchtype" name="searchtype" value='TiledSearch'/>
		{*地图等级 默认国家-中国*}
		<input type="hidden" id="searchlevel" name="searchlevel" value='china'/>
		<input type="hidden" id="searchmapproe" name="searchmapproe" value=''/>
    </form>
</div>
<div id="country_div" class="retPro" style="float: left;height:35px;line-height:35px;margin-left: 15px;position: relative;padding: 4px 0 0 0;display: none;">
	<input class="ld-button ld-button-primary" onclick="goBackChinaMap()" type="button" name="goBackChinaMap" value="{'RETURNCOUNTRY'|@getFixedLabel}"/>
</div>
<div style="display:flex;justify-content: center">
	<div>
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
	{*				<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0" name="cmb_span_optiontext_{$fldname}" onclick="cmb_picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}','dv_chzn_{$fldname}')" value="{$module_optText}">*}
					<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0" name="cmb_span_optiontext_{$fldname}" onclick="cmb_picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}','Home_Map_Module_Showselect')" placeholder="{$module_optText}">
					<div>
						<b></b>
					</div>
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
	{*显示隐藏保存查询条件 仅管理员有这个操作*}
{*	{if $is_admin=='on'}*}
	<div style="line-height: 32px;">
		<div style="padding-left:44px;padding-right:5px;">
			<a href="javascript:void(0);" style="color:#555;" onclick="TiledSearchShow('init')"><b class="icon-categorybtn categoryAdvsear-search2"></b>{'TILEDSEARCH'|@getFixedLabel}</a>
		</div>
	</div>
{*	{/if}*}
</div>


<div style="z-index: 1;position: relative;">
	{include file="TiledSearch.tpl"  SOURCE='customview' COLUMNS_BLOCK=$FIELDNAMES}
</div>
<div id="main" style="position: relative;z-index: 0;">
	<div style="width:100%;margin:0 auto;position:relative;text-align:center;top: 20px;z-index:333;" id="map_bill_state">
		<div style="margin-bottom:10px;"><span style="background: #65a5e6;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
		  {'thattheprovincehascustomers'|@getFixedLabel}</div>
		{if $LANGUAGETYPE eq 'zh'}
			<div style="width:100%;margin:0 auto;position:relative;text-align:center;left:7px;"><span style="background: #FFEFD5;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
		  {'indicatesthattheprovincehasnocustomers'|@getFixedLabel}</div>
		{else}
			<div style="width:100%;margin:0 auto;position:relative;text-align:center;left:10px;"><span style="background: #FFEFD5;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
		  {'indicatesthattheprovincehasnocustomers'|@getFixedLabel}</div>
		{/if}
	</div>
	<div id="china_map" style="width:100%;margin:0 auto;position: relative;top:60px;display: block;"></div>
	<div id="proe_map" style="width:100%;margin:0 auto;position: relative;top:60px;display: none;"></div>
</div>
</div>
<script language="JavaScript" type="text/javascript">
var chart;
var option;
var myChartProe;
var myChartOption;
var accountNumLabel = "{'THECUSTOMERNUMER'|@getFixedLabel}";
{literal}

	ld().ready(function(){
		//if(is_admin!="on"){
			//非管理员 平铺查找一直显示  可以点击按钮显示隐藏
			//ld('#tiledSearch').show();
			chang_content_table_divid_height('show');
			// ld('#main #map_bill_state').css('top',ld('#tiledSearch').get(0).clientHeight+55+'px');
			// ld('#main #china_map').css('top',ld('#tiledSearch').get(0).clientHeight+55+'px');
			// ld('#main #proe_map').css('top',ld('#tiledSearch').get(0).clientHeight+55+'px');
		//}

	    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
		{
			//通讯录(pc端企业微信)
			cls_wxOpenDataobj.bindAllOpenData();
		}
		var _clientHeight = document.documentElement.clientHeight;
		var _clientWidth  = ld('#pagecontent').get(0).clientWidth;
		_clientHeight = _clientHeight - 50-37-25-50-35;
		if(_clientHeight > 0){
			var china_map_height = _clientHeight-10;
			ld("#china_map").height(china_map_height+"px");
			ld("#proe_map").height(china_map_height-20+"px");
		}
		ld("#proe_map").width(_clientWidth-16+"px");
        LocalTiledSearchstatus();//加载客户地图获取上一次平铺查找的打开关闭状态
		renderChina();
        
	});

	function renderChina(status){
		ld.get('chinamap/json/china.json', function (mapJson) {
			echarts.registerMap('china', mapJson);
			chart = echarts.init(document.getElementById('china_map'));//在id为mainMap的dom元素中显示地图
			var Module_SmOwnerSearchScope;	//查看范围
			if(document.getElementById('Module_SmOwnerSearchScope') != undefined){
				Module_SmOwnerSearchScope = document.getElementById('Module_SmOwnerSearchScope').value;
			}
			option = {
				tooltip: {
					trigger: 'item',
					backgroundColor:"#ffffff",//提示标签背景颜色
					textStyle:{color:"#000000"}, //提示标签字体颜色
					//@edit:liujiajun,2023-07-06,reason:BUG0069244:客户地图区域名称由显示变为隐藏，鼠标悬浮在相应地区后显示地区名字和客户数量
					formatter: function (result){//回调函数，参数params具体格式参加官方API
						if(isNaN(result.value)) {
							result.value=0;
						}
						return result.name+'<br/>'+accountNumLabel+': '+result.value;
					}
				},
				dataRange:{
					min:0,
					max:50,
					splitNumber:0,
					text:['高','低'],
					calculable:false,
					selectedMode:false,
					realtime:false,
					show:false,
					itemWidth:10,
					itemHeight:60,
                    //zkt 20220401 50768: (https://www.51mis.com/hy/GDBPW/index.php [^] ) BPW客户 — 客户地图模块，客户数量越多，反而该地区的颜色越浅（实际应该客户越多颜色越深）
					color:['#3B7CFF','lightskyblue']
				},
				title:{
					text:arrJsPopLabel['ANTIONALDATAOVERVIEW'],
					//subtext:'',
					x:'center',
					y:'top',
					textAlign:'left'
				},
				series: [{
					type: 'map',
					map: 'china',//要和echarts.registerMap（）中第一个参数一致
					roam:true,
					scaleLimit: { min: 1.2, max: 3.9 },    //缩放
					mapLocation:{
						x : 'center',
						y : 'center'
					},
					itemStyle:{
						normal: {
							borderWidth: .5,//区域边框宽度
							borderColor: '#009fe8',//区域边框颜色
							areaColor:"#ffefd5",//区域颜色
						},
						emphasis: {
							borderWidth: .5,
							borderColor: '#4b0082',
							areaColor:"#F09451",
						}
					},
					label: {
						normal: {
							show: false,//显示省份标签
							textStyle:{color:"#000000"}//省份标签字体颜色
						},
						emphasis: {//对应的鼠标悬浮效果
							show: false,
							textStyle:{color:"#800080"}
						}
					},
					data:[]

				}]
			};
			var urlstring = getUrlString('Tiled');
			if(urlstring==false||status=="no"){
				ld("#tiledSearch").hide();
				urlstring = '';
			}
			//获取平铺查找自动隐藏属性值
			if(ld("#Autohideafterfinding").length>0 && ld("#Autohideafterfinding").is(':checked') == true){
				ld("#tiledSearch").hide();
			}
			//zkt 20231013 XUQIU1001341 SQL注入
			ldAjax("index.php?module=Users&action=UsersAjax&file=ChinaMap&getCountry=true&bill_country=中国&SearchScope="+Module_SmOwnerSearchScope+urlstring,'',function(res){
				option.series[0].data = res;
				chart.setOption(option);
				TiledSearchShow('update');
				DelProgressObjs();
			});
			chart.off('click');
			//省份点击事件
			chart.on('click', function (result) {//回调函数，点击时触发，参数params格式参加官方API
				setTimeout(function () {
					ld('#china_map').css('display','none');
					ld('#city_map').css('display','none');
					ld('#country_div').css('display','block');
					ld('#map_bill_state').css('display','none');
					ld('#proe_map').css('display','block');
				}, 500);
				//选择省的单击事件
				var selectProe = result.name;
				ld('#searchmapproe').val(selectProe);
				renderProe(selectProe,Module_SmOwnerSearchScope);
			});
		});
	}
	//渲染省份
	function renderProe(selectProe,Module_SmOwnerSearchScope){
		ld('#searchlevel').val('proe');
		ld.get('chinamap/json/'+selectProe+'/'+selectProe+'.json', function(Citymap) {
			echarts.registerMap(selectProe, Citymap);
			myChartProe = echarts.init(document.getElementById('proe_map'));
			myChartOption = {
				tooltip: {
					trigger: 'item',
					backgroundColor:"#ffffff",//提示标签背景颜色
					textStyle:{color:"#000000"}, //提示标签字体颜色
					//@edit:liujiajun,2023-07-06,reason:BUG0069244:客户地图区域名称由显示变为隐藏，鼠标悬浮在相应地区后显示地区名字和客户数量
					formatter: function loadData(result){//回调函数，参数params具体格式参加官方API
						if(isNaN(result.value)) {
							result.value=0;
						}
						return result.name+'<br/>客户数: '+result.value;
					}
				},
				dataRange:{
					min:0,
					max:50,
					splitNumber:0,
					text:['高','低'],
					calculable:false,
					selectedMode:false,
					realtime:false,
					show:false,
					itemWidth:10,
					itemHeight:60,
					color:['lightskyblue','#3b7cff']
				},
				title:{
					text:selectProe+'数据总览',
					//subtext:'',
					x:'center',
					y:'top',
					textAlign:'left'
				},
				series: [{
					type: 'map',
					map: selectProe ,//要和echarts.registerMap（）中第一个参数一致
					roam:true,
					zoom:1.2,
					bottom:0,
					scaleLimit: { min: 1.2, max: 3.9 },//缩放
					mapLocation:{
						x : 'center',
						y : 'center'
					},
					itemStyle:{
						normal: {
							borderWidth: .5,//区域边框宽度
							borderColor: '#009fe8',//区域边框颜色
							areaColor:"#ffefd5",//区域颜色
						},
						emphasis: {
							borderWidth: .5,
							borderColor: '#4b0082',
							areaColor:"#F09451",
						}
					},
					label: {
						normal: {
							show: false,//显示省份标签
							textStyle:{color:"#000000"}//省份标签字体颜色
						},
						emphasis: {//对应的鼠标悬浮效果
							show: false,
							textStyle:{color:"#800080"}
						}
					},
					data : []
				}]
			};
			var urlstring = getUrlString('Tiled');
			if(urlstring==false||status=="no"){
				ld("#tiledSearch").hide();
				urlstring = '';
			}
			//获取平铺查找自动隐藏属性值
			if(ld("#Autohideafterfinding").length>0 && ld("#Autohideafterfinding").is(':checked') == true){
				ld("#tiledSearch").hide();
			}
			//zkt 20231013 XUQIU1001341 SQL注入
			ldAjax("index.php?module=Users&action=UsersAjax&file=ChinaMap&getCountry=true&bill_state="+encodeURIComponent(selectProe)+"&SearchScope="+Module_SmOwnerSearchScope+urlstring,'',function(res){
				myChartOption.series[0].data = res;
				myChartProe.setOption(myChartOption);
				TiledSearchShow('update');
				DelProgressObjs();
			});
			myChartProe.off('click');
			//城市单击事件
			myChartProe.on('click',function(rel){
				var selectCity = rel.name;
				renderCity(selectProe,selectCity,Module_SmOwnerSearchScope);
			})
		});
	}
	//城市跳转
	function renderCity(selectProe,selectCity,Module_SmOwnerSearchScope){
		ld('#searchlevel').val('city');
		if(selectCity == '昌吉'){
			selectCity = '昌吉回族自治州';
		}
		if(selectCity == '阿克苏'){
			selectCity = '阿克苏地区';
		}
		if(selectCity == '阿勒区'){
			selectCity = '阿勒泰地区';
		}
		if(selectCity == '伊犁'){
			selectCity = '伊犁哈萨克自治州';
		}
		var urlstring = getUrlString('Tiled');
		if(urlstring==false||status=="no"){
			ld("#tiledSearch").hide();
			urlstring = '';
		}
		//zkt 20231013 XUQIU1001341 SQL注入
		var tmpurlsting = "index.php?module=Users&action=UsersAjax&file=ChinaMap&bill_state="+encodeURIComponent(selectProe)+"&bill_city="+encodeURIComponent(selectCity)+"&SearchScope="+Module_SmOwnerSearchScope+urlstring;
		tmpurlsting= cls_encryptyurl.Puyoung_Encryptyurl(tmpurlsting,'');
		ldAjax(tmpurlsting,'',function () {
			var addurl = encodeURIComponent('&query_session=1');
			url = 'index.php?pageto_module=Accounts&pageto_action=ListView&page_addurl='+addurl;
			//zkt 20231013 XUQIU1001341 SQL注入
			url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
			DelProgressObjs();
			window.open(url);
		})
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
//不引入homestuff.js了 把这两个这里用到的方法先拿过来
function setScope(obj)
{

	if('smowner_search_senior' == obj){//高级
		SmOwnerSearchSeniorHome('Home',obj);return false;
	}
	document.getElementById('hiddenscope').value = obj;
	var add_url = '&scope=true'+'&hiddenscope='+ld('#hiddenscope').val()+'&selectuid='+ld('#selectuid').val()+'&homecontrol='+ld('#homecontrol').val();
	var surl = "index.php?pageto_action=index&pageto_module=ChinaMap&page_addurl="+encodeURIComponent(add_url);
	//zkt 20231013 XUQIU1001341 SQL注入
	surl= cls_encryptyurl.Puyoung_Encryptyurl(surl,'');
	window.location.href=surl;
	// UnifiedScope.submit();

}
function SmOwnerSearchSeniorHome(module,searchview){
	getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
		ScopePopup_Details.getInstance().SmOwnerSearchSenior(module,searchview,'home');
	});
}
{/literal}
</script>