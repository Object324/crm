{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/SetUeryScope.js"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js"></script>
<!--新添加的部分-->
<div id="divPrintAllocate" class="D_pop_box LdPopWidth500px" style="display:none;width:500px;position:absolute;z-index: 9999;"></div>

<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_Signin_Optionalmodule_Customization'|@getFixedLabel}
        </span>
        <!-- <span class="grid-view-choose dinline-block">{'SELECTMODULE'|@getFixedLabel}</span>
        <select onchange="changeModule(this)" id="CurrentOption" class="btn-radius-system">
            {foreach item=tabname key=tabid from=$TABS}
                <option value="{$tabname.tabid}" {if $tabname.tabid eq $TABID}selected{/if}>{$tabname.name}</option>                       
            {/foreach}
        </select> -->
    </div>
    <div class="grid_tool">
        <div class="create-entity-toolbar lfloat prelative">
            <a href="javascript:;" class="pg-btn-blue dinline-block lfloat" onclick="fnvshobj(this,'sortoption')" title="{'SORT'|@getFixedLabel}">{'SORT'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="optionlistview" class="cont_wrap clear_float">
            {include file="OptionModuleEntries.tpl"}
        </div>
    </div>
</div>

<script>
var TABID = "{$TABID}";
{literal}
//排序
function sortModule(tabid){
    var string = '';
    ld('#selectedAssmablyColumns option').each(function(){
            string += ld(this).val()+',';
    });
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:'module=Settings&action=SettingsAjax&file=OptionModuleSave&parenttab=Settings&sortOption=yes&selectTabid='+tabid+'&option='+string,
			onComplete: function(response) {
				 AjaxListView(tabid);
                 fninvshnew('sortoption');
			}
		}
	);
 
   
}

//编辑
function editOption(optionid){
    // var tabid = $('CurrentOption').value;
    // @edit:dong @date:2020/08/13 @reason: tapd ID1001007 签到源单类型定制功能优化
    var tabid = TABID;
    var option_presence = $('option_presence_'+optionid);
    var option_default = $('option_default_'+optionid);
    var option_approve = $('option_approve_'+optionid);
    //var option_required = $('option_required_'+optionid);
   // var option_automatically = $('option_automatically_'+optionid);
    //var option_enablewhenadding = $('option_enablewhenadding_'+optionid);
    var datarang=$("datarang_"+optionid);
    var maxrowsshow=$("maxrowsshow_"+optionid);
    var option_uploadwatermark = $("option_uploadwatermark_"+optionid);//拜访签到上传图片添加水印
    var no_signin = $("no_signin_"+optionid);
    var nosignout_cantsignin = $("nosignout_cantsignin"+optionid);
    var allowsupsignout = $("allowsupsignout"+optionid);
    
    var urlstring = '';
    if(option_presence != null){
        if(option_presence.checked)
            urlstring += '&presence=0';
        else
            urlstring += '&presence=1';
    }
    if(option_default != null){
        urlstring += '&default='+Number(option_default.checked);
    }
    if(option_approve != null){
        urlstring += '&approve='+option_approve.value;
    }
    /*if(option_required != null){
        urlstring += '&required='+Number(option_required.checked);
    }*/
    urlstring += '&required=0';
    /*if(option_automatically != null){
        urlstring += '&automaticallysign='+Number(option_automatically.checked);
    }*/
    urlstring += '&automaticallysign=0';
    /*if(option_automatically != null){
        urlstring += '&enablewhenadding='+Number(option_enablewhenadding.checked);
    }*/
    urlstring += '&enablewhenadding=0';
    if(datarang!=null)
    {
        urlstring+="&datarang="+datarang.value;
    }
    if(maxrowsshow!=null)
    {
        urlstring+="&maxrowsshow="+maxrowsshow.value;
    }
    if(option_uploadwatermark!=null)
    {
        if(option_uploadwatermark.checked)
            urlstring += '&uploadwatermark=yes';
        else
            urlstring += '&uploadwatermark=no';
    }
    if(no_signin != null){
        if(no_signin.checked){
            urlstring += '&no_signin=yes';
            var allowable_distance = ld('#allowable_distance_'+optionid).val();
            if(allowable_distance == 'custom'){
                if(ld('#custom_allowable_distance_'+optionid).val() == ''){
                    RemindsMsg("","LdPopWidth400px","",'yes','yes',arrJsPopLabel['Checkinerrorvaluecannotbeempty']);
                    return false;
                }else{
                    allowable_distance = ld('#custom_allowable_distance_'+optionid).val();
                }
                urlstring += '&allowable_distance='+allowable_distance;
            }else{
                urlstring += '&allowable_distance='+allowable_distance;
            }
        }else{
            urlstring += '&no_signin=no&allowable_distance=0';
        }
    }
    if(nosignout_cantsignin!=null)
    {
        if(nosignout_cantsignin.checked)
            urlstring += '&nosignout_cantsignin=yes';
        else
            urlstring += '&nosignout_cantsignin=no';
    }
    if(allowsupsignout!=null)
    {
        if(allowsupsignout.checked)
            urlstring += '&allowsupsignout=yes';
        else
            urlstring += '&allowsupsignout=no';
    }
    //alert(urlstring);return false;
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:'module=Settings&action=SettingsAjax&file=OptionModuleSave&parenttab=Settings&editModule=yes&optionid='+optionid+urlstring+'&tabid='+tabid,
			onComplete: function(response) {
				var rest = response.responseText;
				if(rest == 'error'){
					var confirm_str = arrJsPopLabel['ATLEASTONESOURCESINGLEMODULEISENDALED'];
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					return false;	
				}
				 AjaxListView(tabid);
                 fninvshnew('editOption_'+optionid);
			}
		}
	);
}

