/*
{*修改编码格式:统一编码：UTF-8*}
*/
var CKTemplatePrint;

/*
edit:andrew
date:20140928
reason:选择服务绩效参数
*/
function templateServerSel(obj)
{
    var tabid=obj.value;
	if(tabid == 2){
		ld('#table_serviceformancepick').show();
	}else{
		ld('#table_serviceformancepick').hide();
	}
	var surl = "index.php?module=Settings&action=SettingsAjax&file=Serviceperformance&selectserverttab="+tabid+"&ajax=yes";
	ldAjax(surl,"",function(data){
		if(data.code == 1){
			ld(".main_grid_box [name=serviceperformancecontent]").html(data.result.content);
		}
        DelProgressObjs();
	})
}
/*
edit:andrew
date:20140929
reason:选择城市
*/
var isserviepermance=false;
function getBillCityDepency(obj)
{
    if(picklist==false)
    return ;
     var tabid=obj.value;
    var servicetype = document.getElementById('servicetype').value;
   //if(document.getElementById('servicetype').selectedIndex==0)
        var bill_state = document.getElementById('bill_state').value;
   var url="index.php?module=Settings&action=SettingsAjax&file=Serviceperformance&parenttab=Settings&ajax=yes&selectserverttab=2&selecttype=selected&billcityid="+tabid+'&bill_state='+bill_state+'&servicetype='+encodeURIComponent(servicetype);
   if(ld("#servicetype").find("option").length==2&&document.getElementById('servicetype').selectedIndex==1)
   {
    if(document.getElementById('bill_city')!=undefined)
        url+="&bill_city="+encodeURIComponent(document.getElementById('bill_city').value);
   }
	ldAjax(url,"",function(data){
		if(data.code == 1){
			ld(".main_grid_box [name=serviceperformancecontent]").html(data.result.content);
			ld("#table_serviceformancepick").html(data.result.pickhtml);
		}
        DelProgressObjs();
	})
    //window.location=url;
}
function getServicePerformanceType(obj,BLOCKIDSETTING,FIELDIDSETTING)
{
    //服务考核方法
}
/**
 *@andrw:
 *@date:20140825
 *@reason:服务绩效参数显示编辑
 *type:1.显示编辑框，2.隐藏编辑框
 *roleid：显示或隐藏的编辑框
 */
function vtlib_showeditinput_Server(type,roleid,countasrict)
{

    if(type == 1)
    {
      document.getElementById('editarea_'+roleid).style.display = 'block';
      document.getElementById('seetxtbox_'+roleid).style.display = 'none';
    }
    else
    {
     //   document.getElementById('txtbox_'+roleid).value = countasrict;
      document.getElementById('editarea_'+roleid).style.display = 'none';
      document.getElementById('seetxtbox_'+roleid).style.display = 'block';

    }
}

/**
 *@andrw:
 *@date:20140825
 *@reason:服务绩效参数上限编辑保存
 */
function vtlib_saveServercount(countasrict,roleid)
{
    var count = document.getElementById('txtbox_'+roleid).value;
    //edit:can 20210121 44312: (http://116.63.172.133:85/crm/ [^])客户问题-蝶金时代>系统设置>参数设置>服务考核设置>选择绩效维度“交通补贴报销比例”：编辑“交通补贴报销比例(%)”任意修改数字，保存后刷新界面，交通补贴报销比例(%)还是显示为“3.00”
    var selectserverttab = ld('#TemplateModule').val();
   // var type="^[0-9]\d*(\.\d+)?$";
    //var re = new RegExp(type);
    if(count==''){
        document.getElementById('txtbox_'+roleid).value = countasrict;
        var confirm_str = arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
    else if(count < 0){
        document.getElementById('txtbox_'+roleid).value = countasrict;
         var confirm_str = arrJsPopLabel['Must_number_greater_than_0'];
         RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
    else if(isNaN(count))
    {
         document.getElementById('txtbox_'+roleid).value = countasrict;
         var confirm_str = arrJsPopLabel['Must_number_greater_than_0'];
         RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }else{
         ld('#rptContentLoading').show();
        var data = "module=Settings&action=SettingsAjax&file=SaveServiceperformance&count=" +count + "&roleid="+roleid+"&ajax=true&seltab="+selectserverttab;
        if(selectserverttab==2)
        {
            //城市区域
			if(document.getElementById('servicetype') != undefined){
				data+="&servicetype="+encodeURIComponent(document.getElementById('servicetype').value);//服务考核方法
			}
        }
        new Ajax.Request(
		  'index.php',
            {queue: {position: 'end', scope: 'command'},
        	   method: 'post',
                postBody: data,
                onComplete: function(response) {
                    if(response.responseText.indexOf('SUCCESS')>-1){
                        document.getElementById('editarea_'+roleid).style.display = 'none';
                        document.getElementById('seetxtbox_'+roleid).style.display = 'block';
                        document.getElementById('txtbox_'+roleid).value = count;
                        document.getElementById('seetxtbox_'+roleid).innerHTML = commafy(count);
                        //alert(arrJsPopLabel['SUCCESSFULLYSAVED']);
                      ld('#rptContentLoading').hide();
                    }else if(response.responseText.indexOf('USEDEN')>-1)
                    {
                        var confirm_str = arrJsPopLabel['Savefailed'];
                        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                        ld('#rptContentLoading').hide();
                    }
                }
		  }
	   );
    }

}
//千分位格式
function commafy(num) {
//1.先去除空格,判断是否空值和非数
num = num + "";
num = num.replace(/[ ]/g, ""); //去除空格
    if (num == "") {
    return;
    }
    if (isNaN(num)){
    return;
    }
    //2.针对是否有小数点，分情况处理
    var index = num.indexOf(".");
    if (index==-1) {//无小数点
      var reg = /(-?\d+)(\d{3})/;
        while (reg.test(num)) {
        num = num.replace(reg, "$1,$2");
        }
    } else {
        var intPart = num.substring(0, index);
        var pointPart = num.substring(index + 1, num.length);
        var reg = /(-?\d+)(\d{3})/;
        while (reg.test(intPart)) {
        intPart = intPart.replace(reg, "$1,$2");
        }
       num = intPart +"."+ pointPart;
    }
return num;
}
//适用人员全选js  2014 0107
function select_all(checkel,groupname){
    var checkel=$(checkel);
    var thechecked=checkel.checked;
    var allcheckvals=$$('.StepUserClass');
    for(var i=0;i<allcheckvals.length;i++){
    var el=allcheckvals[i];
    var groupnameattr=el.getAttribute("groupname");
    if(groupnameattr==groupname)
    {
       el.checked=thechecked;
    }
  }
}
//保存模板打印适用人员 20140108
function SaveTemplatePrintAllocate(obj)
{
    var form=document.forms['frmTemplatePrint'];
    for(var i=0;i<form.elements.length;i++)
    {
         if(form.elements[i].name=='owners[]'&&form.elements[i].checked==true)
         {
            form.submit();
            return true;
         }
    }
    //form.submit();
    //请至少选择一个用户！
    var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
    RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
    return false;
}

/*
edit:can
date:20130815
reason:打印模板中插入模板
*/

function InsertTemplates(obj)
{
    if(trim(document.getElementById("selField").value )=="")
    {
        //请选择字段！
        var confirm_str = arrJsPopLabel['PLEASESELECTFIELD'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return false;
    }

    /*
    * editor:gyq_05
    * reason:适配审批通知提醒
    * date  :2016 2 25
    * */
    var txtvalue=document.forms['frmsendInfoContent'].SelectField.options[document.forms['frmsendInfoContent'].SelectField.selectedIndex].text;

    if(txtvalue.length > 0){
        document.getElementById('CKcontent').value += document.getElementById("selField").value;
        ld('#CKcontent').focus();
    } else{

        var txtvalue=document.forms['TemplatePrintform'].SelectField.options[document.forms['TemplatePrintform'].SelectField.selectedIndex].text;

        var body = UE.getEditor('CKTemplatePrint').getContent();
        var value = UE.getEditor('CKTemplatePrint').focus();
    }





    //document.getElementsByTagName("iframe")[0].contentWindow.document.body.innerHTML('CKTemplatePrint',document.getElementById("selField").value);
    //bodyEditor.innerHTML('CKTemplatePrint',document.getElementById("selField").value);
    /*
    if ( CKTemplatePrint.mode == 'wysiwyg' )
    {
		CKTemplatePrint.insertText( document.getElementById("selField").value );
	}
    */
}

function InsertHTML(value)
{
    //alert(value);
    //bodyEditor.html(document.getElementById("selField").value);
    /*
	if ( CKTemplatePrint.mode == 'wysiwyg' )
	{

		CKTemplatePrint.insertHtml( value );
	}
    else
    {
        //错误！
        alert(arrJsPopLabel['ERROR']);
    }
    */
}
function setTemplateDefault(obj)
{
    if(obj.checked)
    {
        obj.value=1
    }
    else
    {
        obj.value=0;
    }
}
var httpreq=null;
var NodeButton;
function RoleUser(obj,RoleID)
{
     httpreq=createXMLHTTP();
     NodeButton=obj;
     var urlparam='modules/Settings/RoleUser.php?roleid='+RoleID+'&parenttab=Settings&mode=Role2User';
     httpreq.open("POST",urlparam,true);
     httpreq.onreadystatechange=RoleAjax;
     httpreq.setRequestHeader("If-Modified-Since","0");
     httpreq.send();
     return false;

}
function RoleAjax()
{
      if(httpreq.readyState==4)
          {
              if(httpreq.status==0||httpreq.status==200)
              {
                RemindsMsg("","LdPopWidth400px",'',"yes","yes",httpreq.responseText);
                document.getElementById("Role2UserDiv").innerHTML= httpreq.responseText;
                fnvshobj(NodeButton, "Role2User");
              }
          }
}
/*
edit:can
date:20131205
reason:产品工具自定义字段属性修改
*/
function ProductToolEditField(obj,divid,id)
{

   if(ld('#cfList tr').hasClass('selectedbj')){
        ld('#cfList tr').removeClass('selectedbj');
    }
    //设置当前字段所在为黄色
    //ld('input[name=producttoolfield'+id+']').parent().parent().addClass('selectedbj');
    ld('#rptContentLoading').show();
	var tabid;
	if(ld('#selectmodule').val() != undefined){
		tabid = ld('#selectmodule').val();
	}
    //zkt 获取选择的源单类型（收款单、付款单）
    var selectsourcetype = '';
    var selecttypeobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=selecttype]");
    if(selecttypeobj.length>0&&selecttypeobj!=undefined){
        selectsourcetype = ld(selecttypeobj).find("option:selected").val();
    }
    var url = "module=Settings&action=SettingsAjax&file=ProductToolEditField&id="+id+"&tabid="+tabid+"&selectsourcetype="+selectsourcetype;
    var popupobj = CrmPopup.load("","","","LdPopWidth650px",'Settings',"","","","");
    popupobj.prevshow();
    ldAjax('index.php',url,function (data) {
        if (data.code == 1){
            var tmp_arr=[];
            tmp_arr.push(tabid);
            tmp_arr.push(id);
            ld('#rptContentLoading').hide();
            popupobj.setParams(data.result.title,saveFieldInfo,'','LdPopWidth650px','Settings',tmp_arr,data.result.oktext,'',data.result.canceltext)
            popupobj.show(data.result.content);
            var productdetailinfoArr = data.result.productdetails;
            popupobj.productdetailinfo = productdetailinfoArr;
            var divobj = ld('#'+popupobj.divid);
            // var  maxheight=ld(window).height()-ld("#"+divid+'_head').outerHeight()-ld("#"+divid+"_popupbottom").outerHeight()-35;
            // ld("#dvProductToolEditField [name=layout-productfieldmaxheight]").css("max-height",maxheight);
            // divobj.find("#dvProductToolEditField").css("zIndex",999);
            // ld("#layer").css("display","none");
            tooltip(divobj.find('.tip-items-list'), {transition: true, time: 200});
            popupobj.producttoolfieldid=id;
            //edit: xll BUG0062024 单据分录定制新增字段字段类型下拉框无搜索功能
            var selectobj=divobj.find(" [name=selectFieldType]");
            if(selectobj.length>0&&selectobj!=undefined){
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.attr("name"));
                cls_resetComboxHtmlobj.setPopupObj(popupobj);
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj,150);
            }
            // CrmPopup.center(tmpobj);
            var selectFieldType = divobj.find('#selectFieldType').val();
            //单据分录：引用字段 - 源单
            if(selectFieldType != undefined && (selectFieldType == 'RelatedModuleField'||selectFieldType == 101)){
                if( divobj.find('#fromvalue_type').val() == 'selectsource'){
                    var optionmodule_string =  divobj.find('#optionmodule_string').val();
                    /*if(!empty(optionmodule_string)){
                        var optionmodules = [];
                        optionmodules = optionmodule_string.split(',');
                        ld.each(optionmodules,function(index,module){
                            var name = 'relatedsourcefield_' + module;
                            if(ld('#'+name).val() != undefined){
                                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(name);
                                cls_resetComboxHtmlobj.setComboxObjHtml();
                                //zkt 20220624 1000143  采购订单、收付款单、出入库单，分录明细增加“合同订单”字段（咏睿）
                                var tdobj = Tools.getParentobjByChild(ld('#'+name),'td');
                                var width = ld(tdobj).width();
                                var cmb_divobj = ld(tdobj).find(' [name=dv_chzn_'+name+']');
                                var cmb_divwidth = ld(cmb_divobj).width();
                                var leftpadding = (width-cmb_divwidth)/2;
                                ld(cmb_divobj).css('left',leftpadding+'px');
                            }
                        });
                    }*/
                }
            }
            else if(selectFieldType == 'SelectComBox' || selectFieldType == 63 || selectFieldType == 'Select' || selectFieldType == 60){

                divobj.find("#fldpicklist").select2({
                    tags:true,width:'90%',
                    closeOnSelect: true,
                    minimumResultsForSearch: Infinity,
                    dropdownParent: divobj
                });

                divobj.find("#fldpicklist").on("select2:close", function (e)  {
                    var select2obj=divobj.find("#fldpicklist").select2('data');
                    divobj.find("#defaultvalue_picklist").empty();
                    if(selectFieldType == 'SelectComBox' || selectFieldType == 63 ){

                        ld.each(select2obj,function(index,info){
                            var text=info.text;
                            divobj.find("#defaultvalue_picklist").append("<option value='"+text+"'>"+text+'</option>');
                        });
                    }
                    else
                    {

                        divobj.find("#defaultvalue_picklist").append("<option value=''></option>");
                        ld.each(select2obj,function(index,info){
                            var text=info.text;
                            divobj.find("#defaultvalue_picklist").append("<option value='"+text+"'>"+text+'</option>');
                        });
                    }
                    //修改下拉框的样式
                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml("defaultvalue_picklist");
                    cls_resetComboxHtmlobj.setComboxObjHtml();

                    divobj.find("[name=dv_cmb_defaultvalue_picklist]").css("display",'block');
                });

                var cls_resetComboxHtmlobj=new cls_resetComboxHtml("defaultvalue_picklist");
                cls_resetComboxHtmlobj.setComboxObjHtml();
                divobj.find("[name=dv_cmb_defaultvalue_picklist]").css("display",'block');

            }

            //仅允许从价格表选择 受 允许编辑 控制
            if (productdetailinfoArr && productdetailinfoArr.columnname == 'listprice'){
                var editobj = divobj.find('#is_edit');
                var selectpricefrombookobj =  divobj.find('#selectpricefrombook');
                var tr_selectpricefrombookobj =  divobj.find('#tr_selectpricefrombook');
                editobj.off('change').on('change',function (){
                    var checked_value = ld(this).prop('checked');
                    selectpricefrombookobj.prop('checked',false);
                    if(checked_value){
                        tr_selectpricefrombookobj.show();
                    }else {
                        tr_selectpricefrombookobj.hide();
                    }
                })
            }

        }
    })

}
//zxm 2021-1230 详情字段颜色选择方法
function chooseDetailFieldColor(obj){
    var colpick_num = 1;
    var pick_color = ld(obj).attr('color');
    var css_type = pick_color==''||pick_color==undefined?'#3B4859':pick_color;
    var trobj = ld('#tr_fieldvaluecolor');
    var inputobj = ld('#tr_fieldvaluecolor #fieldvaluecolor');
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
    crmPopupobj.prevshow();
    var content='<link rel="stylesheet" href="themes/softed/colpick.css" type="text/css" /><div id="picker" name="picker" class="menu-colpick"></div>';
    getJsScript('include/js/colpick/colpick.js',function(){
        getJsScript('include/js/colpick/plugin.js',function(){
            crmPopupobj.setParams('选择颜色','',"","LdPopWidth350px",'Settings',"",'',"",'');
            crmPopupobj.show(content);
            var divid = crmPopupobj.divid;
            CrmPopup.findHtmlobj(divid,'picker').colpick({
                color:css_type,
                flat:true,
                layout:'RGB',
                submitText:'确认',
                onSubmit:function(hsb,hex,rgb,el){//ok之后的确认事件
                    var _color = '#'+hex;
                    inputobj.val(_color);
                    trobj.find('div[name="color_div"]').css('background',_color);
                    crmPopupobj.CancelEvent();
                }

            });
            var windowWidth = document.documentElement.clientWidth;
            var windowHeight = document.documentElement.clientHeight;
            if(colpick_num == 1)
                var popupHeight = ld('#'+divid).height()-126;
            else{
                var popupHeight = ld('#'+divid).height();
            }
            colpick_num++;
            var popupWidth = ld('#'+divid).width();
            ld('#'+divid).css({
                "position": "fixed",
                "top": (windowHeight-popupHeight)/2,   //+ld(document).scrollTop()明细界面的相关信息，滚动条到最下面，则弹出层显示错误
                "left": (windowWidth-popupWidth)/2
            });
        });
    });
}

/*
edit:chj
date:2016-02-15
reason:显示自定义字段的排序界面
*/
function ShowFieldSort(obj,divid,sType){
	var tabid = ld("#selectmodule").val();
    ld('#rptContentLoading').show();
    //获取选择的源单类型（收款单、付款单）
    var selectsourcetype = '';
    var selecttypeobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=selecttype]");
    if(selecttypeobj.length>0&&selecttypeobj!=undefined){
        selectsourcetype = ld(selecttypeobj).find("option:selected").val();
    }
    var url = "index.php?module=Settings&action=SettingsAjax&file=ProductToolSetupField&tabid="+tabid+"&type="+sType+"&selectsourcetype="+selectsourcetype;
    ldAjax(url,'',function(data){
        if (data.code == 1){
            ld('#rptContentLoading').hide();
            var OkfunParamsObj = ['','sortview',tabid,sType];
            var popupobj = CrmPopup.load(data.result.title,saveFieldSort,'','LdPopWidth400px','Settings',OkfunParamsObj,data.result.oktext,'',data.result.canceltext)
            popupobj.show(data.result.content);
            var divobj = ld('#'+popupobj.divid);
            //xxy 2023-11-17 单据分录定制排序，显示隐藏弹窗样式优化
            var tableobj = divobj.find('#sortview_table');
            var RightObj = tableobj.find(" .commonMultipleSelect:first");
            var Drag_Transfer = new DragTransfer();
            var translabel = {
                available: '',
                selected: '',
                placeholder: arrJsPopLabel['PleaseEnterFieldSearchFor'],
            };
            Drag_Transfer.SetTranslabel(translabel);
            if(sType == 'Sort'){//排序
                Drag_Transfer.right_Sortable = true;
                Drag_Transfer.SetDragTransfer(tableobj,"",RightObj,'reset','320');
                // ld("#sortview_form_div").parent("div#sortview").css('width','420px');
            }else if(sType == 'Dis'){//显示隐藏
                Drag_Transfer.right_Sortable = false;
                Drag_Transfer.SetDragTransfer(tableobj,"",RightObj,'reset','372');
                // ld("#sortview_form_div").parent("div#sortview").css('width','420px');
                // ld("#sortview_form_div").parent("div#sortview").css('left','52%');
            }
            // ld("#sortview_form_div").parent("div#sortview").css('top','40%');
        }
    });
    /*
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module=Settings&action=ProductToolSetupField&tabid="+tabid+"&type="+sType,
			onComplete: function(response) {
				ld('#rptContentLoading').hide();
				var results = response.responseText.split('&#&#&#');
                $("sortview_form_div").update(results[1]);
				fnvshobj(obj, divid);
			}
		}
	);*/

}
/*
edit:chj
date:2016-02-15
reason:保存自定义字段的排序
*/
function saveFieldSort(obj,divid,tabid,stype){
	ld('#rptContentLoading').show();
    var popupobj = CrmPopup.getPopupObj('last');
    var divobj = ld('#'+popupobj.divid);
	var selectedFieldStr = "";
    var selectedColumnsObj = divobj.find('#selectedColumns2').get(0);
    if(selectedColumnsObj != undefined){
        for (var i=0;i<selectedColumnsObj.options.length;i++){
            //获取模块所有自定义字段的排序顺序
            if(stype == 'Sort'){
                selectedFieldStr += selectedColumnsObj.options[i].value + ";";
            }else{
                //获取取消隐藏的所有自定义字段
                if(selectedColumnsObj.options[i].selected){
                    selectedFieldStr += selectedColumnsObj.options[i].value + ";";
                }
            }
        }
	}
    //zkt 获取选择的源单类型（收款单、付款单）
    var selectsourcetype = '';
    var selecttypeobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=selecttype]");
    if(selecttypeobj.length>0&&selecttypeobj!=undefined){
        selectsourcetype = ld(selecttypeobj).find("option:selected").val();
    }
	//更新、保存自定义字段顺序
	if(selectedFieldStr != ''){
        var url = "index.php?module=Settings&action=SettingsAjax&file=ProductToolField&submode=UpdateField"+stype+"&tabid="+tabid;
        url += "&parenttab=Settings&ajax=true&selectedFieldStr="+selectedFieldStr+"&selectsourcetype="+selectsourcetype;
        ldAjax(url,'',function(data){
            popupobj.CancelEvent();
            ld('#rptContentLoading').hide();
            ld("[name=producttoofieldlist]").html(data.result.content);
        });

	/*	new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
					method: 'post',
					postBody:"module=Settings&action=SettingsAjax&file=ProductToolField&submode=UpdateField"+stype+"&tabid="+tabid+"&parenttab=Settings&ajax=true&selectedFieldStr="+selectedFieldStr,
					onComplete: function(response) {
						ld('#rptContentLoading').hide();
						var strs= response.responseText.split('###SUCCESS###');
						document.getElementById("cfList").innerHTML=strs[1];
						fninvshnew(divid);

					}
			}
		);*/
	}else{//0026798: 控制面板-单据分录定制：点击【显示隐藏字段】，弹出层中直接点击保存，结果弹出层没有关闭
	   ld('#rptContentLoading').hide();
        popupobj.CancelEvent();
	}
}
/*
edit:chj
date:2015/6/3
reason:更改产品工具自定义字段显示顺序
*/
function UpdateFieldSequence(obj,producttoolfieldid,tabid,sequence,optype){
	ld('#rptContentLoading').show();
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:"module=Settings&action=SettingsAjax&file=ProductToolField&submode=UpdateFieldSequence&producttoolfieldid="+producttoolfieldid+"&tabid="+tabid+"&type="+optype+"&sequence="+sequence+"&parenttab=Settings&ajax=true",
				onComplete: function(response) {
					ld('#rptContentLoading').hide();
					var strs= response.responseText.split('###SUCCESS###');
					document.getElementById("cfList").innerHTML=strs[1];
					fninvshnew('dvProductToolEditField');

				}
		}
	);
}
//选择角色
function setproducttoolfieldprofile_idx(div_hidden_id,div_title){
	var selectuseridall = ld('#hidden_pro_profile_value').val();
	if(ld('#'+div_hidden_id) != undefined){
		var ids = ld('#'+div_hidden_id).val();
		var module = 'Users';
		var popup_caption_value = arrJsPopLabel['SELECT']+arrJsPopLabel['LBL_ROLE_NAME'];
		var popup_url = 'module=Users&action=UsersAjax&file=viewprofileinfo&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=profile';

    	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){

			var methodObj = {'popup_check_inactiveuser':'no'};
			scopepopupobj =  new ScopePopupObj(methodObj);
			scopepopupobj.popup_caption_value = popup_caption_value;//标题title
			scopepopupobj.popup_searchvalue = arrJsPopLabel['pleaseenterprofile'];//查询框默认值
			scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['pleaseenterprofile']+'\' onfocus=\'clearPlaceholder(this)\'></div>';
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
			   cls_ScopePopup.prop.popup_module = module;//模块
			   cls_ScopePopup.prop.popup_value = ids;
			    var parentsetEventBtnCancel=scopepopupobj.setEventBtnCancel;
			   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				 scopepopupobj.setEventBtnCancel=function(divid){
					   parentsetEventBtnCancel.apply(this,[divid]);

					 ld('#'+scopepopupobj.divid+' .E_pbtn .E_pbtncancel').unbind('closediv').on('closediv',function(){

							// if(ld('#'+scopepopupobj.divid).length > 0){
							// 	//删除div
							// 	var divobj = ld('#'+scopepopupobj.divid).get(0);
							// 	divobj.parentNode.removeChild(divobj);
							// }
						});
				   }
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
						//没有选择任何用户，则给出提示
						if(empty(cls_ScopePopup.return_obj.return_id)){
							var confirm_str = arrJsPopLabel['Pleaseselectatleaprofile'];
                              RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                              return false;
						}else{
							var selected_profile_id = cls_ScopePopup.return_obj.return_id;//选中的用户
							var selected_profile_name = cls_ScopePopup.return_obj.return_name;
							ld('#'+div_hidden_id).val(selected_profile_id);
	                        ld("#hidden_pro_profilefieldtype").val('role');
							ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
						}
					});
				}
			});
		});
	}
}
/*
edit:chj
date:2015/6/3
reason:设置自定义字段用户权限
*/
var setproducttoolfielduser_idx = 0;
function setProductToolFieldUser(producttoolfieldid,module){
    if(ld('#cfList tr').hasClass('selectedbj')){
        ld('#cfList tr').removeClass('selectedbj');
    }
    ld('#hidden_pro_profile_value').val();
                    //edit:can 20200825 单据分录数据权限控制，支持按照“角色控制”
    ld("#hidden_pro_profilefieldtype").val("user");
    //设置当前字段所在为黄色
    ld('input[name=producttoolfield'+producttoolfieldid+']').parent().parent().addClass('selectedbj');
	var tabid;
	var scopepopupobj;//自定义弹出层页面html，绑定事件
    var popup_caption_value = arrJsPopLabel['LBL_FIELDS_ACCESS'];//标题
    var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user&checkprivilege=no';
	//重写header
	var popup_header_html = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']+'\' onfocus=\'clearPlaceholder(this)\'><input type="checkbox" id=\'viewuser_nogroupuser\'><label for=\'viewuser_nogroupuser\'>'+arrJsPopLabel['SHOWNOGROUPUSER']+'</label></div>';
    //重写查询框的下拉div
	var popup_searchTextDiv_html = '<div id=\'popup_search_div\' style=\'padding-left:59px;display: block;position: absolute;top: 99px;\'><div class=\'view-search\' ></div></div>';
	if(document.getElementById('hiddentabid') != undefined){
		tabid = document.getElementById('hiddentabid').value;
	}
	var selectuseridall = ld('#hidden_pro_profile_value').val();
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		scopepopupobj =  new ScopePopupObj(module);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		scopepopupobj.popup_header = popup_header_html;
        scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认显示内容
		scopepopupobj.popup_searchTextDiv = popup_searchTextDiv_html;
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
            cls_ScopePopup.prop.popup_url = popup_url;//popup_url
           cls_ScopePopup.prop.popup_module = module;//模块
           cls_ScopePopup.prop.popup_value = selectuseridall;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
          var parentsetEventBtnCancel=scopepopupobj.setEventBtnCancel;
          //edit:can 202107 26 46944: (81mis.com/kfbcrm/)单据分录定制-测试合计-编辑-选择按部门-取消-遮罩层消失
           scopepopupobj.setEventBtnCancel=function(divid){
               parentsetEventBtnCancel.apply(this,[divid]);

             ld('#'+scopepopupobj.divid+' .E_pbtn .E_pbtncancel').unbind('closediv').on('closediv',function(){

            		// if(ld('#'+scopepopupobj.divid).length > 0){
            		// 	//删除div
            		// 	var divobj = ld('#'+scopepopupobj.divid).get(0);
            		// 	divobj.parentNode.removeChild(divobj);
            		// }
                });
           }
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){

                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){

                    ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                    var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
					ld('#hidden_pro_profile_value').val(selected_user);
                    //edit:can 20200825 单据分录数据权限控制，支持按照“角色控制”
                    ld("#hidden_pro_profilefieldtype").val("user");


					return false;
                });
            }
		});
	});
}

/*
edit:chj
date:2022/3/29
reason:设置自定义字段用户权限
*/
//选部门
function setProductToolFieldGroup(producttoolfieldid,module){
	var popup_caption_value = arrJsPopLabel['SELECT']+arrJsPopLabel['USERGROUPLIST'];
    var popup_url = 'module=Users&action=UsersAjax&file=viewgroupinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=group';
	var selectuseridall = ld('#hidden_pro_profile_value').val();
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var methodObj = {'popup_check_inactiveuser':'yes'};
		scopepopupobj =  new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];//查询框默认值
		scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP']+'\' onfocus=\'clearPlaceholder(this)\'></div>';
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
		   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
           cls_ScopePopup.prop.popup_module = module;//模块
		   cls_ScopePopup.prop.popup_value = selectuseridall;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		   var parentsetEventBtnCancel=scopepopupobj.setEventBtnCancel;
          //edit:can 202107 26 46944: (81mis.com/kfbcrm/)单据分录定制-测试合计-编辑-选择按部门-取消-遮罩层消失
           scopepopupobj.setEventBtnCancel=function(divid){
               parentsetEventBtnCancel.apply(this,[divid]);

             ld('#'+scopepopupobj.divid+' .E_pbtn .E_pbtncancel').unbind('closediv').on('closediv',function(){

            		// if(ld('#'+scopepopupobj.divid).length > 0){
            		// 	//删除div
            		// 	var divobj = ld('#'+scopepopupobj.divid).get(0);
            		// 	divobj.parentNode.removeChild(divobj);
            		// }
                });
           }
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){

                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){

                    ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                    var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
					ld('#hidden_pro_profile_value').val(selected_user);
                    //edit:can 20200825 单据分录数据权限控制，支持按照“角色控制”
                    ld("#hidden_pro_profilefieldtype").val("group");


					return false;
                });
            }
		});
	});
}

//230417 wyt BUG0064764 kfbcrm 单据分录定制---编辑字段---适用范围“按部门”“按成员”“按角色”---查询选择框内文字没有清空
function clearPlaceholder(obj){
    obj.placeholder='';
}

/*
edit:andy
date:20140310
reason:立即查找(用户使用分析表),
*/
function UserAnalySisSearch(obj,searchtype)
{
    var url='module=Settings&action=userloginanalysis';
    var useReportid=0;
    if(searchtype=='BasicSearch')
    {
        var startmonth=document.getElementById('startmonth').value;
        var endmonth=document.getElementById('endmonth').value;
        var cversion=encodeURIComponent(document.getElementById('cversion').value);
        var city=encodeURIComponent(document.getElementById('city').value);
        var phone=document.getElementById('phone').value;
        url+='&startmonth='+startmonth+'&endmonth='+endmonth+'&cversion='+cversion+'&city='+city+'&phone='+phone;
        url+='&ajax=true&searchtype=BasicSearch';
        //ld('#rptContentLoading').show();
        document.getElementById('status').style.display = 'inline';

        new Ajax.Request
        (
        		'index.php',
        		{
        			queue: {
        				position: 'end',
        				scope: 'command'
        			},
        			method: 'post',
        			postBody:url,
        			onComplete: function(response)
                    {
                        document.getElementById('status').style.display = 'none';
                        var results=response.responseText.split("###SUCCESS###");
                        //$("UseReportList").innerHTML=results[1];
                        document.getElementById('UseReportList').innerHTML=results[1];

                    }
                }
          )
    }

    //return false;
}

/**
 *@andrw:
 *@date:20140826
 *@reason:公海客户上限类型显示隐藏
 *type:1.显示用户，2.显示角色
 */
/*function changeastricttype(type,count){

    if(type == 1)
    {
        document.getElementById('select_user_ASTRICTTYPE').disabled = false;
        document.getElementById('select_role_ASTRICTTYPE').style.display = 'none';
    }
    else
    {
        document.getElementById('select_role_ASTRICTTYPE').style.display = 'block';
        document.getElementById('select_user_ASTRICTTYPE').disabled = true;
        //document.getElementById('select_user_ASTRICTTYPE').value = count;
    }
}*/
/**
 *@andrw:
 *@date:20140825
 *@reason:公海客户上限显示编辑
 *type:1.显示编辑框，2.隐藏编辑框
 *roleid：显示或隐藏的编辑框
 */
function vtlib_showeditinput_account(type,roleid,countasrict)
{
    if(type == 1)
    {
      document.getElementById('editarea_'+roleid).style.display = 'block';
      document.getElementById('seetxtbox_'+roleid).style.display = 'none';
    }
    else
    {
      document.getElementById('editarea_'+roleid).style.display = 'none';
      document.getElementById('seetxtbox_'+roleid).style.display = 'block';
      document.getElementById('txtbox_'+roleid).value = countasrict;
    }
}

/**
 *@andrw:
 *@date:20140825
 *@reason:模公海客户上限编辑保存
 */
