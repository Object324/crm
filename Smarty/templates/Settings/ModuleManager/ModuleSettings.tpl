<script language="JavaScript" type="text/javascript" src="include/js/advancefilter.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript">
{literal}
//相关项目设置
 //edit:can 2021-03-15 044977: （https://61mis.com/kfbcrm [^]）进入页面设置后再进入单据查看详情界面，点击【相关信息设置】->【保存】，弹出层没有关闭
//相关信息显示设置保存
function saveRelatedList(){
	var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
	var selectedColumnsObj=getObj("selectedAssmablyColumns");
    var selectedColStr = "";
    //alert(selectedColumnsObj.options.length);
    
    for (i=0;i<selectedColumnsObj.options.length;i++) 
    {
        selectedColStr += selectedColumnsObj.options[i].value + ";"
    }
	 CrmPopup.findHtmlobj(divid,'selectedAssmablyColumnsString').val(selectedColStr);
    
    //document.getElementById['selectedAssmablyColumnsString'].value = selectedColStr;
    var ColumnsObj=getObj("AssmablyList")
    var ColStr = "";
    for (i=0;i<ColumnsObj.options.length;i++) 
    {
		ColStr += ColumnsObj.options[i].value + ";"
    }
	CrmPopup.findHtmlobj(divid,'AssmablyColumnsString').val(ColStr);
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: ld(document.forms['Saveresults']).serialize(),
			onComplete: function(response) {
				cancelCrmPopup();
			}
		}
		
	);
}
//快捷操作设置
function QuickSetactions(obj,module,BLOCKIDSETTING,FIELDIDSETTING)
{
    $('status').style.display = "block";
    
    new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: 'module=Settings&action=SettingsAjax&file=LayoutBlockList&backaction=ModuleSettings&sub_mode=QuickSetActions&parenttab=Settings&modulename='+module+'&ajax=true&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,
			onComplete: function(response) {
			if(response.responseText.indexOf('###SUCCESS###')>-1){
                var results=response.responseText.split('###SUCCESS###');
			    $("Quicksetactions_div").innerHTML=results[1];
                $('status').style.display = "none";
    			fnvshobj(obj, 'Quicksetactions_div');     
			 }
			      
			}
		}
		
	);
}
function checkoptionvalus(from,type)
{
    formSelectColumnString(type);
    /*
    if(type == '1')
    {
       if(document.forms['Saveresults'].selectedAssmablyColumnsString.value.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
       {
        alert('显示项目不能为空');
        return false;
       } 
    }
    else
    {
        if(document.forms['Quicksetactions'].beselected_module_String.value.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
        {
            alert('显示项目不能为空');
            return false;
        }
    }
    */
    
    from.submit();
}
function formSelectColumnString(type)
{   
    if(type == '1')
    {
        selectedColumnsObj=getObj("selectedAssmablyColumns");
    }
    else
    {
        selectedColumnsObj=getObj("beselected_module");
    }
    //selectedColumnsObj=getObj("selectedAssmablyColumns");
    var selectedColStr = "";
    //alert(selectedColumnsObj.options.length);
    
    for (i=0;i<selectedColumnsObj.options.length;i++) 
    {
        selectedColStr += selectedColumnsObj.options[i].value + ";"
    }
    if(type == '1')
    {
        document.forms['Saveresults'].selectedAssmablyColumnsString.value = selectedColStr;
    }
    else
    {
        document.forms['Quicksetactions'].beselected_module_String.value = selectedColStr;
    }
    
    //document.getElementById['selectedAssmablyColumnsString'].value = selectedColStr;
    if( type == '1')
    {
        ColumnsObj=getObj("AssmablyList")
    }
    else
    {
        ColumnsObj=getObj("tobeselecte_module")
    }
    var ColStr = "";
    for (i=0;i<ColumnsObj.options.length;i++) 
    {
    ColStr += ColumnsObj.options[i].value + ";"
    }
    if( type =='1')
    {
        document.forms['Saveresults'].AssmablyColumnsString.value = ColStr;
    }
    else
    {
        document.forms['Quicksetactions'].tobeselecte_module_String.value = ColStr;
    }
    
}
function ModuleDetailmoveUp(objid)
{
var elem = document.getElementById(objid);
    if(elem.options.selectedIndex>=0){
    	for (var i=1;i<elem.options.length;i++){
    		if(elem.options[i].selected == true){
    			//swap with one up
    			var first = elem.options[i-1];
    			var second = elem.options[i];
    			var temp = new Array();
    
    			temp.value = first.value;
    			temp.innerHTML = first.innerHTML;
    
    			first.value = second.value;
    			first.innerHTML = second.innerHTML;
    
    			second.value = temp.value;
    			second.innerHTML = temp.innerHTML;
    
    			first.selected = true;
    			second.selected = false;
    		}
    	}
    }
	
}
function ProductDetailmoveDown(objid)
{
var elem = document.getElementById(objid);
	if(elem.options.selectedIndex>=0){
		for (var i=elem.options.length-2;i>=0;i--){
			if(elem.options[i].selected == true){
				//swap with one down
				var first = elem.options[i+1];
				var second = elem.options[i];
				var temp = new Array();

				temp.value = first.value;
				temp.innerHTML = first.innerHTML;

				first.value = second.value;
				first.innerHTML = second.innerHTML;

				second.value = temp.value;
				second.innerHTML = temp.innerHTML;

				first.selected = true;
				second.selected = false;
			}
		}
	}
}
{/literal}</script>
<img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" id="vtbusy_info" style="display:none;position:fixed;top:10%;right:10%;position:fixed; z-index:99;" border="0" />
<div id="vtlib_modulemanager" style="display:block;position:absolute;width:500px;"></div>


