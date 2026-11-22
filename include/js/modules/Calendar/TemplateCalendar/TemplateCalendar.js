/* creator:gyq_13 explain:日程模板处理类 date:20160630 */

var TemplateCalendar = (function () {

    function entrance() {
        this.contentRows = ld('#CalendarDetailContent tr[mark="content_rows"]');
        this.popDivId = 'pop_calendar_templates';
        this.module;
    }

    /* 设置显示列字段按钮*/
    entrance.prototype.switchModule = function(customField,blockidsetting)
    {
        var moduleid = customField.options[customField.options.selectedIndex].value;
        new Ajax.Request(
            'index.php',
            {
                queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody: 'module=Settings&action=SettingsAjax&file=CalendarTemplate&template_showtype=listview&blockid='+moduleid+'&parenttab=Settings&ajax=true&blockidsetting='+blockidsetting,
                onComplete: function(response) {
                    $("cfList").innerHTML=response.responseText;
                    approvalProcessMovetable();	//weiyannan 20231127 在切换模块后还能正常拖拽
                }
            }
        );
    }
    /* 保存模板 */
    entrance.prototype.saveTemplate = function(){
        if(ScopePopup_Details.getInstance().validate('EditCalendarTemplate') &&  entrance.prototype.save_calendardetail() &&  entrance.prototype.jointConditions()){
			var popupobj=CrmPopup.getPopupObj("last");
			var data = new FormData(ld(".ajax_form")[0]);
			var blockid = ld("#"+popupobj.divid+" [name=blockid]").val();
			var record = ld("#"+popupobj.divid+" [name=record]").val();
			var surl = "";
			ld('#rptContentLoading').show();
			ld.ajax({
				type: 'POST',
				dataType: 'json',
				processData: false, // 告诉jquery不要处理数据
				contentType: false, // 告诉jquery不要设置contentType
				data: data,
				url: 'index.php?module=Settings&action=SettingsAjax&file=CalendarTemplate&template_showtype=save_template',
				success: function(json, textStatus, xhr) {
					popupobj.CancelEvent();
					ld('#rptContentLoading').hide();
					entrance.prototype.refresh();
				},
				error: function(xhr, textStatus, errorThrown) {
					//alert(2);
				}
			  })
        }
    };
    /* 保存模板明细 */
    entrance.prototype.save_calendardetail = function(obj){
        var header = ld('#template_detailheader').val();
        var header_arr = JSON.parse(header)?JSON.parse(header):eval('('+ header +')');
        var multi_jsonstr="[";
        var remindmistake = 'enter';
        ld('#CalendarDetailContent tr[mark="content_rows"]').each(function(i){
            var display = ld(this).css('display');
            if(display != 'none') {
                var json_str = '{';
                //editor:gyqX161020 reason:header_arr键异常，不是依次加一的自然数
                var nanum = 0;
                var date_start = '';
                for (var j in header_arr) {
                    var k = parseInt('1') + parseInt(nanum);
                    var he = header_arr[j]['uitype'];
                    var typeofdata = header_arr[j]['typeofdata'];
                    var fldname = header_arr[j]['fldname'];
                    var trueval = '';
                    if (he == 2 || he == 19 || he == 86) {
                        trueval = ld(this).find('td').eq(k).find('input').val();
                        //editor:gyqX161020 Bug:0023975: 日程模板：客户、联系人、销售机会查看界面：关联创建日程管理弹出层中 当起始日期大于截止日期时应该给出提示信息
                        if(he == 86 && fldname == 'date_start'){
                            date_start = trueval;
                        }else if(he == 86 && fldname == 'due_date'){
                            //$temp = trueval - date_start;
                        
                            if(parseInt(trueval) < parseInt(date_start)){ //字符串2是比字符串12大的，得转int类型去比较
                                remindmistake = 'empty';
                                var confirm_str = arrJsPopLabel['TEMPLATEREMINDSFORDUEDATELTDATASTART'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                return false;
                            }
                        }
                    } else if (he == 53 || he == 153 || he == 15) {
                    
                        trueval = CrmPopup.findHtmlobj('CalendarDetailContent',fldname+'_' + i).val();
                       
                    }
                    if(typeofdata == 'M' &&　(trueval== '' )){
                        if(remindmistake == 'enter'){
                            remindmistake = 'empty';
                        }
                        var confirm_str = arrJsPopLabel['TEMPLATE']+header_arr[j]['fldlabel']+arrJsPopLabel['CANOTEMPTY'];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        return false;
                    }
                    json_str += "\"" + header_arr[j]['fldname'] + "\"" + ":" + "\"" + trueval + "\",";
                    nanum++;
                }
                json_str = json_str.substring(0, json_str.lastIndexOf(','));
                json_str += '}';
                multi_jsonstr += json_str + ',';
            }
        });

        if(multi_jsonstr.length > 5){
            multi_jsonstr = multi_jsonstr.substring(0,multi_jsonstr.lastIndexOf(','));
            multi_jsonstr += ']';
        }else{
            multi_jsonstr = '';
        }
        ld('#template_calendardetail').val(multi_jsonstr);
        
        if(remindmistake == 'empty'){
            return false;
        }else{
            return true;
        }
    }
    /* 保存条件判断明细 */
    entrance.prototype.jointConditions = function(){
		var popupobj=CrmPopup.getPopupObj("last");
		if(popupobj.advanceFilterObj.checkAdvancedFilter()==false)
		{
				return false;
		}
		var advft_criteria=popupobj.advanceFilterObj.advft_criteria;
		var advft_criteria_groups=popupobj.advanceFilterObj.advft_criteria_groups;
		 ld('#template_judgeinfo').val(advft_criteria);
        ld('#template_judgeinfo_groups').val(advft_criteria_groups);
        /*for(i=1;i<=26;i++)
        {
            var data_td_id = 'alpha_'+ eval(i);
            if(getObj(data_td_id)!=null){
                getObj(data_td_id).className = 'searchAlph';
            }
        }
        gPopupAlphaSearchUrl = '';
        if(document.getElementById("SmOwnerSearchScope")!=null)
            var searchScope= encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
        else
            searchScope='';
        var urlstring = '';
        var checkresult = checkAdvancedFilter();
		var popupobj=CrmPopup.getPopupObj("last");
		var advft_criteria=CrmPopup.getHtmlobjval(popupobj.divid,"advft_criteria");
		alert(advft_criteria);
		return false;
         var advft_criteria_groups=CrmPopup.getHtmlobjval(popupobj.divid,"advft_criteria_groups");
        var advft_criteria = $('advft_criteria').value;
        var advft_criteria_groups = $('advft_criteria_groups').value;
        ld('#template_judgeinfo').val(advft_criteria);
        ld('#template_judgeinfo_groups').val(advft_criteria_groups);
        return checkresult;*/
		return true;
    };
    /* 模板明细界面新日程 */
    entrance.prototype.addNewCalendarDetail = function(address){
        var jself = this;
        var length = ld('#CalendarDetailContent tr[mark="content_rows"]').length;
        ld.post("index.php",{template_showtype : "newdetailrow" ,address:address,rownumber:length,module:"Calendar",file:"CalendarTemplate",'action':"CalendarAjax"},function(response) {
           ld('#bottom_calendar_row').before(response);
            inputAddSubNumberBox.getInstance().init(ld('#CalendarDetailContent div[mark="numberbox"]'));
            jself.contentRows = ld('#CalendarDetailContent tr[mark="content_rows"]');
            ld('#CalendarDetailContent tr[mark="content_rows"]:first td:first').find('img').show();
        });
    }
    /* 删除日程 */
    entrance.prototype.hideDeailRow = function(obj){
        var rows = ld('#CalendarDetailContent tr[mark="content_rows"]').length;
        if(rows > 1){
            var parent = ld(obj).parent().parent();
            parent.hide().attr('mark',"content_rows_hidden");
            if(rows == 2){
                ld('#CalendarDetailContent tr[mark="content_rows"]:first td:first').find('img').hide();
            }
        }else{
            ld('#CalendarDetailContent tr[mark="content_rows"]:first td:first').find('img').hide();
        }
    }
    /* 单据关联创建日程 P1*/
    entrance.prototype.createCalendars = function(orignhref){
        var jself = this;
        //30542: 客户明细界面：关联创建日程管理，结果弹出层中下拉框无法点击选择
       
        ld.post("index.php",{template_showtype : "create_calendars" ,quicktag:orignhref,module:"Calendar",file:"CalendarTemplate",'action':"CalendarAjax"},function(response) {
            if(response.indexOf('$==$EmptyTemplate$==$') > -1){
                //31862: 系统设置 > 日程模板定制 -新增一个日程模板，进入满足条件的客户明细界面关联新增日程管理，结果打开的弹出层不正确
                 var objparams=new CreatePagePopup.params();
                  objparams.params['refreshpage']='no';
                 CreatePagePopup.showpage("Calendar",orignhref,objparams);
            }else if(response.indexOf('$==$AutoExecEmpty$==$') > -1){
                return false;
            }else{
                  var obj=new Object();
                 obj.divid=jself.popDivId;
                 obj.type="createCalendars";
                 CrmPopup.global_listPopupObj.push(obj);
                createElementDiv(jself.popDivId);
                ld('#' + jself.popDivId).attr('class','D_pop_box LdPopWidth950px');
                ld('#' + jself.popDivId).html(response);
                //jself.DetailWidth_Correct();
                jself.hideDeailRow();
                fnvshobj('', jself.popDivId);
            }
        });
    }
    entrance.prototype.DetailWidth_Correct = function(){
        ld('#' + jself.popDivId).find('div[class="chzn-container chzn-container-single"]').css('width','125px');
        ld('#' + jself.popDivId).find('a[class="chzn-single"]').css('width','120px');
        ld('#' + jself.popDivId).find('div[class="chzn-drop"]').css('width','125x');
        ld('#' + jself.popDivId).find('input[class="search_bg"]').css('width','120x');
    }
    /* 初始化弹框按钮 P1_1*/
    entrance.prototype.init_PopSurfaceButtons = function(){
        var jself = this;
        ld('#'+jself.popDivId).find('*[mark="close"]').click(function(){
            fninvshnew(jself.popDivId);
        });
        ld('#'+jself.popDivId).find('*[mark="confirm"]').click(function(){
            var details = '';
            if(jself.save_calendardetail()) {
                details = ld('#template_calendardetail').val();
                var currentuser_id = ld('#currentuser_id').val();
                var record = ld('#related_calendar_form').find('input[name="currentrecord"]').val();
                var subject = ld('input[name="subject"]').val();
                curr_time=new Date();
                cur_mon = curr_time.getMonth()+1;
                curr_time1=curr_time.getFullYear()+'-'+getDigital(cur_mon)+'-'+getDigital(curr_time.getDate())+' '+getDigital(curr_time.getHours())+':'+getDigital(curr_time.getMinutes())+':'+getDigital(curr_time.getSeconds());
                //curr_time2=curr_time.getFullYear()+'-'+getDigital(cur_mon2)+'-'+getDigital(curr_time.getDate())+' '+getDigital(curr_time.getHours())+':'+getDigital(curr_time.getMinutes())+':'+getDigital(curr_time.getSeconds()+10);
              
                ld.post("index.php", {
                    template_showtype: "create_calendars_confirm",
                    multi_details: details,
                    currenturldate:record,
                    module: "Calendar",
                    file: "CalendarTemplate",
                    'action': "CalendarAjax",
                    set_remind:'Yes',
                    pop_reminds:'Yes',
                    email_remind:curr_time1,
                    date_time:curr_time1,
                    assigned_user_id:currentuser_id,
                    subject:subject,
                }, function (response) {
                   
                    CrmPopup.global_listPopupObj.pop();
                    fninvshnew(jself.popDivId);
                    var tmparra=[];
                     var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,getEmptyValueInfo(),tmparra);
                        
                       tmparra.push(popupobj.module);
                      tmpobj.eachrefreshlistbyModules(tmparra);
                       
                       
                    
                });
            }
        });
    }
    entrance.prototype.changestatusTemplate = function(record,tabid,checked_status,blockid,blockidsetting)
    {
        if(checked_status){
            var status = 'open';
        }else{
            var status = 'close';
        }
        ld.post("index.php",{template_showtype : "listview",changestatus:"yes",status:status,ajax:true,record:record,blockid:blockid,blockidsetting:blockidsetting,module:"Calendar",file:"CalendarTemplate",'action':"CalendarAjax"},function(response) {
           
                ld('#cfList').html(response);
  
        });
    }

    /* 新增模板 */
    entrance.prototype.addNewCalendar = function(tabid,record)
    {
		if(tabid <= 0){
			tabid = ld('#pick_module').val()
		}
		var surl = "index.php?module=Settings&parenttab=Settings&action=SettingsAjax&file=CalendarTemplate&template_showtype=edit_template&blockid="+tabid;
		if(record > 0){
			surl += '&mode=edit&record='+record;
		}
		var popupobj=CrmPopup.getPopupObj("last");
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,entrance.prototype.saveTemplate,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext); 
				crmPopupobj.createScrollDiv();//创建滚动条
				crmPopupobj.show(data.result.content);
                crmPopupobj.fields = data.result.fields;
				ScopePopup_Details.getInstance().allocateTemplate(this,data.result.approve[0].tabid,data.result.approve[0].templateid,data.result.approveallocateid,data.result.approve[0].allocatetype,'CalendarTemplate');
				inputAddSubNumberBox.getInstance().init(ld('#CalendarDetailContent div[mark="numberbox"]'));

                crmPopupobj.showvalues=data.result.showvalues;
                crmPopupobj.datetimestr=data.result.datetimestr;//基本查询
                crmPopupobj.viewnamelabel=data.result.viewnamelabel;
                crmPopupobj.modulelabel=data.result.modulelabel;

                var advanceFilterObj = new cls_advanceFilter();
                var params = {};
                params.columnOptionHtml = data.result.columns_block;
                params.fLabels = data.result.flabels;
                params.datetimestr = data.result.datetimestr;
                params.advfilterhtml = data.result.foption;
                params.fieldsinfo = data.result.fields;
                params.criteria_groups_arr = data.result.criteria_groups;
                params.module = 'Settings';
                // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
                params.advanceFields = data.result.advanceFields;
                advanceFilterObj.showAdvanceFilter(crmPopupobj,params);

				// 设置内容最大高度
                crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
				crmPopupobj.center();
					
			}
		})
    }
    entrance.prototype.cancel = function(blockid,blockidsetting)
    {
        document.location.href="index.php?module=Settings&parenttab=Settings&action=CalendarTemplate&template_showtype=listview&blockid="+blockid+"&blockidsetting="+blockidsetting;
    }
    entrance.prototype.editTemplate = function(record,tabid,blockidsetting)
    {
        document.location.href="index.php?module=Settings&action=CalendarTemplate&template_showtype=edit_template&mode=edit&parenttab=Settings&record="+record+"&blockid="+tabid+"&blockidsetting="+blockidsetting;
    }
    entrance.prototype.deleteTemplate = function(record,tabid,blockidsetting)
    {
        var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        //点击确认
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
           var surl = "index.php?module=Settings&action=SettingsAjax&file=CalendarTemplate&template_showtype=delete_template&parenttab=Settings&record="+record+"&blockid="+tabid+"&blockidsetting="+blockidsetting;
		   ldAjax(surl,"",function(data){
				if(data.code == 1){
					entrance.prototype.refresh();
				}
                DelProgressObjs();
		   })
        });
        return false;       
    }
    entrance.prototype.popSet_Templates = function(tabid,blockidsetting,fieldidsetting)
    {
        var addurl=encodeURIComponent("&blockid="+tabid);
        
        window.open("index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=ModuleManager&pageto_menufile=CalendarTemplate&addurl="+addurl);
    }
	entrance.prototype.refresh = function(){
		var tabid = ld('#pick_module').val();
		var surl = 'index.php?module=Settings&action=CalendarTemplate&parenttab=Settings&template_showtype=listview&ReportHeader=dheader&blockid='+tabid;
		ldAjax(surl,"",function(data){
			if(data.code==1){
				ld(' [name=SettingRightContent]').html(data.result.content);
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
			}
            DelProgressObjs();
		})
	}



    var instance;
    var _static = {
        getInstance: function () {
            if (instance === undefined) {
                instance = new entrance();
            }
            return instance;
        }
    };
    return _static;

})();