function vtlib_savecount(countasrict,roleid)
{
    var count = document.getElementById('txtbox_'+roleid).value;
    var type="^[0-9]*[1-9][0-9]*$";
    var re = new RegExp(type);
    if(count==''){
        document.getElementById('txtbox_'+roleid).value = countasrict;
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['CANOTEMPTY']);
        return;
    }
    else if(count.match(re)==null)
    {
         document.getElementById('txtbox_'+roleid).value = countasrict;
         RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['Limitthenumbermustbeapositiveinteger']);
        return;
    }else{
        var data = "module=Settings&action=SettingsAjax&file=SaveAcctountAstrictRole&count=" +count + "&roleid="+roleid+"&ajax=true";
        new Ajax.Request(
		  'index.php',
            {queue: {position: 'end', scope: 'command'},
        	   method: 'post',
                postBody: data,
                onComplete: function(response) {
				    $('status').hide();
                    if(response.responseText.indexOf('SUCCESS')>-1){
                        document.getElementById('editarea_'+roleid).style.display = 'none';
                        document.getElementById('seetxtbox_'+roleid).style.display = 'block';
                        document.getElementById('txtbox_'+roleid).value = count;
                        document.getElementById('seetxtbox_'+roleid).innerHTML = count;

                        RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['SUCCESSFULLYSAVED']);
                    }else if(response.responseText.indexOf('USEDEN')>-1)
                    {
                        RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['Savefailed']);
                    }
                }
		  }
	   );
    }

}
/**
 *@andy:
 *@date:20140819
 *@reason:模块中英文名称保存-
 *@version:v5.61
 */
 var prevtrobj=undefined;
function vtlib_showeditinput(event,type,modulename_zh,modulename_en)
{

    var e=event||window.event;
    var editobj=e.srcElement||e.target;//当前点击的编辑/取消按钮对象
    var nowtr=editobj.parentNode||editobj.parentElement;//当前编辑行父级(td)对象

    nowtr=nowtr.parentNode||nowtr.parentElement;//获取当前点击的编辑/取消按钮所在行(tr)
    var hideobj=ld(nowtr).find("a[ifhide=1]");
    hideobj.toggle();

    var tddivobj=undefined;//td下 div
    var tdspnobj=undefined;//td下span
    var tdcell=undefined;//表格的单元格

    if(type == 1)//点击"编辑"按钮
    {
       //2:关闭/启用和编辑列
       //3:只修改中英文列的值，28808: 控制面板>模块管理：OA表单的模块，编辑后保存或者取消，备注列不显示“OA表单”
       for(var i=0;i<4;i++)//获取当前对象的单元格数 nowtr.cells.length -1为去掉操作列一个td,操作当前行下其余单元格下的div 和 span
       {
         /**
          *@edit:andy
          *@date:20140828
          *@reason:每行增加序列号，JS报错
          *@version:v5.6
          */
         if(i==0)
            continue;
         tdcell=nowtr.cells[i];//单元格td对象

         tddivobj_input= tdcell.getElementsByTagName('input');//输入框input对象

         tdspnobj_span= tdcell.getElementsByTagName('span');//原显示span对象
         if(tdspnobj_span.length<=0)//‘启用按钮’列
            continue;
		 if(tddivobj_input[0] != undefined){
			tddivobj_input[0].value=tdspnobj_span[0].innerHTML;//取消不改变原值
		 }
         tddivobj= tdcell.getElementsByTagName('div');//单元格td对象下的div对象数组
		if(tddivobj[0] != undefined){
			tddivobj[0].style.display='block';//这里默认第一个对象样式改变
		}

         tdspnobj= tdcell.getElementsByTagName('span');//单元格td对象下的span对象数组
		 if(tdspnobj[0] != undefined){
			tdspnobj[0].style.display='none';//这里默认第一个对象样式改变
		 }
       }
     //zkt 20220601 52404（https://81mis.com/kfbtest/index.php）系统设置》模块设置，编辑模块名称时，编辑框异常；还有同时取消2个模块编辑时，有个模块编辑框还在
        if(prevtrobj != undefined && nowtr != prevtrobj)
        {
             for(var i=0;i<4;i++)
               {
                 if(i==0)
                    continue;
                 tdcell=prevtrobj.cells[i];
                 tddivobj= tdcell.getElementsByTagName('div');
                 tddivobj[0].style.display='none';
                 tdspnobj= tdcell.getElementsByTagName('span');
                 tdspnobj[0].style.display='block';
               }
               ld(prevtrobj).find('.btns_edit_action').show();
                ld(prevtrobj).find('.btns_upload_action').hide();
                ld(prevtrobj).find('.editarea_action').hide();
        }
        ld(nowtr).find('.btns_edit_action').hide();
        ld(nowtr).find('.btns_upload_action').show();
        ld(nowtr).find('.editarea_action').show();
         prevtrobj=nowtr;


    }
    else//点击保存按钮
    {

        //prevtrobj会在上次编辑但未保存的操作行定义

        if(prevtrobj!=undefined)
        {

             for(var i=0;i<prevtrobj.cells.length-1;i++)//获取上次操作对象的单元格数 -2为去掉操作列两个td,操作当前行下其余单元格下的div 和 span
               {
                 if(i==0)
                    continue;
                 tdcell=prevtrobj.cells[i];//获取上次操作行的单元格td对象
                 tddivobj= tdcell.getElementsByTagName('div');//单元格td对象下的div对象数组

                 tddivobj_input= tdcell.getElementsByTagName('input');//输入框input对象
                 if(tddivobj_input.length<=0)//备注字段
                    continue;

                 tdspnobj_span= tdcell.getElementsByTagName('span');//原显示span对象
                 if(tdspnobj_span.length<=0)//‘是否启用按钮’列
                    continue;

                 tddivobj_input[0].value=tdspnobj_span[0].innerHTML;//取消不改变原值
                 tddivobj[0].style.display='none';
                 tdspnobj= tdcell.getElementsByTagName('span');//单元格td对象下的span对象数组
                 tdspnobj[0].style.display='block';
                 //更新成修改后的值
                 if(modulename_zh != '' && modulename_en != ''){
                    var tag = tdspnobj[0].getAttribute('tag');
                    if(tag == 'zh'){
                        tdspnobj[0].innerHTML = modulename_zh;
                    }else if(tag == 'en'){
                        tdspnobj[0].innerHTML = modulename_en;
                    }
                 }

               }
        }
        ld(nowtr).find('.btns_edit_action').show();
        ld(nowtr).find('.btns_upload_action').hide();
        ld(nowtr).find('.editarea_action').hide();
        prevtrobj=undefined;//取消事件则 prevtrobj 对象 = undefined
    }

}

/**
 *@andy:
 *@date:20140819
 *@reason:模块中英文名称保存
 *@version:v5.61
 */
function vtlib_savemodulename(event,modulename_zh_id,modulenename_en_id,actionmodle,BLOCKIDSETTING,FIELDIDSETTING)
{

    var modulenename_zh=document.getElementById(modulename_zh_id).value;
    var modulenename_en=document.getElementById(modulenename_en_id).value;
    //zxm 2021-1206 上传模块图标
    var editIconAreaDivid = 'editarea_'+actionmodle+'_action';
    var formData = new FormData();
    var have_active_icon = false;
    if( ld("#"+editIconAreaDivid+" [name=active_icon]").get(0).files.length>0)
    {
        have_active_icon = true;
        formData.append('active_icon', ld("#"+editIconAreaDivid+" [name=active_icon]").get(0).files[0]);
        formData.append('active_icon_name', ld("#"+editIconAreaDivid+" [name=active_icon_name]").val());
        formData.append("active_icon_size",ld("#"+editIconAreaDivid+" [name=active_icon]").get(0).files[0].size);
        formData.append("active_icon_type",ld("#"+editIconAreaDivid+" [name=active_icon]").get(0).files[0].type);
    }
    if(modulenename_zh == '' || modulenename_en == '')
    {
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['MODULENAMECANNOTBEEMPTY']);
        return false;
    }
	var surl = "index.php?module=Settings&action=SettingsAjax&file=ModuleManager&actionmodle=" +actionmodle + "&modulenename_zh="+encodeURIComponent(modulenename_zh)+"&modulenename_en="+encodeURIComponent(modulenename_en)+"&ajax=true&blockidsetting="+BLOCKIDSETTING+"&fieldidsetting="+FIELDIDSETTING;
    ld.ajax({
        url:surl,
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
        if(data.code==1){
            // @edit:diony @date:2020-07-08 @reason: 清除缓存
            // 0036825: 设置-系统设置-模块名称，修改“服务合同”模块名称，成员管理字段“ 显示服务合同信息”没有更改过来，需要清除缓存
            clearcachesNoMsg();
            vtlib_showeditinput(event,2,modulenename_zh,modulenename_en);
            //图片刷新
            //ld('#vtlib_modulemanager_list').html(data.result.content);
            var randNum = Math.random();
            randNum = randNum.toFixed(4);
            if (have_active_icon){
                ld("#editarea_"+actionmodle+"_showcontent").find('img').attr('src',data.result.active_icon+'?a='+randNum).show();
                //ld("#"+editIconAreaDivid).find('img').attr('src','dataCache/moduleIcon/active_icon_'+actionmodle+'.png?a='+randNum);
            }
        }
        else if(data.code=='-1')
        {
            RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['MODULECHINESENAMEALREADYEXISTS']);

        }
        else
        {
            RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['MODULEENGLISHNAMEALREADYEXISTS']);
        }
        DelProgressObjs();
    })
    // ldAjax(surl,{data:formData},function(data){
	// 	if(data.code==1){
    //   // @edit:diony @date:2020-07-08 @reason: 清除缓存
    //   // 0036825: 设置-系统设置-模块名称，修改“服务合同”模块名称，成员管理字段“ 显示服务合同信息”没有更改过来，需要清除缓存
    //   clearcachesNoMsg();
    //   vtlib_showeditinput(event,2,modulenename_zh,modulenename_en);
	// 	}
	// 	else if(data.code=='-1')
	// 	{
	// 		RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['MODULECHINESENAMEALREADYEXISTS']);
    //
	// 	}
	// 	else
	// 	{
	// 		RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['MODULEENGLISHNAMEALREADYEXISTS']);
	// 	}
    //     DelProgressObjs();
	// })
}

/**
 *@edit:andy
 *@date:20140909
 *@reason:左右选择项改进
 *@version:
 */
 if (document.all)

	var browser_ie=true

else if (document.layers)

	var browser_nn4=true

else if (document.layers || (!document.all && document.getElementById))

	var browser_nn6=true
function copySelectedOptionsSettingModule(source, destination) {


    var srcObj = document.getElementById(source);//$(source);
	var destObj = document.getElementById(destination);//$(destination);
	if(typeof(srcObj) == 'undefined' || typeof(destObj) == 'undefined') return;
    for(i=0;i<destObj.length;i++){
        destObj.options[i].selected=false;
    }
    for (i=0;i<srcObj.length;i++) {
		if (srcObj.options[i].selected==true) {
			var rowFound=false;
			var existingObj=null;
			for (j=0;j<destObj.length;j++) {
				if (destObj.options[j].value==srcObj.options[i].value) {
                    srcObj.options.remove(i);//无论默认有无，都去掉该备选项 ,
					rowFound=true
					existingObj=destObj.options[j]
					break
				}
			}
			if (rowFound!=true) {
				var newColObj=document.createElement("OPTION")
				newColObj.value=srcObj.options[i].value
                if (browser_ie)
                    newColObj.innerText=srcObj.options[i].innerText
				else if (browser_nn4 || browser_nn6)
                    newColObj.text=srcObj.options[i].text
				destObj.appendChild(newColObj)//右键
				srcObj.options[i].selected=false
                srcObj.options.remove(i);
                i=-1;
				newColObj.selected=true
				rowFound=false
			} else {
				if(existingObj != null)
                    existingObj.selected=true
			}
		}
	}
}

//快速创建
function copySelectedQuickFields(source, destination) {


    var srcObj = document.getElementById(source);//$(source);
	var destObj = document.getElementById(destination);//$(destination);
	if(typeof(srcObj) == 'undefined' || typeof(destObj) == 'undefined') return;
    for(i=0;i<destObj.length;i++){
        destObj.options[i].selected=false;
    }
    var isMustWrite='no';
    var selectedlength=0;
    for (i=0;i<srcObj.length;i++) {

		if(srcObj.options[i].selected==true) {
			var rowFound=false;
			var existingObj=null;
            selectedlength++;
            var fieldinfo=srcObj.options[i].value;
            var infos=fieldinfo.split(":");
            var typeofdata=infos[1];
            var typeofdatas=typeofdata.split("~");
            if(typeofdatas.length>=1&&typeofdatas[1].toLocaleLowerCase()=='m'&&destination=='AssmablyList')
            {
                isMustWrite='yes';
                continue;
            }
			for (j=0;j<destObj.length;j++) {
				if (destObj.options[j].value==srcObj.options[i].value) {
                    srcObj.options.remove(i);//无论默认有无，都去掉该备选项 ,
					rowFound=true
					existingObj=destObj.options[j]
					break
				}
			}
			if (rowFound!=true) {
				var newColObj=document.createElement("OPTION")
				newColObj.value=srcObj.options[i].value
                if (browser_ie)
                    newColObj.innerText=srcObj.options[i].innerText
				else if (browser_nn4 || browser_nn6)
                    newColObj.text=srcObj.options[i].text
				destObj.appendChild(newColObj)//右键
				srcObj.options[i].selected=false
                srcObj.options.remove(i);
                i=-1;
				newColObj.selected=true
				rowFound=false
			} else {
				if(existingObj != null)
                    existingObj.selected=true
			}
		}
	}

    if(isMustWrite=='yes'&&selectedlength==1)
    {
         RemindsMsg("","LdPopWidth400px",'',"yes","yes",quickcreatetip);
    }
}


/**
 *@edit:andy
 *@date:
 *@reason:左右结构点击事件
 *@version:
 */
function addColumn(source, destination)
{
    var availListObj=getObj(source)
    var selectedColumnsObj=getObj(destination)


    for (i=0;i<availListObj.length;i++)
    {
        if (availListObj.options[i].selected==true)
        {
        	var rowFound=false;
        	var existingObj=null;
            for (j=0;j<selectedColumnsObj.length;j++)
            {
                if (selectedColumnsObj.options[j].value==availListObj.options[i].value)
                {
                    rowFound=true
                    existingObj=selectedColumnsObj.options[j]
                    break
                }
            }
            if (rowFound!=true)
            {
                var newColObj=document.createElement("OPTION")
                newColObj.value=availListObj.options[i].value
                if (browser_ie) newColObj.innerText=availListObj.options[i].innerText
                else if (browser_nn4 || browser_nn6) newColObj.text=availListObj.options[i].text
                selectedColumnsObj.appendChild(newColObj)
                availListObj.options[i].selected=false
                newColObj.selected=true
                availListObj.remove(i);//20140902，diony，右移时删除左边信息
                rowFound=false
            }
            else
            {
                if(existingObj != null) existingObj.selected=true
            }
        }
    }
}
function updateMenu(obj){
	var tag = ld(obj).attr('tag');
  RemindsMsg("","LdPopWidth400px",'',"yes","yes",tag);
}
/**
 *@edit:chj
 *@date:2015/3/31
 *@reason:权限管理、部门 设置成员事件
 *@version:V6.0 角色权限改进
 */
function clickOnBlurMember(obj){
	if(obj.value == '')
	{
		obj.value = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];
		obj.style.color='#999';
	}
}
/**
 *@edit:chj
 *@date:2015/3/31
 *@reason:权限管理、部门 设置成员事件
 *@version:V6.0 角色权限改进
 */
function clickOnFoucusMember(obj){
	var membermessage = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];
	if(obj.value == membermessage)
	{
		obj.value="";
		obj.style.color='#000';
	}
}
/**
 *@edit:cyb
 *@date:2016-02-24
 *@reason:【控制面板】-【员工轨迹组】新增或者编辑事件
**/
function CreateTracks(trackpostion_id,operatetype)
{
  //  puyoungJS_DialogBox.block();//遮罩层
  //  ld('#rptContentLoading').show();
	url = 'index.php?module=Settings&action=SettingsAjax&file=EditTracks&trackpostion_id='+trackpostion_id+'&operatetype='+operatetype;

    var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',[trackpostion_id,operatetype],"","","");
    crmPopupobj.prevshow();
    ldAjax(url,{},function(ajaxdata){

        crmPopupobj.setParams(ajaxdata.result.title,SaveTrackPostion,"","LdPopWidth600px","trackposition",
            [trackpostion_id],ajaxdata.result.oktext,"",ajaxdata.result.canceltext);

        CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,ajaxdata.result.content);
        var cls_resetComboxHtmlobj=new cls_resetComboxHtml("cycle");
        cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(280);
        var cls_resetComboxHtmlobj=new cls_resetComboxHtml("frequency");
        cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(280);

        // 设置内容最大高度
        crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
    })
}
/**
 *@edit:cyb
 *@date:2016-02-25
 *@reason:保存员工轨迹定位组信息；
 **/
function SaveTrackPostion(trackpostion_id)
{
    var popupuobj=CrmPopup.getPopupObj("last");

    var operatetype=document.getElementById('operatetype').value;
    var trackpostion=document.getElementById('trackpostion').value;
    var starttime=document.getElementById('starttime').value;
    var stoptime=document.getElementById('stoptime').value;

    var cycle=ld("#"+popupuobj.divid+" [name=cycle]").val();
    var frequency=ld("#"+popupuobj.divid+" [name=frequency]").val();
    if(trim(trackpostion)=='')
    {
       var confirm_str = arrJsPopLabel['TRACKGROUPNAME']+arrJsPopLabel['CANOTEMPTY'];
       RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
       var currObj = getObj("trackpostion");
       currObj.focus();
       return false;
    }
    if(trim(starttime)=='')
    {
       var confirm_str = arrJsPopLabel['STARTDATE']+arrJsPopLabel['CANOTEMPTY'];
       RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
       return false;
    }
    if(trim(stoptime)=='')
    {
       var confirm_str = arrJsPopLabel['ENDDATE']+arrJsPopLabel['CANOTEMPTY'];
       RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
       return false;
    }
    if(trim(stoptime)<=trim(starttime)) //结束日期不得小于开始日期
    {
       var confirm_str = arrJsPopLabel['ENDTIME']+arrJsPopLabel['GREATETHAN']+arrJsPopLabel['BEGINTIME'];
       RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
       return false;
    }

	url = 'index.php?module=Settings&action=SettingsAjax&file=SaveTracks&trackpostion_id='+trackpostion_id+'&operatetype='+operatetype;
    url+='&trackpostion='+trackpostion+'&starttime='+starttime+'&stoptime='+stoptime+"&cycle="+cycle+"&frequency="+frequency;
    ldAjax(url,{},function(){
        //BUG20240705-70
        //edit:can  后台设置，轨迹定位组，新增定位起始时间大于结束时间保存，点击提示信息中的确定修改为正确的时间保存后，弹窗没有关闭（定位参数保存成功了）

        popupuobj.CancelEvent();
        RefreshTrackGroup()
    })
	/*new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
					if(trim(response.responseText)=='Duplicate')
					{
                       var confirm_str = arrJsPopLabel['POSITIONINGGROUPNAMECANNOTBEREPEATED'];
                       RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                       var currObj = getObj("trackpostion");
                       //document.getElementById('trackpostion_name').value=="";
                       currObj.focus();
                       return false;
                    }
         window.location="index.php?module=Settings&action=listtracks&blockidsetting="+blockidsetting+"&fieldidsetting="+fieldidsetting;
                    }
          }
     );*/


 }
 /**
  *@edit:cyb
  *@date:2016-02-26
  *@reason:显示工作日历管理弹出层界面；
 *
 function ShowWorkingSpace(start){

    ld('#EditTrackProfile').hide();
    puyoungJS_DialogBox.block();//遮罩层
    ld('#rptContentLoading').show();
	url = 'module=Settings&action=SettingsAjax&file=ShowWorkingSpace&start='+start;
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
					ld('#rptContentLoading').hide();
					var results=response.responseText.split('&#&#&#');
					if($("listworkcalender")!=undefined)
					{
						$("listworkcalender").innerHTML=results[1];
						fnvshobj(obj, 'listworkcalender');
					}
				}
		}
	);

 }*/
/**
 *@edit:cyb
 *@date:2016-02-26
 *@reason:弹出层分页刷新事件
*
function getPopEntries_js(start){
    ShowWorkingSpace(start);
}*/
/**
*edit:cyb
*date:2016-05-25
*reason: bug:21563:控制面板>轨迹定位组：新增轨迹定位组>工作日历管理>新增工作日历，翻页组件 无效
*
function getWorkingSpace_js(start){
    ShowWorkingSpace(start);
}*/
/**
 *@edit:cyb
 *@date:2016-02-26
 *@reason:显示工作日历管理编辑或新增界面
 *
 function  EditWorkingSpace(id,operatetype,start_spec_year,start_hol_year,pop_portion,selected_date){
    ld('#listworkcalender').hide();
    puyoungJS_DialogBox.block();//遮罩层
    ld('#rptContentLoading').show();
    //attr_selectdate=ld('#attr_selectdate').val();
    attr_selectdate=selected_date;
	url = 'module=Settings&action=SettingsAjax&file=EditWorkingSpace&workcalender_id='+id+'&operatetype='+operatetype+'&start_spec_year='+start_spec_year+'&start_hol_year='+start_hol_year+'&pop_portion='+pop_portion;
	url+='&attr_selectdate='+attr_selectdate;
    new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
					ld('#rptContentLoading').hide();
					var results=response.responseText.split('&#&#&#');
                    if(trim(pop_portion)!=''&&trim(pop_portion)=='all_poptable'){//刷新整个弹出层
                        if($("EditWorkingSpace")!=undefined)
    					{
    						$("EditWorkingSpace").innerHTML=results[1];
    						fnvshobj(obj, 'EditWorkingSpace');
                            var spec_year=ld('#specialworkingday .mar_lr5').text();
                            var hol_year=ld('#holiday_valcation .mar_lr5').text();
                            ld('#special_'+spec_year).attr("style", "display:block;");
                            ld('#hol_'+hol_year).attr("style", "display:block;");
    					}
                    }else{
                        if($("workingday")!=undefined)//刷新日期
    					{
    						$("workingday").innerHTML=results[1];
                            var spec_year=ld('#specialworkingday .mar_lr5').text();
                            var hol_year=ld('#holiday_valcation .mar_lr5').text();
                            ld('#special_'+spec_year).attr("style", "display:block;");
                            ld('#hol_'+hol_year).attr("style", "display:block;");
    					}
                    }

				}
		}
	);
 }*/
 /**
 *@edit:cyb
 *@date:2016-03-01
 *@reason:工作日历管理编辑保存界面工作日刷新事件
 *
 function getWorkingdayEntries_js(type,pop_portion)
 {
     if(pop_portion=='pop_special'){
        var spec_year=ld('#specialworkingday .mar_lr5').text();
        if(type=='pre'){
             spec_year=parseInt(spec_year)-1;
        }else{
            spec_year=parseInt(spec_year)+1;

        }
        ld('#specialworkingday .mar_lr5').text(spec_year);
        ld('#specialworkingday .holidaydate').attr("style", "display:none;");
        ld('#special_'+spec_year).attr("style", "display:block;");
     }else{
        var hol_year=ld('#holiday_valcation .mar_lr5').text();
        if(type=='pre'){
             hol_year=parseInt(hol_year)-1;
        }else{
            hol_year=parseInt(hol_year)+1;
        }
        ld('#holiday_valcation .mar_lr5').text(hol_year);
        ld('#holiday_valcation .holidaydate').attr("style", "display:none;");
        ld('#hol_'+hol_year).attr("style", "display:block;");
     }
 }*/
 /**
 *@edit:cyb
 *@date:2016-03-01
 *@reason:工作日历管理保存事件
 *
 function SaveWorkingSpace(id,operatetype)
 {
    var workcalender_name=document.getElementById('workcalender_name').value; //日历名称
    if(trim(workcalender_name)=='')
    {
        var confirm_str = arrJsPopLabel['CALENDERNAME']+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        var currObj = getObj("workcalender_name");
        currObj.focus();
        return false;
    }
    var defworkday=document.getElementsByName('defworkday');
    var strarr=new Array();
    for(var i=0;i<defworkday.length;i++){
        if(defworkday[i].checked == true)
        {
            strarr[i]=1;
        }
        else{
            strarr[i]=0;
        }
    }
    var strdefworkday=strarr.join(',');//获取复选框选中星期
    var special=ld("#specialworkingday  span ").text();
    var holiday=ld("#holiday_valcation  span").text();
    var def_workingday=ld("#def_workingday ").val();
   	var url = 'module=Settings&action=SaveWorkingSpace&workcalender_id='+id+'&operatetype='+operatetype;
    url+= '&workcalender_name='+workcalender_name+'&defworkday='+strdefworkday;
    url+='&special='+special+'&holiday='+holiday+'&def_workingday='+def_workingday;
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
				if(trim(response.responseText)=='Duplicate')
				{
                   var confirm_str = arrJsPopLabel['WORKCALENDERCANNOTBEREPEATED'];
                   RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                   var currObj = getObj("workcalender_name");
                   currObj.focus();
                   return false;
                }
                fninvshnew('EditWorkingSpace');//保存完之后关闭当前弹出层
                ShowWorkingSpace(1); //显示工作日历列表
                changeSelectWorkingCalender();//动态改变新增或者编辑轨迹定位组弹出层工作日历下拉框取值 ；
           }
        }
     );
 }*/
 /**
  *@edit:cyb
  *@date:2016-03-02
  *@reason:工作日历管理界面”添加“按钮事件
 *
 function AddWorkingday(id,operatetype,languageType,workingdaytype){
    ld('#EditWorkingSpace').hide();
    puyoungJS_DialogBox.block();//遮罩层
    ld('#rptContentLoading').show();
    var	url = 'module=Settings&action=SettingsAjax&file=AddWorkingday&workcalender_id='+id+'&workingdaytype='+workingdaytype+'&operatetype='+operatetype;

    //alert(url);
    if(languageType=='zh') {
        var dNMin=['日','一', '二', '三', '四', '五', '六'];
        var mNam=['一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月'];
        var preMonth='上月';
        var nextMonth='下月';

    }
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
					ld('#rptContentLoading').hide();
					var results=response.responseText.split('&#&#&#');
					if($("addWorkingday")!=undefined)
					{
						$("addWorkingday").innerHTML=results[1];
                        ld('#calenderview').multiDatesPicker({
                            	altField: '#altField', //设置保存选中日期值ID；
                                dayNamesMin: dNMin, //设置一周每天的格式;
                                dateFormat: 'yy-mm-dd', //设置日期格式；
                                firstDay: 1 , //设置星期一为第一天
                                monthNames:mNam, // 设置月份显示格式;
                                prevText :preMonth,
                                nextText :nextMonth
                        });
						fnvshobj(obj, 'addWorkingday');
					}
				}
		}
	);
 }*/
  /**
  *@edit:cyb
  *@date:2016-03-03
  *@reason:添加特殊工作日保存事件
 *
 function SaveWorkingday(id,workingdaytype,operatetype)
 {
    var selected_date=ld('#altField').val();
    var remark = ld('#remark').val();
    if(empty(remark)){//备注不能为空
        var confirm_str = document.getElementById('remark').title+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        var currObj = getObj("remark");
            currObj.focus();
        return false;
    }
    if(trim(selected_date).length<1){//至少选择一个日期
        var confirm_str = arrJsPopLabel['PLEASESELECTADATEATLEAST'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return false;
    }
    var special=ld("#specialworkingday  span ").text();
    var holiday=ld("#holiday_valcation  span").text();
    var spec_year=ld('#specialworkingday .mar_lr5').html();
    var hol_year=ld('#holiday_valcation .mar_lr5').html();
    var url = 'module=Settings&action=SaveWorkingday&workcalender_id='+id+'&workingdaytype='+workingdaytype;
    url+= '&selected_date='+selected_date+'&remark='+remark+'&operatetype='+operatetype;
    url+='&special='+special+'&holiday='+holiday;
    //alert(url);
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
			   	results=response.responseText.split('##&&');
                fninvshnew('addWorkingday');
                showPopDiv('EditWorkingSpace');//显示编辑工作日历弹出层
                //ld('#attr_selectdate').val(results[1]);
                var selected_date=results[1];
                EditWorkingSpace(id,operatetype,spec_year,hol_year,'switch',selected_date);

           }
        }
     );
 }*/
/**
 *@edit:cyb
 *@date:2016-03-03
 *@reason:删除特殊工作日
*
function DeleteWorkingday(date,falsh_portion)
{
    if(!confirm(arrJsPopLabel['SUREWANTDELETE']))
    {
      return false;
    }
    if(falsh_portion=='special')//特殊工作日
    {
       ld('#specialworkingdays_'+date).remove();
    }
    else{  //节假日
       ld('#holiday_valcation_'+date).remove();
    }
}*/
/**
 *@edit:cyb
 *@date:2016-03-03
 *@reason:删除工作日历
*
function DeleteWorkingcalender(id,start){
    if(!confirm(arrJsPopLabel['SUREWANTDELETE']))
    {
      return false;
    }
    ld('#workcalender_'+id).remove();
    ld('#listworkcalender .listEntries tr').each(function(index,el){//刷新工作日历列表
        if(index!=0)
        {
            ld(el).find('td').eq(0).html(index);
        }
     }
    )
    if(ld('#listworkcalender .listEntries tr').length==1){
        start=start-1;
    }
    var url='module=Settings&action=DeleteWorkingcalender&workcalender_id='+id;
    new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
				  ShowWorkingSpace(start); //显示工作日历列表
                  changeSelectWorkingCalender();//动态改变新增或者编辑轨迹定位组弹出层工作日历下拉框取值 ；
              }
          }
     );
}*/
/**
*@edit:cyb
*@date:2016-03-03
*@reason:删除员工轨迹定位组
*/
function DeleteTrackPostion(obj,id)
{
    var trobj=Tools.getParentobjByChild(ld(obj),'tr');

    var url='index.php?module=Settings&action=SettingsAjax&file=DeleteTrackPostion&trackpostion_id='+id;
    ldAjaxNoProgress(url,{},function(ajaxdata){
         if(ajaxdata.code==1)
         {
             ld(trobj).remove();
         }
    })
}
//duan 20240618删除定位组时给出提示
function DeleteTrackPostionBefore(obj,id) {
    var confirm_str = arrJsPopLabel['DELETIONNOPOSITIONING'];
    MessagePopup.TipTwo_warning(confirm_str);
    var popupobj = CrmPopup.getPopupObj('last');
    ld('#'+popupobj.divid +'_btnok').bind('click',function () {
        DeleteTrackPostion(obj,id);
    });
}
/**
*@edit:cyb
*@date:2016-03-03
*@reason:分配员工轨迹定位组；
**/
function AllocateTrackGroup(obj,trackpostion_id,selected_userid)
{
	var scopepopupobj;
    var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_module=Users&popup_inputtype=checkbox&popup_selecttype=user&checkprivilege=no';
    getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var methodObj = {'popup_check_inactiveuser':'no'};
		scopepopupobj =  new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = arrJsPopLabel['DISTRIBUT'];//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
		   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
           cls_ScopePopup.prop.popup_module = "Settings";//模块
		   cls_ScopePopup.prop.popup_value = selected_userid;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                    //没有选择任何用户，则给出提示
                    if(empty(cls_ScopePopup.return_obj.return_id)){
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                        return false;
                    }else{
                        var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                        var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=AllocateTrackGroup&selecteduserid='+selected_user+'&trackpostion_id='+trackpostion_id;
						 ldAjax(urlstring,{},function(){
                             ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtncancel').click();
                             RefreshTrackGroup();
                             DelProgressObjs();
                         })
                    }
                });
            }
		});
	});
}
//刷新定位组列表
function RefreshTrackGroup(){
    ldAjax("index.php?module=Settings&file=listtracks&action=SettingsAjax",{},function(ajaxdata){

        ld("#SettingRightContent").html(ajaxdata.result.content);

        initRightContentHeight();//加载右侧内容中菜单和详细内容高度
    })
}

var trackpostion={id:0};
var setuserid = function(obj,userobj){
    if(obj!='cancel')//点击确定按钮时，获取到选中的用户，执行保存操作；
    {
        /* eidtor:gyq_14 date:20160718 */
     selecteduserid=obj.value;//获取分配时选择到的用户；
     var blockidsetting =document.getElementById('blockidsetting').value;
     var fieldidsetting =document.getElementById('fieldidsetting').value;
     var url='module=Settings&action=AllocateTrackGroup&selecteduserid='+selecteduserid+'&trackpostion_id='+trackpostion.id;
     new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
				window.location="index.php?module=Settings&action=listtracks&blockidsetting="+blockidsetting+"&fieldidsetting="+fieldidsetting;
                    }
          }
     );
   }
}
/**
*reason:0021564: 控制面板>轨迹定位组：新增轨迹定位组>工作日历管理>新增工作日历，返回至“新增轨迹定位组”弹出层，点击“工作日历”下拉框，没有该工作日历
*edit:cyb
*date:2016-07-20

function changeSelectWorkingCalender(){
     var trackpostion_id=document.getElementById('trackpostion_id').value;
     var url='module=Settings&action=SettingsAjax&file=changeSelectWorkingCalender&trackpostion_id='+trackpostion_id;
     ld('#rptContentLoading').show();
          new Ajax.Request
        (
    		'index.php',
    		{
    			queue: {
    				position: 'end',
    				scope: 'command'
    			},
    			method: 'post',
    			postBody:url,
    			onComplete: function(response)
                {
                     ld('#rptContentLoading').hide();
					 var results=response.responseText.split('&#&#&#');
                     ld("#workcalenderid").html(results[1]);
                     return false;
                }
            }
        )
}*/
//显示隐藏的弹出层
function showPopDiv(id){
    ld('#'+id+'').show();
    puyoungJS_DialogBox.block();//遮罩层
 }

//税率设定编辑
function editTaxConfig(taxid,type){
    if(type == 1){    //编辑
        ld('span[tag=showspan]').show();
        ld('div[tag=hiddendiv]').hide();
        ld('#span_tax_'+taxid).hide();
        ld('#div_tax_'+taxid).show();
        ld('#span_rate_'+taxid).hide();
        ld('#div_rate_'+taxid).show();
    }else{  //取消
        ld('span[tag=showspan]').show();
        ld('div[tag=hiddendiv]').hide();
        //取消时将input value值还原
        ld('#div_tax_'+taxid+' input').attr('value',ld('#span_tax_'+taxid).text());
        ld('#div_rate_'+taxid+' input').attr('value',parseFloat(ld('#span_rate_'+taxid).text()).toFixed(3));
    }
}

//税率设定保存
function saveTaxConfig(taxid,taxname){
    var tax = ld('#div_tax_'+taxid+' input').val();
    var taxrate = ld('#div_rate_'+taxid+' input').val();
    var url='module=Settings&action=SettingsAjax&file=TaxConfig&ajax=true&savetax=yes&taxid='+taxid+'&tax='+tax+'&taxname='+taxname+'&taxrate='+taxrate;
    new Ajax.Request
    (
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:url,
			onComplete: function(response)
            {
				 $("TaxConfigContents").update(response.responseText);
                 return false;
            }
        }
    )
}