//切换模块
function changeModule(obj){
    AjaxListView(obj.value);
}
//根据模块id获取源单列表信息
function AjaxListView(selectTabid){
   ld('#rptContentLoading').show();
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:'module=Settings&action=SettingsAjax&file=OptionModule&Ajax=yes&parenttab=Settings&selectTabid='+selectTabid,
			onComplete: function(response) {
				ld('#rptContentLoading').hide();
                $("optionlistview").update(response.responseText);
			}
		}
	);
}
//签到
function allowable_distance_click(obj,blockid){
    var allowable_distance_type = ld(obj).val();
    if('custom' == allowable_distance_type){
        ld('#custom_allowable_distance_'+blockid).show();
    }else{
        ld('#custom_allowable_distance_'+blockid).hide();
    }
}
//zxm 搜索框 搜索option的内容选中加阴影 0043378: （61mis.com/kfbcrm）系统设置-系统定制-源单类型定制-排序；在“源单类型定制”的排序弹出层中，没有搜索的功能
function _onsortoptionkeyup(obj,inputname){
    var input_obj = ld('#sortoption [name="'+inputname+'"]');
    if(input_obj != ''){
        var selectlength = ld("#sortoption [name="+inputname+"] option ").length;
        var isSel=0;
        var isSelectOpteion =0;
        var objlength = obj.value.length;
        if(obj.value != '')
        {
            getScriptBackWithURL('include/js/multipingyin.js',null);//加载拼音代码
            var selectHeight = input_obj[0].scrollHeight;//下拉框的高度
            var optionHeight = selectHeight/selectlength;
            ld.each(ld("#sortoption [name="+inputname+"] option "), function (keys, selobj) {
                var selectValue =selobj.text;
                var selT = selectValue.indexOf(obj.value);
                var pinyin = makePy(selectValue);//17222: (71mis.com/crm)控制面板>部门设置/权限管理,关于设置成员模糊搜索的问题
                pinyin=pinyin.join("").toLowerCase();

                //pinyinArray[i]=pinyin;
                var selP = pinyin.indexOf(obj.value);
                if(selT >=0 || selP >=0)
                {
                    if(isSel == 0)
                    {
                        if(selP > 0){
                            if(pinyin.indexOf(obj.value)>0){
                                selobj.selected = true;
                                isSel = 1
                            }
                            //if(pinyin.substring(0, objlength) == obj.value){
                            //objMember.options[i].selected = true;
                            //isSel = 1;
                            //}
                        }
                        else{
                            selobj.selected = true;
                            isSel = 1;
                        }

                        isSelectOpteion = keys;
                    }
                    else{
                        selobj.selected = false;
                    }
                }
                else{
                    if(selobj.selected == true)
                    {
                        selobj.selected = false;
                    }
                }
            });
            if(isSelectOpteion >=10){
                input_obj.animate({ scrollTop: optionHeight*isSelectOpteion-70});
            }else{
                input_obj.animate({ scrollTop: 0});
            }

        }else{
            ld.each(ld("#sortoption [name="+inputname+"] option "), function (keys, selobj) {
                if(selobj.selected == true)
                {
                    selobj.selected = false;
                }
            });
            isSel = 0;
            input_obj.scrollTop(0);
        }
    }

}
function _onsortoptionblur(obj){
    if(obj.value == '')
    {
        obj.value = obj.getAttribute('tag');
        obj.style.color='#999';
    }
}
function _onsortoptionfocus(obj){
    var membermessage = obj.getAttribute('tag');
    if(obj.value == membermessage)
    {
        obj.value="";
        obj.style.color='#666';
    }
}
{/literal}
</script>