<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/colpick/colpick.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/colpick/plugin.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/SetUeryScope.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_TABLIST'|@getFixedLabel}
{*            	//@edit:liushuai,2020-8-7,reason:0042318: （https://61mis.com/kfbtest [^]）英文版本，系统设置中，“网页端菜单定制”和“移动端报表菜单定制”去掉标签右侧的英文提示信息*}
            {if $LANGUAGETYPE eq 'zh'}
                <font>（{'LBL_TABLIST_DESCRIPTION'|@getFixedLabel}）</font>
            {/if}
        </span>
    </div>
    <div class="grid_tool">
      <div class="displayflex">
          <a href="javascript:;" class="ld-button ld-button-primary" onclick="editMenuList('');" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
          <a href="javascript:;" class="ld-button" onclick="detailbutton_click(this,'Home','MenuStyle','1');return false;" title="{'menustyle'|@getFixedLabel}">{'menustyle'|@getFixedLabel}</a>
{*        <a href="javascript:;" class="ld-button" onclick="sortMenuList()" title="{'SortMenu'|@getFixedLabel}">{'SortMenu'|@getFixedLabel}</a>*}
          <a href="javascript:;" class="ld-button" onclick="RestoreDefaultIcon('menu')" title="{'RestoreDefaultIcon'|@getFixedLabel}">{'RestoreDefaultIcon'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
       <div name="menulistcontent">
        {include file="Menu/MenuListContent.tpl"}
       </div>
    </div>
</div>
</form>

<div id="menu" class="LdPop_box LdPopWidth800px" style="display:none;"></div>
<script>
var _menuback = '{$MENUBACK}';
var _menuhover = '{$MENUHOVER}';
{literal}
function editchildmenu(edit_types,BLOCKIDSETTING,FIELDIDSETTING){
      
   /**
    *更新操作
    *edit:lmx
    *time:20140304
    *reson:0005828: 控制面板->菜单定制，新增菜单
    */
     if(edit_types=='add'){
        window.location.href="index.php?module=Settings&action=EditMenu&parenttab=Settings&blockidsetting="+BLOCKIDSETTING+"&fieldidsetting="+FIELDIDSETTING;
        return false;
     }
     new Ajax.Request(
        'index.php',
        {queue: {position: 'end', scope: 'command'},
        method: 'post',
        postBody:'module=Settings&action=ChildMenu&parenttab=Settings&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,
        onComplete: function(response) {
            $("menu").style.display='';            
        if(response.responseText.indexOf('SUCCESS')>-1){
        var result=response.responseText.split('###SUCCESS###');
        //puyoungJS_DialogBox.block();
         $("menu").style.visibility='';
        $("menu").innerHTML=result[1];        
        fnvshobj('','menu');
        //Drag.init(document.getElementById("menuheader"), document.getElementById("menu"));
        }
        }
        });
}

/**
 * 中英文标签分开判断，中文跟中文判断，英文跟英文判断，不再交叉判断
 * @reason 0009305 编辑子模块时中英文名称不能重复
 * @author Tujt 2014-06-10
 */
function validata(){
	var classmethods = $$('.tab-chan-link');
	for(var i=0;i<classmethods.length;i++){
		var value=classmethods[i].value;
		if(value.length==0){
            var confirm_str = arrJsPopLabel['DISPLAYNAMECANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}else if(value.indexOf("\\")>0){
            var confirm_str = arrJsPopLabel['DISPLAYNAMENOTLEGAL'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}
	}
	
	var divs = document.getElementById('Content_div');
	var inputs = divs.getElementsByTagName("input");
	var inputlen = inputs.length;
	var i = 0;var j = 0;var inl = '';
	for(i=0;i<inputlen;i++){
		if(i%2==0){//英文
			for(j=0;j<inputlen;j=j+2){
				if(i == j) continue;//自己
				if(inputs[i].value == inputs[j].value){
					inl = inputs[i].value;break;
				}
			}
		}else{//中文
			for(j=1;j<inputlen;j=j+2){
				if(i == j) continue;//自己
				if(inputs[i].value == inputs[j].value){
					inl = inputs[i].value;break;
				}
			}
		}
	}
	if(inl != ''){//名称有重复
        var confirm_str = arrJsPopLabel['DNCNBRIE'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	return true;
}
{/literal}
</script>