//税率设定启用、停用切换
function toggleTaxConfig(taxname,checked_status){
    if(checked_status){
        var status = 0;
    }else{
        var status = 1;
    }
    var url='module=Settings&action=SettingsAjax&file=TaxConfig&ajax=true&changestatus=yes&taxname='+taxname+'&deleted='+status;
    new Ajax.Request
    (
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:url,
			onComplete: function(response)
            {
				 //$("TaxConfigContents").update(response.responseText);
                 return false;
            }
        }
    )
}

function CloseDivSendInformContent(idname,divold){



    divold = 'approvestep';

    var divold=document.getElementById(divold);
    divold.style.display="inline";
    //29270: 控制面板>审批流程管理：审批通知，点击审批通知的“设置提醒内容”弹出框的【取消】按钮，结果：没有显示审批步骤弹出层，而是显示了遮罩层
    //fninvshnew(idname);
    fninvshnew(divold);


}
function SaveSendInfoContent(obj)
{
    var textRecipient=ld("#CKcontent").val();
    if(textRecipient==''){
        //内容模板为空！
        var confirm_str = arrJsPopLabel['CONTENTTEMPLATEEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return false;
    }

	//系统参数审批步骤页


		ld('#div_approveRemindsContent').parent().next().find('textarea').val(textRecipient);

		ld("divSendInform_content_div").innerHTML='';
		ld('#div_approveRemindsContent').removeAttr("id");
            document.forms['frmsendInfoContent'].module.value='Settings';
	//	CloseDivSendInformContent('divSendInform_content','approvestep');

    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.CancelEvent();
     var divold=document.getElementById("approvestep");
    divold.style.display="inline";

}
SaveSendInfoContent.funname='SaveSendInfoContent';

// ls 2022-04-15 【1000118】页面设置，字段属性中增加【字段公式】页签
var objmainField = new Array();
var objmainFieldSql = new Array();
function PageSetup(){
    this.inputmode = 0;
    var that = this;
}
PageSetup.prototype={
    fieldid:0,
    columnname:'',
    fieldlabel:'',
    defaultvalue:'',
    presence:0,
    uitype:1,
    typeofdata:'V~O',
    sequence:1,
    tabid:22,
    tablename:'',
    width:10,
    allowedit:'yes',
    input_type:'',
    letter:'a',
    columnstring:'',
    formulastring:'',
    functiontype:'Avg',
}

PageSetup.changePageSetupMenu = function (menutype,blockid) {
    ld('#changemenu_'+blockid+' .ld-ui-tabs-nav li').removeClass('ld-ui-tabs-active');
    ld('#advanceDiv_'+blockid+',#basicDiv_'+blockid+',#SensitiveRules_'+blockid).hide();
    if(menutype == 1){
        ld('#changemenu_'+blockid+' .ld-ui-tabs-nav li:first').addClass('ld-ui-tabs-active');
        ld('#basicDiv_'+blockid).show();
    }else if(menutype==2){
        ld('#changemenu_'+blockid+' .ld-ui-tabs-nav li[tag=2]').addClass('ld-ui-tabs-active');
        ld('#advanceDiv_'+blockid).show();
    }else if(menutype==3){
        ld('#changemenu_'+blockid+' .ld-ui-tabs-nav li[tag=3]').addClass('ld-ui-tabs-active');
        ld('#SensitiveRules_'+blockid).show();
    }
};
//选择录入方式 0手动录入 1函数功能 2通过公式计算 3通过SQL查询
PageSetup.selectInputMode = function (obj,blockid) {
    if (empty(obj)) {
        // var inputmode = ld('#inputModeType_'+blockid +' option:first').val();
        var inputmode = ld('#inputModeType_'+blockid +' option:selected').val();
    }else{
        var inputmode = obj.value;
    }
    // document.getElementById('definingContentDiv_'+blockid).style.display='none';
    ld('#attributeDiv_'+blockid).css('display','none');
    ld('#functionDiv_'+blockid).css('display','none');
    ld('#definingDiv_'+blockid).css('display','none');
    ld('#definingContentDiv_'+blockid).css('display','none');
    ld('#mulaDiv_'+blockid).css('display','none');
    ld('#mulaContentDiv_'+blockid).css('display','none');
    ld('#sqlDiv_'+blockid).css('display','none');
    ld('#sqlContentDiv_'+blockid).css('display','none');
    PageSetup.clearFormulaTable(blockid);//删除字段公式行
    PageSetup.inputmode=inputmode;

    if(inputmode == 1){	//函数功能
        PageSetup.selectFunction('',blockid);//选择函数功能时初始化下拉框字段(不知道当时为什么先隐藏掉，隐藏掉的话，编辑字段时参数字段就无法初始化了)
        ld('#functionDiv_'+blockid).css('display','');
        ld('#attributeDiv_'+blockid).css('display','');
    }else if (inputmode == 2) {	//通过公式计算
        ld('#definingDiv_' + blockid).css('display', '');
        ld('#mulaDiv_' + blockid).css('display', '');
        ld('#mulaContentDiv_' + blockid).css('display', '');
        PageSetup.addFormulaTableTr(2, blockid);
    } else if (inputmode == 3){ //通过SQL查询
        ld('#definingDiv_' + blockid).css('display', '');
        ld('#sqlDiv_' + blockid).css('display', '');
        ld('#sqlContentDiv_' + blockid).css('display', '');
        PageSetup.addFormulaTableTr(2, blockid);
    }
};
PageSetup.clearFormulaTable = function (blockid)
{
    /*var tableobj=document.getElementById('toolfieldFormula_'+blockid);
    var i=1;
    while(true)
    {  if(i>tableobj.rows.length-1)
    {
        break;
    }
        tableobj.deleteRow(0);
        i++;
    }*/

    // if (ld('#toolfieldFormula_'+blockid + ' tr:not(:last-child)')) {
        ld('#toolfieldFormula_'+blockid + ' tr:not(:last-child)').remove();//除了最后一个tr(新变量)，都可以删掉
    // }

}
/*
eidt:can
reasoN:增加字段公司下拉框
rowcount:增加的行数
*/
PageSetup.addFormulaTableTr = function (rowcount,blockid)
{

    var tableobj=document.getElementById('toolfieldFormula_'+blockid);
    var rowobj;
    var cellobj;
    if(tableobj.rows.length>26)
    {
        alert('最多只能新增26个变量！');
        return false;
    }
    for(var i=0;i<rowcount;i++)
    {
        var totalrow=tableobj.rows.length-1;
        var rowobj=tableobj.insertRow(totalrow);
        rowobj.id='formual_row_'+blockid+'_'+totalrow;
        rowobj.setAttribute('deleted',0);
        cellobj=rowobj.insertCell(0);
        cellobj.innerHTML=PageSetup.addFormulaCombox('formualcombox_'+blockid+'_'+totalrow,blockid);
        cellobj.style.width = '40%';
        cellobj=rowobj.insertCell(1);
        cellobj.innerHTML="<input class='ld-input-inner gwidth90' type='text' name='formualtext_"+blockid+"_"+totalrow+"' id='formualtext_"+blockid+"_"+totalrow+"' value='"+letters[totalrow]+"'>";
        cellobj.style.width = '50%';
        cellobj=rowobj.insertCell(2);
        cellobj.innerHTML='<a href="javascript:;" id="formualdeleteimg_'+blockid+'_'+totalrow+'" title="'+arrJsPopLabel["DELETE"]+'" onclick="PageSetup.deleteFormulaRow(\''+totalrow+'\','+blockid+')">'+arrJsPopLabel['DELETE']+'</a>';
        cellobj.style.width = '10%';
    }
    document.getElementById('definingContentDiv_'+blockid).style.display='';
}

PageSetup.addFormulaCombox = function (name,blockid)
{
    if (typeof PageSetup.inputmode == "undefined") {
        PageSetup.inputmode =  ld('#inputModeType_' + blockid).val();
    }
    var combox="<select id='"+name+"' name='"+name+"' class='ld-select-inner gwidth90'>";
    if (PageSetup.inputmode == 2) {
        for(var i=0;i<objmainField.length;i++)
        {
            combox+=" <option value='"+objmainField[i].columnname+"'>"+objmainField[i].fieldlabel+"</option> ";
        }
    }else if(PageSetup.inputmode == 3){
        for(var i=0;i<objmainFieldSql.length;i++)
        {
            combox+=" <option value='"+objmainFieldSql[i].columnname+"'>"+objmainFieldSql[i].fieldlabel+"</option> ";
        }
    }
    combox+='</select>';

    return combox;
}
PageSetup.deleteFormulaRow = function (rowIndex,blockid)
{
    var tableobj=document.getElementById('toolfieldFormula_'+blockid);
    tableobj.deleteRow(rowIndex);
    var totalrow=tableobj.rows.length-1;

    if(rowIndex>=totalrow)
    {
        return ;
    }
    var rowobj;
    var idIndex=0;
    var objlettertext;
    var objdeleteimg;
    var formulafieldsCombox;
    for(var i=rowIndex;i<totalrow;i++)
    {
        idIndex=parseInt(i,10)+1;
        rowobj=document.getElementById('formual_row_'+blockid+'_'+idIndex);
        rowobj.setAttribute('id','formual_row_'+blockid+'_'+i);
        formulafieldsCombox=document.getElementById('formualcombox_'+blockid+'_'+idIndex);
        formulafieldsCombox.setAttribute('id','formualcombox_'+blockid+'_'+i);
        formulafieldsCombox.setAttribute('name','formualcombox_'+blockid+'_'+i);
        objlettertext=document.getElementById('formualtext_'+blockid+"_"+idIndex);
        objlettertext.setAttribute('id','formualtext_'+blockid+"_"+i);
        objlettertext.setAttribute('name','formualtext_'+blockid+"_"+i);
        objlettertext.value=letters[i];
        rowobj.cells[2].innerHTML='<a  href="javascript:;" id="formualdeleteimg_'+totalrow+'" title="'+arrJsPopLabel["DELETE"]+'" onclick="PageSetup.deleteFormulaRow(\''+i+'\','+blockid+')">'+arrJsPopLabel["DELETE"]+'</a>';


    }
}
//选择函数功能
PageSetup.selectFunction = function (obj,blockid) {
    if (empty(obj)) {
        var functiontype = ld('#functionType_'+blockid +' option:selected').val();
        if (empty(functiontype)) {//该if不写应该也可以
            var functiontype = ld('#functionType_'+blockid +' option:first').val();
            ld('#functionType_'+blockid +' option:first').prop('selected','selected');
        }
    }else{
        var functiontype = obj.value;
    }

    if (empty(functiontype)) return;//非分录模块没有选择函数功能

    ld('#attributeField_'+blockid +' option').css('display','none');

    if(ld.inArray(functiontype.toLowerCase(),['avg','sum']) >=0){  //数字金额类型
        // console.log(ld('#attributeField_'+blockid +' option[functype=numamount]'));
        ld('#attributeField_'+blockid +' option[functype=numamount]').css('display','');
        ld('#attributeField_'+blockid +' option[functype=numamount]').first().prop('selected','selected');//默认选中第一个
    }else if(ld.inArray(functiontype.toLowerCase(),['max','min']) >=0){  //数字金额日期类型
        ld('#attributeField_'+blockid +' option[functype=numamount]').css('display','');
        ld('#attributeField_'+blockid +' option[functype=date]').css('display','');
        ld('#attributeField_'+blockid +' option[functype=numamount]').first().prop('selected','selected');//默认选中第一个
    }else{//其他类型，显示全部字段
        ld('#attributeField_'+blockid +' option').css('display','');
        ld('#attributeField_'+blockid +' option:first').prop('selected','selected');//默认选中第一个
    }
};

//选择函数的参数字段
PageSetup.selectFunctionField= function (obj,blockid) {
    var functionfield = ld('#attributeField_'+blockid +' option:selected').attr("functype");
    ld('#functionType_'+blockid +' option').css('display','none');

    if(functionfield.toLowerCase() == 'date'){//选择的参数字段为日期类型时，只显示最大值最小值。
        ld('#functionType_'+blockid +' option[value=Max]').css('display','');
        ld('#functionType_'+blockid +' option[value=Min]').css('display','');
        // ld('#functionType_'+blockid +' option[value=Max]').prop('selected','selected');
    }else{//其他类型，显示全部字段
        ld('#functionType_'+blockid +' option').css('display','');
    }
};

//获取字段公式下拉框（点击新增字段或者编辑字段时更新值）
PageSetup.getFormualFields = function () {
    var fld_module = CrmPopup.getPopupObj("lastprev").frommodule;
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=getFormualFields&fld_module='+fld_module+'&parenttab=Settings&ajax=true';
    ldAjax(surl, "", function (data) {
        if (data.code == 1) {
            objmainField = [];//多次新增或编辑时，下拉框选项需重新赋值。
            var formulafields = data.result.formula;
            for(var i=0 ;i<formulafields.length;i++)
            {
                var toolfield=new PageSetup();

                toolfield.columnname=formulafields[i].columnname;
                toolfield.fieldlabel=formulafields[i].fieldlabel;
                objmainField.push(toolfield);
            }
        }
        DelProgressObjs();
    })
};
//获取通过Sql查询的字段下拉框（点击新增字段或者编辑字段时更新值）
PageSetup.getFormualFieldsSql = function () {
    var fld_module = CrmPopup.getPopupObj("lastprev").frommodule;
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=getFormualFieldsSql&fld_module='+fld_module+'&parenttab=Settings&ajax=true';
    ldAjax(surl, "", function (data) {
        if (data.code == 1) {
            objmainFieldSql = [];//多次新增或编辑时，下拉框选项需重新赋值。
            var formulafields = data.result.formula;
            for(var i=0 ;i<formulafields.length;i++)
            {
                var toolfield=new PageSetup();

                toolfield.columnname=formulafields[i].columnname;
                toolfield.fieldlabel=formulafields[i].fieldlabel;
                objmainFieldSql.push(toolfield);
            }
        }
        DelProgressObjs();
    })
};

//页面设置：编辑属性
var fun_editField = function(fieldid,uitype,frommodule){
	if(!empty(fieldid) && !empty(uitype)){
	  var crmPopupobj=CrmPopup.load("","","","LdPopWidth650px",'Settings',"","","","");
	  crmPopupobj.prevshow();
		//alert('index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList_EditField&fieldid='+fieldid+'&uitype='+uitype+'&frommodule='+frommodule);
		ld.ajax({
        url:'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList_EditField&fieldid='+fieldid+'&uitype='+uitype+'&frommodule='+frommodule,
        type: 'POST',
		data:'',
		dataType:'json',
		async: true,
		timeout: 90000,
		success:function(data){
            crmPopupobj.setParams(data.result.title,"","","LdPopWidth400px",frommodule,"","","","");
            //重写创建弹出层底部事件
            crmPopupobj.createBottomHtml=function(){
                var ok_class = '';
                this.popupbottomhtml='<div class="E_pbtn" id="'+this.divid+'_popupbottom"> ';
                var funname=this.Okfun.funname;
                if(funname==undefined){
                    funname=this.Okfun.name;
                }
                // this.popupbottomhtml+=this.createTextBeforeSave();
                this.popupbottomhtml+=` <input type="button" name="save" class="E_pbtnok ld-button ld-button-primary" value="`+arrJsPopLabel['SAVE']+`" onclick="saveFieldInfo('`+fieldid+`','`+frommodule+`','updateFieldProperties','`+data.result.typeofdata+`','`+uitype+`');"/>`;
                if(data.result.allowdelete == 'yes'){
                    this.popupbottomhtml+=`<input type="button" name="delete" value="`+arrJsPopLabel['DELETE']+`" class="E_pbtncancel ld-button ld-button-cancel" onclick="deleteCustomField('`+fieldid+`','`+frommodule+`','`+data.result.columnname+`','`+uitype+`')" />`
                }
                this.popupbottomhtml+=`<input type="button" name="cancel" class="E_pbtncancel ld-button ld-button-cancel" value="`+arrJsPopLabel['CANCEL']+`" onclick="CrmPopup.getPopupObj('last').CancelEvent()"/>`

                this.popupbottomhtml+=' </div>';
                this.btnokid=this.divid+"_btnok";
                this.btncancelid=this.divid+"_btncancel";
            };
            CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,data.result.content);
            crmPopupobj.htmlselectid='defaultvalue_'+fieldid+"_name";
            crmPopupobj.bigtype=data.result.bigtype;
            crmPopupobj.fieldid=fieldid;
            crmPopupobj.fieldname='defaultvalue_'+fieldid;
            crmPopupobj.uitype=uitype;
            if(uitype==33)
            {

                ld("#defaultvalue_"+fieldid+"_name").select2({closeOnSelect: false});
                 //设置select2的zIndex
                 ld("#defaultvalue_"+fieldid+"_name").select2({closeOnSelect: true, dropdownParent: ld("#"+crmPopupobj.divid)});

            }
            else if(uitype==23 ||uitype==5 ||uitype==86)	//chj 2021/5/18 45761: （61mis.com/kfbcrm）系统设置-页面设置-客户；“日期时间”“下次回访日期”字段，编辑该字段设置默认值时，请参考“最晚服务到期日”修改样式
            {
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml("defaultvalue_"+fieldid+"_name");
                cls_resetComboxHtmlobj.setComboxObjHtml();
            }
            else if (uitype == 1109 || uitype == 1108 || uitype == 28){
                var uploadFileobj = new WebUploadFile();
                var WaterMarkWebUploadType=uploadFileobj.uploadType();
                if (WaterMarkWebUploadType == 'cos'){
                    ld('#'+crmPopupobj.divid+' [name=tr_excel_watermark_'+fieldid+']').css('display','none');
                    ld('#'+crmPopupobj.divid+' [name=tr_word_watermark_'+fieldid+']').css('display','none');
                }
            }
            //选择源单字段，上下移改为拖动排序
            if(crmPopupobj.bigtype == 'selectsource'){
                editSourceDragMove(frommodule);
            }
            // 设置最大宽度,防止超出弹窗宽度
            // ld('#definitionsqlformula_'+fieldid).css("max-width", "500px");

            //edit: xll 2024/07/09 XUQIU20240628-14 附件字段增加下载预览权限的条件控制
            var keyArr = ['DownloadAllowed','PreviewAllowed'];
            ld.each(keyArr,function (i,v) {
                if(typeof data.result[v] !== "undefined")
                    crmPopupobj[v] = data.result[v];
            })

            var popupJqObj = ld(`#${crmPopupobj.divid}`);
            // edit: xll 2024/09/26 XUQIU20240813-12 日期、日期时间、时间字段格式化
            var timeFormatInfo = data.result.timeFormatInfo;
            if(timeFormatInfo) {
                var valueFormatRow = popupJqObj.find(`#tr_value_format_${fieldid}`),
                    valueFormatSel = valueFormatRow.find(`#value_format_${fieldid}`),
                    tipObj = valueFormatRow.find(`#value_format_${fieldid}_tip`),
                    valueFormat = timeFormatInfo.selected,
                    optionArr = timeFormatInfo.options,
                    tip = timeFormatInfo.tips;
                if(optionArr) {
                    tipObj.attr('data-tip', getVarJsPop('TimeFieldHeplTip1',[tip])+' <br> '+ getVarJsPop('TimeFieldHeplTip2',[tip]));
                    tooltip(tipObj, {transition: true, time: 200});
                    var option = '',
                        exampleObj = valueFormatRow.find(`#value_format_${fieldid}_example`),
                        selIndex = 0;
                    ld.each(optionArr, function (index, info) {
                        option += `<option value="${info.value}">${info.label}</option>`;
                        (info.value === valueFormat) && (selIndex = index)
                    })
                    valueFormatSel.html(option);
                    valueFormatSel.prop('selectedIndex', selIndex);
                    exampleObj.find('span').html(optionArr[selIndex].example);
                    valueFormatSel.unbind('change').bind('change', function () {
                        var selIndex = ld(this).prop('selectedIndex'),
                            example = optionArr[selIndex].example;
                        exampleObj.find('span').html(example);
                    })
                    var cls_resetComboxHtmlobj = new cls_resetComboxHtml(`value_format_${fieldid}`);
                    cls_resetComboxHtmlobj.setComboxObjHtml();

                    var col = 'valueFormat',
                        dataBindObj = new DataHtmlBind();
                    crmPopupobj[col] = valueFormat;
                    dataBindObj.setDataBindByJqObj(valueFormatSel, crmPopupobj, col);
                }
            }

            PageSetup.getFormualFields();//获取字段公式下拉框
            PageSetup.getFormualFieldsSql();//获取通过Sql查询的字段下拉框

		}
	});
 }
	//fnvshobj(this,'editfield_{$value.fieldselect}');isuitypedisp({$value.fieldselect},{$value.uitype});
}
//页面设置：新增区块
var fun_createblock = function(frommodule){
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",frommodule,"",'none',"","");
    crmPopupobj.prevshow();
    ldAjax('index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList_CreateBlock&frommodule='+frommodule,'',function (data) {
        if(data.code == 1){
            crmPopupobj.setParams(data.result.title,getCreateCustomBlockForm,"","LdPopWidth600px",frommodule,"",data.result.oktext,"",data.result.canceltext);
            crmPopupobj.module=frommodule;
            crmPopupobj.mode='add';
            crmPopupobj.show(data.result.content);
            crmPopupobj.center();
        }
    })
}

//wyt 221212 XUQIU1000876 单据详情界面显示优化第三版（增加关键信息区块设置，需要可拖动调整）
//页面设置->关键信息栏->设置显示字段
var set_dispaly_fields = function(obj,module,BLOCKIDSETTING,FIELDIDSETTING){

    // console.log(module);
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth720px",module,"",'none',"","");
    crmPopupobj.prevshow();
    ld.ajax({
        url: 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=SetDisplayFields&parenttab=Settings&modulename='+module+'&ajax=true&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 5000,
        success: function(data)
        {
            if(data.code==1)
            {
                if($("status") != undefined)
                    $("status").style.display="none";
                //edit:can 2021-03-15 044977: （https://61mis.com/kfbcrm [^]）进入页面设置后再进入单据查看详情界面，点击【相关信息设置】->【保存】，弹出层没有关闭
                crmPopupobj.setParams(data.result.title,saveSetDisplayFieldsPage,"","LdPopWidth720px",module,"",data.result.oktext,"",data.result.canceltext);
                crmPopupobj.quickcreatehtml=data.result.content;
                crmPopupobj.show(data.result.content);
                ld("#"+crmPopupobj.divid).addClass("popMarginPadding");
                var tableobj = ld('#'+crmPopupobj.divid).find(" table.relatedListsTable");
                var LeftObj = tableobj.find(" .commonMultipleSelect:first");
                var RightObj = tableobj.find(" .commonMultipleSelect:last");
                var Drag_Transfer = new DragTransfer();
                Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','280');
                crmPopupobj.center();
            }
        }
    });
}

//页面设置->是否启用关键信息栏
var view_display_fields = function(module){

    var url='index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=ViewDisplayFields&parenttab=Settings&modulename='+module+'&ajax=true';
        ldAjax(url,"",function(data){
        if(data.code == 1){
            DelProgressObjs();
        }
    })
}


// @edit:liushuai,2020-08-24,reason:ID1000927/页面设置，关联选择单据（单选）字段类型的字段编辑属性中增加“其他条件”文字按钮
//页面设置-》新增字段-》关联选择单据-》审批要求（其他条件）
var fun_other_conditions = function(jqueryobj,blockid){
    // var frommodule=ld("input[name=fld_module]").val();
	//wym 多选关联字段 新增字段/编辑字段页面 获取多选对应的input元素
    var popupobj=CrmPopup.getPopupObj('last');
    var seltype= CrmPopup.findHtmlobj(popupobj.divid,"selectfieldtype").val();
    var fldtype= popupobj.bigtype;
    if(seltype==31||fldtype=='multireference'){
        if(ld("#multireferencemodule_"+blockid).length>0){
            var referencemodule=ld("#multireferencemodule_"+blockid).val();
        }else if(ld("#advance_multireferencemodule_"+blockid).length>0){
            var referencemodule=ld("#advance_multireferencemodule_"+blockid).val();
        }
    }else{
        //wym 231220 BUG0077541 页面设置-编辑页-字段如果没有默认值，就没有ld("#referencemodule_"+blockid)，所以编辑页添加了ld("#advance_referencemodule_"+blockid)来取关联模块
        if(ld("#referencemodule_"+blockid).length>0){
            var referencemodule=ld("#referencemodule_"+blockid).val();
        }else if(ld("#advance_referencemodule_"+blockid).length>0){
            var referencemodule=ld("#advance_referencemodule_"+blockid).val();
        }
    }
    
    var triggercolumnname='';
    var tmprange=ld(jqueryobj).attr('tmprange');
 
    //新增时  更改关联选择对象 时，要清除 其他条件 的值, 一旦选择栏更改 其他条件值就置空， 编辑无需判断  属于未定义
    var advance_demand_referencemodule = ld("#advance_demand_referencemodule_"+blockid).val();
    if(advance_demand_referencemodule != undefined && advance_demand_referencemodule != 'undefined' && (tmprange=='undefined' || tmprange==undefined)){ //新增界面才有定义
        if(advance_demand_referencemodule == ''){//第一次选择初始化
            ld("#advance_demand_referencemodule_"+blockid).val(referencemodule);
        }else if (advance_demand_referencemodule != referencemodule){ //重新选择
            ld("#advance_demand_"+blockid).val('');
            ld("#advance_demand_groups_"+blockid).val('');
            ld("#advance_demand_referencemodule_"+blockid).val(referencemodule);
        }
    }
    if(empty(ld("#advance_demand_"+blockid).val())){
        var advancedemand = {"groupid":1, "columnname":"",'comparator':'',"value":'',"basicsearchid":0,'columncondition':''};
        var  groupcondition={"groupcondition":""};
    }else{
        var advancedemand = trim(ld("#advance_demand_"+blockid).val());
        var groupcondition=trim(ld("#advance_demand_groups_"+blockid).val());
    }

    //wyt 221021 XUQIU1000764 负责人、单选用户、多选用户、团队成员字段，“设置可选择的成员范围”增加“其他条件”参数控制
    var memberrangetype = ld("#memberrangetype_"+blockid).val();//下拉框的值
    var memberrange_type= ld("#memberrange_type"+blockid).val();//隐藏域
    if(memberrange_type != undefined && memberrange_type!='undefined' && tmprange=='memberrange'){
        if(memberrange_type==''){
            ld("#memberrange_type"+blockid).val(memberrangetype);
        }else if (memberrange_type != memberrangetype){
            ld("#memberrange_type"+blockid).val('');
            ld("#memberrange_other_condition"+blockid).val('');
            ld("#memberrange_other_condition_groups"+blockid).val(memberrangetype);
        }
    }
    if(tmprange=='memberrange'){
        if(empty(ld("#memberrange_other_condition"+blockid).val())){
            var advancedemand ={"groupid":1, "columnname":"",'comparator':'',"value":'',"basicsearchid":0,'columncondition':''};
            var groupcondition={"groupcondition":""};
        }else{
            var advancedemand=trim(ld("#memberrange_other_condition"+blockid).val());
            var groupcondition=trim(ld("#memberrange_other_condition_groups"+blockid).val());
        }
    }
    var Popupobj=CrmPopup.load("","","","LdPopWidth800px",referencemodule,"","","","");
    Popupobj.prevshow();
    Popupobj.advanceSearchDivid=Popupobj.divid;
    // var advancesearchstr=JSON.stringify(advancesearch);

    //zkt 20231013 XUQIU1001341 SQL注入
    var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockRuleAdvancePop&frommodule=' + referencemodule + "&triggercolumnname=" + triggercolumnname + "&advancesearch=" + encodeURIComponent(advancedemand)+"&groupcondition="+groupcondition+"&tmprange="+tmprange;
    ldAjaxNoProgress(urlstring,'',function (data) {
        if (data.code == 1) {

            Popupobj.setParams(data.result.title, set_advancedemand, "", "LdPopWidth800px", referencemodule, blockid, data.result.oktext, "", data.result.canceltext);
            Popupobj.fields = data.result.fieldinfo;
            Popupobj.setInnerHtml = function () {
                //jquery执行脚本
                if (Popupobj.scrolldiv != "") {
                    ld("#" + Popupobj.divid).html(Popupobj.popupheadhtml + Popupobj.scrolldiv + Popupobj.htmlcontent + "</div>" + Popupobj.popupbottomhtml);
                } else
                    ld("#" + Popupobj.divid).html(Popupobj.popupheadhtml + Popupobj.htmlcontent + Popupobj.popupbottomhtml);
                document.getElementById(Popupobj.divid).style.display = "block";
            }
            CrmPopup.setPopupobjHtmlContent_scroll(Popupobj, data.result.content);

            var advancefilterobj = new cls_advanceFilter();
            var params = {};
            params.columnOptionHtml = data.result.FIELDNAMES;
            params.fLabels = data.result.fLabels;
            params.datetimestr = data.result.datetimestr;
            params.advfilterhtml = data.result.advfilterhtml;
            params.fieldsinfo = data.result.fieldinfo;
            params.criteria_groups_arr = data.result.criteria_groups_arr;
            params.module = referencemodule;
            // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
            params.advanceFields = data.result.advanceFields;
            advancefilterobj.showAdvanceFilter(Popupobj,params);
        }
    });
}
//设置其他条件的值
set_advancedemand=function(blockid)
{
    var popupobj=CrmPopup.getPopupObj('last');
    if(!popupobj.advanceFilterObj.checkAdvancedFilter()) return false;
    var advft_criteria = popupobj.advanceFilterObj.advft_criteria;//$('advft_criteria').value;
    var advft_criteria_groups = popupobj.advanceFilterObj.advft_criteria_groups;//$('advft_criteria_groups').value;
    // this.advancesearch=JSON.stringify(advft_criteria);
    ld("#advance_demand_"+blockid).val(advft_criteria);
    ld("#advance_demand_groups_"+blockid).val(advft_criteria_groups);
    //wyt  获取搜索的值
    ld("#memberrange_other_condition"+blockid).val(advft_criteria);
    ld("#memberrange_other_condition_groups"+blockid).val(advft_criteria_groups);
    popupobj.CancelEvent();

}
set_advancedemand.funname="set_advancedemand";

//edit: xll 2024/07/09 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
function SetConditions(keyId,module) {
    var popupObj = CrmPopup.getPopupObj('last');
    if(popupObj && typeof popupObj[keyId] === "undefined")
        popupObj[keyId] = {
            computemodule: module,
            advance_demand: "",
            advance_demand_groups: "",
        }
    var dataObj = popupObj[keyId];
    dataObj.includeDetail = 'no';
    getJsScript('include/js/modules/Home/SetOtherConditions.js', function () {
        var SetOtherConditionsObj = new SetOtherConditions();
        SetOtherConditionsObj.SetDirDataObj(dataObj);
        SetOtherConditionsObj.fun_other_conditions();
    });
}

//菜单定制
function CustomScope(){

}
CustomScope.setAllUser = function(){
	ld('#customscope_type').val('all');
	ld('#customscope_ids').val('');
}

