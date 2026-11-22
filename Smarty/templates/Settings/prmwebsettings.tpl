<script type="text/javascript" src="{$JSURL}include/js/modules/Home/Home.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/Home/Homestuff.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/Home/Homeboard.js?v={$GLOBALMINVERSION}"></script>
<link rel="stylesheet" type="text/css" href="themes/softed/Homeboard.css"/>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/cutImg.js"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/cropper.min.js"></script>
<link rel="stylesheet" href="themes/softed/cropper.min.css">
<link rel="stylesheet" href="themes/softed/cropperImg.css">
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'prm_web_customization'|@getFixedLabel}
        </span>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        {include file='Settings/prmwebsettings_content.tpl'}
    </div>
</div>
<script>
    {literal}
    function prmsettings() {

    }
    prmsettings.prmMenuSettings = function() {
        var surl='index.php?module=Settings&action=SettingsAjax&file=prmmenusettings';
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
        ldAjax(surl,"",function(data){
            if(data.code == 1){
                crmPopupobj.setParams(data.result.title,prmsettings.savemenu,"","LdPopWidth600px","Settings","",data.result.oktext,"",data.result.canceltext,"");
                crmPopupobj.show(data.result.content);
                // 设置内容最大高度
                crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
                getJsScript('include/js/DragTransfer.js',function(){
                    var tableobj = ld('#'+crmPopupobj.divid).find(" .commonMultipleSelect").parents("table");
                    var LeftObj = tableobj.find(" .commonMultipleSelect:first");
                    var RightObj = tableobj.find(" .commonMultipleSelect:last");
                    //传入翻译参数
                    var Drag_Transfer = new DragTransfer();
                    var translabel = {
                        available: arrJsPopLabel['OptionModules'],
                        selected: arrJsPopLabel['Selectedmodule'],
                        placeholder: arrJsPopLabel['PleaseEnterModuleSearchFor'],
                    };
                    Drag_Transfer.SetTranslabel(translabel);
                    Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','210');
                    crmPopupobj.center();
                });

            }
        });
    }
    prmsettings.savemenu = function () {
        var popupobj=CrmPopup.getPopupObj("last");
        var form=document.forms['prmmenu'];
        var obj=form.selectedColumns;
        var selectedColStr='';
        if(obj.options.length>0){
            for(var i=0;i<obj.options.length;i++){
                selectedColStr += obj.options[i].value+";";
            }
        }
        else{
            RemindsMsg("", "LdPopWidth400px", 'Settings', "yes", "yes", arrJsPopLabel['PLEASESELECTONEENTITY']);
            return;
        }

        var surl = 'index.php?module=Settings&action=SettingsAjax&file=prmsavemenu';
        var param = {};
        param['selectedtabColumnsString'] = selectedColStr;
        ldAjax(surl,param,function(data){
            if(data.code == 1){
                popupobj.CancelEvent();
                prmsettings.refreshPrmWeb();
            }
        });
    }
    prmsettings.refreshPrmWeb = function () {
        var url = 'index.php?module=Settings&action=SettingsAjax&file=prmwebsettings&ajax=true';
        ldAjax(url,'',function (rest) {
            if(rest.code == 1){
                ld('.grid-analysis-box').html(rest.result.content);
            }
        })
    }
    prmsettings.logosettings = function() {
        var surl='index.php?module=Settings&action=SettingsAjax&file=prmlogosettings';
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
        ldAjax(surl,"",function(data){
            if(data.code == 1){
                crmPopupobj.setParams(data.result.title,prmsettings.prmsavelogo,"","LdPopWidth600px","Settings","",data.result.oktext,"",data.result.canceltext,"");
                crmPopupobj.show(data.result.content);
                crmPopupobj.center();

                crmPopupobj.imgInfo = {};
                crmPopupobj.imgInfo['big'] = {imgurl:"",imgname:""};
                ld('#'+crmPopupobj.divid+' #overlay_Img_big').unbind('click').bind('click',function(){
                    if(crmPopupobj.imgInfo['big']['imgname']==""){
                        var prev_name = ld(this).data('prevname');
                        crmPopupobj.imgInfo['big']['imgname']= prev_name;
                    }
                    var suggest_info =arrJsPopLabel[ld(this).data('suggest')] ;//专有提示
                    //suggest_info += suggest_info+'<br>'+ '其他通用提示语'
                    var width =ld(this).data('width');
                    var height =ld(this).data('height');
                    var showbox = ld(this).data('showbox');
                    var showname = ld(this).data('showname');
                    var cutImgObj = new cutImg();
                    cutImgObj.lastPrevPop = crmPopupobj;
                    cutImgObj.label = 'big';
                    cutImgObj.imgShowBox = showbox;
                    cutImgObj.imgShowName = showname;
                    cutImgObj.openPop(suggest_info,width,height);
                })

            }
        });
    }
    prmsettings.prmsavelogo = function () {
        var popupobj=CrmPopup.getPopupObj("last");
        var data = new FormData(ld(".ajax_form")[0]);
        var prev_file_name= ld('#'+popupobj.divid).find('#overlay_Img_big').data('prevname');
        data.append("prev_file_big",prev_file_name);
        data.append("imgurl_big",popupobj.imgInfo['big']["imgurl"]);
        data.append("imgname_big",popupobj.imgInfo['big']["imgname"]);

        ld('#rptContentLoading').show();
        ld.ajax({
            type: 'POST',
            dataType: 'json',
            processData: false, // 告诉jquery不要处理数据
            contentType: false, // 告诉jquery不要设置contentType
            data: data,
            url: 'index.php?module=Settings&action=SettingsAjax&file=prmsavelogo',
            success: function(data) {
                ld('#rptContentLoading').hide();
                popupobj.CancelEvent();
                ld('img#prm_LOGO_name').attr('src','dataCache/test/logo/'+data.result.prmlogoname);
            },
            error: function(xhr, textStatus, errorThrown) {

            }
        })
    }
    {/literal}
</script>