<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_PAGE_SET'|@getFixedLabel}<font>（{'LBL_PAGE_SET_DESCRIPTION'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="vtlib_modulemanager_list" class="cont_wrap clear_float">
            <table id="modmgr_standard" class="settingTable fir-center" width="100%" cellspacing="0" cellpadding="0">
                <tbody>
                    <tr>
                        <th>#</th>
                        <th align="left" title="{"PARENTMENU"|@getFixedLabel}{"CHINESE"|@getFixedLabel}">{"PARENTMENU"|@getFixedLabel}{"CHINESE"|@getFixedLabel}</th>
                        <th align="left" title="{"PARENTMENU"|@getFixedLabel}{"ENGLISH"|@getFixedLabel}">{"PARENTMENU"|@getFixedLabel}{"ENGLISH"|@getFixedLabel}</th>
                       {if $LANGUAGETYPE eq 'zh'} 
                        <th width="170">{"OPERATING"|@getFixedLabel}</th> 
                        {else} 
                        <th width="290">{"OPERATING"|@getFixedLabel}
                        {/if}
                    </tr>
                    {assign var="modulenamenum" value='1'}
                    {assign var="i" value=0}
                    {foreach key=modulename item=modinfo from=$TOGGLE_MODINFO}
                    {if $modinfo.customized eq false}
                    {assign var="modulelabel" value=$modulename}
                        {if $modinfo.presence eq 0 && $modinfo.hassettings}
                        {assign var="j" value=$i++}
                        {if $j mod 2 eq '0'}
                            <tr id="setting_{$j}" class="lvtColData" onmouseout="settingListOnMouseOut({$j},'on');" onmouseover="settingListOnMouseOver({$j});">
                        {else}
                            <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="settingListOnMouseOut({$j},'On');" onmouseover="settingListOnMouseOver({$j});">
                        {/if} 
                          <td>{$modulenamenum}</td>
                          <td><span title="{$modinfo.label.zh}">{$modinfo.label.zh}</span></td>
                          <td><span title="{$modinfo.label.en}">{$modinfo.label.en}</span></td>
                          <td>
                            <a class="Anu3_a" tag="pagesettings" href="javascript:void(0);" modulesettingsmodulename='{$modulename}'>
                                {'LBL_PAGE_SET'|@getFixedLabel}
                            </a>
                            <a class="Anu3_a" href="javascript:void(0);" onclick="SetRelatedlists(this,'{$modulename}','{$BLOCKIDSETTING}','{$FIELDIDSETTING}')">{'PROJECTSETTINGS'|@getFixedLabel}</a>
                            <!--<a class="Anu3_a" href="javascript:void(0);" onclick="QuickSetactions(this,'{$modulename}','{$BLOCKIDSETTING}','{$FIELDIDSETTING}')">{'ASSOCIATIONTOCREATESET'|@getFixedLabel}</a>-->
                            {if $modulename eq "Documents" || $modulename eq "Faq" || $modulename eq "Calendar"}
                            {else}
                                <!-- <a class="Anu3_a" href="index.php?module=FieldFormulas&action=index&parenttab=Settings&formodule={$modulename}&parenttab=Settings&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}">
                                    {'FIELDFORMULAS'|@getFixedLabel}
                                </a> -->
                            {/if}
                          </td>
                        </tr>
                        {assign var="modulenamenum" value=$modulenamenum+1}
                        {/if}
                    {/if}
                    {/foreach}
                </tbody>
            </table>
        </div>
    </div>
</div>


<script  type="text/javascript">
{literal}

    function setPageSettingClick()
    {
    //页面设置按钮事件
   
        ld("[tag=pagesettings]").unbind("click").bind("click",function(){
                ld.ajax({
                    url:"index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList&formodule="+ld(this).attr('modulesettingsmodulename'),
                    type:"post",
                    dataType:"json",
                    success:function(data){
                            ld(" [name=SettingRightContent]").html(data.result.content);
                        // ld('.main_grid .main_grid_box').niceScroll({
                        //
                        //     touchbehavior:false,     //是否是触摸式滚动效果
                        //
                        //     cursorcolor:"#d8d8d8",     //滚动条的颜色值
                        //
                        //     cursoropacitymax:1,   //滚动条的透明度值
                        //
                        //     cursorwidth:6,         //滚动条的宽度值
                        //
                        //     background:"#fff",  //滚动条的背景色，默认是透明的
                        //
                        //     autohidemode:false,      //滚动条是否是自动隐藏，默认值为 true
                        //
                        //     cursorborder: 0,
                        //
                        // });
                        // ld('.main_grid .main_grid_box').getNiceScroll().resize();
                    }
                })
        })
    }
    ld(function(){

    setPageSettingClick();
    })
{/literal}
</script>