//选用户
CustomScope.setScopeUser = function(ids){
  var module = 'Home';
	var popup_caption_value = arrJsPopLabel['SELECT']+arrJsPopLabel['LBL_USERS'];
  var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user&checkprivilege=no';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var methodObj = {'popup_check_inactiveuser':'yes'};
		scopepopupobj =  new ScopePopupObj(methodObj);
    scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
		  cls_ScopePopup.prop.popup_url = popup_url;//popup_url
      cls_ScopePopup.prop.popup_module = module;//模块
      //电信宽频客户的CRM账套，公海成员设置无法保存，保存，再打开还是空的。
		  cls_ScopePopup.prop.popup_value = document.getElementById("customscope_ids").value;
		  var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		  //重写确认按钮事件
            scopepopupobj.setEventBtnOk = function () {
                ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
                    //没有选择任何用户，则给出提示
                    if (empty(cls_ScopePopup.return_obj.return_id)) {
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        RemindsMsg("", "LdPopWidth400px", '', "yes", "yes", confirm_str);
                        return false;
                    } else {
                        var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                        console.log(selected_user);
                        ld('#customscope_type').val('user');
                        ld('#customscope_ids').val(selected_user);
                        //ls 20220818 BUG0055199 系统设置的移动端报表定制中，按成员设置之后，点击保存之后界面卡住
                        ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                    }
                });
            }
			scopepopupobj.setEventBtnCancel=function(){
				//关闭事件
				ld('#'+cls_ScopePopup.popup_divid+' .E_pop_tit .E_ptitc').unbind('click').on('click',function(){
					//alert(1123);
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                    var customscope_type = ld('#customscope_type').val();
                    ld('#view_scope').find('input[name="radioUser"]').each(function(i){
                        if(customscope_type==ld(this).val()){
                            ld(this).prop('checked',true);
                        }
                    });
                    ld('#layer').remove();
					return false;
				});
				//取消事件
				ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').unbind('click').on('click',function(){
					//alert(123123);
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').trigger('closediv');
                    var customscope_type = ld('#customscope_type').val();
                    ld('#view_scope').find('input[name="radioUser"]').each(function(i){
                        if(customscope_type==ld(this).val()){
                            ld(this).prop('checked',true);
                        }
                    });
                    ld('#layer').remove();
				});
				ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').unbind('closediv').on('closediv',function(){
					var customscope_type = ld('#customscope_type').val();
					ld('#view_scope').find('input[name="radioUser"]').each(function(i){
						if(customscope_type==ld(this).val()){
							ld(this).prop('checked',true);
						}
					});
                     ld('#layer').remove();
					// if(ld('#'+cls_ScopePopup.popup_divid).length > 0){
					// 	//删除div
					// 	var divobj = ld('#'+cls_ScopePopup.popup_divid).get(0);
					// 	divobj.parentNode.removeChild(divobj);
					// }
				});
				return true;
			}
		});
	});
}
//按角色
CustomScope.setScopeRole = function(ids){
	var module = 'Home';
	var popup_caption_value = arrJsPopLabel['SELECT']+arrJsPopLabel['LBL_ROLE_NAME'];//pleaseenterprofile
	var popup_url = 'module=Users&action=UsersAjax&file=viewprofileinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=profile';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var methodObj = {'popup_check_inactiveuser':'no'};
		scopepopupobj =  new ScopePopupObj(methodObj);
		scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		scopepopupobj.popup_searchvalue = arrJsPopLabel['pleaseenterprofile'];//查询框默认值
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			cls_ScopePopup.prop.popup_url = popup_url;//popup_url
			cls_ScopePopup.prop.popup_module = module;//模块
			scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+arrJsPopLabel['pleaseenterprofile']+'\'>'+'</div>';
			//电信宽频客户的CRM账套，公海成员设置无法保存，保存，再打开还是空的。
			cls_ScopePopup.prop.popup_value = document.getElementById("customscope_ids").value;
			var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
			//重写确认按钮事件
			scopepopupobj.setEventBtnOk=function(){
				ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
					//没有选择任何用户，则给出提示
					if(empty(cls_ScopePopup.return_obj.return_id)){
						var confirm_str = arrJsPopLabel['Pleaseselectatleaprofile'];
						RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
						return false;
					}else{
						var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
						ld('#customscope_type').val('role');
						ld('#customscope_ids').val(selected_user);
                        ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
					}
				});
			}
			scopepopupobj.setEventBtnCancel=function(){
				//关闭事件
				ld('#'+cls_ScopePopup.popup_divid+' .E_pop_tit .E_ptitc').unbind('click').on('click',function(){
					//alert(1123);
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                    var customscope_type = ld('#customscope_type').val();
                    ld('#view_scope').find('input[name="radioUser"]').each(function(i){
                        if(customscope_type==ld(this).val()){
                            ld(this).prop('checked',true);
                        }
                    });
                    ld('#layer').remove();
					return false;
				});
				//取消事件
				ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').unbind('click').on('click',function(){
					//alert(123123);
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').trigger('closediv');
                    var customscope_type = ld('#customscope_type').val();
                    ld('#view_scope').find('input[name="radioUser"]').each(function(i){
                        if(customscope_type==ld(this).val()){
                            ld(this).prop('checked',true);
                        }
                    });
                    ld('#layer').remove();
				});
				ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').unbind('closediv').on('closediv',function(){
					var customscope_type = ld('#customscope_type').val();
					ld('#view_scope').find('input[name="radioUser"]').each(function(i){
						if(customscope_type==ld(this).val()){
							ld(this).prop('checked',true);
						}
					});
                     ld('#layer').remove();
					// if(ld('#'+cls_ScopePopup.popup_divid).length > 0){
					// 	//删除div
					// 	var divobj = ld('#'+cls_ScopePopup.popup_divid).get(0);
					// 	divobj.parentNode.removeChild(divobj);
					// }
				});
				return true;
			}
		});
	});
}
//选部门
CustomScope.setScopeGroup = function(ids){
  var module = 'Home';
	var popup_caption_value = arrJsPopLabel['SELECT']+arrJsPopLabel['USERGROUPLIST'];
  var popup_url = 'module=Users&action=UsersAjax&file=viewgroupinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=group';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var methodObj = {'popup_check_inactiveuser':'yes'};
		scopepopupobj =  new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];//查询框默认值
        //zkt 0046535: （81mis.com/kfbcrm）系统设置-界面设置-网页端菜单定制-新增菜单，选择使用范围“按部门”，弹出层界面没有“子部门默认收起”的控制按钮
		scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP']+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox" ><label for="viewuser_unfoldsubgroup">'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
	    cls_ScopePopup.prop.popup_url = popup_url;//popup_url
        cls_ScopePopup.prop.popup_module = module;//模块
	    cls_ScopePopup.prop.popup_value = ids;
	    var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
	    //重写确认按钮事件
        scopepopupobj.setEventBtnOk=function(){
            ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
              if(empty(cls_ScopePopup.return_obj.return_id)){
                var confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
                RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                return false;
              }else{
                var selected_user = cls_ScopePopup.return_obj.return_id;//选中的部门
        		ld('#customscope_type').val('group');
        		ld('#customscope_ids').val(selected_user);
        		ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
              }
            });
        }
		  scopepopupobj.setEventBtnCancel=function(){
				//关闭事件
				ld('#'+cls_ScopePopup.popup_divid+' .E_pop_tit .E_ptitc').unbind('click').on('click',function(){
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
					return false;
				});

				//取消事件
				ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').unbind('click').on('click',function(){

					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').trigger('closediv');
				});
			  ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').unbind('closediv').on('closediv',function(){

				  var customscope_type = ld('#customscope_type').val();
				  ld('#view_scope').find('input[name="radioUser"]').each(function(i){
						if(customscope_type==ld(this).val()){
							ld(this).prop('checked',true);
						}
				  });
                  //edit:can 20210506 045610: （https://61mis.com/kfbcrm [^]）系统设置-网页端菜单定制-修改可见范围-点击按部门，任意选择一个之后点击确认或者是取消，页面都会灰屏无法点击
                   ld('#layer').remove();

				  // if(ld('#'+cls_ScopePopup.popup_divid).length > 0){
					// 	//删除div
					// 	var divobj = ld('#'+cls_ScopePopup.popup_divid).get(0);
					// 	divobj.parentNode.removeChild(divobj);
				  // }
			  });
			  return true;
		  }
		});
	});
}
//选择角色
function ApproveAllocateProfile(div_hidden_id,div_title){
	if(ld('#'+div_hidden_id) != undefined){
		var ids = ld('#'+div_hidden_id).val();
		var module = 'Users';
		var popup_caption_value = arrJsPopLabel['SELECT']+div_title;
		var popup_url = 'module=Users&action=UsersAjax&file=viewprofileinfo&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=profile';

    	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){

			var methodObj = {'popup_check_inactiveuser':'no'};
			scopepopupobj =  new ScopePopupObj(methodObj);
			scopepopupobj.popup_caption_value = popup_caption_value;//标题title
			scopepopupobj.popup_searchvalue = arrJsPopLabel['pleaseenterprofile'];//查询框默认值
			scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['pleaseenterprofile']+'\'></div>';
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
			   cls_ScopePopup.prop.popup_module = module;//模块
			   cls_ScopePopup.prop.popup_value = ids;
			   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
						//没有选择任何用户，则给出提示
						if(empty(cls_ScopePopup.return_obj.return_id)){
							var confirm_str = arrJsPopLabel['Pleaseselectatleaprofile'];
                              RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                              return false;
						}else{
							var selected_profile_id = cls_ScopePopup.return_obj.return_id;//选中的用户
							var selected_profile_name = cls_ScopePopup.return_obj.return_name;
							ld('#'+div_hidden_id).val(selected_profile_id);
	                        ld("#selectallocatetype").val(3);
							ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
						}
					});
				}
			});
		});
	}
}
//选择角色
function selectPopupProfile(div_hidden_id,div_title){
	if(ld('#'+div_hidden_id) != undefined){
		var ids = ld('#'+div_hidden_id).val();
		var module = 'Users';
		var popup_caption_value = arrJsPopLabel['SELECT']+div_title;
		var popup_url = 'module=Users&action=UsersAjax&file=viewprofileinfo&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=profile';
		getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
			var methodObj = {'popup_check_inactiveuser':'no'};
			scopepopupobj =  new ScopePopupObj(methodObj);
			scopepopupobj.popup_caption_value = popup_caption_value;//标题title
			scopepopupobj.popup_searchvalue = arrJsPopLabel['pleaseenterprofile'];//查询框默认值
			scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+arrJsPopLabel['pleaseenterprofile']+'\'></div>';
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
			   cls_ScopePopup.prop.popup_module = module;//模块
			   cls_ScopePopup.prop.popup_value = ids;
			   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
						//没有选择任何用户，则给出提示
						if(empty(cls_ScopePopup.return_obj.return_id)){
							var confirm_str = arrJsPopLabel['Pleaseselectatleaprofile'];
                              RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
                              return false;
						}else{
							var selected_profile_id = cls_ScopePopup.return_obj.return_id;//选中的用户
							var selected_profile_name = cls_ScopePopup.return_obj.return_name;
							ld('#user_role').val(selected_profile_id);
							ld('#role_name').val(selected_profile_name);
							ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
						}
					});
				}
			});
		});
	}
}
//editor:gyq_92 reason:系统设置登录日志查询增加分类功能  2018/12/20 17:19
function get_new_loginlog(r_url){
  //  var selectedvalue = ld(obj) .val();
    var obj_userlist = ld('#user_list');
    var obj_logintype = ld('#login_type');
    var userid = obj_userlist.val();
    var logintype = obj_logintype.val();
    if(userid=='none'){
        userid = '';
    }
    ldAjax("index.php?"+r_url,{module : 'Users' ,action:"UsersAjax",file:"ShowHistory",'ajax':'true','record':userid,'login_type':logintype},function (data) {
        if (data.code == 1){
            DelProgressObjs();
            ld("#div_loginhistory_select").html(data.result.content) ;
            ld("#div_loginhistory_select").show();
            //BUG0068281 txy 2023.06.18 kfbcrm 后台设置--登录日志查询--翻页没有浮显
            tooltip('.tip-items-list', {transition: true, time: 200});
        }
    });
}
//editor:gyq_94 reason:企业微信外部联系人批量导入  2018/12/25 11:39
function import_get_external_contact(){
    /*ld.post("index.php",{module : 'Settings' ,action:"SettingsAjax",file:"ExternalContact",'ajax':'true','second_action':'import_contact'},function(response) {

    });*/
    var blockset_obj = ld('input[name="blockidsetting"]');
    var blockid = blockset_obj.val();
    var fieldidsetting = ld('input[name="fieldidsetting"]').val();
    //0044189 系统设置->接口设置->企业微信客户联系设置：点击【导入联系人】，弹出提示信息“确定要导入企业微信客户吗？”
    RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['isSureImportWxUsers']);
    var  popupobj=CrmPopup.getPopupObj('last');
    CrmPopup.center(ld("#"+popupobj.divid),popupobj);
    ld('#'+popupobj.divid+' .E_pbtnok').click(function() {
        RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['IMPORTDATAREMIND1']);
        var surl = 'index.php?module=Settings&action=SettingsAjax&file=ExternalContact&parenttab=Settings&blockidsetting=' + blockid + '&fieldidsetting=' + fieldidsetting + '&second_action=import_contact';
        ldAjax(surl, "", function (data) {
            if (data.code == 1) {
                ld('input[tagclick="msgConfirm"]').click();
                fnvshNrm('dvUpdate');
                ld('#dvc').hide();
                ld('#total_num').html(data.result.html);
                document.getElementById("dv").innerHTML = data.result.progress_i + '/' + data.result.progress_total;
                document.getElementById("dvprogress").style.width = data.result.progress_width + 'px';
                DelProgressObjs();
            } else if (data.code == 2){
                ld('input[tagclick="msgConfirm"]').click();
                var param = {};
                external_contact_list_progress(popupobj.module,0,param,"");
            } else {
                ld('input[tagclick="msgConfirm"]').click();
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['IMPORTDATAREMIND2']);
                DelProgressObjs();
                return false;
            }
        })
    });
}
//批量获取外部联系人时生成进度条
function external_contact_list_progress(module,startrow,param,param_wechatsession){
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=ExternalContact&parenttab=Settings&second_action=import_contact&progress=yes';
    if(param_wechatsession!=""){
        surl += '&wechatsession=yes';
    }
    ldAjax(surl,param,function (data){//批量提交保存
            if(data.code == 1){
                ld('#rptContentLoading').hide();//隐藏加载图标
                var result = data.result;//简化使用
            	var intervalrow = parseInt(result.intervalrow_last);
                var maxrows=parseInt(result.maxrows);
                var endrow = parseInt(startrow)+intervalrow;
            	if (endrow > maxrows){  //最后一个请求
            		endrow = maxrows;
            	}
                var tmppopupobjobj;
                if(CrmPopup.getPopupObj('last')!=undefined&&CrmPopup.getPopupObj('last').type == 'ProgressPopup'){//新建或修改进度条弹出层
                    tmppopupobjobj=CrmPopup.getPopupObj('last');
                }else{
                    tmppopupobjobj=ProgressPopup.load(result.title,"","",500,module,"","","","");
                    var htmlcontent="<div class='import_process' style='margin-left:30px;'><div class='progressbar batchProgress'></div>";
                    htmlcontent+="<div class='import_info'>当前操作成员为:<span class='num username'></span>(<span class='num curuser'></span>/"+result.all_usernum+"),共选择了<span class='num totalnum'></span>条记录，</span> 正在操作第<span class='num curnum'></span>条记录，请稍后……</div></div>";
            		tmppopupobjobj.showhtml(htmlcontent);
                }
                //修改当前操作用户和顺序
                tmppopupobjobj.setusername(result.username);
                tmppopupobjobj.setcuruser(result.cur_user);
                //更新进度条显示
                if(maxrows==0){//没有获取数据时显示最大进度条
                    tmppopupobjobj.setPercentWidth(100);
                	tmppopupobjobj.setTotalNum(0);
                	tmppopupobjobj.setCurNum(0);
                }else{
                    var percent=parseInt(startrow/maxrows*100);
                    tmppopupobjobj.setPercentWidth(percent);
                	tmppopupobjobj.setTotalNum(maxrows);
                	tmppopupobjobj.setCurNum(endrow);
                }
                //进度条完成或提前结束过程时，重置顺序
                if(endrow >= maxrows||result.end_progress=='yes'){
                    startrow = 0;
                }else{
            	   startrow = endrow;
            	}
                 param = {'wxuserid_last':result.wxuserid_last,//当前操作用户的企业微信id
                             'intervalrow':intervalrow, //每次查询的数量
                             'next_cursor':result.next_cursor, //api批量查询游标
                             'end_progress':result.end_progress, //是否结束当前用户的进度
                             'maxrows':maxrows,
                             //用于显示导入结果,导入数据的条数,总记录的条数,新建或更新单据的数量
                             'progress_i':result.progress_i,
                             'progress_total':result.progress_total,
                             'progress_num':result.progress_num,
                             //小循环参数
                             'index_now':result.index_now
                             };
                //循环更新进度条弹出层
                external_contact_list_progress(module,startrow,param,param_wechatsession);
      		}else if(data.code == 2){
      		    //导入结束后显示导入结果
      		    var tmppopupobjobj=CrmPopup.getPopupObj('last');
      		    tmppopupobjobj.CancelEvent();
      		    DelProgressObjs();
                if(param_wechatsession != ""){//回到会话存档
                    getJsScript('include/js/modules/WechatSession/ChatSessionList.js',function (){
                        var arr = param_wechatsession;
                        var ChatSessionListobj = arr.obj;
                        ldAjax(arr.surl+"&import_external_contact="+arr.import_external_contact,"",function(data){
                            if (data.code == 1){ //继续下一个
                                //同步会话存档的外部联系人
                                ChatSessionListobj.start_sync_external_contact(arr.surl,arr.import_external_contact,arr.sync_external_contact,arr.sync_group_name);
                            }
                        })
                    });
                }else{
                    fnvshNrm('dvUpdate');
                    ld('#dvc').hide();
                    ld('#total_num').html(data.result.total_html);
                    ld('#dv').html(data.result.new_html);
                    ld('#dv').css('float','');
                    ld('#dv').css('margin','0 auto');
                    ld("#dvprogress").parent().hide();
                }
      		}else{
                ld('input[tagclick="msgConfirm"]').click();
                var tmppopupobjobj=CrmPopup.getPopupObj('last');
      		    tmppopupobjobj.CancelEvent();
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['IMPORTDATAREMIND2']);
                DelProgressObjs();
                return false;
            }
    });
}

