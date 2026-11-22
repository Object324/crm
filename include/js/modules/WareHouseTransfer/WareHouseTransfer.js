/*********************************************************************************
**{*修改编码格式:统一编码：UTF-8*} 
* The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/


function warehouseValidate()
{
    if(document.getElementById('outwarehouse') != undefined && document.getElementById('inwarehouse') != undefined)
    {
        if(document.getElementById('outwarehouse').value == document.getElementById('inwarehouse').value)
            return false;
        else
            return true;
    }
    else
    {
        return false;
    }
}
//审核
function submit_warehousetransfer(outwarehouse,inwarehouse,recordid,submittransfer)
{
    if(submittransfer == 'Confirm')//审核
        var message = arrJsPopLabel['DETERNUBETHEALLOCATION'];
    else//反审核
        var message = arrJsPopLabel['AFTEREXECUTIONDETERNUBETHEALLOCATION'];
        
    RemindsMsg("","LdPopWidth400px","","yes","yes",message);
    //点击确认
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        ld('#rptContentLoading').show();
        new Ajax.Request("index.php",
            {
                queue:{
                    position:"end",
                    scope:"command"
                },
                method:"post",
                postBody:"action=WareHouseTransferAjax&file=UpdateWareHouseTransfer&module=WareHouseTransfer&parenttab=Stock&record="+recordid+"&outwarehouse="+outwarehouse+"&inwarehouse="+inwarehouse+"&salestype=yes&submittransfer="+submittransfer,
                onComplete:function (response) {
                     // $("status").style.display="none";
                     var str=response.responseText;
                     var results = str.split('###error###');
                     if(results[1] == 1)
                     {
                        // 调入和调出仓库不能相同
                        var confirm_str = arrJsPopLabel['INANDOUTNOTSAME'];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        return false;
                     }
                     else if(results[1] == 2)
                     {
                        //您对该单据的仓库没有操作权限
                        var confirm_str = arrJsPopLabel['SORRYYOUDONOTHAVEPERMISSIONTOTHISDOCUMENT'];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        return false;
                     }
                     else 
                     {
                        if(str.indexOf("$$success$$")<0&&str!=""&&str.length>5)
                        {
                            var restobj = eval('('+ str +')')?eval('('+ str +')'):JSON.parse(str);
                       
                            if(restobj!=undefined&&restobj.code==-3)
                            {
                                alert(restobj.msg);
                                return false;
                            }
                        }
                     }
                     /*if(document.getElementById('record') != undefined && document.getElementById('record').value > 0)
                     {
                        window.location.href="index.php?action=DetailView&module=WareHouseTransfer&parenttab=Stock&record="+recordid+"&salestype=yes"; 
                     }
                     else
                     {
                        window.location.href="index.php?module=WareHouseTransfer&action=index&parenttab=Stock";
                     }*/
                    // var popupobj
                    //33555: 库间调拨明细界面>点击审核按钮：审核成功后返回到了列界面。
                    //  window.location.reload();

                    // @edit:liushuai,2021-03-19,reason:44343: 调拨单->审批功能优化：建议参考盘点单，点击“审核”时，打开详情界面，并且审核后停留在单据详情界面
                    var tmparra = new Array();
                    tmparra.push(recordid);
                    var tmpobj = new AfterUpdatePrevPopupObjContent('WareHouseTransfer', "", tmparra);
                    var refreshlistmodules = new Array('WareHouseTransfer');

                    var popupobj = CrmPopup.getPopupObj("last");
                    if (popupobj.type == 'listpage')  //序时簿
                    {
                        tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                    } else //单据详情页
                    {
                        tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                        tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);  //(查看界面)
                    }
                    if (recordid > 0) {
                        tmpobj.update();//更新界面字段
                    }
                    DelProgressObjs();
                }
            }
        );
    });
    return false;
}