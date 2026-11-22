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
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/SetUeryScope.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js?v={$GLOBALMINVERSION}"></script>

<div id="divLinkModuleCustom">
    <div class="main_grid_top">
        <div class="grid-view-title lfloat overflow-hidden">
            <span class="grid-view-name dinline-block lfloat">
                {'LBL_HREFMODULE_Custom'|@getFixedLabel}
                {if $LANGUAGETYPE eq 'zh'}<font>（{'LBL_HREFMODULE_CustomDescription'|@getFixedLabel}）</font>{/if}
            </span>
        </div>
        <div class="grid_tool">
            <div class="displayflex">
                <a href="javascript:;" class="ld-button ld-button-primary" name="New" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
                <a href="javascript:;" class="ld-button" onclick="RestoreDefaultIcon('linkmodule')" title="{'RestoreDefaultIcon'|@getFixedLabel}">{'RestoreDefaultIcon'|@getFixedLabel}</a>
            </div>
        </div>
    </div>
    <div class="main_grid_box">
        <div class="grid-analysis-box">
            <div class="grid-analysis-header">
            </div>
            <div class="cont_wrap clear_float">
                <input type="hidden" name="mode" value="create"/>
                <input type="hidden" name="parenttab" value="Settings"/>
                <input type="hidden" name="printtabid" value="{$PRINTTABID}" />
                <input type="hidden" name="blockidsetting" id="blockidsetting" value="{$BLOCKIDSETTING}"/>
                <!-- <input class="createauto" type="button" name="New" value="{'NEW'|@getFixedLabel}"/> -->
                <input type="hidden" name="fieldidsetting" id="fieldidsetting" value="{$FIELDIDSETTING}"/>
                <div name="listcontent">
                    {include file="Settings/LinkModuleCustomListContent.tpl"}
                </div>
            </div>
        </div>
    </div>
</div>

<script>