function import_get_external_contact_okbutton(){
    var blockid = ld('input[name="blockidsetting"]').val();
    var fieldidsetting = ld('input[name="fieldidsetting"]').val();
    fninvshnew('dvUpdate');
    // window.location='index.php?module=Settings&action=ExternalContact&parenttab=Settings&blockidsetting='+blockid+'&fieldidsetting='+fieldidsetting;
}
function import_get_external_contact_remind() {
    RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['IMPORTDATAREMIND2']);
}
//新增审批流程
function addApprove(){
	var popupobj=CrmPopup.getPopupObj("last");
	var tabid = ld("#pick_module").val();
	var url = 'index.php?module=Settings&parenttab=Settings&action=SettingsAjax&file=EditMultiApprove&blockid='+tabid;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth1200px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjax(url,"",function(data){
		if(data.code==1)
		{
			//approvereminds:是一个非常重要变量，变量内容包括了审批提醒的显示内容
			//EditApproveStep.tpl文件中methodtaggroup非常重要，每一个html元素的命名都是以methodtaggroup开始
			ld('#rptContentLoading').hide();
			crmPopupobj.setParams(data.result.title,saveMenuValidate,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			//crmPopupobj.show(data.result.content);
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
            DelProgressObjs();
		}
	 })

}

//@edit:liushuai,2020-8-4,reason:ID1000738/网页端菜单定制优化：增加“菜单排序”功能(排序弹窗)
//网页端菜单定制 ：菜单排序
function sortMenuList(){
    var urlstring='index.php?module=Settings&action=SettingsAjax&file=MenuList&type=sortMenu&ajax=true';
    var popupobj=CrmPopup.load("","","","LdPopWidth300px",'Settings',"","","","");
    popupobj.prevshow();
    ld.ajax({
        url: urlstring,
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 10000,
        success: function(data)
        {
            if(data.code==1)
            {
                popupobj.setParams(data.result.title,saveSortMenu,"","300",'Settings',"",data.result.oktext,"",data.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content);
            }
        }
    })
}
saveSortMenu.funame='saveSortMenu';
function saveSortMenu(){
    var tabids = ld("#selectedColumns2 option").map(function(){return ld(this).val(); }).get().join(",");
    var SaveSortMenuUrl = 'index.php?module=Settings&action=SettingsAjax&file=MenuList&type=saveSortMenu&ajax=yes&tabids='+tabids;
    ld.ajax({
        url: SaveSortMenuUrl,
        type: 'POST',
        dataType:'json',
        success: function(data)
        {
            if(data.code==1)
            {
                CrmPopup.getPopupObj("last").CancelEvent(); //隐藏弹窗
                ld("div[name=menulistcontent]").html(data.result.content);
                window.location.reload();//刷新当前页
            }
        }
    })
}

function DeleteMenuList(parenttabid) { //XUQIU20240823-04 网页端菜单定制增加删除功能 wsh 20240826
    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['DELETEMENUTIP']);
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
        var surl = 'index.php?module=Settings&action=SettingsAjax&file=MenuList&type=delete&ajax=yes&parenttabid=' + parenttabid;
        ldAjaxNoProgress(surl, '', function (data) {
            if(data.code == 1){
                ld("div[name=menulistcontent]").html(data.result.content);
            }
        })
    });
}
//网页端菜单定制 ：编辑
function editMenuList(parenttabid){
	var surl='module=Settings&action=SettingsAjax&file=EditMenu&parenttabid='+parenttabid;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ld.ajax({
		url: 'index.php?'+surl,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
        success: function(data)
        {

            if(data.code==1)
            {
                //approvereminds:是一个非常重要变量，变量内容包括了审批提醒的显示内容
                //EditApproveStep.tpl文件中methodtaggroup非常重要，每一个html元素的命名都是以methodtaggroup开始
                crmPopupobj.setParams(data.result.title,saveMenuValidate,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
                //crmPopupobj.show(data.result.content);
                CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);

                // 设置内容最大高度
                crmPopupobj.setPopBodyMaxHeight(".dvpopupsroll");

                /*edit:weiyannan
                date:2023-11-14
                reason:XUQIU1002049 系统穿梭框界面样式统一 后台设置--网页端菜单定制 */
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
		}
	})
	//index.php?module=Settings&action=EditMenu&parenttab=Settings&parenttabid={$value.parenttabid}&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}
}
//网页端菜单定制 ：编辑--系统设置特殊
function editMenuList8(parenttabid){
    var surl='module=Settings&action=SettingsAjax&file=EditMenu8&parenttabid='+parenttabid;
    var popupobj=CrmPopup.getPopupObj("last");
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
    crmPopupobj.prevshow();
    ld.ajax({
        url: 'index.php?'+surl,
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 5000,
        success: function(data)
        {
            if(data.code==1)
            {
                crmPopupobj.setParams(data.result.title,saveMenuValidate8,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
            }
        }
    })
    //index.php?module=Settings&action=EditMenu&parenttab=Settings&parenttabid={$value.parenttabid}&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}
}
function saveMenuValidate8(){
    var popupobj=CrmPopup.getPopupObj("last");
    var form=document.forms['menu'];
    var parenttabid = form.parenttabid.value;
    var urlstring = 'module=Settings&action=SettingsAjax&file=SaveMenu8&parenttabid='+parenttabid;
    //zxm 2021-1206 上传菜单图标
    var formData = new FormData();
    if( ld("#"+popupobj.divid+" [name=inactive_icon]").get(0).files.length>0)
    {
        formData.append('inactive_icon', ld("#"+popupobj.divid+" [name=inactive_icon]").get(0).files[0]);
        formData.append('inactive_icon_name', ld("#"+popupobj.divid+" [name=inactive_icon_name]").val());
        formData.append("inactive_icon_size",ld("#"+popupobj.divid+" [name=inactive_icon]").get(0).files[0].size);
        formData.append("inactive_icon_type",ld("#"+popupobj.divid+" [name=inactive_icon]").get(0).files[0].type);
    }
    if( ld("#"+popupobj.divid+" [name=active_icon]").get(0).files.length>0)
    {
        formData.append('active_icon', ld("#"+popupobj.divid+" [name=active_icon]").get(0).files[0]);
        formData.append('active_icon_name', ld("#"+popupobj.divid+" [name=active_icon_name]").val());
        formData.append("active_icon_size",ld("#"+popupobj.divid+" [name=active_icon]").get(0).files[0].size);
        formData.append("active_icon_type",ld("#"+popupobj.divid+" [name=active_icon]").get(0).files[0].type);
    }
    ld.ajax({
        url:'index.php?'+urlstring,
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
        ld('#rptContentLoading').hide();
        if(data.code==-1){
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);return;
        }
        popupobj.CancelEvent();
        ld.ajax({
            url:"index.php?module=Settings&action=MenuList&parenttab=Settings&ReportHeader=dheader&ajax=yes",
            dataType:"json",
            timeout:20000,
            success:function(data){
                ld("div[name=menulistcontent]").html(data.result.content);
            }
        })
        DelProgressObjs();
    })
}
//网页端菜单定制 ：保存
function saveMenuValidate(){
	var popupobj=CrmPopup.getPopupObj("last");
	var form=document.forms['menu'];
    var parentname=form.parentchinese.value;
    var enparentname=form.parentenglish.value;
    var parentindex=form.parentindex.value;
	var parenttabid = form.parenttabid.value;
    //duan 2022-2-18 从两个单选（radio）改为一个（checkbox）
	var visible = ld("#"+popupobj.divid+" [name=visible]").prop('checked')?0:1;
	if(parentname.length<=0){
        var confirm_str = arrJsPopLabel['MENUNAMECANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }else if(enparentname.length<=0){
        var confirm_str = arrJsPopLabel['MENUNAMECANOTEMPTYEN'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    else if(parentname.indexOf("\\")>0){
        var confirm_str = arrJsPopLabel['MENUCHINESENAMENOTLEGAL'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    if(parentindex.length<=0){
        var confirm_str = arrJsPopLabel['ORDERCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }else if( isNaN(parentindex) || parentindex <= 0 ){
        var confirm_str = arrJsPopLabel['ORDERISPOSITIVEINTEGERS'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    ld('#rptContentLoading').show();
    var obj=form.selectedColumns;
    var selectedColStr='';
    if(obj.options.length>0){
        for(var i=0;i<obj.options.length;i++){
            selectedColStr += obj.options[i].value+";";
        }
    }
	var customscope_type = form.customscope_type.value;
	var customscope_ids = form.customscope_ids.value;

	var urlstring = 'module=Settings&action=SettingsAjax&file=SaveMenu&parenttabid='+parenttabid;
	urlstring += '&parentchinese='+encodeURIComponent(parentname)+'&parentenglish='+encodeURIComponent(enparentname)+'&parentindex='+parentindex+'&visible='+visible+'&selectedtabColumnsString='+selectedColStr;
	urlstring += '&customscope_type='+customscope_type+'&customscope_ids='+customscope_ids;
	//zxm 2021-1206 上传菜单图标
    var formData = new FormData();
    if( ld("#"+popupobj.divid+" [name=inactive_icon]").get(0).files.length>0)
    {
        formData.append('inactive_icon', ld("#"+popupobj.divid+" [name=inactive_icon]").get(0).files[0]);
        formData.append('inactive_icon_name', ld("#"+popupobj.divid+" [name=inactive_icon_name]").val());
        formData.append("inactive_icon_size",ld("#"+popupobj.divid+" [name=inactive_icon]").get(0).files[0].size);
        formData.append("inactive_icon_type",ld("#"+popupobj.divid+" [name=inactive_icon]").get(0).files[0].type);
    }
    if( ld("#"+popupobj.divid+" [name=active_icon]").get(0).files.length>0)
    {
        formData.append('active_icon', ld("#"+popupobj.divid+" [name=active_icon]").get(0).files[0]);
        formData.append('active_icon_name', ld("#"+popupobj.divid+" [name=active_icon_name]").val());
        formData.append("active_icon_size",ld("#"+popupobj.divid+" [name=active_icon]").get(0).files[0].size);
        formData.append("active_icon_type",ld("#"+popupobj.divid+" [name=active_icon]").get(0).files[0].type);
    }
    ld.ajax({
        url:'index.php?'+urlstring,
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
        ld('#rptContentLoading').hide();
        if(data.code==-1){
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);return;
        }
        popupobj.CancelEvent();
        ld.ajax({
            url:"index.php?module=Settings&action=MenuList&parenttab=Settings&ReportHeader=dheader&ajax=yes",
            dataType:"json",
            timeout:20000,
            success:function(data){
                ld("div[name=menulistcontent]").html(data.result.content);
                //hzx 20240528 保存菜单后刷新左侧菜单
                //LeftMenu_functionobj=LeftMenu_function.getInstance();
                //LeftMenu_functionobj.LeftMenu_flesh();//加载左边的菜单
            }
        })
        DelProgressObjs();
    })

    // ldAjax(urlstring,formData,function(rest){
	// 	var restlist = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
	// 	//alert(restlist.parentchinese);
	// 	popupobj.CancelEvent();
	// 	ld('#rptContentLoading').hide();
    //     ld.ajax({
    //         url:"index.php?module=Settings&action=MenuList&parenttab=Settings&ReportHeader=dheader&ajax=yes",
    //         dataType:"json",
    //         timeout:20000,
    //         success:function(data){
    //             ld("div[name=menulistcontent]").html(data.result.content);
    //         }
    //     })
	// 	//window.location.reload();
    //    DelProgressObjs();
	// })
    return true;
}
saveMenuValidate.funame='saveMenuValidate';
//恢复默认图标 菜单 模块管理 链接模块管理
function RestoreDefaultIcon(type,range,obj){
    var confirm_str = arrJsPopLabel['Areyousureyouwanttorestorethedefaulticon'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    //确定按钮
    if (type=='module'){
        if(range=='all'){
            restoreTd = ld("td[name=ICON]:visible");
        }else if(range=='single'){
            restoreTd = Tools.getParentobjByChild(obj,'td');
        }
        var tabid = restoreTd.map(function(i){
            return restoreTd.eq(i).attr("tabid");
        }).get().join(',');
    }

    ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
        ld('#rptContentLoading').show();
        ldAjaxHtmlNoProgress("index.php?module=Settings&action=RestoreDefaultIcon&parenttab=Settings&ReportHeader=dheader&ajax=yes&type="+type+"&tabid="+tabid,{},function(response){
                window.location.reload();
        });
        DelProgressObjs();
    });
}


var currencies = '';
//系统设置-其他设置-货币设定 (新增、编辑)
function editCurreny(record,detailview){
	var surl='index.php?module=Settings&action=SettingsAjax&file=CurrencyEditView&record='+record+'&detailview='+detailview;

	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1)
		{
			currencies = data.result.currencies;
			crmPopupobj.setParams(data.result.title,saveCurreny,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
            updateSymbolAndCode();
            //gwq 输入框有内容时直接显示红色字体,不用悬浮事件
            ld('#'+crmPopupobj.divid+' #conversion_rate_formula').html('¥1 ≈ '+ld('#'+crmPopupobj.divid+' #span_currency_symbol').text()+ld('#'+crmPopupobj.divid+' input[name="conversion_rate"]').val());

            ld('#'+crmPopupobj.divid+' input[name="conversion_rate"]').unbind('input').bind('input', function(){
                ld('#'+crmPopupobj.divid+' #conversion_rate_formula').html('¥1 ≈ '+ld('#'+crmPopupobj.divid+' #span_currency_symbol').text()+ld(this).val());
            });
			//wym BUG20240514-13 后台设置->其他设置->货币设定，1、新增货币后，编辑界面“货币名称”应该不允许修改 2、“是否启用”样式修改
            if(empty(record)){
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml('currency_name');
                var width=parseInt(CrmPopup.findHtmlobj(crmPopupobj.divid,'currency_name').parent().css("width"))-10;
                cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(width);
            }
		}
	})

}
//系统设置-其他设置-货币设定 (保存)
function saveCurreny(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var detailview = CrmPopup.findHtmlobj(divid,'detailview').val();
	if(detailview == 'detail_view'){
		popupobj.CancelEvent();
		return false;
	}

	var templatename_label = CrmPopup.findHtmlobj(divid,'templatename_label').val();
	if(isNaN(getObj("conversion_rate").value) || eval(getObj("conversion_rate").value) <= 0 || getObj("conversion_rate").value == '')
	{
		var confirm_str = arrJsPopLabel['ENTERVALIDCONVERSIONRATE'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false
	}
    //wym BUG20240514-13 后台设置->其他设置->货币设定，1、新增货币后，编辑界面“货币名称”应该不允许修改 2、“是否启用”样式修改
	if (getObj("currency_status") != null && getObj("currency_status").value == "on" && getObj("old_currency_status") != null && getObj("old_currency_status").value == "Active")
	{
		if (getObj("CurrencyEditLay") != null) getObj("CurrencyEditLay").style.display = "block";
		return false;
	}
	var urlstring = 'module=Settings&action=SaveCurrencyInfo';
	var currency_name = CrmPopup.findHtmlobj(divid,'currency_name').val();
	var currency_code = CrmPopup.findHtmlobj(divid,'currency_code').val();
	var currency_symbol = CrmPopup.findHtmlobj(divid,'currency_symbol').val();
	var conversion_rate = CrmPopup.findHtmlobj(divid,'conversion_rate').val();
    //wym BUG20240514-13 后台设置->其他设置->货币设定，1、新增货币后，编辑界面“货币名称”应该不允许修改 2、“是否启用”样式修改
    if(CrmPopup.findHtmlobj(divid,'currency_status').prop('checked')){
        var currency_status = 'Active';
    }else{
        var currency_status = 'Inactive';
    }
	var record = CrmPopup.findHtmlobj(divid,'record').val();
	urlstring += '&currency_name='+currency_name+'&currency_code='+currency_code+'&currency_symbol='+currency_symbol+'&conversion_rate='+conversion_rate+'&currency_status='+currency_status+'&record='+record;
	RequestAjax(urlstring,function(rest){
        //zkt 0048965: （81mis.com/kfbcrm/index.php）系统设置》其他设置》货币设置》编辑保存时，弹窗显示空白，实际内容是保存了
        rest = rest.trim();
		if(rest == ''){
			popupobj.CancelEvent();
			var surl = "index.php?module=Settings&action=SettingsAjax&file=CurrencyListView&ReportHeader=dheader&ajax=true";
			//alert(surl);
			ldAjax(surl,"",function(data){
				if(data.code==1){

					ld('#CurrencyListViewContents').html(data.result.content);
				}
				DelProgressObjs();
			})
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","yes",rest);
            DelProgressObjs();
			return false;
		}
		DelProgressObjs();
	})
}
//货币设定  - 选择货币带出币种符号
function updateSymbolAndCode(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var selected_curr = CrmPopup.findHtmlobj(divid,'currency_name').val();
	var currency_array = eval('('+ currencies +')')?eval('('+ currencies +')'):JSON.parse(currencies);
	ld('#span_currency_code').html(currency_array[selected_curr][0]);
	ld('#span_currency_symbol').html(currency_array[selected_curr][1]);
	getObj('currency_code').value = currency_array[selected_curr][0];
	getObj('currency_symbol').value = currency_array[selected_curr][1];
    if (ld('#'+popupobj.divid+' #conversion_rate_formula').length > 0){
        ld('#'+popupobj.divid+' #conversion_rate_formula').html('¥1 ≈ '+ld('#'+popupobj.divid+' #span_currency_symbol').text()+ld('#'+popupobj.divid+' input[name="conversion_rate"]').val());
    }

}

//仓库管理 - 编辑
function EditWareHouse(wareid){
	// ld('#rptContentLoading').show();
	var surl='index.php?module=Settings&action=SettingsAjax&file=EditWareHouse&record='+wareid;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			currencies = data.result.currencies;
			crmPopupobj.setParams(data.result.title,saveWareHouse,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
            crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
			updateSymbolAndCode();
		}
	})

}

function wareHouseselectUser(){
    /* gyq_14 */
    getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
        ScopePopup_Details.getInstance().wareHouseselectUser('owners','userid');
    });
}
//仓库管理 - 保存
function saveWareHouse(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var warehousename = CrmPopup.findHtmlobj(divid,'wareHouseName').val();
	var mode = CrmPopup.findHtmlobj(divid,'mode').val();
	var record = CrmPopup.findHtmlobj(divid,'record').val();
	var radiouser =  CrmPopup.findHtmlobj(divid,'customscope_type').val();
	var owners = CrmPopup.findHtmlobj(divid,'customscope_ids').val();
	var description = CrmPopup.findHtmlobj(divid,'description').val();
	if(warehousename==''){
		var confirm_str = arrJsPopLabel['WAREHOUSENAMECANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	var urlstring = "module=Settings&action=SaveWareHouse&ajax=true&wareHouseName="+warehousename+"&record="+record;
	urlstring += '&mode='+mode+'&radiouser='+radiouser+'&owners='+owners+'&description='+description;
	RequestAjax(urlstring,function(rest){
		if(rest.indexOf('success')){
			popupobj.CancelEvent();
			var surl = "index.php?module=Settings&action=ListWareHouse&parenttab=Settings&ReportHeader=dheader";
			//alert(surl);
			 DelProgressObjs();
			ldAjax(surl,"",function(data){
				if(data.code==1){
					ld(" [name=SettingRightContent]").html(data.result.content);
				}
                initRightContentHeight();
                DelProgressObjs();
			})
		}else{
            var confirm_str = warehousename+arrJsPopLabel['ALREADYEXISTSREENTRY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            DelProgressObjs();
			return false;
		}
	})
}
//页面设置保存原单的设置
function saveSelectSourceSet(){
    var popupobj=CrmPopup.getPopupObj("last");
    var frommodule=popupobj.frommodule;
    var selectmodule=ld("#"+popupobj.divid+" [name=optionmodule]").val();
    var divid=popupobj.divid;
    var option_presence = ld('#'+divid+' [name=presence]').prop("checked");
    var option_default =ld('#'+divid+' [name=default]').prop("checked");
    var option_approve = ld('#'+divid+' [name=approve]').val();
    var urlstring = '';

    if(option_presence){
        urlstring += '&presence=0';
    }
    else
    {
       urlstring += '&presence=1';
    }
    if(option_default){
        urlstring += '&default=1';
    }
    else
    {
         urlstring += '&default=0';
    }

    urlstring += '&approve='+option_approve;

    urlstring+="&maxrowsshow="+ld("#"+popupobj.divid+" [name=maxrowsshow]").val();
    urlstring+="&datarang="+ld("#"+popupobj.divid+" [name=datarang]").val();
	//chj 2022/6/22 审批要求的其他设置
	urlstring+='&approve_advft_criteria='+ld("#"+popupobj.divid+" [name=approve_advft_criteria]").val();
    urlstring+='&approve_advft_criteria_groups='+ld("#"+popupobj.divid+" [name=approve_advft_criteria_groups]").val();
    //duan 20221209 拜访签到模块源单类型定制
    if(frommodule == 'Singin'){
        if(ld("#"+popupobj.divid+" #uploadwatermark").prop('checked')){
            urlstring+='&uploadwatermark=yes';
        }else{
            urlstring+='&uploadwatermark=no';
        }
        if(ld("#"+popupobj.divid+" #no_signin").prop('checked')){
            urlstring+='&no_signin=yes';
        }else{
            urlstring+='&no_signin=no';
        }
        var allow_distance = ld("#"+popupobj.divid+" #allowable_distance").val();
        if(allow_distance == 'custom'){
            allow_distance = ld("#"+popupobj.divid+" #custom_allowable_distance").val();
        }
        urlstring+='&allowable_distance='+allow_distance;
        if(ld("#"+popupobj.divid).find("#nosignout_cantsignin").prop('checked')){
            urlstring+='&nosignout_cantsignin=yes';
        }else{
            urlstring+='&nosignout_cantsignin=no';
        }
        if(ld("#"+popupobj.divid).find("#allowsupsignout").prop('checked')){
            urlstring+='&allowsupsignout=yes';
        }else{
            urlstring+='&allowsupsignout=no';
        }
        // 2024-4-11 xxy 拜访地址映射规则
        var signmappingrule = ld("#"+popupobj.divid).find("[name=signmappingrule]").val();
        var signmappingcontent = '';
        if(signmappingrule == 'sql'){
            signmappingcontent = ld("#"+popupobj.divid).find("[name=signmappingsql]").val();
            signmappingcontent = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(signmappingcontent,false,"");// SQL安全性加密
        }else if(signmappingrule == 'field'){
            signmappingcontent = popupobj.signmappingfieldsvalue;
        }
        urlstring+='&signmappingrule='+signmappingrule;
        urlstring+='&signmappingcontent='+encodeURIComponent(signmappingcontent);
    }

    var withdetail=ld("#"+popupobj.divid+' [name=withdetail]').prop("checked");
    if(withdetail)
    {
        urlstring+='&withdetail=yes';
		//chj 2022/6/22 自动带出所选源单的分录明细   设置控制生效条件
		if(ld("#"+popupobj.divid+" [name=withdetail_advft_criteria]").val() != '' && ld("#"+popupobj.divid+" [name=withdetail_advft_criteria_groups]").val() != ''){
			urlstring+='&withdetail_advft_criteria='+ld("#"+popupobj.divid+" [name=withdetail_advft_criteria]").val();
            urlstring+='&withdetail_advft_criteria_groups='+ld("#"+popupobj.divid+" [name=withdetail_advft_criteria_groups]").val();
		}
        ld.each(ld("#"+popupobj.divid+' [tag=strictsourcechk]'),function(){
            var columnname=ld(this).attr("name");
            var propchecked=ld(this).prop("checked");
            if(propchecked){
                urlstring+='&'+columnname+'=yes';
                //选中后保存高级查询条件
                urlstring+='&'+columnname+'_advft_criteria='+ld("#"+popupobj.divid+" [name="+columnname+"_advft_criteria]").val();
                urlstring+='&'+columnname+'_advft_criteria_groups='+ld("#"+popupobj.divid+" [name="+columnname+"_advft_criteria_groups]").val();
            }
            else
                urlstring+='&'+columnname+'=no';
        })
        if(ld("#"+popupobj.divid+' [name=autobalancecolumn]').prop("checked"))
            urlstring+='&autobalancecolumn='+ld("#"+popupobj.divid+' [name=balancecolumn]').val();
        else
            urlstring+='&autobalancecolumn=';

    // @edit:liushuai,2021-06-05,reason:【ID1001679】带产品分录的表单，选择源单字段->源单类型定制中增加字段属性参数“剩余数量为0时自动带出
        if (ld("#"+popupobj.divid+' [name=withbalanceqtycondition]').prop("checked")) {
            urlstring+='&withbalanceqtycondition=yes';//勾选
        }else{
            urlstring+='&withbalanceqtycondition=no';
        }
    }
    else{
        urlstring+='&withdetail=no';

    }

    //edit: xll 2023/05/08 XUQIU1001203 选择源单 增加“显示超链接”字段属性
    var ShowHyperlinks = ld("#"+popupobj.divid+' [name=ShowHyperlinks]').prop("checked") ? 'yes' : 'no';
    urlstring += '&ShowHyperlinks='+ShowHyperlinks;

    // edit: ljj 选择源单 增加"不允许重复"字段属性
    var unallowrepeat=ld("#"+popupobj.divid+' [name=unallowrepeat]').prop("checked");
    unallowrepeat = unallowrepeat?'yes':'no';
    urlstring += '&unallowrepeat='+unallowrepeat;


    var url = 'index.php?module=Settings&action=SettingsAjax&file=OptionModuleSave&editModule=yes&optionmodule='+selectmodule+urlstring+'&frommodule='+frommodule;
    ldAjaxHtmlNoProgress(url,'',function (response){
        var rest = response.responseText;
        if(rest == 'error'){
            var confirm_str = arrJsPopLabel['ATLEASTONESOURCESINGLEMODULEISENDALED'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
        var popupobj=CrmPopup.getPopupObj('last');
        popupobj.CancelEvent();
        RefreshSourceList(frommodule);
        editSourceDragMove(frommodule);
        // AjaxListView(tabid);
        //  fninvshnew('editOption_'+optionid);
    });
}
saveSelectSourceSet.funname='saveSelectSourceSet';


function editSourceSetting(frommodule,fieldid,selectmodule)
{
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",selectmodule,"",'none',"","");
	crmPopupobj.prevshow();
    ld.ajax({
		url: 'index.php?module=Settings&action=SettingsAjax&file=EditSourcePop&frommodule='+frommodule+"&selectmodule="+selectmodule,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
		success: function(data)
		{
			if(data.code==1)
			{
				if($("status") != undefined)
					ld('#rptContentLoading').hide();
				crmPopupobj.setParams(data.result.title,saveSelectSourceSet,"","LdPopWidth600px",selectmodule,"",data.result.oktext,"",data.result.canceltext);
				crmPopupobj.frommodule=frommodule;
                crmPopupobj.selectmodule=selectmodule;
				crmPopupobj.show(data.result.content);

                if(frommodule == 'Singin'){
                    ld("#"+crmPopupobj.divid+" [name=allowable_distance]").unbind('change').bind('change',function(){
                        changeSignAllowCustomDistance(this);
                    })
                    crmPopupobj.signmappingfields = data.result.signmappingfields;
                    crmPopupobj.signmappingfieldsvalue = data.result.signmappingfieldsvalue;
                    tooltip('.tip-items-list', {transition: true, time: 200});
                }
			}
		}
	});
}
//签到签退自定义允许误差
function changeSignAllowCustomDistance(obj){
    var popupobj=CrmPopup.getPopupObj('last');

    if(ld(obj).val() == 'custom'){
        ld("#"+popupobj.divid+" [name=custom_allowable_distance]").show();
    }else{
        ld("#"+popupobj.divid+" [name=custom_allowable_distance]").hide();
    }
}
//选择源单是否带出产品明细
function SourceBillWithDetail(jqueryobj){
    var popupobj=CrmPopup.getPopupObj('last');


    if(ld(jqueryobj).prop("checked"))
    {
        ld("#"+popupobj.divid+' [tag=strictsourcechk]').removeAttr("disabled");
        ld("#"+popupobj.divid+" [tag=tr_StrictSourceBillColumn]").css("display",'');
        ld("#"+popupobj.divid+" [tag=tr_autobalancecolumn]").css("display",'');
        ld("#"+popupobj.divid+" [name=autobalancecolumn]").prop("checked",true);

        if (ld("#"+popupobj.divid+" [name=balancecolumn]").val() == 'quantity') {
            //ld("#"+popupobj.divid+" [tag=tr_withbalanceqtycondition]").css("display",'');
        }
        ld("#"+popupobj.divid+' [name=withdetail_condition_set]').show();
        ld("#"+popupobj.divid+' [name=unallowrepeat_span]').html(arrJsPopLabel['UnallowRepeatLabelWithDetail']);
    }
    else{
        ld("#"+popupobj.divid+' [tag=strictsourcechk]').attr("disabled",true);
        ld("#"+popupobj.divid+' [tag=strictsourcechk]').prop("checked",false);
        ld("#"+popupobj.divid+" [name=autobalancecolumn]").prop("checked",false);
        ld("#"+popupobj.divid+" [tag=tr_StrictSourceBillColumn]").css("display",'none');
        ld("#"+popupobj.divid+" [tag=tr_autobalancecolumn]").css("display",'none');

        //ld("#"+popupobj.divid+" [tag=tr_withbalanceqtycondition]").css("display",'none');
        //取消选中带出分录明细时，隐藏'设置控制生效条件按钮'
        ld("#"+popupobj.divid+' [name=tax_amount_condition_set]').hide();
        ld("#"+popupobj.divid+' [name=quantity_condition_set]').hide();
		ld("#"+popupobj.divid+' [name=withdetail_condition_set]').hide();
        ld("#"+popupobj.divid+' [name=unallowrepeat_span]').html(arrJsPopLabel['UnallowRepeatLabelWithNoDetail']);
    }
    popupobj.center();
}

// @edit:liushuai,2021-06-05,reason:【ID1001679】带产品分录的表单，选择源单字段->源单类型定制中增加字段属性参数“剩余数量为0时自动带出
//自动带出源单剩余 数量/价税合计
function SourceBillWithBalanceColumn(obj){
    var popupobj=CrmPopup.getPopupObj('last');
    if (ld(obj).prop("checked") === true && ld("#"+popupobj.divid+" [name=balancecolumn]").val() == 'quantity'){
        ld("#"+popupobj.divid+" [tag=tr_withbalanceqtycondition]").css("display",'');
    }else{
        ld("#"+popupobj.divid+" [tag=tr_withbalanceqtycondition]").css("display",'none');
    }
}

// @edit:liushuai,2021-06-05,reason:【ID1001679】带产品分录的表单，选择源单字段->源单类型定制中增加字段属性参数“剩余数量为0时自动带出
//若参数“自动带出源单剩余”设置为“数量”时，下方增加显示“剩余数量为0时自动带出”参数，默认勾选
function WhenSourceSelectQuantity(jqueryobj){
    var popupobj=CrmPopup.getPopupObj('last');

    if(ld(jqueryobj).val() == 'quantity')
    {
        ld("#"+popupobj.divid+" [tag=tr_withbalanceqtycondition]").css("display",'');
        // ld("#"+popupobj.divid+" [name=withbalanceqtycondition]").prop("checked",true);
    }
    else{
        ld("#"+popupobj.divid+" [tag=tr_withbalanceqtycondition]").css("display",'none');
        // ld("#"+popupobj.divid+" [name=withbalanceqtycondition]").prop("checked",false);
    }
    popupobj.center();
}

function RefreshSourceList(frommodule)
{
    ld.ajax({
		url: 'index.php?module=Settings&action=SettingsAjax&file=SelectSourceList&frommodule='+frommodule,

		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
		success: function(data)
		{
			if(data.code==1)
			{
				if($("status") != undefined)
					ld('#rptContentLoading').hide();
                var popupobj=CrmPopup.getPopupObj('last');
                ld("#"+popupobj.divid+" [name=sourcelist]").html(data.result.content);

			}
		}
	});
}
//选择源单，排序改为拖动
function editSourceDragMove(frommodule){
    var popupobj = CrmPopup.getPopupObj('last');
    var tableobj = ld("#"+popupobj.divid).find('[name=SourceListTable]');
    tableobj.find('tr').off('hover').hover(function(){
        tableobj.find('.ld-dragicon').hide();
        ld(this).find('.ld-dragicon').show();
    });
    var oldIndex = 0;
    var dragobj = tableobj.find("tbody").get(0);
    Sortable.create(dragobj, {
    group: 'selectsource',
    draggable: ".ld-category-draggable",
    handle: ".drag-handle",
    animation: 150,
    onStart: function(evt) {
        oldIndex = evt.oldIndex; // 获取开始时的位置
    },
    onEnd: function (evt){
        var newIndex = evt.newIndex; // 获取新的位置
        var trobjs = tableobj.find("tr");
        ld.each(trobjs,function(index,trobj){
            if(index == 0){
                return;
            }
            ld(trobj).find('td:first').html(index);
        });
        if(oldIndex != newIndex){// 调换位置才发送请求
            var selectmodule = ld(evt.item).attr('selectmodule');
            var update_url = 'index.php?module=Settings&action=SettingsAjax&file=OptionModuleSave&dragmove=yes';
            update_url += '&frommodule='+frommodule+'&selectmodule='+selectmodule+'&oldsequence='+oldIndex+'&newsequence='+newIndex;
            ldAjaxNoProgress(update_url,'',function(data){
                if(data.code==1){

                }
            })
        }
    }
    });
}
//切换拜访地址映射规则
function changeSigninMappingRule(obj){
    var selectvalue = ld(obj).val();
    var popupobj = CrmPopup.getPopupObj('last');

    ld("#"+popupobj.divid).find('[name=signmappingfields_tr]').toggle();
    ld("#"+popupobj.divid).find('[name=signmappingsql_tr]').toggle();
    if(selectvalue == 'field'){
        ld('#'+popupobj.divid).find("#signinsqlwildcard").hide();
    }
    popupobj.center();

}
//设置拜访地址映射字段
function setSigninMappingFields(){
    var popupobj = CrmPopup.getPopupObj('last');
    var selectmodule = ld("#"+popupobj.divid).find('[name=optionmodule]').val();
    var crmPopupobj = CrmPopup.load("","","","LdPopWidth650px",selectmodule,"",'none',"","");
	crmPopupobj.prevshow();
    var update_url = 'index.php?module=Settings&action=SettingsAjax&file=EditSourcePop&selectmodule='+selectmodule+'&mode=setSigninMappingFields';
    ldAjaxNoProgress(update_url,'',function(data){
        if(data.code==1){

            crmPopupobj.setParams(data.result.title,saveSigninMappingFields,"","LdPopWidth650px",selectmodule,"",data.result.oktext,"",data.result.canceltext);
            var leftfields_arr = data.result.leftfields_arr;
            var rightfields_arr = !empty(popupobj.signmappingfields)?popupobj.signmappingfields : new Array();
            if(rightfields_arr.length > 0)
                leftfields_arr = leftfields_arr.filter(leftitem => !rightfields_arr.some(rightitem => rightitem.value === leftitem.value));// 在左侧数组中去掉右侧已选字段

            crmPopupobj.show('<div id="MappingFieldsDiv"></div>');
            var tableobj = ld('#'+crmPopupobj.divid).find("div#MappingFieldsDiv");
            var LeftObj = leftfields_arr;
            var RightObj = rightfields_arr;
            var Drag_Transfer = new DragTransfer();
            Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'set','250');
            crmPopupobj.center();
        }
    });
}
//保存拜访地址映射字段
function saveSigninMappingFields(){
    var popupobj = CrmPopup.getPopupObj('last');
    var Drag_Transfer = new DragTransfer();
    Drag_Transfer.tableObj = ld('#'+popupobj.divid).find("div#MappingFieldsDiv");
    var selectvalue_arr = Drag_Transfer.getData('right');
    var selectlabel_arr = Drag_Transfer.getData('right','text');
    popupobj.CancelEvent();
    var popupobj = CrmPopup.getPopupObj('last');
    popupobj.signmappingfields = selectvalue_arr.map((element, index) => ({ value: element, text: selectlabel_arr[index] }));// 映射字段放popupobj中
    popupobj.signmappingfieldsvalue = selectvalue_arr.join(',');
    var selectlabel_str = selectlabel_arr.join(',');
    ld('#'+popupobj.divid).find('input[name=signmappingfields]').val(selectlabel_str);// label显示到input框

}
//
function showSigninMappingSQLCard(){
    var popupobj = CrmPopup.getPopupObj('last');
    ld('#'+popupobj.divid).find("#signinsqlwildcard").toggle();
    popupobj.center();
}

//BUG0067244 yujun 2023-6-6  增加函数enable_deflaut_checkbox控制是否启用与是否默认复选框
/*是否启用以及是否默认*/
function enable_deflaut_checkbox(type,obj,frommodule,selectmodule){
    var htmlobj = ld(obj);
    var presence_;
    var default_;
    var data_arr = {};
    var popupobj = CrmPopup.getPopupObj('last');
    var divobj = ld('#'+popupobj.divid);
    if(type == 'presence'){
        presence_ = htmlobj.prop('checked')?0:1;
        data_arr['presence_value'] = presence_;
    }else{
        if(htmlobj.prop('checked') == false) {
            default_ = 0;
        }
        else{
            default_ = 1;
            ld("input[id='checkbox_first']").each(function(){

                ld(this).prop('checked',false);
            })
            htmlobj.prop('checked',true);
        }
        data_arr['default_value'] = default_;
    }
    var url = 'index.php?module=Settings&action=SettingsAjax&file=OptionModuleSave&frommodule='+frommodule+"&selectmodule="+selectmodule+"&type="+type;
    ldAjax(url,data_arr,function(data){
        DelProgressObjs();
        if(data.code == 1){
            //console.log(data);
            if(type == 'presence' && !htmlobj.prop('checked')){
                if (divobj.find('[name='+frommodule+'_'+selectmodule+'_default]').prop('checked')){
                    divobj.find('[name='+frommodule+'_'+selectmodule+'_default]').click();
                }
            }else if (type == 'default' && htmlobj.prop('checked')){
                console.log(divobj.find('[name='+frommodule+'_'+selectmodule+'_presence]'))
                console.log(divobj.find('[name='+frommodule+'_'+selectmodule+'_presence]').prop('checked'))
                if (!divobj.find('[name='+frommodule+'_'+selectmodule+'_presence]').prop('checked')){
                    divobj.find('[name='+frommodule+'_'+selectmodule+'_presence]').click();
                }
            }
        }
    });
}
/*
新增选择源单模块的弹出层
*/
function NewSourceModulePopup(frommodule)
{
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth650px",'Settings',"","","","");
    crmPopupobj.prevshow();
    //alert('index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList_EditField&fieldid='+fieldid+'&uitype='+uitype+'&frommodule='+frommodule);
    ld.ajax({
        url:'index.php?module=Settings&action=SettingsAjax&file=SelectSourceModulePopup&frommodule='+frommodule,
        type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,

		success:function(data){
            crmPopupobj.setParams(data.result.title,saveSelectSourceSet,"","LdPopWidth650px",frommodule,"",data.result.oktext,"",data.result.canceltext);
            crmPopupobj.show(data.result.content);
            //收款单选择源单新增时，"自动带出所选源单的分录明细"默认不勾选
            if(frommodule == 'CashBill'){
                ld("#"+crmPopupobj.divid+" [name=withdetail]").click();
            }
            crmPopupobj.frommodule=frommodule;
            tooltip('.tip-items-list', {transition: true, time: 200});
		}
	});

}

var layoutblockEventClick = function(){
	//区块移动
    var explorer = navigator.userAgent;
    if (explorer.indexOf("Chrome") <0) {
        document.onmousemove = function (e) {
            //禁止文字选中
            var event=window.event?e:window.event;

            if(event.srcElement!=undefined )
            {
                if( event.target.nodeName == 'TEXTAREA'){//2024-3-15 xxy 火狐浏览器 文本区域框 拖不动
                    return true;
                }
                //谷歌浏览器新增字段无法输入标签内容

                if(CrmPopup.global_listPopupObj.length>1)
                {
                    return false;
                }

                if(ld("#relatedlistdiv_blockname").css("display")!='none'||ld("#addblock").css("display")!='none')
                {
                    return false;
                }

            }

            window.getSelection ? window.getSelection().removeAllRanges() : document.selection.empty();
        }

    }

	Sortable.create(ld("#dv_pagelayt_drag").get(0), {
		//animation: 500,
		draggable:".blocks",
		handle: '.drag-handle',
		onUpdate: function (evt){
			if(evt != undefined){
				//如果newIndex和oldIndex相等，则表示选择后并没有拖动
				if(evt.newIndex != evt.oldIndex){
					$('status').style.display = "block";
					var new_blockid_sequence = new Array();
					ld.each(ld("#dv_pagelayt_drag .blocks"),function(index,obj){
						var objJquery = ld(obj);
						var blockid = objJquery.attr('blockid');
						new_blockid_sequence.push(blockid);
					});
					//alert('module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=updateBlockSequence&fld_module='+module+'&new_blockid_sequence='+new_blockid_sequence+'&ajax=true');
					if(!empty(new_blockid_sequence)){
						new Ajax.Request(
							'index.php',
							{queue : {position: 'end',scope:'command'},
								method:'post',
								postBody:'module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=updateBlockSequence&fld_module='+module+'&new_blockid_sequence='+new_blockid_sequence+'&ajax=true',
								onComplete: function(response) {
									$('status').style.display = "none";
									puyoungJS_DialogBox.unblock();
								}
							}
						);
					}
				}
			}
			//console.log(evt);
			//var objJquery = ld(item);
			//alert(objJquery.attr('class'));
		}

	});

	//列表
	ld.each(ld("#dv_pagelayt_drag .blockfields"),function(index,obj){
        //wyt 221212 XUQIU1000876 单据详情界面显示优化第三版（增加关键信息区块设置，需要可拖动调整）
        //关键字段信息区块和普通区块不能相互拖动
        if(ld(this).attr('blockid') == 'keyword'){
            Sortable.create(ld(this).get(0),{
                group: 'keyword_photo',
                //	animation: 500,
                handle: '.drag-handle',
                filter: '.js-remove',
                onEnd: function (evt) {	//单个区块 移动字段事件
                    var item = evt.item;
                    var objJquery = ld(item);
                    var blockid = objJquery.attr('blockid');
                    if(evt.newIndex != evt.oldIndex){
                        $('status').style.display = "block";
                        var new_columnname_sequence = new Array();
                        ld.each(ld("#dv_pagelayt_drag #block_"+blockid+" ul li"),function(index,obj){
                            var objJquery = ld(obj);
                            if(objJquery.attr('columnname') != undefined){
                                var columnname = objJquery.attr('columnname');
                                new_columnname_sequence.push(columnname);
                            }
                        });
                        //alert('module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=updateColumnSequence&fld_module='+module+'&new_columnname_sequence='+new_columnname_sequence+'&ajax=true&blockid='+blockid);
                        if(!empty(new_columnname_sequence)){
                            new Ajax.Request(
                                'index.php',
                                {queue : {position: 'end',scope:'command'},
                                    method:'post',
                                    postBody:'module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=updateColumnSequence&fld_module='+module+'&new_columnname_sequence='+new_columnname_sequence+'&ajax=true&blockid='+blockid,
                                    onComplete: function(response) {
                                        $('status').style.display = "none";
                                        puyoungJS_DialogBox.unblock();
                                    }
                                }
                            );
                        }
                    }
                    //console.log('end');
                }
            });
        }
        else{
            Sortable.create(ld(this).get(0),{
                group: 'photo',
            //	animation: 500,
                handle: '.drag-handle',
                filter: '.js-remove',
                onAdd: function (evt) {

                    var objJquery = ld(evt.from);
                    var first_blockid = objJquery.attr('blockid');
                    var objJquery = ld(evt.to);
                    var second_blockid = objJquery.attr('blockid');
                    if(!empty(first_blockid) && !empty(second_blockid) && first_blockid != second_blockid && !(first_blockid == 'keyword' || second_blockid == 'keyword')){
                        $('status').style.display = "block";
                        var first_columnname_sequence = new Array();
                        ld.each(ld("#dv_pagelayt_drag #block_"+first_blockid+" ul li"),function(index,obj){
                            var objJquery = ld(obj);
                            if(objJquery.attr('columnname') != undefined){
                                var columnname = objJquery.attr('columnname');
                                first_columnname_sequence.push(columnname);
                            }
                        });
                        //alert(first_columnname_sequence);
                        if(first_columnname_sequence == ''){
                            ld("#dv_pagelayt_drag #block_"+first_blockid+" #ul_none_"+first_blockid+"").show();
                        }else{
                            ld("#dv_pagelayt_drag #block_"+first_blockid+" #ul_none_"+first_blockid+"").hide();
                        }
                        //console.log(first_blockid+'___'+first_columnname_sequence);
                        var second_columnname_sequence = new Array();
                        ld.each(ld("#dv_pagelayt_drag #block_"+second_blockid+" ul li"),function(index,obj){
                            var objJquery = ld(obj);
                            if(objJquery.attr('columnname') != undefined){
                                var columnname = objJquery.attr('columnname');
                                second_columnname_sequence.push(columnname);
                            }
                            //console.log(columnname);
                        });
                        //alert(second_columnname_sequence);
                        if(second_columnname_sequence == ''){
                            ld("#dv_pagelayt_drag #block_"+second_blockid+" #ul_none_"+second_blockid+"").show();
                        }else{
                            ld("#dv_pagelayt_drag #block_"+second_blockid+" #ul_none_"+second_blockid+"").hide();
                        }
                        //console.log(second_blockid+'___'+second_columnname_sequence);
                        //alert('module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=updateColumnSequence_Block&fld_module='+module+'&first_columnname_sequence='+first_columnname_sequence+'&ajax=true&first_blockid='+first_blockid+'&second_columnname_sequence='+second_columnname_sequence+'&second_blockid='+second_blockid);
                        new Ajax.Request(
                            'index.php',
                            {queue : {position: 'end',scope:'command'},
                                method:'post',
                                postBody:'module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=updateColumnSequence_Block&fld_module='+module+'&first_columnname_sequence='+first_columnname_sequence+'&ajax=true&first_blockid='+first_blockid+'&second_columnname_sequence='+second_columnname_sequence+'&second_blockid='+second_blockid,
                                onComplete: function(response) {
                                    $('status').style.display = "none";
                                    puyoungJS_DialogBox.unblock();
                                }
                            }
                        );
                    }
                },
                onEnd: function (evt) {	//单个区块 移动字段事件
                    var item = evt.item;
                    var objJquery = ld(item);
                    var blockid = objJquery.attr('blockid');
                    if(evt.newIndex != evt.oldIndex){
                        $('status').style.display = "block";
                        var new_columnname_sequence = new Array();
                        ld.each(ld("#dv_pagelayt_drag #block_"+blockid+" ul li"),function(index,obj){
                            var objJquery = ld(obj);
                            if(objJquery.attr('columnname') != undefined){
                                var columnname = objJquery.attr('columnname');
                                new_columnname_sequence.push(columnname);
                            }
                            // console.log(new_columnname_sequence);
                        });
                        //alert('module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=updateColumnSequence&fld_module='+module+'&new_columnname_sequence='+new_columnname_sequence+'&ajax=true&blockid='+blockid);
                        if(!empty(new_columnname_sequence)){
                            new Ajax.Request(
                                'index.php',
                                {queue : {position: 'end',scope:'command'},
                                    method:'post',
                                    postBody:'module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=updateColumnSequence&fld_module='+module+'&new_columnname_sequence='+new_columnname_sequence+'&ajax=true&blockid='+blockid,
                                    onComplete: function(response) {
                                        $('status').style.display = "none";
                                        puyoungJS_DialogBox.unblock();
                                    }
                                }
                            );
                        }
                    }
                    //console.log('end');
                }
            });
        }
	});

}


function SmsSetting(){
    //短信接口设置
    this.selectSmsType = function(obj){
        var popupobj=CrmPopup.getPopupObj("last");
        if(obj.value == 'tencent'){
            ld("#"+popupobj.divid+" span[name=sms_account_name]").html('SDK AppId');
            ld("#"+popupobj.divid+" span[name=sms_account_pwd]").html('App Key');
        }else if(obj.value == 'aliyun'){
            ld("#"+popupobj.divid+" span[name=sms_account_name]").html('AccessKeyId');
            ld("#"+popupobj.divid+" span[name=sms_account_pwd]").html('AccessKeySecret');
        }

        var surl = 'index.php?module=Settings&action=SettingsAjax&file=SMSSetting&mode=getsmsconf&platform='+obj.value;
        ldAjax(surl,'',function (data){
            if(data.code == 1){
                ld("#"+popupobj.divid+" input[name=sms_username]").val(data.result.account_name);
                ld("#"+popupobj.divid+" input[name=sms_password]").val(data.result.account_pwd);
                ld("#"+popupobj.divid+" input[name=sms_autograph]").val(data.result.autograph);
                ld("#"+popupobj.divid+" input[name=service_tel]").val(data.result.service_tel);

            }else{
                return false;
            }
            DelProgressObjs();
        });


    }
}
SmsSetting.curobj = '';
SmsSetting.getInstance=function(){
    if(!empty(SmsSetting.curobj)){
    }else{
        SmsSetting.curobj=new SmsSetting();
    }
    return SmsSetting.curobj;
}

//系统设置 - 接口设置 - 短信账户设置
function editSmsSetting(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=SMSSetting&mode=edit';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,saveSmsSetting,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
		}
	})
}
//zxm 2021-0909系统设置-接口设置-语音账户设置
function editSmsVoiceSetting(){
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=SMSVoiceSetting&mode=edit';
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
    crmPopupobj.prevshow();
    ldAjaxNoProgress(surl,"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,saveSmsVoiceSetting,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);
            crmPopupobj.show(data.result.content);
        }
    })
}

function editExpress100Setting(){
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=Express100&mode=edit';
    var popupobj=CrmPopup.getPopupObj("last");
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
    crmPopupobj.prevshow();
    ldAjaxNoProgress(surl,"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,saveExpress100Setting,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
            crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
        }
    })
}
function saveExpress100Setting(){
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=Express100';
    var popupobj=CrmPopup.getPopupObj("last");
    var key = ld("#"+popupobj.divid+" [name=key]").val();
    var customer = ld("#"+popupobj.divid+" [name=customer]").val();
    var key_type = ld("#"+popupobj.divid+" [name=display_type]").val();
    if(key_type === 'self_purchase' && key === ''){
        //密码不能为空！
        var confirm_str = 'Key'+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    if(key_type === 'self_purchase' && customer === ''){
        //用户名不能为空！
        var confirm_str = 'Customer' + arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    surl += '&key_type='+key_type+'&key='+key+'&customer='+customer+'&mode=save';
    ldAjax(surl,"",function(data){
        if(data.code==1){
            popupobj.CancelEvent();
            var surl = "index.php?module=Settings&action=Express100&parenttab=Settings&ReportHeader=dheader";
            ldAjaxNoProgress(surl,"",function(data){
                if(data.code==1){
                    ld(' [name=SettingRightContent]').html(data.result.content);
                }
            })
        }
        DelProgressObjs();
    })
    return false;
}
function selectExpress100KeyType(obj){
    if(obj.value === 'default'){
        console.log(obj.value);
        ld('#kuaiDi_100_Setting').hide();
        //document.getElementById('weixinSetting').style.display='';
    }else{
        ld('#kuaiDi_100_Setting').show();
    }
}
//系统设置 - 接口设置 - 短信账户设置
function saveSmsSetting(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=SaveSMS';
	var popupobj=CrmPopup.getPopupObj("last");
    var sms_platform = ld("#"+popupobj.divid+" [name=sms_platform]").val();
	var sms_username = ld("#"+popupobj.divid+" [name=sms_username]").val();
	var sms_password = ld("#"+popupobj.divid+" [name=sms_password]").val();
	var sms_autograph = ld("#"+popupobj.divid+" [name=sms_autograph]").val();
	var service_tel = ld("#"+popupobj.divid+" [name=service_tel]").val();
	if(sms_username==""){
        //用户名不能为空！
        var confirm_str = ld("#"+popupobj.divid+" span[name=sms_account_name]").html() + arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    if(sms_password==""){
        //密码不能为空！
        var confirm_str = ld("#"+popupobj.divid+" span[name=sms_account_pwd]").html()+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
	if(ld("#"+popupobj.divid+" [name=sms_autograph]").attr('tag') != undefined){
		var sms_autograph_label = ld("#"+popupobj.divid+" [name=sms_autograph]").attr('tag');
		if(sms_autograph == ""){
			var confirm_str = sms_autograph_label+arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
	}
	surl += '&sms_username='+sms_username+'&sms_password='+sms_password+'&sms_autograph='+encodeURIComponent(sms_autograph)+'&service_tel='+service_tel+'&sms_platform='+encodeURIComponent(sms_platform);
	ldAjax(surl,"",function(data){
		if(data.code==1){
			popupobj.CancelEvent();
			//刷新列表
			var surl = "index.php?module=Settings&action=SMSSetting&parenttab=Settings&ReportHeader=dheader";
			ldAjaxNoProgress(surl,"",function(data){
				if(data.code==1){
					ld(' [name=SettingRightContent]').html(data.result.content);
				}
			})
		}else{
            MessagePopup.TipOne_warning(data.msg);
        }
        DelProgressObjs();
	})
	return false;
}
//zxm 2021-0909系统设置-接口设置-语音账户设置保存
function saveSmsVoiceSetting(){
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=SaveSMSVoice';
    var popupobj=CrmPopup.getPopupObj("last");
    var SecretId = ld("#"+popupobj.divid+" [name=SecretId]").val();
    var SecretKey = ld("#"+popupobj.divid+" [name=SecretKey]").val();
    var SDKAppId = ld("#"+popupobj.divid+" [name=SDKAppId]").val();
    var templateIdObj = ld("#"+popupobj.divid+" [name='templateId[]']");
    var templateNameObj = ld("#"+popupobj.divid+" [name='templateName[]']");
    var templateId = new Array()
    var templateName = new Array()
    ld.each(templateIdObj,function(index,obj){
        templateId.push(ld(obj).val());
    });
    ld.each(templateNameObj,function(index,obj){
        templateName.push(ld(obj).val());
    });
    if(SecretId==""){
        //SecretId不能为空！
        var confirm_str = '访问密钥SecretId' + arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    if(SecretKey==""){
        //SecretKey不能为空！
        var confirm_str = '访问密钥SecretKey'+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    if(SDKAppId==""){
        //SDKAppId不能为空！
        var confirm_str = '语音消息应用SDK AppId'+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }

    surl += '&SecretId='+SecretId+'&SecretKey='+SecretKey+'&SDKAppId='+SDKAppId+'&templateId='+templateId+'&templateName='+templateName;
    ldAjax(surl,"",function(data){
        if(data.code==1){
            popupobj.CancelEvent();
            //刷新列表
            var surl = "index.php?module=Settings&action=SMSVoiceSetting&parenttab=Settings&ReportHeader=dheader";
            ldAjaxNoProgress(surl,"",function(data){
                if(data.code==1){
                    ld(' [name=SettingRightContent]').html(data.result.content);
                }else{
                    var confirm_str = data.msg;
                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    return false;
                }
            })
        }else{
            var confirm_str = data.msg;
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
        DelProgressObjs();
    })
    return false;
}
//系统设置 - 接口设置 - 短信账户设置 - 注销
function CancelSmsSetting(){
    MessagePopup.TipTwo_warning(arrJsPopLabel['COMFIRMTOWRITEOFF']);
    var msgpopupobj = CrmPopup.getPopupObj('last');
    ld("#" + msgpopupobj.divid).find("input[tagclick='msgConfirm']").unbind("click").bind("click", function () {
        var surl = 'index.php?module=Settings&action=SettingsAjax&file=SMSSetting&mode=logout';
        ldAjax(surl,"",function(data){
            if(data.code==1){
                ld(' [name=SettingRightContent]').html(data.result.content);
            }
            DelProgressObjs();
        })
    });

}
//系统设置 - 接口设置 - 语音账户设置 - 注销
function CancelSmsVoiceSetting(){
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=SMSVoiceSetting&mode=logout';
    ldAjax(surl,"",function(data){
        if(data.code==1){
            ld(' [name=SettingRightContent]').html(data.result.content);
        }
        DelProgressObjs();
    })
}
//系统设置 - 接口设置 - 邮件服务器设置
function editEmailConfig(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=EmailConfig&emailconfig_mode=edit';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,saveEmailConfig,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
		}
	})
}

// 系统设置 - 接口设置 - 邮件服务器注销
function deleteEmailConfig(){
    // 弹窗提示框
    MessagePopup.TipTwo_warning(arrJsPopLabel['InterfaceLogoutReminder']);
    // 获取弹窗
    var messagepopup = CrmPopup.getPopupObj('last');
    // 点击确认出发函数进行ajax请求
    ld('#'+messagepopup.divid).find('[tagclick=msgConfirm]').off('click').on('click',function () {
        // 点击按钮回调函数
        var url = 'index.php?module=Settings&action=SettingsAjax&file=EmailConfig&emailconfig_mode=delete';
        ldAjax(url,'',function (data){
            if(data.code == 1){
                //刷新列表
                var surl = "index.php?module=Settings&action=SettingsAjax&file=EmailConfig&emailconfig_mode=edit";
                ldAjaxNoProgress(surl,"",function(data){
                    if(data.code==1){
                        ld(' [name=SettingRightContent]').html(data.result.content);
                    }
                })
                DelProgressObjs();
            }
        });
    });
}

//系统设置 - 接口设置 - 邮件服务器设置
function saveEmailConfig(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=Save';
	var popupobj=CrmPopup.getPopupObj("last");
	//chj 2021/5/24 46011: （https://61mis.com/kfbcrm [^]）客户问题（邬丹华），系统设置->接口设置->邮件服务器设置，编辑密码含有特殊字符#时，密码保存不上（需要补丁）
	var server = encodeURIComponent(ld("#"+popupobj.divid+" [name=server]").val());
	var server_username = encodeURIComponent(ld("#"+popupobj.divid+" [name=server_username]").val());
	var server_password = encodeURIComponent(ld("#"+popupobj.divid+" [name=server_password]").val());
	var from_email_field = encodeURIComponent(ld("#"+popupobj.divid+" [name=from_email_field]").val());
    var smtp_ssl='no';
	var smtp_auth = 0;
	if( ld("#"+popupobj.divid+" [name=smtp_auth]").is(':checked') == true){
		smtp_auth = 1;
	}
    if( ld("#"+popupobj.divid+" [name=smtp_ssl]").is(':checked') == true){
		smtp_ssl = 'yes';
	}
	if(server==""){
        //SMTP服务器
        var confirm_str = ld("#"+popupobj.divid+" [name=server]").attr('tag');
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
	surl += '&server='+server+'&server_username='+server_username+'&server_password='+server_password+'&from_email_field='+from_email_field+'&smtp_auth='+smtp_auth+"&server_type=email";
	surl+='&smtp_ssl='+smtp_ssl;
    ldAjax(surl,"",function(data){
		if(data.code==1){
			popupobj.CancelEvent();
			//刷新列表
			var surl = "index.php?module=Settings&action=EmailConfig&parenttab=Settings&ReportHeader=dheader";
			ldAjaxNoProgress(surl,"",function(data){
				if(data.code==1){
					ld(' [name=SettingRightContent]').html(data.result.content);
				}
			})
            DelProgressObjs();
		}else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.result.error);
            var lastpopupobj=CrmPopup.getPopupObj('last');
            //edit:can 20210520 46006: （https://61mis.com/kfbcrm [^]）客户问题（邬丹华），系统设置->接口设置->邮件服务器设置，编辑数据保存，弹出温馨提示点击【确定】按钮时，邮件服务器设置编辑弹窗应该关闭（需要补丁）
            ld("#"+lastpopupobj.divid+" [tagclick=msgConfirm]").unbind("click").bind("click",function(){
                popupobj.CancelEvent();
            })
            var surl = "index.php?module=Settings&action=EmailConfig&parenttab=Settings&ReportHeader=dheader";
            ldAjaxNoProgress(surl,"",function(data){ //BUG0073334 xxy 2023-9-27 后台设置--邮箱接口设置--编辑内容保存后，界面不会刷新，但点击编辑出来的内容是新写的
                if(data.code==1){
                    ld(' [name=SettingRightContent]').html(data.result.content);
                }
            })
            DelProgressObjs();
			return false;
		}
	})
	return false;
}

//系统设置 - 接口设置 - 帮我吧接口设置
function editBangwoInterface(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=bangwo8interface&mode=edit';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,saveBangwoInterface,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);
		}
	})
}

//系统设置 - 接口设置 - 帮我吧接口设置 - 保存
function saveBangwoInterface(){
	//alert(1);
}

//系统设置 - 接口设置 - 考勤接口设置
function editCheckin(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=checkin_setting_edit';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,saveCheckin,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
		}
	})
}

