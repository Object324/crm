function sign_recalculate_record(selectid,start,selectlen){
    var interval = 10;
    if(selectlen >interval){
        var maxrows = 0;
        var rowlimit = getMaxMassOperationLimit();
        if(selectlen >rowlimit){
            maxrows = rowlimit;
        }else{
            maxrows = selectlen;
        }
        var popupobj = CrmPopup.getPopupObj('last');
        if(popupobj!=undefined&&popupobj.type == 'ProgressPopup'){//新建或修改进度条弹出层
            var tmppopupobjobj=popupobj;
        }else{
            var title = arrJsPopLabel['RECALCULATEERRORJS'];
            var tmppopupobjobj=ProgressPopup.load(title,"","",500,module,"","","","");
            var htmlcontent="<div class='import_process' style='margin-left:30px;'><div class='progressbar batchProgress'></div>";
            htmlcontent+="<div class='import_info'>共选择了<span class='num totalnum'></span>条记录，</span> 正在操作第<span class='num curnum'></span>条记录，请稍后……</div></div>";
    		tmppopupobjobj.showhtml(htmlcontent);
        }
        //更新进度条显示
        if(maxrows==0){//没有获取数据时显示最大进度条
            tmppopupobjobj.setPercentWidth(100);
        	tmppopupobjobj.setTotalNum(0);
        	tmppopupobjobj.setCurNum(0);
        }else{
            var percent=parseInt(start/maxrows*100);
            tmppopupobjobj.setPercentWidth(percent);
        	tmppopupobjobj.setTotalNum(maxrows);
        	tmppopupobjobj.setCurNum(start);
        }
    }
    var surl = 'index.php?module=Signout&action=SignoutAjax&file=RecalculateDistance&selectid='+selectid+'&start='+start+'&selectlen='+selectlen;
    ldAjaxNoProgress(surl,'',function(data){
        if(data.code == 1){
            var distancearr = data.result.distancearr;
            var tmp_record = 0;
            var tmp_distance = '';
            if(!empty(distancearr)){
                for(tmp_record in distancearr){
                    tmp_distance = distancearr[tmp_record];
                    ld("[module=Signout][fieldname=signout_distince][record="+tmp_record+"]").html(tmp_distance);
                }
            }
            if(selectlen >interval){
                var end = data.result.end;
                if(end < selectlen ){
                    sign_recalculate_record(selectid,end,selectlen);
                }else{
                    if(tmppopupobjobj != undefined){
                        tmppopupobjobj.CancelEvent();
                    }
                    MessagePopup.TipOne_success (arrJsPopLabel['SUCCESSFULOPERATION']);
                    //RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['SUCCESSFULOPERATION']);
                }
            }else if(selectlen>1){
                MessagePopup.TipOne_success (arrJsPopLabel['SUCCESSFULOPERATION']);
                //RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['SUCCESSFULOPERATION']);
            }else{
                // audioRemindsMsg("","","","","",arrJsPopLabel['SUCCESSFULOPERATION']);
                MessagePopup.TipOne_success (arrJsPopLabel['SUCCESSFULOPERATION']);
            }
        }else if(data.code == 2){
            if(tmppopupobjobj != undefined){
                tmppopupobjobj.CancelEvent();
            }
            console.log
            MessagePopup.TipOne_success (arrJsPopLabel['SUCCESSFULOPERATION']);
            // RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['SUCCESSFULOPERATION']);
        }else if(data.code == -1){
            audioRemindsMsg("","","","","",arrJsPopLabel['OPERATIONFAILED']);
        }
    })
}
function sign_recalculate_list(){
    var popupobj=CrmPopup.getPopupObj('last');
    
    var selectid =ld("#"+popupobj.divid+" [name=allselectedboxes]").val();
    var selectlen = 0;
    if (selectid != 'all') {
        var selectobj = document.getElementsByName("selected_id");
        var selectobjlen = selectobj.length;
        selectid = '';
        for (var i = 0; i < selectobjlen; i++) {
            if (selectobj[i].checked) {//获取选中的ID
                selectid += selectobj[i].value + ',';
                selectlen++;
            }
        }
        if (selectid == '') {//请至少选择一条记录
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", "");
            return false;
        }
    } else {
        selectlen = parseInt(document.getElementById('numOfRows').value);//获取全选的条数
    }
    
    //超过500条，给出提示
    
    if (selectlen > getMaxMassOperationLimit()) {
        var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', selectlen, getMaxMassOperationLimit(), '');
        //创建提示弹出层
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);
        //确定事件
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function(){
            sign_recalculate_record(selectid,0,selectlen);
        });
    } else {
        sign_recalculate_record(selectid,0,selectlen);
    }
    
}