{literal}
    var listpopupobj=new Object();
    listpopupobj.divid="divLinkModuleCustom";
    CrmPopup.global_listPopupObj.push(listpopupobj);
    var LinkModuleCustomobj=new LinkModuleCustom();
    LinkModuleCustomobj.setEvent();
    
    function LinkModuleCustom()
    {
        var that=this;
        this.setEvent=function()
        {
            ld("#"+listpopupobj.divid+" [name=New]").unbind("click").bind("click",function(){
                //新增
                that.setPagePopup(0);
            });
            
            ld("#"+listpopupobj.divid+" [name=edit]").unbind("click").bind("click",function(){
                //编辑
                that.setPagePopup(ld(this).attr('tag'));
            });
            ld("#"+listpopupobj.divid+" [name=allocate]").unbind("click").bind("click",function(){
                //分配
            });
            
            ld("#"+listpopupobj.divid+" [name=delete]").unbind("click").bind("click",function(){
                //删除
                var alert_str = arrJsPopLabel['SUREWANTDELETE'];
                RemindsMsg("","LdPopWidth400px","LinkModuleCustom","yes","yes",alert_str);
                //确定按钮
                var tmpid=ld(this).attr('tag');
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                    ldAjax('index.php?module=Settings&action=SettingsAjax&file=LinkModuleCustomDelete&id='+tmpid,'',function(data){
                        DelProgressObjs();
                        if(data.code=='-1'){
                            RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
                        }
                        else{
                            //38451: 链接模块定制：删除功能不能连续删除
                            var popupobj=new Object();
                            popupobj.CancelEvent=function(){
                                CrmPopup.global_listPopupObj.pop();
                            }
                            CrmPopup.global_listPopupObj.push(popupobj);
                            that.loadlist();
                        }
                    });
                });
            })
        }
        this.setPagePopup=function(id)
        {
            var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px","Settings","",'none',"","");
	        crmPopupobj.prevshow();
            ld.ajax({
                url:"index.php?module=Settings&action=SettingsAjax&file=LinkModuleCustomPagePopup&id="+id,
                type: 'POST',
                dataType:"json",
                timeout:10000,
                success:function(data){
                    crmPopupobj.record=id;
                    crmPopupobj.urlparam_arr=data.result.urlparam_arr;//链接参数
                    crmPopupobj.setParams(data.result.title,that.save,"","LdPopWidth600px","Settings","",data.result.oktext,"",data.result.canceltext);
                    CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,data.result.content);
                    // 设置内容最大高度
                    crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
                    ld("#"+crmPopupobj.divid+' [name=accessTokenCheck]').unbind("click").bind("click",function(event){
                        that.tokenaccess_click(ld(this));
                    });
                    ld("#"+crmPopupobj.divid+" [name=addparam]").unbind("click").bind("click",function(event){
                        that.addParamPopupEvent()
                    });
                }
            });
        }
        this.tokenaccess_click=function(jqueryobj)
        {
                var popupobj=CrmPopup.getPopupObj('last');
                
                if(ld(jqueryobj).prop("checked"))
                {
                     ld("#"+popupobj.divid+" [name=addparam]").css("display",'')
                }
                else{
                    ld("#"+popupobj.divid+" [name=addparam]").css("display",'none')
                }
        }
        this.addParamPopupEvent=function()
        {
            //添加参数
            var popupobj=CrmPopup.getPopupObj('last');
            var urlparam_arr=popupobj.urlparam_arr;
            
            var crmPopupobj=CrmPopup.load("","","","350","Settings","",'none',"","");
            crmPopupobj.prevshow();
            crmPopupobj.setParams("添加参数",that.OkParam,"","400","Settings","","确定","","取消");
            var tablehtml="<table class='settingPopTable' name='paramtable' cellspacing=0 cellpadding=0 border=0>";
            tablehtml+='<tr><th width="150px">参数名称</th><th width="150px">参数值</th><th width="100px">操作</th></tr>';
           
          
            tablehtml+='</table>';
            tablehtml+='<div style="padding: 10px 5px;"><a href="javascript:void(0);" name="addparamtr" class="ld-button">新增参数</a></div>';
            CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,tablehtml);
            var tableobj=ld("#"+crmPopupobj.divid+' [name=paramtable]');
          
            if(urlparam_arr!=undefined)
            {
                ld.each(urlparam_arr,function(tmpkey,tmpvalue){
                     var trhtml="<tr deleted='no'><td><input type='text' name='paramname' value='"+tmpkey+"' class='ld-input-inner'/></td><td><input type='text' name='paramvalue' value='"+tmpvalue+"' class='ld-input-inner'/></td><td><a class='icon-homeimg icon-sdel' style='cursor: pointer;' name='deleteparamtr'  title='删除'></a></td></tr>";
                     tableobj.append(trhtml);
                })
            }
            
            ld("#"+crmPopupobj.divid+" [name=deleteparamtr]").unbind("click").bind("click",function(){
                that.deleteParam(ld(this));
            })
            ld("#"+crmPopupobj.divid+" [name=addparamtr]").unbind("click").bind("click",function(){
                that.addNewParamTr();
            })
        }
        this.addNewParamTr=function(){
            var popupobj=CrmPopup.getPopupObj('last');
            var tableobj=ld("#"+popupobj.divid+' [name=paramtable]');
            var trhtml="<tr deleted='no'><td><input type='text' name='paramname' class='ld-input-inner'/></td><td><input type='text' name='paramvalue' class='ld-input-inner'/></td><td><a class='icon-homeimg icon-sdel' style='cursor: pointer;' name='deleteparamtr'  title='删除'></a></td></tr>";
            tableobj.append(trhtml);

            ld("#"+popupobj.divid+" [name=deleteparamtr]").unbind("click").bind("click",function(){
                that.deleteParam(ld(this));
            })
        }
        this.deleteParam=function(jqueryobj){
            //删除参数
            var trobj=Tools.getParentobjByChild(jqueryobj,'tr');
            ld(trobj).remove();
        }
        this.OkParam=function(){
            var popupobj=CrmPopup.getPopupObj('last');
            var prevpopupobj=CrmPopup.getPopupObj('lastprev');
            var tableobj=ld("#"+popupobj.divid+' [name=paramtable]');
            var arr={};
            ld.each(ld(tableobj).find("tr[deleted=no]"),function(){
                var paramname=ld(this).find("input[name=paramname]").val();
                var paramvalue=ld(this).find("input[name=paramvalue]").val();
                if(ld.trim(paramname)!=''&&ld.trim(paramvalue)!='')
                {
                    arr[paramname]=paramvalue;
                }
            })
            prevpopupobj.urlparam_arr=arr;
            popupobj.CancelEvent();
        }
        that.save=function()
        {
            var popupobj=CrmPopup.getPopupObj('last');
            var url='index.php?module=Settings&action=SettingsAjax&file=LinkModuleCustomSave&id='+popupobj.record;
            url+="&zh_label="+encodeURIComponent(ld("#"+popupobj.divid+" [name=zh_label]").val());
            url+="&en_label="+encodeURIComponent(ld("#"+popupobj.divid+" [name=en_label]").val());
            url+="&linkaddress="+encodeURIComponent(ld("#"+popupobj.divid+" [name=linkaddress]").val());
            url+="&scopetype="+encodeURIComponent(ld("#"+popupobj.divid+" [name=customscope_type]").val());
            url+="&scopeids="+encodeURIComponent(ld("#"+popupobj.divid+" [name=customscope_ids]").val());
            if(ld("#"+popupobj.divid+" [name=accessTokenCheck]").prop("checked"))
            {
                url+="&authcheck=yes";
            }
            else
            { 
                popupobj.urlparam_arr=[];
                url+="&authcheck=no";
            }

            //zxm 2021-1206 上传菜单图标
            var formData = new FormData();
            if( ld("#"+popupobj.divid+" [name=active_icon]").get(0).files.length>0)
            {
                formData.append('active_icon', ld("#"+popupobj.divid+" [name=active_icon]").get(0).files[0]);
                formData.append('active_icon_name', ld("#"+popupobj.divid+" [name=active_icon_name]").val());
                formData.append("active_icon_size",ld("#"+popupobj.divid+" [name=active_icon]").get(0).files[0].size);
                formData.append("active_icon_type",ld("#"+popupobj.divid+" [name=active_icon]").get(0).files[0].type);
            }
            //zkt 20230719 BUG0069775 链接模块定制，新增参数保存不了。 
            formData.append('param',JSON.stringify(popupobj.urlparam_arr));
            ld.ajax({
                url:url,
                type: 'POST',
                cache: false,
                data:formData,
                processData: false,
                contentType: false,
                timeout:20000,
                dataType:'json',
                xhr:function(){
                    var xhr=new XMLHttpRequest();
                    xhr.upload.addEventListener('progress',function(e){

                    })
                    return xhr;
                }
            }).done(function(data) {
                if(data.code=='-1')
                {
                    RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
                }
                else
                {
                    // chj 2020/11/12 43241: （本地php54，8.3.0版本）系统设置-链接模块定制；新增链接保存并操作分配后；编辑和删除点击没有反应
                    popupobj.CancelEvent();
                    that.loadlist();
                }
            })
            // ld.ajax({
            //     url:url,
            //     data:formData,
            //     type:"POST",
            //     dataType:"json",
            //     success:function(data){
            //         if(data.code=='-1')
            //         {
            //             RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
            //         }
            //         else
            //         {
			// 			// chj 2020/11/12 43241: （本地php54，8.3.0版本）系统设置-链接模块定制；新增链接保存并操作分配后；编辑和删除点击没有反应
			// 			popupobj.CancelEvent();
            //             that.loadlist();
            //         }
            //     }
            // });
        }
        that.loadlist=function()
        {
            ld.ajax({
                url:"index.php?module=Settings&action=SettingsAjax&file=LinkModuleCustom&ajax=yes",
                data:"POST",
                dataType:"json",
                timeout:10000,
                success:function(data)
                {
                    ld("#"+listpopupobj.divid+" [name=listcontent]").html(data.result.content);
                    
                    var popupobj=CrmPopup.getPopupObj('last');
                    that.setEvent();
                    
                    initRightContentHeight();//加载右侧内容中菜单和详细内容高度
                }
            });
        }
        that.save.funname="that.save";
    }
    LinkModuleCustom.refresh=function(){
        LinkModuleCustomobj.loadlist();
    }
{/literal}
</script>