// 系统设置 - 接口设置 - 考勤接口设置 - 注销考勤参数
function deleteCheckin(){
    // 弹窗提示框
    MessagePopup.TipTwo_warning(arrJsPopLabel['InterfaceLogoutReminder']);
    // 获取弹窗
    var messagepopup = CrmPopup.getPopupObj('last');
    // 点击确认出发函数进行ajax请求
    ld('#'+messagepopup.divid).find('[tagclick=msgConfirm]').off('click').on('click',function () {
        // 点击按钮回调函数
        var url = 'index.php?module=Settings&action=SettingsAjax&file=checkin_setting_edit&ajax=delete';
        ldAjax(url,'',function (data){
            if(data.code == 1){
                //刷新列表
                var surl = "index.php?module=Settings&action=checkin_setting&parenttab=Settings&ReportHeader=dheader";
                ldAjaxNoProgress(surl,"",function(data){
                    if(data.code==1){
                        ld(' [name=SettingRightContent]').html(data.result.content);
                    }
                })
                DelProgressObjs();
            }
        })
    })
}


//系统设置 - 接口设置 - 考勤接口设置 - 选择考勤类型
function selectCheckinType(obj){
	if(obj.value == 'weixin'){
		ld('#weixinSetting').show();
		//document.getElementById('weixinSetting').style.display='';
	}else{
		ld('#weixinSetting').hide();
	}
}

//系统设置 - 接口设置 - 考勤接口设置 - 保存
function saveCheckin(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=checkin_setting_edit&ajax=save';
	var popupobj=CrmPopup.getPopupObj("last");
	var interfaceType = ld("#"+popupobj.divid+" [name=interfaceType]").val();
	var corpid = ld("#"+popupobj.divid+" [name=corpid]").val();
	var secret = ld("#"+popupobj.divid+" [name=secret]").val();
	var secret_approve = ld("#"+popupobj.divid+" [name=secret_approve]").val();
	var smtp_auth = 0;
	surl += '&interfaceType='+interfaceType+'&corpid='+corpid+'&secret='+secret+'&secret_approve='+secret_approve;
	ldAjax(surl,"",function(data){
		if(data.code==1){
			popupobj.CancelEvent();
			//刷新列表
			var surl = "index.php?module=Settings&action=checkin_setting&parenttab=Settings&ReportHeader=dheader";
			ldAjaxNoProgress(surl,"",function(data){
				if(data.code==1){
					ld(' [name=SettingRightContent]').html(data.result.content);
					DelProgressObjs();
				}
			})
		}
	})
}

//系统设置 - 接口设置 - 呼叫中心参数设置
function EditPhoneSteward(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=EditPhoneSteward';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,savePhoneSteward,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
		}
	})
}
//系统设置 - 接口设置 - 呼叫中心参数设置 - 保存
function savePhoneSteward(){

	var surl = 'index.php?module=Settings&action=SettingsAjax&file=SavePhoneSteward';
	var popupobj=CrmPopup.getPopupObj("last");
	var interfaceType = ld("#"+popupobj.divid+" [name=interfaceType]").val();
	var hantianurl = ld("#"+popupobj.divid+" [name=hantianurl]").val();
	var htrelvalue = 0;
	if(ld("#"+popupobj.divid+" [name=htrelvalue]").is(':checked') == true){
		htrelvalue = 1;
	}
    var idLeads = ld("#"+popupobj.divid+" [name=idLeads]").val();
	var idAccounts = ld("#"+popupobj.divid+" [name=idAccounts]").val();
	var idContacts = ld("#"+popupobj.divid+" [name=idContacts]").val();
	var idPotentials = ld("#"+popupobj.divid+" [name=idPotentials]").val();
	var idVendors = ld("#"+popupobj.divid+" [name=idVendors]").val();
	var idVendorContact = ld("#"+popupobj.divid+" [name=idVendorContact]").val();
	var jiuweiurl = ld("#"+popupobj.divid+" [name=jiuweiurl]").val();
	var jiuweiprefix = ld("#"+popupobj.divid+" [name=jiuweiprefix]").val();
	var sophourl = ld("#"+popupobj.divid+" [name=sophourl]").val();
	var sophourl2 = ld("#"+popupobj.divid+" [name=sophourl2]").val();
    // @edit:dong @date:2020/09/07 @reason:  天润融通旧
	var tianrun_enterpriseId = ld("#"+popupobj.divid+" [name=tianrun_enterpriseId]").val();
	var tianrun_zhanghao = ld("#"+popupobj.divid+" [name=tianrun_zhanghao]").val();
	var tianrun_password = ld("#"+popupobj.divid+" [name=tianrun_password]").val();

    // @edit:dong @date:2020/09/07 @reason:  天润融通新
    var newtianrun_address = ld("#"+popupobj.divid+" [name=newtianrun_address]").val();
    var newtianrun_accesskeyid = ld("#"+popupobj.divid+" [name=newtianrun_accesskeyid]").val();
    var newtianrun_secret = ld("#"+popupobj.divid+" [name=newtianrun_secret]").val();

	var smtp_auth = 0;
	surl += '&interfaceType='+interfaceType+'&hantianurl='+encodeURIComponent(hantianurl)+'&htrelvalue='+htrelvalue+'&idLeads='+idLeads+'&idAccounts='+idAccounts+'&idContacts='+idContacts+'&idPotentials='+idPotentials+'&idVendors='+idVendors+'&idVendorContact='+idVendorContact+'&jiuweiurl='+encodeURIComponent(jiuweiurl)+'&jiuweiprefix='+encodeURIComponent(jiuweiprefix)+'&sophourl='+encodeURIComponent(sophourl)+'&sophourl2='+encodeURIComponent(sophourl2)+'&tianrun_enterpriseId='+encodeURIComponent(tianrun_enterpriseId)+'&tianrun_zhanghao='+encodeURIComponent(tianrun_zhanghao)+'&tianrun_password='+encodeURIComponent(tianrun_password)+'&newtianrun_address='+newtianrun_address+'&newtianrun_accesskeyid='+newtianrun_accesskeyid+'&newtianrun_secret='+newtianrun_secret;

	ldAjax(surl,"",function(data){
		if(data.code==1){
			popupobj.CancelEvent();
			//刷新列表
			var surl = "index.php?module=Settings&action=PhoneSteward&parenttab=Settings&ReportHeader=dheader";
			ldAjaxNoProgress(surl,"",function(data){
				if(data.code==1){
					ld(' [name=SettingRightContent]').html(data.result.content);
				}
			})
		}
        DelProgressObjs();
	})
}
//系统设置 - 接口设置 - 呼叫中心参数设置
function checkPhoneSteward(obj){
	var popupobj=CrmPopup.getPopupObj("last");
    if(obj.value == '苏州九维'){
		ld("#"+popupobj.divid+" #interfaceurl").show();
		ld("#"+popupobj.divid+" #interfaceprefix").show();
    }else{
        ld("#"+popupobj.divid+" #interfaceurl").hide();
		ld("#"+popupobj.divid+" #interfaceprefix").hide();
    }

    // @edit:dong @date:2020/09/02 @reason: 添加天润融通旧
    if(obj.value == '天润融通旧'){
        ld("#"+popupobj.divid+" #interface_enterpriseId_tianrun").show();
        ld("#"+popupobj.divid+" #interface_zhanghao_tianrun").show();
        ld("#"+popupobj.divid+" #interface_password_tianrun").show();
    }else{
        ld("#"+popupobj.divid+" #interface_enterpriseId_tianrun").hide();
        ld("#"+popupobj.divid+" #interface_zhanghao_tianrun").hide();
        ld("#"+popupobj.divid+" #interface_password_tianrun").hide();
    }
    // @edit:dong @date:2020/09/02 @reason: 添加天润融通旧
    console.log(obj.value)
    if(obj.value == '天润融通新'){
        ld("#"+popupobj.divid+" #interface_address_tianrun").show();
        ld("#"+popupobj.divid+" #interface_accesskeyid_tianrun").show();
        ld("#"+popupobj.divid+" #interface_secret_tianrun").show();
    }else{
        ld("#"+popupobj.divid+" #interface_address_tianrun").hide();
        ld("#"+popupobj.divid+" #interface_accesskeyid_tianrun").hide();
        ld("#"+popupobj.divid+" #interface_secret_tianrun").hide();
    }

    if(obj.value == '苏州思孚'){
		ld("#"+popupobj.divid+" #interfaceurl_sopho").show();
		ld("#"+popupobj.divid+" #interfaceurl_sopho2").show();
    }else{
		ld("#"+popupobj.divid+" #interfaceurl_sopho").hide();
		ld("#"+popupobj.divid+" #interfaceurl_sopho2").hide();
    }

    if(obj.value == '汉天EC2'){
		ld("#"+popupobj.divid+" #interfaceurl_hantian").show();
		ld("#"+popupobj.divid+" #interfaceurl_hantian2").show();
    }else{
		ld("#"+popupobj.divid+" #interfaceurl_hantian").hide();
		ld("#"+popupobj.divid+" #interfaceurl_hantian2").hide();
    }
    if(obj.value == '中建荣真'){//Eidtor:gyq_68X Reason:江阴紫金呼叫 Date:2018/4/23 0023 上午 9:48
        document.getElementsByClassName('Complexform_Div0').style.display='none';
    }
}
//系统设置 - 接口设置 - 呼叫中心参数设置
function checkPhoneStewardtabname(tabname)
{
    /*name="cb_select_{$list.tabname}"*//*idAccountsText*//**/
    /*editor:gyq_25 reason:全选操作 date:20170210*/
    var checked= ld('#select'+tabname).attr('checked');
    if(checked=='checked'){
        ld('input[name="cb_select_'+tabname+'"]').attr("checked", true);
        var txt_user='';var sp_user='';
        ld('input[mark="txt_user_'+tabname+'"]').each(function(i){
            txt_user += ld(this).val()+',';
        })
        ld('span[mark="sp_user_'+tabname+'"]').each(function(i){
            sp_user += ld(this).html()+',';
        })
        var txt_user_content = txt_user.substring(0,txt_user.length-1);
        var sp_user_content = sp_user.substring(0,sp_user.length-1);

        ld('#id'+tabname).val(txt_user_content);
        ld('#id'+tabname+'Text').val(sp_user_content);
    }else{
        ld('input[name="cb_select_'+tabname+'"]').attr("checked", false);
        ld('#id'+tabname).val('');
        ld('#id'+tabname+'Text').val('');
    }

	if(tabname=='Accounts')
    {
        if(!document.getElementById("selectAccounts").checked)
        {
            document.getElementById("idAccounts").value="";
            document.getElementById("idAccountsText").value="";
        }
    }
    else if(tabname=='Contacts')
    {
        if(!document.getElementById("selectContacts").checked)
        {
            document.getElementById("idContacts").value="";
            document.getElementById("idContactsText").value="";
        }
    }
    else if(tabname=='Vendors')
    {
        if(!document.getElementById("selectVendors").checked)
        {
            document.getElementById("idVendors").value="";
            document.getElementById("idVendorsText").value="";
        }
    }
    else if(tabname=='VendorContact')
    {
        if(!document.getElementById("selectVendorContact").checked)
        {
            document.getElementById("idVendorContact").value="";
            document.getElementById("idVendorContactText").value="";
        }
    }
    //zkt 20220509 【ID1002802】【电话录音盒和灵当语音盒，增加销售线索来电和去电匹配字段（郭惠宇-亿海蓝）】
    else if(tabname=='Leads')
    {
        if(!document.getElementById("selectLeads").checked)
        {
            document.getElementById("idLeads").value="";
            document.getElementById("idLeadsText").value="";
        }
    }

}
//系统设置 - 接口设置 - 呼叫中心参数设置
function checkPhoneStewardrelbox(obj){
    var htrelvalue = obj.checked;
    if(htrelvalue){
        ld(obj).next().show();
    }else{
        ld(obj).next().hide();
    }
}
//系统设置 - 接口设置 - 呼叫中心参数设置
function SelectedPhoneStewardPhone(txtidText,txtid,tabname){
    cbobj=document.getElementsByName('cb_select_'+tabname);
    txtidobj=document.getElementById(txtid);
    txtobj=document.getElementById(txtidText);
    if(cbobj!=undefined&&txtobj!=undefined&&txtidobj!=undefined){
        txtobj_str='';
        txtidobj_str='';
        for(i=0;i<cbobj.length;i++){
            if(cbobj[i].checked){
                sp_obj=document.getElementById('sp_user_'+tabname+'_'+i);
                txt_obj=document.getElementById('txt_user_'+tabname+'_'+i);
                txtobj_str=txtobj_str+sp_obj.innerHTML+',';
                txtidobj_str=txtidobj_str+txt_obj.value+',';
            }
        }
        txtobj_str=txtobj_str.substr(0,txtobj_str.lastIndexOf(','));
        txtidobj_str=txtidobj_str.substr(0,txtidobj_str.lastIndexOf(','));
        txtobj.value=trim(txtobj_str);
        txtidobj.value=trim(txtidobj_str);
    }
}
//系统设置 - 接口设置 - 呼叫中心参数设置
//点击label选中复选框
function clicklabeltochecked(obj){
    var input=ld(obj).parent().parent('td').prev('td').find('input');
    var checked=ld(input).prop("checked");
    ld(input).prop('checked',!checked);
    var top_input_id=ld(obj).attr('top');
    var top_input=ld("#"+top_input_id);
    var ischecked='no';
    var alltopinput=ld("label[top="+top_input_id+"]").parent().parent('td').prev('td').find('input');
    ld(alltopinput).each(function (){
        if(ld(this).prop('checked')==true){
            ischecked='yes';
        }
    });
    if (ischecked == 'no'){
        ld(top_input).prop('checked',false);
    }else {
        ld(top_input).prop('checked',true);
    }
}
//系统设置 - 接口设置 - 玎玎接口设置
function dingtalk_setting_edit(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=dingtalk_setting_edit';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,dingSettingSave,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
		}
	})
}
//系统设置 - 接口设置 - 玎玎接口设置 - 注销按钮
function dingtalk_setting_delete(){
    MessagePopup.TipTwo_warning(arrJsPopLabel['DINGDINGINTERFACEDELETETIP']);
    var messagepopup = CrmPopup.getPopupObj('last');
    ld('#'+messagepopup.divid).find('[tagclick=msgConfirm]').off('click').on('click',function () {
        var url = 'index.php?module=Settings&action=SettingsAjax&file=dingtalk_setting_edit&ajax=delete';
        ldAjax(url,'',function (data){
            if(data.code == 1){
                //刷新列表
                var surl = "index.php?module=Settings&action=dingtalk_setting&parenttab=Settings&ReportHeader=dheader";
                ldAjaxNoProgress(surl,"",function(data){
                    if(data.code==1){
                        ld(' [name=SettingRightContent]').html(data.result.content);
                    }
                })
                DelProgressObjs();
            }
        })
    })
}
//系统设置 - 接口设置 - 云之家接口设置
function yunzhijia_setting_edit(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=yunzhijia_setting_edit';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,yunzhijiaSettingSave,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
		}
	})
}
//系统设置 - 接口设置 - 云之家接口设置 - 保存
function yunzhijiaSettingSave() {
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=yunzhijia_setting_edit&ajax=save';
	var popupobj=CrmPopup.getPopupObj("last");
	var login_appid = ld("#"+popupobj.divid+" [name=login_appid]").val();
	var login_secret = ld("#"+popupobj.divid+" [name=login_secret]").val();
	var login_url = ld("#"+popupobj.divid+" [name=login_url]").val();
	var login_appname = ld("#"+popupobj.divid+" [name=login_appname]").val();
	surl += '&login_appid='+encodeURIComponent(login_appid)+'&login_secret='+encodeURIComponent(login_secret)+'&login_url='+encodeURIComponent(login_url)+"&login_appname="+encodeURIComponent(login_appname);
	ldAjax(surl,"",function(data){
		if(data.code==1){
			popupobj.CancelEvent();
			//刷新列表
			var surl = "index.php?module=Settings&action=yunzhijia_setting&parenttab=Settings&ReportHeader=dheader";
			ldAjaxNoProgress(surl,"",function(data){
				if(data.code==1){
					ld(' [name=SettingRightContent]').html(data.result.content);
				}
			})
            DelProgressObjs();
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
			return false;
		}
	})
}

// 系统设置 - 接口设置 - 云之家接口设置 - 注销
function yunzhijia_setting_logout(){
    // 弹窗提示框
    MessagePopup.TipTwo_warning(arrJsPopLabel['InterfaceLogoutReminder']);
    // 获取弹窗
    var messagepopup = CrmPopup.getPopupObj('last');
    // 点击确认出发函数进行ajax请求
    ld('#'+messagepopup.divid).find('[tagclick=msgConfirm]').off('click').on('click',function () {
        // 点击按钮回调函数
        var url = 'index.php?module=Settings&action=SettingsAjax&file=yunzhijia_setting_edit&ajax=delete';
        ldAjax(url,'',function (data){
            if(data.code == 1){
                //刷新列表
                var surl = "index.php?module=Settings&action=yunzhijia_setting&parenttab=Settings&ReportHeader=dheader";
                ldAjaxNoProgress(surl,"",function(data){
                    if(data.code==1){
                        ld(' [name=SettingRightContent]').html(data.result.content);
                    }
                })
                DelProgressObjs();
            }
        });
    });
}

//系统设置 - 接口设置 - 致远接口设置
function zhiyuan_setting_edit(){
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=zhiyuan_setting_edit';
    var popupobj=CrmPopup.getPopupObj("last");
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");

    crmPopupobj.prevshow();

    ldAjaxNoProgress(surl,"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,zhiyuanSettingSave,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);
            crmPopupobj.show(data.result.content);
        }
    })
}

//系统设置 - 接口设置 - 致远接口设置 - 保存
function zhiyuanSettingSave() {
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=zhiyuan_setting_edit&ajax=save';
    var popupobj=CrmPopup.getPopupObj("last");
    var login_crmURL = ld("#"+popupobj.divid+" [name=login_crmURL]").val();
    var login_zyURL = ld("#"+popupobj.divid+" [name=login_zyURL]").val();
    var login_zyCode = ld("#"+popupobj.divid+" [name=login_zyCode]").val();
    var login_zyUsername = ld("#"+popupobj.divid+" [name=login_zyUsername]").val();
    var login_zyUserPassword = ld("#"+popupobj.divid+" [name=login_zyUserPassword]").val();
    surl += '&crm_url='+encodeURIComponent(login_crmURL)+'&zhiyuan_url='+encodeURIComponent(login_zyURL)+'&registerCode='+encodeURIComponent(login_zyCode)+"&userName="+encodeURIComponent(login_zyUsername)+"&password="+encodeURIComponent(login_zyUserPassword);

    ldAjax(surl,"",function(data){
        if(data.code==1){
            popupobj.CancelEvent();
            //刷新列表
            var surl = "index.php?module=Settings&action=zhiyuan_setting&parenttab=Settings&ReportHeader=dheader";
            ldAjaxNoProgress(surl,"",function(data){
                if(data.code==1){
                    ld('[name=SettingRightContent]').html(data.result.content);
                }
            })
            DelProgressObjs();
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['ZHIYUANREMINDCONTENTTEXT']);
            DelProgressObjs();
            return false;
        }
    })
}

// 系统设置-接口设置-飞书接口设置-编辑
function feishu_interface_setting_edit(){
    // http请求连接地址
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=feishu_interface_setting_edit';
    var popupobj=CrmPopup.getPopupObj("last");
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");

    crmPopupobj.prevshow();

    ldAjaxNoProgress(surl,"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,feishuInterfaceSettingSave,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);
            crmPopupobj.show(data.result.content);
        }
    })
}

// 系统设置-接口设置-飞书接口设置-保存
function feishuInterfaceSettingSave(){
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=feishu_interface_setting_edit&ajax=save';
    var popupobj=CrmPopup.getPopupObj("last");
    // 将参数放入到url中
    var login_app_id = ld("#"+popupobj.divid+" [name=login_app_id]").val();
    var login_app_secret = ld("#"+popupobj.divid+" [name=login_app_secret]").val();
    var login_crm_url = ld("#"+popupobj.divid+" [name=login_crm_url]").val();
    surl += '&AppId='+encodeURIComponent(login_app_id)+'&AppSecret='+encodeURIComponent(login_app_secret)+'&CrmUrl='+encodeURIComponent(login_crm_url);

    ldAjax(surl,"",function(data){
        if(data.code==1){
            popupobj.CancelEvent();
            //刷新列表
            var surl = "index.php?module=Settings&action=feishu_interface_setting&parenttab=Settings&ReportHeader=dheader";
            ldAjaxNoProgress(surl,"",function(data){
                if(data.code==1){
                    ld('[name=SettingRightContent]').html(data.result.content);
                }
            })
            DelProgressObjs();
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
            return false;
        }
    })
}

// 系统设置 - 接口设置 - 飞书接口设置 - 注销
function feishu_interface_setting_logout(){
    // 弹窗提示框
    MessagePopup.TipTwo_warning(arrJsPopLabel['InterfaceLogoutReminder']);
    // 获取弹窗
    var messagepopup = CrmPopup.getPopupObj('last');
    // 点击确认出发函数进行ajax请求
    ld('#'+messagepopup.divid).find('[tagclick=msgConfirm]').off('click').on('click',function () {
        // 点击按钮回调函数
        var url = 'index.php?module=Settings&action=SettingsAjax&file=feishu_interface_setting_edit&ajax=delete';
        ldAjax(url,'',function (data){
            if(data.code == 1){
                //刷新列表
                var surl = "index.php?module=Settings&action=feishu_interface_setting&parenttab=Settings&ReportHeader=dheader";
                ldAjaxNoProgress(surl,"",function(data){
                    if(data.code==1){
                        ld(' [name=SettingRightContent]').html(data.result.content);
                    }
                })
                DelProgressObjs();
            }
        });
    });
}

//系统设置 - 接口设置 - 企业微信自建应用设置
function wxselfbuiltapp_setting_edit(){
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=wxselfbuiltapp_setting_edit';
    var popupobj=CrmPopup.getPopupObj("last");
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
    crmPopupobj.prevshow();
    ldAjaxNoProgress(surl,"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,wxselfbuiltapp_setting_save,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
            crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
        }
    })
}
//系统设置 - 接口设置 - 企业微信自建应用设置 - 保存
function wxselfbuiltapp_setting_save() {
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=wxselfbuiltapp_setting_edit&ajax=save';
    var popupobj=CrmPopup.getPopupObj("last");
    var corp_link = trim(ld("#"+popupobj.divid+" [name=corp_link]").val());
    var corpid = trim(ld("#"+popupobj.divid+" [name=corpid]").val());
    var secret = trim(ld("#"+popupobj.divid+" [name=secret]").val());
    var agentid = trim(ld("#"+popupobj.divid+" [name=agentid]").val());

    if (isNaN(agentid)) {
        RemindsMsg("","LdPopWidth400px","","yes","yes",'AgentId错误!');
        return false;
    }else if(secret.length < 30){
        RemindsMsg("","LdPopWidth400px","","yes","yes",'Secret错误!');
        return false;
    }

    surl += '&corp_link='+encodeURIComponent(corp_link)+'&corpid='+encodeURIComponent(corpid)+'&secret='+encodeURIComponent(secret)+'&agentid='+encodeURIComponent(agentid)+'&secret='+encodeURIComponent(secret);
    ldAjax(surl,"",function(data){
        if(data.code==1){
            popupobj.CancelEvent();
            //刷新列表
            var surl = "index.php?module=Settings&action=wxselfbuiltapp_setting&parenttab=Settings&ReportHeader=dheader";
            ldAjaxNoProgress(surl,"",function(data){
                if(data.code==1){
                    ld(' [name=SettingRightContent]').html(data.result.content);
                }
            })
            DelProgressObjs();
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
            return false;
        }
    })
}
//系统设置 - 接口设置 - 企业微信自建应用设置 - 卸载
function wxselfbuiltapp_setting_uninstall(){
    RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['UninstallSelfBuiltTip']);
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        var surl = 'index.php?module=Settings&action=SettingsAjax&file=wxselfbuiltapp_setting_edit&ajax=uninstall';
        ldAjax(surl,"",function(data){
            if(data.code==1){
                //刷新列表
                var surl = "index.php?module=Settings&action=wxselfbuiltapp_setting&parenttab=Settings&ReportHeader=dheader";
                ldAjaxNoProgress(surl,"",function(data){
                    if(data.code==1){
                        ld(' [name=SettingRightContent]').html(data.result.content);
                        DelProgressObjs();
                    }
                })
            }
        })
    })


}
//系统设置 - 接口设置 - 企业微信渠道码设置
function channelcode_setting_edit(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=channelcode_setting_edit';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,channelcodeSettingSave,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);
		}
	})
}

function channelcodeSettingSave(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=channelcode_setting_edit&ajax=save';
	var popupobj=CrmPopup.getPopupObj("last");
	var channelcode_secret = ld("#"+popupobj.divid+" [name=channelcode_secret]").val();
	if(channelcode_secret == ''){
		var channelcode_secret_label = ld("#"+popupobj.divid+" [name=channelcode_secret]").attr('tag');
		RemindsMsg("","LdPopWidth400px","","yes","yes",channelcode_secret_label+arrJsPopLabel['CANOTEMPTYGTH']);
        return false;
	}
	var channelcode_token = ld("#"+popupobj.divid+" [name=channelcode_token]").val();
	if(channelcode_token == ''){
		RemindsMsg("","LdPopWidth400px","","yes","yes",'Token'+arrJsPopLabel['CANOTEMPTYGTH']);
        return false;
	}
	var channelcode_encodingaeskey = ld("#"+popupobj.divid+" [name=channelcode_encodingaeskey]").val();
	if(channelcode_encodingaeskey == ''){
		RemindsMsg("","LdPopWidth400px","","yes","yes",'EncodingAESKey'+arrJsPopLabel['CANOTEMPTYGTH']);
        return false;
	}
	surl += '&channelcode_secret='+encodeURIComponent(channelcode_secret)+'&channelcode_token='+encodeURIComponent(channelcode_token)+'&channelcode_encodingaeskey='+encodeURIComponent(channelcode_encodingaeskey);
	//alert(surl);
	ldAjax(surl,"",function(data){
		if(data.code==1){
			popupobj.CancelEvent();
			//刷新列表
			var surl = "index.php?module=Settings&action=channelcode_settings&parenttab=Settings&ReportHeader=dheader";
			ldAjaxNoProgress(surl,"",function(data){
				if(data.code==1){
					ld(' [name=SettingRightContent]').html(data.result.content);
				}
			})
            DelProgressObjs();
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
			return false;
		}
	})
}

