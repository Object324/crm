//editor:gyq_141 reason:更改启用状态  2019/9/4 14:07 ID1000602
function change_active(obj,report_name) {
    //var rowIndex=obj.parentNode.parentNode.rowIndex;
//    var secondcell=document.getElementById("approvelisttable").rows[rowIndex].cells[2];
    ld.post("index.php",{report_name : report_name ,module:"Settings",file:"mobile_home_setting",action:'SettingsAjax',
        ajax:'true',second_action:'change_active'},function(response) {
        var data = ld.parseJSON(response);
        if(data.code === 1){
            //if(data.result.status=='yes'){
//                ld(obj).text(data.result.btntext);
//                ld(obj).addClass('redFont');
//                secondcell.innerHTML=("<span style='color:green' class='yes'>"+data.result.text+"</span>");
//            } else {
//                ld(obj).text(data.result.btntext);
//                ld(obj).removeClass('redFont');
//                secondcell.innerHTML = ("<span style='color:red' class='no'>"+data.result.text+"</span>");
//            }
        }else{
            RemindsMsg("","LdPopWidth400px","","","",data.msg);
        }
    });
}
//reason:更改报表显示顺序  2019/9/5 10:02
function report_sort() {
    ld.ajax('index.php?module=Settings&action=SettingsAjax&file=mobile_home_setting&second_action=report_sort&ajax=true')
        .done(function(response){
            //alert(response);
            $('block_sort_div').innerHTML=response;
            fnvshobj('', 'block_sort');
            //设置区块排序的按钮事件
            ld("#save_mobile_block_sort").on('click',function(){
                var tabids = ld("#selectedColumns2 option").map(function(){return ld(this).val();}).get().join(",");
                ld.ajax('index.php?module=Settings&action=SettingsAjax&file=mobile_home_setting&second_action=save_sort&ajax=true&tabids='+tabids)
                    .done(function(response){
                        fninvshnew('block_sort');
                        document.getElementById('cfList').innerHTML = response;
                    })
            })
            //取消
            ld("#cancel_mobile_block_sort,#colse_mobile_block_sort").on('click',function(){
                fninvshnew('block_sort');
            })
        })
}

//编辑自定义报表内容
function editCustomReportBlock(obj,blockid){
    var surl='module=Settings&action=SettingsAjax&file=CustomReportBlock&mode=edit&blockid='+blockid;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
    ld.ajax({
		url: 'index.php?'+surl,
		type: 'POST',
		data:'',
		dataType:'json',
		timeout: 5000,
        success: function(data)
        {
            if(data.code == 1)
            {
                crmPopupobj.setParams(data.result.title,saveCustomReportBlock,"","LdPopWidth800px",'Settings',obj,data.result.oktext,"",data.result.canceltext);
                crmPopupobj.show(data.result.content);

                /*
                edit:weiyannan
                date:2023-11-14
                reason:XUQIU1002049 系统穿梭框界面样式统一 后台设置--移动端工作台定制--默认看板--自定义报表
                */
                getJsScript('include/js/DragTransfer.js',function(){
                    var tableobj = ld('#'+crmPopupobj.divid).find(" .commonMultipleSelect").parents("table");
                    var LeftObj = tableobj.find(" .commonMultipleSelect:first");
                    var RightObj = tableobj.find(" .commonMultipleSelect:last");
                    //传入翻译参数
                    var Drag_Transfer = new DragTransfer();
                    var translabel = {
                        available: arrJsPopLabel['OptionModules'],
                        selected: arrJsPopLabel['Selectedmodule'],
                        placeholder: arrJsPopLabel['PleaseEnterColumnSearchFor'],
                    };
                    Drag_Transfer.SetTranslabel(translabel);
                    Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','320');
                    crmPopupobj.center();
                });
            }
		}
	})
}

//保存自定义报表内容
function saveCustomReportBlock(obj){
    //保存
	var blockid = ld('#blockid').val();
	var mobileblock_name = ld('#mobileblock_name').val();
	//区块名称不能为空
	if(empty(mobileblock_name)){
		var mes = ld('#mobileblock_name').attr('tag');
		var confirm_str = mes+arrJsPopLabel['CANOTEMPTY']+'!';
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
    var mobileblock_name_en = ld('#mobileblock_name_en').val();
	//英文不能为空
	if(empty(mobileblock_name_en)){
		var mes = ld('#mobileblock_name_en').attr('tag');
		var confirm_str = mes+arrJsPopLabel['CANOTEMPTY']+'!';
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	//显示的模块不能为空
	var tabids = ld("#selectedtabColumns option").map(function(){return ld(this).val();}).get().join(",");
	/*if(empty(tabids)){
		var mes = ld('#selectedtabColumns').attr('tag');
		var confirm_str = mes+arrJsPopLabel['CANOTEMPTY']+'!';
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}*/
    var presenceobj = ld("input[id='mobileblock_presence']");
    // if(presenceobj.prop('checked')){
    //     var presence = 'yes';
    // }else{
    //     var presence = 'no';
    // }
    var presence = presenceobj.prop('checked')?'yes' : 'no';
    //BUG0066395: 复选框状态无法保存  2023/5/15  余俊
	//var presenc = ld("input[id='mobileblock_presence']:checked").val();
    //var presence = presenc?'yes':'no';
	var customscope_type=ld("#customscope_type").val();
	var customscope_ids=ld("#customscope_ids").val();
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=CustomReportBlock&mode=save&ajax=true&mobileblock_name='+mobileblock_name+'&mobileblock_name_en='+mobileblock_name_en+'&tabids='+tabids+'&presence='+presence+'&blockid='+blockid+"&customscope_type="+customscope_type+"&customscope_ids="+customscope_ids;
    ld.ajax({
		url: surl,
		type: 'POST',
		data:'',
		dataType:'json',
		timeout: 5000,
        success: function(data)
        {
            if(data.code==-1){
                //区块名称不能重复
    			var mes = ld('#mobileblock_name').attr('tag');
    			var confirm_str = mes+arrJsPopLabel['ALREADYEXISTSREENTRY'];
    			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
    			return false;
    		}else if(data.code == -2){
                //英文区块名称不能重复
                var mes = ld('#mobileblock_name_en').attr('tag');
    			var confirm_str = mes+arrJsPopLabel['ALREADYEXISTSREENTRY'];
    			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
    			return false;
    		}
			 else if(data.code == 1){
                var popupobj = CrmPopup.getPopupObj('last');
                popupobj.CancelEvent();
                var rowIndex=obj.parentNode.parentNode.rowIndex;
                var firstcell =document.getElementById("approvelisttable").rows[rowIndex].cells[1];
                var secondcell=document.getElementById("approvelisttable").rows[rowIndex].cells[2];
                var prevobj = ld(obj).prev();
                //duan 2022-2-16 修改编辑按钮位置
                var td_content = "<span title='"+data.result.reportname+"'>"+data.result.reportname+"</span>";
                td_content += '<a style="margin-left:20px;" class="Anu3_a" href="javascript:void(0);" onclick="editCustomReportBlock(this,'+data.result.blockid+')">'+arrJsPopLabel['EDIT']+'</a>';
                firstcell.innerHTML=(td_content);
                if(data.result.status=='yes'){
                    ld(secondcell).find('[class*=switch]').prop('checked',true);
                } else {
                    ld(secondcell).find('[class*=switch]').prop('checked',false);
                }
            }
            
        }
	})
}