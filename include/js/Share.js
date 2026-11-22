//Creator:gyq_66 Reason:共享 Date:2018/5/7 0003 下午 2:05
//Editor:gyq_66 Reason：共享代码优化，增加代码注释 Date:2018/5/16 0003 下午 2:05
var Share = (function () {

    function entrance() {
        this.module;
        this.viewposition;//区分当前操作处于明细界面还是序时簿界面
        this.excluded_records;//序时簿全选，不包含的单据
    }
    //判断序时簿批量操作是否超出上限
    entrance.prototype.getPopup = function(module,id)
    {
        var thisobj = this;
        //序时簿
        if(empty(id)){
            this.viewposition = 'listview';
            List_CheckBox_Ids.getIds(module);
            var rows_num = List_CheckBox_Ids.num_rows;
            //判断至少选择一条单据
            //zkt 20230209  BUG0060493表单推广，新建单据，分享设置界面，选择共享给其他人操作按钮时，提示请至少选择一条记录！ 20230228 BUG0061995kfbcrm 表单推广---不选择数据点击共享---没有弹出提示
            var popupobj=CrmPopup.getPopupObj("last");
            if(rows_num < 1 && !(popupobj.type != undefined && popupobj.type == CreatePagePopup.type && module == 'SocialPromotion')) {
                var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
                MessagePopup.TipOne_warning(confirm_str);
                return false;
            }

            var select_ids = List_CheckBox_Ids.ids;
            this.excluded_records = $('excludedRecords').value;
            //判断选择单据超过最大许可编辑数
            if(rows_num >parseInt(getMaxMassOperationLimit())){
                var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',rows_num,getMaxMassOperationLimit(),'');
                //创建提示弹出层
                RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);
                //确定事件
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    thisobj.setPopupContent(module,select_ids,rows_num);
                });
            }else{
                this.getSelectedUser(module,select_ids,rows_num);
            }
        }else{
            //明细界面
            this.viewposition = 'detailview';
            this.getSelectedUser(module,id,1);
        }
    }
    var that=this;
    entrance.prototype.showEditBtn=function(jqueryobj){
        var tdobj=ld(jqueryobj);
        while(tdobj.prop("tagName").toLowerCase()!='td')
        {
            tdobj=ld(tdobj).parent();
        }
        if(ld(tdobj).find("[showtype=editshow]").css("display")!='none')
           return ;
        var viewuserid=ld(tdobj).attr("viewuserid");
        var columnname=ld(tdobj).attr("columnname");
        var popupobj=CrmPopup.getPopupObj("last");



        if(columnname=='viewuserremark'||columnname=='viewuserduty')
        {

            ld(tdobj).find('a[tag=edit]').css("display",'');
            ld(tdobj).find('a[tag=edit]').unbind("click").bind("click",function(){
                //点击编辑按钮
                ld(this).css("display",'none');
                ld("#"+popupobj.divid+" [showtype=editshow]").css("display",'none');//隐藏所有已经显示编辑框和保存或取消按钮

                ld(tdobj).find("[name=td_content]").css("display",'none');

                ld(tdobj).find("[showtype=editshow]").css("display",'');
                ld(tdobj).find("[name="+columnname+"]").focus();
                ld('textarea').not('.proName_note').autosize();//修改文本域的高度

            })

            ld(tdobj).find('a[name=save]').unbind("click").bind("click",function(){

                //保存
                ld(tdobj).find("[name="+columnname+"]").css("display",'none');


                var editcontent= ld(tdobj).find('[name='+columnname+']').val();

                ldAjax("index.php?module=Users&action=UsersAjax&file=savesharecontent&content="+encodeURIComponent(editcontent),{'viewuserid':viewuserid,'columnname':columnname,'crmid':popupobj.detailpage_record},function(ajaxdata){

                    ld(tdobj).find("[showtype=editshow]").css("display",'none');
                    //ld(tdobj).find("[name=td_content]").html(editcontent.replace(new RegExp("\n","gm"),"<br>"));
                    ld(tdobj).find("[name=td_content]").html(editcontent);
                    ld(tdobj).find("[name=td_content]").css("display",'');
                    DelProgressObjs();
                })



            })

            ld(tdobj).find('a[name=cancel]').unbind("click").bind("click",function(){

                  //取消
                  ld(tdobj).find("[name=td_content]").css("display",'');

                  ld(tdobj).find("[showtype=editshow]").css("display",'none');
                 ld(tdobj).find("[name="+columnname+"]").css("display",'none');
                 ld(tdobj).find('a[tag=edit]').css("display",'none');


            })
        }

    }
     entrance.prototype.hideEditBtn=function(jqueryobj){
        var tdobj=ld(jqueryobj);
        while(tdobj.prop("tagName").toLowerCase()!='td')
        {
            tdobj=ld(tdobj).parent();
        }
        var columnname=ld(tdobj).attr("columnname");

        ld(tdobj).find('a[tag=edit]').css("display",'none');

    }
    //选择一条单据时，显示上次共享的人
    entrance.prototype.getSelectedUser = function(rModule,rIds,rRowNum){
        var userid = '';
        var permit = '';
        var thisobj = this;
        if(rRowNum==1){
            //var recordid = rIds.replace(';','');
            ldAjaxHtmlNoProgress("index.php",{mode : "tabshare" ,recordid:rIds,module:"Users",file:"setModuleShare",'action':"UsersAjax",'fieldname':"team_memberid"},function(response) {
                if(empty(response)) return false;
                var restobj = eval('('+ response +')')?eval('('+ response +')'):JSON.parse(response);
                userid = restobj.userid;
                thisobj.setPopupContent(rModule,rIds,rRowNum,userid);
            });
        }else{
            thisobj.setPopupContent(rModule,rIds,rRowNum,userid);
        }
    }
    //显示共享人选择界面
    entrance.prototype.setPopupContent = function(rModule,rIds,rRowNum,rUserid){
        var viewposition = this.viewposition;
        var excluded_records = this.excluded_records;
        var scopepopupobj;
        var thisobj = this;
        //自定义弹出层页面html，绑定事件
        getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
            var methodObj = {'popup_check_inactiveuser':'yes','popup_check_nogroupuser':'no','rRowNum':rRowNum};
            scopepopupobj =  new ScopePopupObj(methodObj);

            var popup_caption_value;
            var popup_url = '';
            var popupinfo = getAllocateSharePopupInfo('Share', rModule);
            popup_caption_value = popupinfo.poptitle;
            popup_url = popupinfo.popup_url;

			/* 赛可出行
			* edit: chj
			* date: 2020/8/11
			* reason: 工单流转时，调用的是分享事件
			*/
			if(rModule == 'Accounts' && version_account != undefined && version_account == 'saic'){
				scopepopupobj.popup_caption_value = '流转';//标题
			}else{
				scopepopupobj.popup_caption_value = popup_caption_value;//标题
			}

            //若选择的单据数超过一条，则显示额外按钮  CANCEL SHARE  REPLACE TYPE
            //wym 240104 BUG0070560 列表界面共享单据-字段不能通过点击文字勾选
            if(rRowNum > 1){
                scopepopupobj.header = '<div class="pad10" style="display: none; background: #FFF;">'+
                                    '<div class="ld-pop-contnet-title-items">'+
                                        '<div class="ld-pop-contnet-title-item">'+arrJsPopLabel['ShareSettings']+'</div>'+
                                    '</div>'+
                                '</div>';
                scopepopupobj.header += '<div style="padding:20px 24px;background: #FFF;border-bottom: 1px solid #ebedf0;">';
                scopepopupobj.header += '<div class="select-input"><label style="padding-left:0;">' + arrJsPopLabel['TYPE']+'：</label>'+
                    '<input type="radio" name="share_type" id="share_type_add" value="add" checked="checked"/><label for="share_type_add" class="padR10">'+arrJsPopLabel['SUPERADDTION']+'</label>' +
                    '<input type="radio" name="share_type" id="share_type_cover" value="cover"/><label for="share_type_cover" class="padR10">'+arrJsPopLabel['REPLACE']+'</label>' +
                    '<input type="radio" name="share_type" id="share_type_cancel" value="cancel_share"/><label for="share_type_cancel" class="padR10">'+arrJsPopLabel['CANCELSHARE']+'</label>';
                //弹框右上角友情帮助Tips
                if(document.getElementById('oem_crm') != undefined){
                    var oem_crm = document.getElementById('oem_crm').value;
                    if(oem_crm == 'no'){
                        scopepopupobj.header += '<a class="rfloat" href="javascript:;" style="margin-right: 15px;margin-top: -4px;" onclick="getLinksUrl(\'\',\'Share\',\'module_list_share\');">'+arrJsPopLabel['ONLINEHELP']+'</a>';
                    }
                }
                scopepopupobj.header += '</div>';
                scopepopupobj.header += '<div class="select-input" style="padding:12px 0;display: none;"><label style="padding-left:0;">'+arrJsPopLabel['EXPLAIN']+'：</label><label id="share_type_remind">'+arrJsPopLabel['SHARETYPEADD']+'</label></div>'
                scopepopupobj.header += '</div>';
            }else{
                //选择单条记录时，默认共享类型为覆盖
                scopepopupobj.header = '<input type="radio" name="share_type" value="cover" checked="checked" hidden/>';
            }
            //搜索框
            //zkt 增加子部门默认勾选框 0046576: （81mis.com/kfbcrm）客户管理-客户，在单据详情界面，选择客户单据后，点击进行共享，弹出层选择成员中，没有“部门默认收起”的选项
            //wym BUG0075544 模块列表-共享-弹出层中应有“显示离职成员”参数
            //wym BUG0076850 单据相关信息栏共享-弹出层中“显示离职成员”“子部门默认收起”参数不能通过点击文字选中
            scopepopupobj.popup_header += '<div class="select-input">' +
                '<label style="padding-left: 0;">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label>' +
                '<input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']+'\'>' +
                '<input id=\'viewuser_disableuser\' type="checkbox"><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label>'+
                '<input id=\'viewuser_unfoldsubgroup\' type="checkbox" class="marL10"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label>';
            //弹框右上角友情帮助Tips
            if(document.getElementById('oem_crm') != undefined && rRowNum <=1){
                var oem_crm = document.getElementById('oem_crm').value;
                if(oem_crm == 'no'){
                    scopepopupobj.popup_header += '<a class="rfloat" href="javascript:;" style="margin-right: 15px;margin-top: -4px;" onclick="getLinksUrl(\'\',\'Share\',\'module_list_share\');">'+arrJsPopLabel['ONLINEHELP']+'</a>';
                }
            }
            scopepopupobj.popup_header += '</div>';
            getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
                //获取选择用户信息
                cls_ScopePopup.prop.popup_module = rModule;//模块
                cls_ScopePopup.prop.popup_value = rUserid;
                cls_ScopePopup.prop.popup_url = popup_url;
                var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);

                // ljj 20230904 BUG0072070 kfbcrm-弹出层的× title改为tip
                tooltip(".tip-items-pop", {transition: true, time: 200});

                //共享类型给出友好提示
                //@edit:ljj,2023-08-09,reason:BUG0070560 kfbcrm-列表界面共享单据-字段不能通过点击文字勾选
                //wym 240104 BUG0078319 出库单-勾选单据-共享-勾选“显示离职成员”上边的说明信息变为空
                thisobj.sharetypeEvent(ld('#'+cls_ScopePopup.popup_divid));
                //确认按钮事件
                scopepopupobj.setEventBtnOk=function(){
                    ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                        //选中的用户
                        var selected_user = cls_ScopePopup.return_obj.return_id;
                        if(rRowNum>1 && selected_user<=0){
                            RemindsMsg('',"LdPopWidth400px","","yes","yes",arrJsPopLabel['PLEASESELECTLESTONEUSER']);
                            return false;
                        }

                        //选中的共享类型
                        var share_type = ld("#"+cls_ScopePopup.popup_divid+' input[name="share_type"]:checked').val();
                        //处罚取消按钮事件，隐藏用户选择界面
                        ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                        //保存共享信息
                        /*var urlstring = 'module=Users&action=UsersAjax&file=setModuleShare&frommodule='+rModule;
                        urlstring +='&recordall='+rIds+'&share_type='+share_type+'&excluded_records='+excluded_records;
                        urlstring +='&useridall='+selected_user+'&viewposition='+viewposition;*/

                        // @edit:liushuai,2021-03-09,reason:【ID1001390】批量分享增加显示进度条
                        var intervalrow = 8;
                        if (rRowNum > 100){
                            intervalrow = Math.ceil(rRowNum / 10); //向上取整
                        }
                        //duan 2022-2-28 设置批量操作上限20，如果一次性选中的记录条数大于系统设置的批量操作最大条数10倍以上，会导致进度条未生效
                        if(intervalrow >20){
                            intervalrow = 20;
                        }
                        if(rRowNum>0){
                            ld('#rptContentLoading').show();
                            thisobj.startBatchShare(rModule,rIds,share_type,excluded_records,selected_user,viewposition, rRowNum, 0, intervalrow);
                        }
                        var popupobj = CrmPopup.getPopupObj('last');
                        // 社交推广 详细页 共享后刷新详细页
                        if(rModule =='SocialPromotion' && rRowNum ==1){
                            afterDetailShareEvent(rIds)
                        }else if(popupobj.pagetype == 'detailview_modulepage'){
                            //duan 20230804 共享操作后，刷新详情页
                            var tmpobj= new AfterUpdatePrevPopupObjContent(rModule,{},{});
                            var tmpmodules=[rModule];
                            tmpobj.eachrefreshlistbyModules(tmpmodules);
                        }
                        //231031 wym XUQIU1002054 点击确认,保存当前是否勾选显示离职成员并刷新首页下拉框
                        if(ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser')){
                            var displayinactiv=ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser').prop('checked');
                            //wym 231115 BUG0075530 首页-数据简报穿透-取消勾选“显示离职成员” 与首页保持一致 关联需求:XUQIU1002054
                            var tmpurlsting = 'index.php?module=Users&action=UsersAjax&file=viewInactiveusers&frommodule='+cls_ScopePopup.prop.popup_module+'&value='+displayinactiv;
                            ldAjaxNoProgresssync(tmpurlsting,'',function(data){
                            })
                        }
                    });
                    // 社交推广新建保存数据之前需要分享 重写弹出层确定事件
                    if(rModule == 'SocialPromotion'){
                            //编辑和新建执行
                            //重写分享弹出层的点击事件
                            reWriteEventBtnOk(cls_ScopePopup);
                    }
                }
            });
        });
    }

    // @edit:liushuai,2021-03-09,reason:【ID1001390】批量分享增加显示进度条
    // 开始批量分享
    entrance.prototype.startBatchShare = function(rModule,rIds,share_type,excluded_records,selected_user,viewposition, rRowNum, startrow, intervalrow, join_url=''){
        var thisobj = this;
        var endrow = startrow+intervalrow;
        if (endrow > rRowNum){  //最后一个请求
            endrow = rRowNum;
        }
        var urlstring = 'module=Users&action=UsersAjax&file=setModuleShare&frommodule='+rModule;
        urlstring +='&recordall='+rIds+'&share_type='+share_type+'&excluded_records='+excluded_records;
        urlstring +='&useridall='+selected_user+'&viewposition='+viewposition;
        //zkt 模块树结构显示增加条件，获取树结构点击条件
        if(viewposition=='listview'&&ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
    	   urlstring += '&isshowModuleListTree=yes';
    	}

        urlstring+="&selectlen="+rRowNum+"&startrow="+startrow+"&endrow="+endrow;
        urlstring += join_url;
        RequestAjax(urlstring,function(rest){
            var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
            //明细界面的共享操作
            if(restobj.viewposition=='detailview'){
                ld('#rptContentLoading').hide();
                //共享成功
                if(restobj.code==1){
                    // alert('wwww');
                    var popupobj=CrmPopup.getPopupObj('last');
                    if(popupobj.type==RelateListPage.type)
                    {
                        ld("#"+popupobj.divid+" [relatetag=SharedUsers]").click();
                    }
                    DelProgressObjs();
                    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                        //通讯录(pc端企业微信)
                        cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);


                    workflowCallApiPop(restobj);//工作流API弹窗
                }else{
                    DelProgressObjs();
                    RemindsMsg(restobj.title,"LdPopWidth400px","","yes","yes",restobj.log);
                }
            }else{
                ld('#rptContentLoading').hide();
                // 分享进度条框
                var tmppopupobjobj;
                if(startrow==0)
                {
                    tmppopupobjobj=ProgressPopup.load(restobj.title,"","",500,'Users',"","","","");
                    tmppopupobjobj.show();
                }
                else{
                    tmppopupobjobj=CrmPopup.getPopupObj('last');
                }
                var maxrows=parseInt(restobj.maxrows);
                var percent=parseInt(((startrow+intervalrow)/maxrows*100));

                tmppopupobjobj.setPercentWidth(percent);
                tmppopupobjobj.setTotalNum(restobj.selectrows);
                tmppopupobjobj.setCurNum(startrow);
                if(maxrows!=restobj.selectrows)
                {
                    tmppopupobjobj.setValidataNum(maxrows);
                }

                if(parseInt(startrow+intervalrow)<parseInt(restobj.maxrows))
                {
                    thisobj.startBatchShare(rModule,rIds,share_type,excluded_records,selected_user,viewposition, rRowNum, startrow + intervalrow, intervalrow, join_url);
                    return false;
                }
                else{
                    tmppopupobjobj.CancelEvent();
                }


                //序时簿的共享操作
                getJsScript('include/js/ldcrm.base.js',function(){
                    //共享结果展示框
                    // 2024-08-01 xxy BUG20240722-60 在共享后结果框中，超链接对应的单据详情界面出现在弹窗下层
                    resultRemindsMsg(restobj.title, "LdPopWidth650px", "mass_share", "yes", "", restobj.log);
                    var popupobj=CrmPopup.getPopupObj('last');
                    //绑定确认按钮
                    ld("#"+popupobj.divid).find('[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                        fninvshnew('mass_share');puyoungJS_DialogBox.unblock();
                        //清楚选择数据的H5缓存
                        $('basicsearchcolumns').innerHTML = '';
                        $('allselectedboxes').value='';
                        $('excludedRecords').value='';
                        //AJAX重置序时簿内容栏

                        // getListViewEntries_js(module,'start='+restobj.start);//刷新页面
                        var tmparra=new Array();
                        var tmpobj= new AfterUpdatePrevPopupObjContent(module,"",tmparra);
                        //服务单保存后刷新服务单的历史记录(查看界面)
                        var refreshlistmodules = new Array(module);
                        tmpobj.eachrefreshlistbyModules(refreshlistmodules);

                        var popupobj=CrmPopup.getPopupObj('last');
                        if(popupobj.type==RelateListPage.type)
                        {
                            ld("#"+popupobj.divid+" [relatetag=SharedUsers]").click();
                        }
                    });
                    DelProgressObjs();
                    return false;
                });
            }
            /* 赛克
            edit:chj
            date:2020/8/6
            reason: 流转：点击流转后弹出“共享”功能页面，选择数据确认后，再弹出一个页面，必须填写“工单子状态”、“工单标签”、“标签特殊备注”，填写确定后对应更新【业务线工单问题描述】区块里的“工单子状态”、“工单标签”、“标签特殊备注”。同时“工单主状态”为【流转】。并调用MIS接口回调结果到MIS系统。将操作作为日志记录修改日志。
            */
            if(rIds > 0 && rModule == 'Accounts' && version_account != undefined && version_account == 'saic'){
                getGongdanSinInfoForGroup(rIds,'流转',selected_user);
            }
        });
    }

    // 绑定切换共享类型事件
    entrance.prototype.sharetypeEvent = function(obj){
        ld(obj).find('input[name="share_type"]').unbind('click').on('click',function(){
            var e = window.event;
            if (e.target.nodeName == 'INPUT') {
                var share_type =ld(this).val();
            }else{
                var share_type =ld(this).prev('input').val();
                ld(this).prev('input').prop('checked',true);
            }
            var share_type_remind = '';
            if(share_type=='add'){
                share_type_remind = arrJsPopLabel['SHARETYPEADD'];
            }else if(share_type=='cover'){
                share_type_remind = arrJsPopLabel['SHARETYPEREPLACE'];
            }else if(share_type=='cancel_share'){
                share_type_remind = arrJsPopLabel['SHARETYPECANCEL'];
            }
            ld(obj).find('#share_type_remind').html(share_type_remind);

            var selectusers_label_obj =  ld(obj).find('#selectusers_label');
            if(!empty(selectusers_label_obj) && selectusers_label_obj.length>0){
                var selectusers_label = '';
                var sharerelatedinfo_label = arrJsPopLabel['SimultaneouslyShareRelinfo'];
                if(share_type=='add'){
                    selectusers_label = arrJsPopLabel['AddSharers'];
                }else if(share_type=='cover'){
                    selectusers_label = arrJsPopLabel['ReplaceSharer'];
                }else if(share_type=='cancel_share'){
                    selectusers_label = arrJsPopLabel['CancelSharers'];
                    sharerelatedinfo_label = arrJsPopLabel['SimultaneouslyCancelShareRelinfo'];
                }
                selectusers_label_obj.html(selectusers_label);
                if(!empty(ld(obj).find("#headblock_chooserelinfo")) && ld(obj).find("#headblock_chooserelinfo").length>0){
                    ld(obj).find("#headblock_chooserelinfo").html(sharerelatedinfo_label);
                }
            }
        });
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