//ls 2021-12-15 【1002160】企业微信通讯录及部门同步
//系统设置 - 接口设置 - 企业微信通讯录同步设置
function addressbook_setting_edit(){
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=addressbook_setting_edit';
    var popupobj=CrmPopup.getPopupObj("last");
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
    crmPopupobj.prevshow();
    ldAjaxNoProgress(surl,"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,addressbookSettingSave,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
            crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight('.divPopOverflow')
        }
    })
}
//系统设置 - 接口设置 - 企业微信通讯录同步设置 - 保存
function addressbookSettingSave(){
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=addressbook_setting_edit&ajax=save';
    var popupobj=CrmPopup.getPopupObj("last");
    var addressbook_secret = ld.trim(ld("#"+popupobj.divid+" [name=addressbook_secret]").val());
    var addressbook_corpid = ld.trim(ld("#"+popupobj.divid+" [name=addressbook_corpid]").val());
    if(addressbook_corpid == ''){
        var addressbook_corpid_label = ld("#"+popupobj.divid+" [name=addressbook_corpid]").attr('tag');
        RemindsMsg("","LdPopWidth400px","","yes","yes",addressbook_corpid_label+arrJsPopLabel['CANOTEMPTYGTH']);
        return false;
    }
    if(addressbook_secret == ''){
        var addressbook_secret_label = ld("#"+popupobj.divid+" [name=addressbook_secret]").attr('tag');
        RemindsMsg("","LdPopWidth400px","","yes","yes",addressbook_secret_label+arrJsPopLabel['CANOTEMPTYGTH']);
        return false;
    }
    var addressbook_token = ld.trim(ld("#"+popupobj.divid+" [name=addressbook_token]").val());
    /*if(addressbook_token == ''){
        RemindsMsg("","LdPopWidth400px","","yes","yes",'Token'+arrJsPopLabel['CANOTEMPTYGTH']);
        return false;
    }*/
    var addressbook_encodingaeskey = ld.trim(ld("#"+popupobj.divid+" [name=addressbook_encodingaeskey]").val());
    /*if(addressbook_encodingaeskey == ''){
        RemindsMsg("","LdPopWidth400px","","yes","yes",'EncodingAESKey'+arrJsPopLabel['CANOTEMPTYGTH']);
        return false;
    }*/
    surl += '&addressbook_secret='+encodeURIComponent(addressbook_secret)+'&addressbook_token='+encodeURIComponent(addressbook_token)+'&addressbook_encodingaeskey='+encodeURIComponent(addressbook_encodingaeskey);
    //alert(surl);
    surl+="&addressbook_corpid="+encodeURIComponent(addressbook_corpid);

    ldAjax(surl,"",function(data){
        if(data.code==1){
            popupobj.CancelEvent();
            //刷新列表
            var surl = "index.php?module=Settings&action=addressbook_setting&parenttab=Settings&ReportHeader=dheader";
            ldAjaxNoProgress(surl,"",function(data){
                if(data.code==1){
                    ld(' [name=SettingRightContent]').html(data.result.content);
                }
            })
            DelProgressObjs();
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
            return false;
        }
    })
}

//系统设置 - 接口设置 - 玎玎接口设置 - 保存
function dingSettingSave() {
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=dingtalk_setting_edit&ajax=save';
	var popupobj=CrmPopup.getPopupObj("last");
	var corpid = ld("#"+popupobj.divid+" [name=corpid]").val();
	var agentid = ld("#"+popupobj.divid+" [name=agentid]").val();
	var _key = ld("#"+popupobj.divid+" [name=key]").val();
	var secret = ld("#"+popupobj.divid+" [name=secret]").val();
	var login_appid = ld("#"+popupobj.divid+" [name=login_appid]").val();
	var login_secret = ld("#"+popupobj.divid+" [name=login_secret]").val();
	var login_url = ld("#"+popupobj.divid+" [name=login_url]").val();
	surl += '&corpid='+encodeURIComponent(corpid)+'&agentid='+encodeURIComponent(agentid)+'&key='+encodeURIComponent(_key)+'&secret='+encodeURIComponent(secret)+'&login_appid='+encodeURIComponent(login_appid)+'&login_secret='+encodeURIComponent(login_secret)+'&login_url='+encodeURIComponent(login_url);
	ldAjax(surl,"",function(data){
		if(data.code==1){
			popupobj.CancelEvent();
			//刷新列表
			var surl = "index.php?module=Settings&action=dingtalk_setting&parenttab=Settings&ReportHeader=dheader";
			ldAjaxNoProgress(surl,"",function(data){
				if(data.code==1){
					ld(' [name=SettingRightContent]').html(data.result.content);
				}
			})
            DelProgressObjs();
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
			return false;
		}
	})
}
//系统设置 - 其他设置 - 客户和联系人关联字段
function saveAccountsContactsvalidate(){
	var form=document.forms['menu'];
    var obj=form.selectedtabColumns;
    var selectedColStr='';
	if(form.zhname.value == '')
	{
		var confirm_str = arrJsPopLabel['CHINESEBLOCKNAMENOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		form.zhname.focus();
		return false;
	}
	if(form.enname.value=='')
	{
        var confirm_str = arrJsPopLabel['ENGLISHBLOCKNAMENOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		form.enname.focus();
		return false;
	}
    //判断已选字段是否为空
    if(obj.options.length <= 0)
    {
        var confirm_str = arrJsPopLabel['Selected_Fields']+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    if(obj.options.length>0){
        for(var i=0;i<obj.options.length;i++){
            selectedColStr += obj.options[i].value+";";
        }
        form.selectedfields.value = selectedColStr;
    }

	var isdisplay = 1;
	var popupobj=CrmPopup.getPopupObj("last");
	if( ld("#isdisplay").is(':checked') == true){
		 isdisplay = 0;
	}

	var surl = 'index.php?module=Settings&action=SettingsAjax&file=AccountsContactsField&edittype=Add';
	surl += '&zhname='+encodeURIComponent(form.zhname.value)+'&enname='+encodeURIComponent(form.enname.value)+'&selectedfields='+encodeURIComponent(form.selectedfields.value)+'&display_type='+form.display_type.value+'&isdisplay='+isdisplay;
	ldAjax(surl,"",function(data){
		if(data.code==1){
			//edit: chj date: 2020/8/28 42535: （http://51mis.com/YS/liu228/ [^]）系统设置>其他设置>客户和联系人关联字段：勾选“是否显示”，点击“保存”提示报错
			//popupobj.CancelEvent();
			var confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
			// RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            MessagePopup.TipOne_success(confirm_str);
		}
        DelProgressObjs();
	})
    return false;
}


//系统设置 - 接口设置 - 钉钉群消息推送设置
// @edit:liushuai,2020-09-18,reason:【ID1001104】钉钉群消息推送设置功能优化(新增和编辑、复制)
function dingtalk_webhook_setting_create_or_edit(id, tabid, type){
    if (type == 'copy') {
        tabid = ld("#pick_module").val();
    }
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=dingtalk_webhook_setting_edit&tabid='+tabid+'&type='+type;
    if(type == 'edit' || type == 'copy'){//编辑时
        surl += '&record='+id;
    }
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
    crmPopupobj.prevshow();
    ldAjaxNoProgress(surl,"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,dingtalk_webhook_setting_save,"","LdPopWidth800px",'Settings',type,data.result.oktext,"",data.result.canceltext);
            crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");

            //edit: wym 240509 BUG0062024 选择模块无搜索功能
            var selectobj=ld("#"+crmPopupobj.divid).find(" [name=SelectModule]");
            if(selectobj.length>0&&selectobj!=undefined){
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml('SelectModule');
                cls_resetComboxHtmlobj.setPopupObj(crmPopupobj);
                var tdobj=Tools.getParentobjByChild(selectobj,'td');
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj,tdobj.width()+8);//8的内边距
            }
            var tabid = data.result.tabid;
            var urlstring = '&tabid='+tabid+'&printtabid='+tabid;
            ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=TemplatePrintField'+urlstring,{},function(data){
                ld("#"+crmPopupobj.divid+" #tabField").html(data.result.fieldsel);//这一步会让该元素name改为SelectField,可能会有问题,涉及公共代码,先不修改
            });
        }
    })
}
dingtalk_webhook_setting_create_or_edit.funname = 'dingtalk_webhook_setting_save';
function moduleSel(obj)
{
    var crmPopupobj=CrmPopup.getPopupObj("last");
    var tabid = obj.value;
    var urlstring = '&tabid='+tabid+'&printtabid='+tabid;
    ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=TemplatePrintField'+urlstring,{},function(data){
        ld("#"+crmPopupobj.divid+" #tabField").html(data.result.fieldsel);
        ld("#"+crmPopupobj.divid+" #selField").val('');
        ld("#"+crmPopupobj.divid+" textarea#templateTextArea").val("");
    });
}
function fieldSel(obj)
{
    var crmPopupobj=CrmPopup.getPopupObj("last");
    ld("#"+crmPopupobj.divid+" #selField").val("[var."+obj.value+"]");
    // document.getElementById("selField").value="[var."+obj.value+"]";
}
function InsertRemindField(obj)
{
    var crmPopupobj=CrmPopup.getPopupObj("last");
    if(trim(ld("#"+crmPopupobj.divid+" #selField").val()) == "" )
    {
        //请选择字段！
        var confirm_str = arrJsPopLabel['PLEASESELECTFIELD'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return false;
    }
    var str=ld("#"+crmPopupobj.divid+" [name=CKcontent]").val();
    str+= document.getElementById("selField").value;
    ld("#"+crmPopupobj.divid+" [name=CKcontent]").val(str);
    ld("#"+crmPopupobj.divid+" [name=CKcontent]").focus();

}

//系统设置 - 接口设置 - 钉钉群消息推送设置 - 保存
function dingtalk_webhook_setting_save(type) {
    var popupobj=CrmPopup.getPopupObj("last");
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=dingtalk_webhook_setting&ajax=true';
    var keywords = trim(ld("#"+popupobj.divid+" [name=keywords]").val());
    var webhook = trim(ld("#"+popupobj.divid+" [name=webhook]").val());
    var is_enable = ld("#"+popupobj.divid+" [name=is_enable]").prop('checked');
    is_enable = is_enable?'yes':'no';
    var tabid = ld("#"+popupobj.divid+" [name=SelectModule]").val();
    var CKcontent = trim(ld("#"+popupobj.divid+" [name=CKcontent]").val());

    surl += '&webhook='+encodeURIComponent(webhook)+'&is_enable='+is_enable+'&keywords='+encodeURIComponent(keywords)+'&tabid='+tabid+'&CKcontent='+encodeURIComponent(CKcontent)+'&type='+type;
    if (type == 'edit') {
        var record = CrmPopup.getHtmlobjval(popupobj.divid,'record');
        surl += '&record='+record;
    }

    //数据校验
    if (empty(tabid)) {
        var confirm_str = arrJsPopLabel['dingtalk_tabid_not_null'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    if (empty(keywords)) {
        var confirm_str = arrJsPopLabel['dingtalk_keywords_not_null'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    if (empty(webhook)) {
        var confirm_str = arrJsPopLabel['dingtalk_address_not_null'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    if (empty(encodeURIComponent(CKcontent))) {
        var confirm_str = arrJsPopLabel['dingtalk_content_not_null'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }

    ldAjax(surl,"",function(data){
        if(data.code==1){
            popupobj.CancelEvent();
            //刷新列表
            var surl = "index.php?module=Settings&action=dingtalk_webhook_setting&parenttab=Settings&ReportHeader=dheader";
            ldAjaxNoProgress(surl,"",function(data){
                if(data.code==1){
                    ld(' [name=SettingRightContent]').html(data.result.content);
                }
            })
            DelProgressObjs();
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
            return fasle;
        }
    });
}

//@edit:liushuai,2020-09-18,reason:【ID1001104】钉钉群消息推送设置功能优化（删除时需要弹框提示）
async function dingtalk_webhook_setting_by_type(id,checked_status,type){
    //edit:duan 2022-2-18 列表页中的是否改为按钮
    if(type != 'delete'){
        if(checked_status){
            type = 'activate';
        }
        else{
            type = 'inactivate';
        }
    }
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=dingtalk_webhook_setting&record='+id+'&ajax=true&type='+type;
    if(type == 'delete'){
        MessagePopup.TipTwo_warning(arrJsPopLabel['SUREWANTDELETE']);
        var isDelete = 'yes';
        try { //BUG0070087 xxy 2023-7-26 后台设置->接口设置->钉钉群消息推送设置，点击删除后的提示信息弹窗样式修改
            await iscontinuefun(); //用异步函数实现点击弹出层确定键能够继续执行，点击取消则阻断保存函数继续执行
        } catch(error) {
            isDelete = error;
        }
        if (isDelete == 'no') {
            return false;
        }
    }
    ldAjaxNoProgress(surl,"",function(data){
        if(data.code==1){
            //刷新列表
            var surl = "index.php?module=Settings&action=dingtalk_webhook_setting&parenttab=Settings&ReportHeader=dheader";
            ldAjaxNoProgress(surl,"",function(data){
                if(data.code==1){
                    ld(' [name=SettingRightContent]').html(data.result.content);
                }
            })
        }
    });
}
function iscontinuefun() {//BUG0070087 xxy 2023-7-26 后台设置->接口设置->钉钉群消息推送设置，点击删除后的提示信息弹窗样式修改
	return new Promise((resolve, reject) => {
		var popupobj=CrmPopup.getPopupObj('last');
		ld('#'+popupobj.divid+' input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
			resolve();
		})
		ld('#'+popupobj.divid+' input[tagclick="msgConfirmCancel"]').unbind('click').on('click', function () {
			reject('no');
		})
	});
}
//edit:can 20200825 单据分录数据权限控制，支持按照“角色控制”
function ProfileFieldSelectRoles()
{
    var chooseroleobj=new cls_ChooseRoles(new Object(),ld("#hidden_pro_profile_value"));
    if(ld("#hidden_pro_profilefieldtype").val()=='role')
    {
       // alert(ld("#hidden_pro_profile_value").val());
         chooseroleobj.setSelectProfileIds(ld("#hidden_pro_profile_value").val());
    }
    ld("#hidden_pro_profile_value").val();

   ld("#hidden_pro_profilefieldtype").val("role");
    chooseroleobj.show();
    var parentbtnok=chooseroleobj.btnok;
    chooseroleobj.btnok=function()
    {
        parentbtnok.apply(chooseroleobj.btnok,[]);
        ld("#hidden_pro_profilefieldtype").val("role");


    }


}
function smtpcheckclick(jqueryobj)
{
    var popupobj=CrmPopup.getPopupObj('last');

    if(ld(jqueryobj).is(":checked"))
    {
        ld("#"+popupobj.divid+" [name=smtp_port]").html(465);
    }
    else
    {
        ld("#"+popupobj.divid+" [name=smtp_port]").html(25);
    }
}
//duan 系统设置中通过新单选框修改数据表字段的值（checkbox-switch）
function change_tablefield_presence(obj,index_value,type){

    if(ld(obj).is(':checked')){
        var presence = 0;
        //增加ssl参数显示
        if(type == 'systems_smtp_ssl'){
            ld("#smtp_port").html(465);
        }
    }else{
        var presence = 1;
        //增加ssl参数显示
		if(type == 'systems_smtp_ssl'){
            ld("#smtp_port").html(25);
        }
    }
    var popupobj=CrmPopup.getPopupObj('last');

    //帮我吧接口设置,未设置账户无法启用
    if(type == 'bangwo8_presence'&&presence==0){
        var verdorid = ld(obj).attr('verdorid');
        if(empty(verdorid)||verdorid==undefined){
            ld(obj).prop('checked',false);
            RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['BANGWO8ACCOUNTEMPTY']);
            return false;
        }
    }
    else if(type == 'bangwo8_is_customer'&&presence==0){
        var supportname = ld(obj).attr('supportname');
        if(empty(supportname)||supportname==undefined){
            ld(obj).prop('checked',false);
            RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['BANGWO8SERVICEACCOUNTEMPTY']);
            return false;
        }
    }
    //邮箱服务器设置
    else if(type.indexOf('systems_smtp')!=-1){
        var mailserver = ld(obj).attr('mailserver');
        if(empty(mailserver)||mailserver==undefined){
            ld(obj).prop('checked',false);
            RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['PLEASESETMAILSERVER']);
            return false;
        }
    }
    //@edit:liujiajun,2023-07-10,reason:BUG0069249: 水印设置，自定义内容为空不能启用
    else if(type == 'watermark_presence' && presence == 0){
        var watermark_remark=ld('#watermark_remark').text();
        if(empty(watermark_remark)){
            ld(obj).prop('checked', false);
            MessagePopup.TipOne_warning(arrJsPopLabel['CUSTOMWATERMARKNOTEMPTY']);//新弹窗
            return false;
        }
    }
    //xxy 2023-11-22 移动端模块列表定制，是否启用字段同步控制"是否根据此字段查询"参数
    if(type == 'cvcolumnlist_wx_presence'){
        var isforsearch_obj = ld(obj).parents('tr').find("input#cvcolumnlist_wx_isforsearch");
        if(presence == 1){
            isforsearch_obj.prop('checked',false);
            isforsearch_obj.prop('disabled',true);
        }else{
            isforsearch_obj.prop('checked',true);
            isforsearch_obj.prop('disabled',false);
        }
        change_tablefield_presence(isforsearch_obj,index_value,'cvcolumnlist_wx_isforsearch');
    }

    var addurl = '';
    if(type == 'fieldwxmaininfo_presence'){
        addurl += '&modulename='+ld('#modulename').val();
    }

    var url = 'index.php?module=Settings&action=SettingsAjax&file=ChangeTablefieldPresence'+addurl;
    var param = {'index_value':index_value,'type':type,'presence':presence};
    ldAjaxNoProgress(url,param,function(data){
        if(data.code == 1){
            //签到的源单设置默认后更新其他源单
            if(type == 'option_module_default'&&data.result.tabid!=undefined){
                AjaxListView(data.result.tabid);
            }
            //打印模块设置默认后更新其他模板
            else if(type == 'templateprint_isdefault'&&data.result.tabid!=undefined){
                TemplateprintList.refresh();
            }
            //企业微信启用关闭后刷新页面中的数据导入
            else if(type == 'wx_config_switch'){
                settings_ExternalContact.refresh();
            }else if(type == 'workreport_field_is_mandatory' || type == 'workreport_field_active'){//BUG00653904
                WorkTemplate.refresh();
            }
            else if (type == 'watermark_presence'){// ljj 20240131 BUG20240130-68 kfbcrm-水印设置-修改水印显示内容后界面不会自动刷新
                if (!empty(data.result.watermark_txt)){
                    getJsScript('include/js/shuiyin.js', function () {
                        watermark({"watermark_txt": data.result.watermark_txt});
                    });
                }else {
                    ld('[id^=mask_div]').remove();
                }
            }else if (type == 'bangwo8_presence' || type == 'bangwo8_is_customer'){
                bangwo8interface.refresh();
            }
        }else if(data.code == -1){
            //移动端模块列表定制，至少需要一行字段显示
            if(type == 'cvcolumnlist_wx_presence'){
                ld(obj).prop('checked',true);
                var confirm_str = arrJsPopLabel['youdonotallowallfields']+'，'+arrJsPopLabel['pleasereset']+'！';
                MessagePopup.TipOne_warning(confirm_str);
            }
            else if(type=='fieldwxmaininfo_presence'){//移动端详情界面定制 开启数量不允许超过五行
                ld(obj).prop('checked',false);
                var confirm_str = arrJsPopLabel['MOSTOFFIVELINE']+'，'+arrJsPopLabel['pleasereset']+'！';
                MessagePopup.TipOne_warning(confirm_str);
            }
            else if(type=='cvcolumnlist_wx_isforsearch'){//移动端模块列表定制，至少设置一个字段可用于查询
                ld(obj).prop('checked',true);
                ld(obj).prop('disabled',false);
                ld(obj).parents('tr').find('input#cvcolumnlist_wx_presence').prop('checked',true);
                change_tablefield_presence(ld(obj).parents('tr').find('input#cvcolumnlist_wx_presence'),index_value,'cvcolumnlist_wx_presence');
                var confirm_str = arrJsPopLabel['SetLeastOneFieldQuerying'];
                MessagePopup.TipOne_warning(confirm_str);
            } else if (type === 'weixinmp_listfields_presence' || type === "weixinmp_fields_displaytype") {//移动端模块列表定制和详情定制，至少需要一行字段显示
                ld(obj).prop('checked',true);
                ld(obj).prop('disabled',false);
                MessagePopup.TipOne_warning(data.msg);
            }
            else{
                MessagePopup.TipOne_warning(data.msg);
            }
        }
    });
}
//源单类型定制-切换源单类型后清空高级查询条件
function changeOptionModule(obj){
    var popupobj=CrmPopup.getPopupObj('last');
    if(ld("#"+popupobj.divid+" [name*=_advft_criteria]").length>0){
        ld("#"+popupobj.divid+" [name*=_advft_criteria]").val('');
    }
    if(ld("#"+popupobj.divid+" [name*=_advft_criteria_groups]").length>0){
        ld("#"+popupobj.divid+" [name*=_advft_criteria_groups]").val('');
    }
	ld("#"+popupobj.divid+" [name=referencemodule_1]").val(obj.value);
    // 切换模块清空拜访地址映射规则的内容
    popupobj.signmappingfields = [];
    popupobj.signmappingfieldsvalue = '';
    ld('#'+popupobj.divid).find('input[name=signmappingfields]').val('');
}

//勾选控制数量字段不超过源单后显示‘设置控制生效条件’按钮
function change_effective_condition(obj){
    var columnname = ld(obj).attr('name');
    var divname = columnname+'_condition_set';
    if(ld(obj).prop('checked')){
        ld("div[name="+divname+"]").show();
    }else{
        ld("div[name="+divname+"]").hide();
    }
}
//源单类型定制-新增界面需要获取当前选中的源单类型
function create_effective_condition(columnname){
    var popupobj=CrmPopup.getPopupObj('last');
    var frommodule = ld("#"+popupobj.divid+" [name=optionmodule]").val();
    get_effective_condition(columnname,frommodule);
}

//源单类型定制，设置高级查询条件
function get_effective_condition(columnname,frommodule){
    var popupobj=CrmPopup.getPopupObj('last');
    var module = 'Settings';
	var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=SetEfffectiveCondition&frommodule='+frommodule;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
    var advft_criteria_groups_json = ld("#"+popupobj.divid+" [name="+columnname+"_advft_criteria_groups]").val();
    var advft_criteria_json = ld("#"+popupobj.divid+" [name="+columnname+"_advft_criteria]").val();
    var params = {};
    if (!empty(advft_criteria_json)){
        params = {'advft_criteria':advft_criteria_json,'advft_criteria_groups':advft_criteria_groups_json};
    }

	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,params,function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,save_effective_condition,'',"LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			crmPopupobj.createScrollDiv();
			crmPopupobj.show(data.result.content);

            crmPopupobj.showvalues=data.result.showvalues;
            crmPopupobj.datetimestr=data.result.datetimestr;//基本查询
            crmPopupobj.viewnamelabel=data.result.viewnamelabel;
            crmPopupobj.modulelabel=data.result.modulelabel;
            crmPopupobj.columnname = columnname;
            crmPopupobj.fieldinfo = data.result.fieldinfo;

            var advancefilterobj = new cls_advanceFilter();
            var params = {};
            params.columnOptionHtml = data.result.columns_block;
            params.fLabels = data.result.flabels;
            params.datetimestr = data.result.datetimestr;
            params.advfilterhtml = data.result.foption;
            params.fieldsinfo = data.result.fieldinfo;
            params.criteria_groups_arr = data.result.criteria_groups_arr;
            params.module = frommodule;
            // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
            params.advanceFields = data.result.advanceFields;
            advancefilterobj.showAdvanceFilter(crmPopupobj,params);

			crmPopupobj.setScrollDivMaxHeight();
			crmPopupobj.center();
		}
	})
}
//保存高级查询条件到页面中
function save_effective_condition(){
    var popupobj=CrmPopup.getPopupObj('last');
	if(popupobj.advanceFilterObj.checkAdvancedFilter()==false)
	{
        return false;
	}
    var columnname = popupobj.columnname;
	var advft_criteria = popupobj.advanceFilterObj.advft_criteria;
	var advft_criteria_groups = popupobj.advanceFilterObj.advft_criteria_groups;
	var prev_popupobj=CrmPopup.getPopupObj('lastprev');
    if(!empty(advft_criteria)){
        ld("#"+prev_popupobj.divid+" [name="+columnname+"_advft_criteria]").val(advft_criteria);
	   ld("#"+prev_popupobj.divid+" [name="+columnname+"_advft_criteria_groups]").val(advft_criteria_groups);
    }
    popupobj.CancelEvent();
}

//wyt 220920 1000061 选用户（负责人、单选用户、多选用户、团队成员）字段控制只允许选择满足一定条件的数据
//获取部门方法
function get_member_bytype(blockid,type,hidden_input_id,frommodule=''){
    var module = '';
    if(document.getElementById('module') != undefined){
        module = document.getElementById('module').value;
    }
    var scopepopupobj;//自定义弹出层页面html，绑定事件
    var selectvalue;
    var popup_caption_value = arrJsPopLabel['APPLICABLESCOPE'];//标题
    if(ld('#'+hidden_input_id) != undefined){
        selectvalue = ld('#'+hidden_input_id).val();
    }
    var module = 'User';
    getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
        scopepopupobj =  new ScopePopupObj(module);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
        getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
            cls_ScopePopup.prop.popup_module = module;//模块
            cls_ScopePopup.prop.popup_value = selectvalue;

            var confirm_str = "";
            if(type == 'Departments'){
                scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];//查询框默认值
                //wyt 221008 BUG0057285 在页面设置，当“设置可查询的成员范围”是按职位级别的时候，选择职位级别的时候，查询选择的提示字段未灰色显示，点击任意职位的时候就恢复了
                scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id="popup_locationdiv" placeholder="'+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP']+'"><input id="viewuser_unfoldsubgroup" type="checkbox" >'+arrJsPopLabel['SUBGROUPUNFOLD']+'</div>';
                cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewgroupinfo&popup_scopetype=public&popup_module='+frommodule+'&popup_inputtype=checkbox&popup_selecttype=group&checkprivilege=no';
                var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);

            }
            else if(type == 'Roles'){
                scopepopupobj.popup_searchvalue = arrJsPopLabel['pleaseenterprofile'];//查询框默认值
                scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id="popup_locationdiv" placeholder="'+arrJsPopLabel['pleaseenterprofile']+'"></div>';
                cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewprofileinfo&popup_scopetype=public&popup_inputtype=checkbox&popup_selecttype=profile&checkprivilege=no';
                var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
                confirm_str = arrJsPopLabel['Pleaseselectatleaprofile'];
            }
            else if(type == 'Position'){
                scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHELEVEL'];//查询框默认值
                scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id="popup_locationdiv" placeholder="'+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHELEVEL']+'"></div>';
                cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewlevelinfo&popup_scopetype=public&popup_inputtype=checkbox&popup_selecttype=level&checkprivilege=no';
                var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
            }
            else if(type == 'Person'){
                scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认值
                scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']+'\'><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label><input id=\'viewuser_unfoldsubgroup\' class="marL10" type="checkbox"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
                cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_inputtype=checkbox&popup_selecttype=user&checkprivilege=no';
                var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
            }
            // var crmPopupobj=CrmPopup.getPopupObj("last");
            //wyt 221014 BUG0057667 点击确定后，应该提示至少选择一个职位级别（成员、部门也有这个问题）
            //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                    var select_groupid=cls_ScopePopup.return_obj.return_id;
                    var select_groupname=cls_ScopePopup.return_obj.return_name;
                    if(empty(select_groupid)) {
                        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                        return false;
                    }else{
                        ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                        ld('#advance_demand_'+type+'_'+blockid).val(select_groupid);
                        ld('#'+hidden_input_id).val(select_groupid);
                        ld('#advance_demand_'+type+'_'+blockid).html(select_groupname);
                    }
                });
            }
        });
    });
}

function edit_memberrange_selected(obj,fieldid,uitype,columnname)
{
    var type=obj.options[obj.selectedIndex].value;
    if(uitype == 153 || (uitype == 154 && columnname != 'team_memberid')){
    }else{
        ld('#tr_showallgroupstructure_edit'+fieldid).show();
    }

    if(type=='All'){
        ld('#tr_showallgroupstructure_edit'+fieldid).hide();
        ld('#memberrangedetails_Module_'+fieldid).hide();
        ld('#memberrangedetails_Person_'+fieldid).hide();
        ld('#memberrangedetails_Departments_'+fieldid).hide();
        ld('#memberrangedetails_Roles_'+fieldid).hide();
        ld('#memberrangedetails_Position_'+fieldid).hide();
    }else if(type=='Module'){
        ld('#memberrangedetails_Module_'+fieldid).hide();
        ld('#memberrangedetails_Person_'+fieldid).hide();
        ld('#memberrangedetails_Departments_'+fieldid).hide();
        ld('#memberrangedetails_Roles_'+fieldid).hide();
        ld('#memberrangedetails_Position_'+fieldid).hide();
    }else if(type=='Person'){
        ld('#memberrangedetails_Module_'+fieldid).hide();
        ld('#memberrangedetails_Person_'+fieldid).show();
        ld('#memberrangedetails_Departments_'+fieldid).hide();
        ld('#memberrangedetails_Roles_'+fieldid).hide();
        ld('#memberrangedetails_Position_'+fieldid).hide();
        ld('#advance_demand_Person_'+fieldid).html("");
        ld('#Person_'+fieldid).val("");
    }else if(type=='Departments'){
        ld('#memberrangedetails_Module_'+fieldid).hide();
        ld('#memberrangedetails_Person_'+fieldid).hide();
        ld('#memberrangedetails_Departments_'+fieldid).show();
        ld('#memberrangedetails_Roles_'+fieldid).hide();
        ld('#memberrangedetails_Position_'+fieldid).hide();
        ld('#advance_demand_Departments_'+fieldid).html("");
        ld('#Departments_'+fieldid).val("");
    }else if(type=='Roles'){
        ld('#memberrangedetails_Module_'+fieldid).hide();
        ld('#memberrangedetails_Person_'+fieldid).hide();
        ld('#memberrangedetails_Departments_'+fieldid).hide();
        ld('#memberrangedetails_Roles_'+fieldid).show();
        ld('#memberrangedetails_Position_'+fieldid).hide();
        ld('#advance_demand_Roles_'+fieldid).html("");
        ld('#Roles_'+fieldid).val("");
    }else if(type=='Position'){
        ld('#memberrangedetails_Module_'+fieldid).hide();
        ld('#memberrangedetails_Person_'+fieldid).hide();
        ld('#memberrangedetails_Departments_'+fieldid).hide();
        ld('#memberrangedetails_Roles_'+fieldid).hide();
        ld('#memberrangedetails_Position_'+fieldid).show();
        ld('#advance_demand_Position_'+fieldid).html("");
        ld('#Position_'+fieldid).val("");
    }
}

//商城设置 - 小程序商城设置 - 商户号设置
function MerchantNoSettings_edit(){
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=MerchantNoSettings_edit';
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
    crmPopupobj.prevshow();
    ldAjaxNoProgress(surl,"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,MerchantNoSettingsSave,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
            crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
        }
    })
}
//系统设置 - 接口设置 - 商户号设置 - 保存
function MerchantNoSettingsSave() {
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=MerchantNoSettings_edit&ajax=save';
    var popupobj=CrmPopup.getPopupObj("last");
    var apptype = ld("#"+popupobj.divid+" [name=apptype]").val();
    var appid = ld("#"+popupobj.divid+" [name=appid]").val();
    var merchantnum = ld("#"+popupobj.divid+" [name=merchantnum]").val();
    var merchantcertificatenum = ld("#"+popupobj.divid+" [name=merchantcertificatenum]").val();
    var apikey = ld("#"+popupobj.divid+" [name=apikey]").val();
    var apiv3key = ld("#"+popupobj.divid+" [name=apiv3key]").val();
    if(empty(appid)||appid == undefined){
        var confirm_label = ld("#"+popupobj.divid+" [name=appid]").attr('tag');
        var confirm_str = confirm_label+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
    if(empty(merchantnum)||merchantnum == undefined){
        var confirm_label = ld("#"+popupobj.divid+" [name=merchantnum]").attr('tag');
        var confirm_str = confirm_label+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
    if(empty(merchantcertificatenum)||merchantcertificatenum == undefined){
        var confirm_label = ld("#"+popupobj.divid+" [name=merchantcertificatenum]").attr('tag');
        var confirm_str = confirm_label+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
    if(empty(apikey)||apikey == undefined){
        var confirm_label = ld("#"+popupobj.divid+" [name=apikey]").attr('tag');
        var confirm_str = confirm_label+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
    if(empty(apiv3key)||apiv3key == undefined){
        var confirm_label = ld("#"+popupobj.divid+" [name=apiv3key]").attr('tag');
        var confirm_str = confirm_label+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
    //zkt 0049586: 小程序商城设置-商户号设置-保存时判断【api密钥】和【apiv3密钥】为32位，不为32位给出提示
    if(apikey.length!=32){
        var confirm_str = '请确定api密钥是否正确，api密钥应为32位，当前不符合';
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
    if(apiv3key.length!=32){
        var confirm_str = '请确定apiv3密钥是否正确，apiv3密钥应为32位，当前不符合';
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
    surl += '&apptype='+encodeURIComponent(apptype)+'&appid='+encodeURIComponent(appid)+'&merchantnum='+encodeURIComponent(merchantnum)+'&merchantcertificatenum='+encodeURIComponent(merchantcertificatenum)
        +'&apikey='+encodeURIComponent(apikey)+"&apiv3key="+encodeURIComponent(apiv3key);
    ldAjax(surl,"",function(data){
        if(data.code==1){
            popupobj.CancelEvent();
            //刷新列表
            var surl = "index.php?module=Settings&action=MerchantNoSettings&ReportHeader=dheader";
            ldAjaxNoProgress(surl,"",function(data){
                if(data.code==1){
                    ld(' [name=SettingRightContent]').html(data.result.content);
                }
            })
            DelProgressObjs();
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
            return false;
        }
    })
}

// 系统设置 - 接口设置 - 商户号设置 - 注销
function MerchantNoSettings_logout(){
    // 弹窗提示框
    MessagePopup.TipTwo_warning(arrJsPopLabel['InterfaceLogoutReminder']);
    // 获取弹窗
    var messagepopup = CrmPopup.getPopupObj('last');
    // 点击确认出发函数进行ajax请求
    ld('#'+messagepopup.divid).find('[tagclick=msgConfirm]').off('click').on('click',function () {
        // 点击按钮回调函数
        var url = 'index.php?module=Settings&action=SettingsAjax&file=MerchantNoSettings_edit&ajax=delete';
        ldAjax(url,'',function (data){
            if(data.code == 1){
                //刷新列表
                var surl = "index.php?module=Settings&action=MerchantNoSettings&ReportHeader=dheader";
                ldAjaxNoProgress(surl,"",function(data){
                    if(data.code==1){
                        ld(' [name=SettingRightContent]').html(data.result.content);
                    }
                })
                DelProgressObjs();
            }
        });
    });
}

// ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
// 附件字段新增编辑界面 按钮开启显示设置按钮
function showWatermarkSetting(obj,type){
    var checked = ld(obj).prop('checked');
    var watermarkSettingobj=ld(obj).parent().find('[name='+type+'_watermark_setting]');
    if (checked){
        watermarkSettingobj.css('display','');
    }else {
        watermarkSettingobj.css('display','none');
    }
}
// 设置按钮事件
function setWatermark(obj,type){
    var module = ld(obj).attr('module');
    var fieldname = ld(obj).attr('fieldname');
    var settingid = ld(obj).attr('settingid');
    var url = 'index.php?module=Settings&action=SettingsAjax&file=FileWaterMarkSetting&option=show&type='+type;
    url += '&relatedmodule='+module;
    if (!empty(fieldname)){
        url += '&fieldname='+fieldname;
    }
    if (!empty(settingid)){
        url += '&settingid='+settingid;
    }
    var popupobj = CrmPopup.load('','','','LdPopWidth650px','Settings','','','','');
    popupobj.prevshow();
    ldAjax(url,'',function (data) {
        if (data.code == 1) {
            popupobj.setParams(data.result.title, saveWaterMarkSetting, '', 'LdPopWidth650px', 'Settings', obj, data.result.oktext, '', data.result.canceltext)
            popupobj.show(data.result.content);
            popupobj.waterMarkSetting={};
            popupobj.waterMarkSetting['relatedmodule'] = module;
            popupobj.waterMarkSetting['type'] = type;
            popupobj.waterMarkSetting['fieldname'] = fieldname;
            getTemplatePrint(data.result.tabid);
            var divobj = ld('#' + popupobj.divid );
            divobj.find('#image_watermark').unbind('change').bind('change', function (event) {
                var image_checked = ld(this).prop('checked');
                var text_checked = divobj.find('#text_watermark').prop('checked');
                if (image_checked) {
                    if (text_checked){
                        ld(this).prop('checked',image_checked);
                        divobj.find('[name=text_watermark_content_tr]').css('display','none');
                        divobj.find('[name=image_watermark_content_tr]').css('display','');
                        divobj.find('#text_watermark').prop('checked',!image_checked);
                    }else {
                        divobj.find('[name=image_watermark_content_tr]').css('display', '');
                    }
                } else {
                    divobj.find('[name=image_watermark_content_tr]').css('display', 'none');
                }
                popupobj.center();
            });
            divobj.find('#text_watermark').unbind('change').bind('change', function (event) {
                var text_checked = ld(this).prop('checked');
                var image_checked = divobj.find('#image_watermark').prop('checked');
                if (text_checked) {
                    if(image_checked){
                        divobj.find('#image_watermark').prop('checked',!image_checked);
                        ld(this).prop('checked',text_checked);
                        divobj.find('[name=text_watermark_content_tr]').css('display','');
                        divobj.find('[name=image_watermark_content_tr]').css('display','none');
                    }else {
                        divobj.find('[name=text_watermark_content_tr]').css('display', '');
                    }
                } else {
                    divobj.find('[name=text_watermark_content_tr]').css('display', 'none');
                }
                popupobj.center();
            });
            getJsScript('include/js/special_webuploader.js', function () {
                divobj.find('[name=image_buttom_hidden]').special_powerWebUpload({
                    fileTypeDuplicate: 'yes',	//附件类型判断
                    fileNameDuplicate: 'yes',	//同名附件判断
                    mode: 'watermark',
                    module: 'Settings',
                    parentdivid: 'image_show',
                    jsonData: data.result.jsonData,
                    record: '',
                    admin: '',
                    uitype: '69',
                    supportformat: '',
                    inputFileName: 'image'	//选择附件后赋值标签的name
                });
                divobj.find('[name=image_buttom]').bind('click',function (event) {
                    divobj.find('[name=image_buttom_hidden] input[name=file]').click();

                })
            });
            popupobj.center();
        }
    });
}
// 获取内容模版下拉框内容
function getTemplatePrint(tabid) {
    var popupobj = CrmPopup.getPopupObj('last');
    var contentobj = ld('#'+popupobj.divid+' [name=text_watermark_content]');
    var url = 'index.php?module=Settings&action=SettingsAjax&file=TemplatePrintField&tabid='+tabid+'&printtabid='+tabid;
    url += '&mode=FileWaterMark';
    ldAjax(url,'',function (data) {
        if (data.code == 1){
            contentobj.find('#tabField').html(data.result.fieldsel);
            contentobj.find('tr:last td').css('border-bottom','none');
            var tip = '<tr><td></td><td><label class="padL5">'+arrJsPopLabel['WILDCARD']+' : '+arrJsPopLabel['CURRENTDATE']+'{currentdate}</label></td></tr>'
            contentobj.find('tr:last').after(tip);
        }
    })
    
}
// 水印设置保存
function saveWaterMarkSetting(obj) {
    var popupobj = CrmPopup.getPopupObj('last');
    var divobj = ld('#'+popupobj.divid);
    var params = {};
    var relatedmodule = popupobj.waterMarkSetting['relatedmodule'];
    var type = popupobj.waterMarkSetting['type'];
    var fieldid = popupobj.waterMarkSetting['fieldid'];
    var fieldname = popupobj.waterMarkSetting['fieldname'];
    params['relatedmodule']=relatedmodule;
    params['type']=type;
    params['fieldid']=fieldid;
    params['fieldname']=fieldname;
    var settingid = ld(obj).attr('settingid');
    params['settingid']=settingid;
    var image_checked = divobj.find('#image_watermark').prop('checked')?'yes':'no';
    params['image_checked'] = image_checked;
    var UploadhiddenInput=divobj.find('[name=image_buttom_hidden] [name=UploadhiddenInput]')
    if (UploadhiddenInput.find('[tag=image-newfile_name]').length>0){
        params['image_name'] = UploadhiddenInput.find('[name=image-file_name_1]').val();
        params['image_path'] = UploadhiddenInput.find('[name=image-file_path_1]').val();
        params['image_newfilename'] = UploadhiddenInput.find('[name=image-newfile_name_1]').val();
    }else {
        if (image_checked == 'yes'){
            MessagePopup.TipOne_warning(arrJsPopLabel['IMAGECANNOTEMPTY']);
            return false;
        }
    }
    // if (type == 'word'){
        var text_checked = divobj.find('#text_watermark').prop('checked')?'yes':'no';
        params['text_checked'] = text_checked;
        var content=divobj.find('[name=CKcontent]').val();
        if (text_checked == 'yes' && empty(content)){
            MessagePopup.TipOne_warning(arrJsPopLabel['CONTENTTEMPLATECANNOTEMPTY']);
            return false;
        }
        params['content'] = content;
    // }
    var url='index.php?module=Settings&action=SettingsAjax&file=FileWaterMarkSetting&option=save';
    ldAjax(url,params,function (data) {
        if (data.code == 1){
            ld(obj).attr('settingid',data.result.settingid);
            popupobj.CancelEvent();
            DelProgressObjs();
        }
    })


}

function LeftMenuSettingClick(event,jqueryobj){
    var link=ld(jqueryobj).attr("link");
    var service=ld(jqueryobj).attr("miniprogram_service");
    //获取link的action参数
    var action=getSearchString("action",link);
    //控制面板-产品授权中心
    if(link == 'index.php?action=isReg'){
        window.open('index.php?action=isReg&ReportHeader=dheader');
        return false;
    }
    link+="&ReportHeader=dheader";
    if(ld(jqueryobj).attr("page_addurl")!=undefined){
        link+=ld(jqueryobj).attr("page_addurl");
    }
    ld('#rptContentLoading').show();
    ldAjax(link,'',function(data){
        //异地登录
        ld('#rptContentLoading').hide();
        if(data.code==DataCode.logincontrol)
        {
            Tools.Relogin();
        }
        var stateObject = {};
        var href=location.href;
        // var newUrl=href+"&pageto_menufile="+action;
        var hrefArr = href.split('&pageto_menufile');
        var newUrl=hrefArr[0]+"&pageto_menufile="+action;
        history.pushState(stateObject,"",newUrl);
        ld(" [name=SettingRightContent]").html(data.result.content);

        //BUG0068281 txy 2023.06.18 kfbcrm 后台设置--登录日志查询--翻页没有浮显
        tooltip('.tip-items-list', {transition: true, time: 200});
        //将选择模块select下拉框设置为不显示，并在其后插入输入下拉框div
        var selectobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=select]");
        if(selectobj.length>0&&selectobj!=undefined){
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.attr("name"));
            CrmPopup.global_listPopupObj=[];
            var obj=new Object();
            obj.divid="SettingRightContent";
            CrmPopup.global_listPopupObj.push(obj);
            obj.CancelEvent=function(){
                return false;
            }
            cls_resetComboxHtmlobj.setPopupObj(obj);
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj,150);
            var selectdivobj  =Tools.getParentobjByChild(selectobj,'div');
            ld(selectdivobj).css('width', ld(selectdivobj).width()+20+'px');
            ld(selectdivobj).find('.chzn-container').css('margin-top', '17px');
            ld(selectdivobj).find('.chzn-drop').css('margin-left', '10px');

            //
            var selecttypeobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=selecttype]");
            if(selecttypeobj.length>0&&selecttypeobj!=undefined){
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selecttypeobj.attr("name"));
                cls_resetComboxHtmlobj.setPopupObj(obj);
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selecttypeobj,150);
                var sourcetypedivobj  =Tools.getParentobjByChild(selecttypeobj,'div');
                ld(sourcetypedivobj).css('width', ld(sourcetypedivobj).width()+20+'px');
                ld(sourcetypedivobj).find('.chzn-container').css('margin-top', '17px');
                ld(sourcetypedivobj).find('.chzn-drop').css('margin-left', '10px');
            }
        }
        //zxm 20220909 设置冻结前几列
        var selectSetStickyobj=ld(" [name=SettingRightContent] .main_grid_top").find("#selectSetStickyNums");
        if(selectSetStickyobj.length>0 && selectSetStickyobj != undefined){
            cls_resetComboxHtmlobj=new cls_resetComboxHtml('selectSetStickyNums');
            CrmPopup.global_listPopupObj = [];
            var obj = new Object();
            obj.divid="SettingRightContent";
            CrmPopup.global_listPopupObj.push(obj);
            obj.CancelEvent=function(){
                return false;
            }
            cls_resetComboxHtmlobj.setPopupObj(obj);
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectSetStickyobj,150);
            var selectSetStickyobjdivobj  =Tools.getParentobjByChild(selectSetStickyobj,'div');
            ld(selectSetStickyobjdivobj).css('width', ld(selectSetStickyobjdivobj).width()+20+'px');
            ld(' .chzn-container').css('margin-top', '17px');
            ld(' .chzn-drop').css('margin-left', '10px');
            selectSetStickyobj.unbind('change').bind('change',function(){
                selectSetStickyNums(this);
            });
        }
        //以后不准在这个函数写特殊判断 违者罚
        initRightContentHeight();//加载右侧内容中菜单和详细内容高度
        //wyt 220819 BUG0055311 系统设置-订单小程序设置，一些字段没有标题
        if(service!='Service'){
            ld('#setting_miniprogramsecret').hide();
        }
        ld('.main_grid_box').scroll(function (){
            if(ld('.main_grid_box').scrollTop() > 0){
                //BUG0068275 txy 2023.06.18 固定表头加滚动时表头加阴影
                if(ld('.main_grid_box .clear_float table tr').length>0){
                    ld('.main_grid_box .clear_float table tr').get(0).className = 'ld-setting-tabtop-shadow';
                }
            }else{
                if(ld('.main_grid_box .clear_float table tr').length>0) {
                    ld('.main_grid_box .clear_float table tr').eq(0).removeClass('ld-setting-tabtop-shadow');
                }
            }
        });
        //BUG0069796 txy 20230803 后台设置->参数设置->系统参数设置，将“设置计算已收金额时是否统计未审批通过的收款单”修改选项后，滚动条拉到最上方后，界面增加了空白行
        if(ld('.main_grid_box').length > 0){
            var totalheight = ld('.main_grid_box').get(0).clientHeight;
            var headerheight = ld('.D_Tab_div.tabHieght').outerHeight(true);
            ld('#system_div').css('height',totalheight-headerheight+'px');
            ld('#system_div').scroll(function (){
                if(ld('#system_div').scrollTop() > 0){
                    ld('.D_Tab_div table').eq(0).addClass('ld-setting-tabtop-shadow');
                }else{
                    ld('.D_Tab_div table').eq(0).removeClass('ld-setting-tabtop-shadow');
                }
            });
        }
        settingWindowResize();// 系统设置-修改内容高度、宽度
        window.addEventListener('resize', settingWindowResize, true);// 系统设置-监听窗口改变-修改内容高度、宽度
        // 2024-10-11 xxy 在进入后台设置渲染完tpl后可进行的js操作，例如声明类绑定事件等
        afterSettingRightContent(obj,data);
    });
    // console.log(ld(jqueryobj).attr('fieldid'));
    ldAjaxsyncNoProgress('index.php?module=Settings&action=SettingsAjax&file=settingsfieldfrequency&field='+ld(jqueryobj).attr('fieldid'),'',function(data){
        
    });
}

// 系统设置-监听窗口改变-修改内容高度、宽度
function settingWindowResize(){
    // 获取滚动内容高度
    var windowHeight = ld(window).height();
    var headHeight = ld('#pagehead').height();
    var marginHeight = parseInt(ld('#SettingRightContent').css('margin-top').replace('px', ''));//获取上边距
    var rightHeadHeight = 0;
    if (ld('.main_grid_top').length > 0) {
        rightHeadHeight = ld('.main_grid_top').height();
    }
    var rightSetHeight = 0;
    if (ld('.main_grid_set').length > 0) {
        rightSetHeight = ld('.main_grid_set').height();
    }
    var contentHeight = windowHeight-headHeight-marginHeight-rightHeadHeight-rightSetHeight;
    // 计算main_grid_box高度
    if (ld('.main_grid_box').length > 0) {
        ld('.main_grid_box').css('height', contentHeight+'px');
    }
    // 后台设置,工商查询,去掉设置高度
    if (ld('.main_grid_box #showpagecontentheader').length > 0) {
        var businessinformationlistheaderHeight = ld('.main_grid_box #businessinformationlistheader').outerHeight();
        var showpagecontentheaderHeight = ld('.main_grid_box #showpagecontentheader').outerHeight();
        contentHeight = contentHeight-businessinformationlistheaderHeight-showpagecontentheaderHeight; 
    }

    // 计算固定列和表头整体高度
    if (ld('#SettingRightContent').find('.ld-table-container').length > 0) {
        var rightWidth = ld('#pagecontent').width();
        var marginLeftWidth = parseInt(ld('#SettingRightContent').css('margin-left').replace('px', ''));//获取左边距
        var marginRightWidth = parseInt(ld('#SettingRightContent').css('margin-right').replace('px', ''));//获取左边距
        var contentWidth = rightWidth-marginLeftWidth-marginRightWidth;
        var containerObj = ld('#SettingRightContent').find('.ld-table-container');
        var options = {'height':contentHeight,'width':contentWidth,'thwidth':145};
        lockingHeaderColumn(containerObj, options);
    }
}

//单据分录定制拖动排序
function ListFieldDragSort(){//230704 wyt XUQIU1001563 PC端-单据分录定制-排序风格优化
    ld('[name=SettingRightContent] table.ld-table-container-draggable tbody tr').hover(function() {
        ld(this).find('.ld-dragicon').show();
    },
    function () {
        ld(this).find('.ld-dragicon').hide();
    });
    var dragobj=ld(" [name=SettingRightContent]").find('table.ld-table-container-draggable tbody');
    var cur_module='';
    var fieldid='';
    ld.each(dragobj,function(index,obj){
        Sortable.create(obj, {
            // group: 'stuff',
            //animation: 150,
            draggable:".ld-category-draggable",
            handle:".drag-handle",
            sort:true,
            onEnd: function (evt){
                var sortfield_arr='';
                ld('[name=SettingRightContent] table.ld-table-container-draggable.fir-center tr').attr('onmouseover','');
                ld('[name=SettingRightContent] table.ld-table-container-draggable.fir-center tr').attr('onmouseout','');
                ld('[name=SettingRightContent] table.ld-table-container-draggable.fir-center tr').removeClass('lvtColData');
                ld('[name=SettingRightContent] table.ld-table-container-draggable.fir-center tr').removeClass('lvtColDataBj');
                ld('[name=SettingRightContent] table.ld-table-container-draggable.fir-center tr').removeClass('lvtColDataHover');
                ld.each(ld('[name=SettingRightContent] table.ld-table-container-draggable.fir-center tr'),function(index,tmpobj){
                    if(index>0){
                        if(index%2==0){
                            ld(tmpobj).addClass('lvtColDataBj');
                            ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                            ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"On")');
                            ld(tmpobj.childNodes[0]).html(index);
                            cur_module=ld(tmpobj).attr('cur_module');
                            fieldid=ld(tmpobj).attr('tag');
                            sortfield_arr+=fieldid+";";

                        }else{
                            ld(tmpobj).addClass('lvtColData');
                            ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                            ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                            ld(tmpobj.childNodes[0]).html(index);
                            cur_module=ld(tmpobj).attr('cur_module');
                            fieldid=ld(tmpobj).attr('tag');
                            sortfield_arr+=fieldid+";";
                        }
                    }
                });

                var selectsourcetype = '';
                var selecttypeobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=selecttype]");
                if(selecttypeobj.length>0&&selecttypeobj!=undefined){
                    selectsourcetype = ld(selecttypeobj).find("option:selected").val();
                }
                if(sortfield_arr !=''){
                    var update_url="index.php?module=Settings&action=SettingsAjax&file=ProductToolField&submode=UpdateFieldSort&tabid="+cur_module+"&parenttab=Settings&ajax=true&selectedFieldStr="+sortfield_arr+"&selectsourcetype="+selectsourcetype;
                    ldAjax(update_url,'',function(data){
                        if(data.code==1){

                            DelProgressObjs();
                        }
                    })
                }
            }
        })
    });
}

//zxm 20220909 设置冻结前几列
function selectSetStickyNums(obj){
    var value = ld(obj).val();
    var selectTabid = ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=select]").val();
    ld.ajax({
        url:"index.php?module=Settings&file=ProductToolField&action=SettingsAjax&ajax=yes&selectTabid="+selectTabid+'&detail_issticky='+value+'&setdetail_issticky=yes',
        dataType:"json",
        timeout:20000,
        type:"post",
        success:function(data){

        }
    });
}

//网页端菜单定制拖动排序
function MenuListDragSort(){
    ld('div[name=menulistcontent] table.settingTable.fir-center tr').hover(function() {
        ld('.ld-dragicon').hide();
        ld(this).find('.ld-dragicon').show();
    });

    var dragobj=ld('div[name=menulistcontent]').find('table tbody');
    var parenttabid='';

    ld.each(dragobj,function(index,obj){
        Sortable.create(obj, {
            // group: 'stuff',
            // animation: 150,
            draggable:".ld-category-draggable",
            handle:".drag-handle",
            sort:true,
            onEnd: function(evt){
                var sortparenttab='';
                ld('div[name=menulistcontent] table.settingTable.fir-center tr').attr('onmouseover','');
                ld('div[name=menulistcontent] table.settingTable.fir-center tr').attr('onmouseout','');
                ld('div[name=menulistcontent] table.settingTable.fir-center tr').removeClass('lvtColData');
                ld('div[name=menulistcontent] table.settingTable.fir-center tr').removeClass('lvtColDataBj');
                ld('div[name=menulistcontent] table.settingTable.fir-center tr').removeClass('lvtColDataHover');
                ld.each(ld('div[name=menulistcontent] table.settingTable.fir-center tr'),function(index,tmpobj){
                    if(index>0){
                        if(index%2==0){
                            ld(tmpobj).addClass('lvtColDataBj');
                            ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                            ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"On")');
                            ld(tmpobj.childNodes[1]).html(index);
                            parenttabid=ld(tmpobj).attr('tag');
                            sortparenttab+=parenttabid+",";


                        }else{
                            ld(tmpobj).addClass('lvtColData');
                            ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                            ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                            ld(tmpobj.childNodes[1]).html(index);
                            parenttabid=ld(tmpobj).attr('tag');
                            sortparenttab+=parenttabid+",";
                        }
                    }
                });

                if(sortparenttab !=''){
                    var update_url='index.php?module=Settings&action=SettingsAjax&file=MenuList&type=saveSortMenu&ajax=yes&tabids='+sortparenttab;
                    ldAjax(update_url,'',function(data){
                        if(data.code==1){
                            DelProgressObjs();
                            // window.location.reload();//刷新当前页
                        }
                    })
                }
            }
        })
    });
}

//移动端功能菜单定制拖动排序
function MobileListDragSort() {

    ld('#cfList table.settingTable.fir-center tr').hover(function () {
        ld('.ld-dragicon').hide();
        ld(this).find('.ld-dragicon').show();
    });

    var dragobj = ld('#cfList').find('table tbody');
    var blockid = '';

    ld.each(dragobj, function (index, obj) {
        Sortable.create(obj, {
            // group: 'stuff',
            // animation: 150,
            draggable: ".ld-category-draggable",
            handle: ".drag-handle",
            sort: true,
            onEnd: function (evt) {
                var sortblockid = '';
                ld('#cfList table.settingTable.fir-center tr').attr('onmouseover', '');
                ld('#cfList table.settingTable.fir-center tr').attr('onmouseout', '');
                ld('#cfList table.settingTable.fir-center tr').removeClass('lvtColData');
                ld('#cfList table.settingTable.fir-center tr').removeClass('lvtColDataBj');
                ld('#cfList table.settingTable.fir-center tr').removeClass('lvtColDataHover');
                ld.each(ld('#cfList table.settingTable.fir-center tr'), function (index, tmpobj) {
                    if (index > 0) {
                        if (index % 2 == 0) {
                            ld(tmpobj).addClass('lvtColDataBj');
                            ld(tmpobj).attr('onmouseover', 'listOnMouseOver(ld(this))');
                            ld(tmpobj).attr('onmouseout', 'listOnMouseOut(ld(this),"On")');
                            ld(tmpobj.childNodes[0]).html(index);
                            blockid = ld(tmpobj).attr('tag');
                            sortblockid += blockid + ",";


                        } else {
                            ld(tmpobj).addClass('lvtColData');
                            ld(tmpobj).attr('onmouseover', 'listOnMouseOver(ld(this))');
                            ld(tmpobj).attr('onmouseout', 'listOnMouseOut(ld(this),"on")');
                            ld(tmpobj.childNodes[0]).html(index);
                            blockid = ld(tmpobj).attr('tag');
                            sortblockid += blockid + ",";
                        }
                    }
                });

                if (sortblockid != '') {
                    var setting_position = ld('#setting_position').val();
                    if (setting_position === 'report') {
                        var update_url = 'index.php?module=Settings&action=SettingsAjax&file=mobileReportListOpertion&type=SaveMobileBlockSort&ajax=true&tabids=' + sortblockid;
                    } else {
                        var update_url = 'index.php?module=Settings&action=SettingsAjax&file=MobileList&type=SaveMobileBlockSort&ajax=true&tabids=' + sortblockid;
                    }
                    update_url = update_url.slice(0, -1);
                    ldAjaxHtml(update_url, '', function () {

                        DelProgressObjs();
                        // window.location.reload();//刷新当前页
                    })
                }
            }
        })
    });
}

//wsh 2024-07-03 XUQIU20240607-08 单据查看详情界面，相关信息操作日志，“编辑”操作详情增加“修改日志详情”操作按钮
function get_edit_detail_logs(obj)
{
    getJsScript('include/js/DetailViewTab.js',function (){
        get_edit_detail_log(obj)
    })
}
// wsh 20240807 XUQIU20240725-02 服务小程序登录页设置--增加首页横幅图片设置
function show_banner_img(obj){
    var file = ld(obj).get(0).files[0];
    if (file.type.startsWith('image/')){
        var url = window.URL.createObjectURL(file);
        var img_obj = ld("#setting_image").find("[name=banner_img_url]");
        img_obj.attr("src",url);
    }else {
        RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['CHOOSEIMAGECORRECTLY']);
    }

}

//BUG20240805-57  	后台设置->系统参数设置，“设置序时簿列表界面批量操作记录条数的上限”为空时，消息列表全选并批量已读时，单据列表没有反应 ---控制参数不能为空
function systemSetBlur(obj){
    var name = ld(obj).attr('name');
    var value = ld(obj).val();
    // 	后台设置->系统参数设置，“设置序时簿列表界面批量操作记录条数的上限”参数中输入后，应该在用户点击右上角的“保存”按钮后，判断用户输入的是否为整数形式（往输入框中输入内容的同时点击右上角的保存，文字会被保存进去）
    if (!Number.isInteger(value)){
        value = value.replace(/[^\d]/g,'');
        if (!empty(value)){
            ld(obj).val(value);
        }
    }
    if(empty(value)){
        switch (name){
            case '13':
                value = 1;
                break;
            case '14':
                value = 20;
                break;
            case '67':
                value = 500;
            default:
                // 敏感规则部分加密 只能是数字
                value = 1;

        }
        ld(obj).val(value);
    }
    event.stopPropagation();//阻止事件冒泡到父元素
}

//edit:duan date:2024/11/15 reason:翻译字段设置
function TranslatedFieldSet(frommodule,columnname) {
    var url = 'index.php?module=Settings&action=SettingsAjax&file=TranslatedFieldSet';
    var param = {};
    param['frommodule'] = frommodule;//后续可以改成动态读取模块，现在按所有模块通用做
    param['columnname'] = columnname;
    param['mode'] = 'edit';
    ldAjaxNoProgress(url,param,function(data) {
        if(data.code == 1){
            var CrmPopupobj=ComboxPopup.load('','',"",'LdPopWidth600px','Settings','',data.result.oktext,"",data.result.canceltext);
            CrmPopupobj.setParams(data.result.title,TranslatedFieldSetSave,"",'LdPopWidth600px','Settings',[CrmPopupobj,frommodule,columnname,'no'],data.result.oktext,"",data.result.canceltext);
            CrmPopupobj.show(data.result.content);

            // 需要去掉的给高度
            CrmPopupobj.reduceBodyHeight = 59;
            // 设置内容最大高度
            CrmPopupobj.setPopBodyMaxHeight(".divPopOverflow");

            ld('#'+CrmPopupobj.divid+' #translateset_clearbtn').on('click',function(){
                var show_label_zhobjs = ld('#'+CrmPopupobj.divid+' [name=show_label_zh]');
                if(show_label_zhobjs.length >0 ){
                    ld.each(show_label_zhobjs,function (tmp_index,tmp_boj){
                        ld(tmp_boj).val(ld(tmp_boj).data('origin_label'));
                    })
                }
                /* 英文的先注释
                var show_label_enobjs = ld('#'+CrmPopupobj.divid+' [name=show_label_en]');
                if(show_label_enobjs.length >0 ){
                    ld.each(show_label_enobjs,function (tmp_index,tmp_boj){
                        ld(tmp_boj).val(tmp_boj.data('origin_label'));
                    })
                }*/
                var value_color_objs = ld('#'+CrmPopupobj.divid+' [name=value_color]');
                if(value_color_objs.length >0 ){
                    value_color_objs.data('choosecolor','').css('background','');
                }
            })
        }else{
            MessagePopup.TipTwo_warning(data.msg);
        }
    });
}
//审批状态设置保存
function TranslatedFieldSetSave(popupobj,frommodule,columnname,confirm_click) {
    var confirm_str = '';
    if(confirm_click == 'no' && frommodule == 'lingdang' && columnname == 'approvestatus'){
        confirm_str = arrJsPopLabel['APPLIEDALLAPPROVAL'];
        MessagePopup.TipTwo_warning(confirm_str);
        var remindpopup = CrmPopup.getPopupObj('last');
        ld('#'+remindpopup.divid+'_btnok').bind('click',function () {
            TranslatedFieldSetSave(popupobj,frommodule,columnname,'yes')
        })
        return false;
    }
    var tableobj = ld('#'+popupobj.divid+' [name=translateset_table]');
    var trobjs = tableobj.find('tr[name=translateset_tr]');
    var translateset_info = new Array();
    ld.each(trobjs,function (tmp_index,tmp_trboj) {
        var jq_trboj = ld(tmp_trboj);
        var labelbol = jq_trboj.data('labelbol');
        var dbvalue = jq_trboj.data('dbvalue');
        var show_label_zh = jq_trboj.find('[name=show_label_zh]').val();
        var show_label_enobj = jq_trboj.find('[name=show_label_en]');
        //保留以后传英语的内容
        if(show_label_enobj.length>0){
            var show_label_en = show_label_enobj.val();
        }else{
            var show_label_en = show_label_zh;
        }
        var value_color = jq_trboj.find('[name=value_color]').data('choosecolor');

        var tmp_arr = {
            'labelbol': labelbol,
            'dbvalue': dbvalue,
            'show_label_zh': show_label_zh,
            'show_label_en': show_label_en,
            'value_color': value_color
        };
        translateset_info.push(tmp_arr);
    })

    var url = 'index.php?module=Settings&action=SettingsAjax&file=TranslatedFieldSet';
    var param = {};
    param['frommodule'] = frommodule;
    param['mode'] = 'save';
    param['columnname'] = columnname;
    param['translateset_info'] = translateset_info;
    ldAjaxNoProgress(url,param,function(data) {
        if(data.code == 1){
            confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
            popupobj.CancelEvent();
            MessagePopup.TipZero_success(confirm_str);
        }else{
            MessagePopup.TipTwo_warning(data.msg);
        }
    });


}

function afterSettingRightContent(popupobj,data){
    if(!empty(popupobj)){
        popupobj.settingpopuptype = !empty(data.result.popuptype)?data.result.popuptype:'';
        if(popupobj.settingpopuptype == "ButtonsCustomization"){
            var buttoncustomizationObj = new ButtonsCustomization();
            buttoncustomizationObj.setPopupobj(popupobj);
            buttoncustomizationObj.setListEvent();
            buttoncustomizationObj.listdata_arr = data.result.listdata_arr;
        }
	}
}
//设置颜色公共方法，需要有data-choosecolor属性
function CommonChooseColor(jsobj){
    var jqobj = ld(jsobj);
    var pick_color = jqobj.data('choosecolor');
    var css_type = pick_color==''||pick_color==undefined?'#F3F3FC':pick_color;
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth400px",'Settings',"","","","");
    crmPopupobj.prevshow();
    var url='index.php?module=PickList&action=PickListAjax&file=PickListActions&mode=gethtml';
    var dataurl='selectedcolor='+css_type;
    ldAjaxNoProgress(url,dataurl,function (data){
        if (data.code == 1){
            crmPopupobj.setParams(data.result.title,'',"","LdPopWidth400px",'Settings',"",'',"",'');
            crmPopupobj.show(data.result.content);
            var divid=crmPopupobj.divid;
            //加载自定义
            getCommonColPick(jqobj);
            //页签点击事件
            ld("#"+divid+" #changetab").find('[name=tag]').unbind('click').bind('click',function () {
                //隐藏之前选中的页签
                var selected=ld("#"+divid+" #changetab").find('.ld-change-tab-active');
                ld('#'+divid+' #'+selected.attr('tag')).hide();
                selected.removeClass('ld-change-tab-active');
                //显示选中页签
                var tag=ld(this).attr('tag');
                ld(this).addClass('ld-change-tab-active');
                ld('#'+divid+' #'+tag).show();
            });
            //浅色亮色色块点击事件
            var color=ld('#'+divid+' #preset').find('[name=presetcolor_li]');
            ld(color).unbind('click').bind('click',function () {
                var selectedcolor=ld(this).find('[name=presetcolor]').attr('color');
                crmPopupobj.CancelEvent();
                jqobj.data('choosecolor',selectedcolor)
                jqobj.css('background',selectedcolor);
            })
        }
    });
}
function getCommonColPick(jqobj) {
    var pick_color = jqobj.css('background-color');
    pick_color = getCommonColorInHex(pick_color);
    var css_type = pick_color==''||pick_color==undefined?'#F3F3FC':pick_color;
    getJsScript('include/js/colpick/colpick.js',function(){
        getJsScript('include/js/colpick/plugin.js',function(){
            var divid = popupobj.divid;
            CrmPopup.findHtmlobj(divid,'picker').colpick({
                color:css_type,
                flat:true,
                layout:'RGB',
                submitText:'确认',
                onSubmit:function(hsb,hex,rgb,el){//ok之后的确认事件
                    var _color = '#'+hex;
                    jqobj.data('choosecolor',_color)
                    jqobj.css('background',_color);
                    popupobj.CancelEvent();
                }

            });
            popupobj.center();
        });
    });
}

function getCommonColorInHex(color) {
    if (!color) {
        return null;
    }
    // 如果已经是十六进制格式，‌则直接返回
    if (color.startsWith('#')) {
        return color;
    }
    // 移除可能的空格和"rgb()"或"rgba()"字符串
    color = color.match(/\d+/g);
    if (!color || color.length !== 3 && color.length !== 4) {
        return null; // 无效的颜色格式
    }

    // 转换RGB或RGBA为十六进制
    var hex = '#';
    for (var i = 0; i < 3; i++) {
        var intVal = parseInt(color[i], 10);
        if (isNaN(intVal)) {
            return null; // 无效的颜色分量
        }
        hex += intVal.toString(16).padStart(2, '0');
    }

    return hex;
}