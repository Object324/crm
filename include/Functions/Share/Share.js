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
            if(rows_num < 1) {
                var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                return false;
            }

            var select_ids = List_CheckBox_Ids.ids;
            this.excluded_records = $('excludedRecords').value;
            //判断选择单据超过最大许可编辑数
            if(rows_num >parseInt(getMaxMassOperationLimit())){
                var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',rows_num,getMaxMassOperationLimit(),'');
                //创建提示弹出层
                create_divobj('confirm_reminder',arrJsPopLabel['WARMPROMPT'],confirm_str,'yes','','no');
                //确定事件
                ld('#confirm_reminder .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                    thisobj.setPopupContent(module,select_ids,rows_num);
                    fninvshnew('confirm_reminder');
                });
                //取消事件
                ld('#confirm_reminder .D_pbtn .D_pbtncancel').unbind('click').on('click',function(){
                    fninvshnew('confirm_reminder');
                    return false;
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
    //选择一条单据时，显示上次共享的人
    entrance.prototype.getSelectedUser = function(rModule,rIds,rRowNum){
        var userid = '';
        var permit = '';
        var thisobj = this;
        if(rRowNum==1){
            //var recordid = rIds.replace(';','');
            ld.post("index.php",{mode : "tabshare" ,recordid:rIds,module:"Users",file:"setModuleShare",'action':"UsersAjax"},function(response) {
                if(empty(response)) return false;
                var restobj = eval('('+ response +')')?eval('('+ response +')'):JSON.parse(response);
                userid = restobj.userid;
                thisobj.setPopupContent(rModule,rIds,rRowNum,userid);
            });
        }else{
            thisobj.setPopupContent(rModule,rIds,rRowNum,userid);
        }
    }
    entrance.prototype.showEditBtn=function(jqueryobj){
        var tdobj=ld(jqueryobj).parent();
        while(tdobj.prop("tagName").toLowerCase()!='td')
        {
            tdobj=ld(tdobj).parent();
        }
        var columnname=ld(tdobj).attr("columnname");
        
        ld(tdobj).find(['a[tag=edit']).css("display",'');
        
    }
     entrance.prototype.hideEditBtn=function(jqueryobj){
        var tdobj=ld(jqueryobj).parent();
        while(tdobj.prop("tagName").toLowerCase()!='td')
        {
            tdobj=ld(tdobj).parent();
        }
        var columnname=ld(tdobj).attr("columnname");
        
        ld(tdobj).find(['a[tag=edit']).css("display",'');
        
    }
    //显示共享人选择界面
    entrance.prototype.setPopupContent = function(rModule,rIds,rRowNum,rUserid){
        var viewposition = this.viewposition;
        var excluded_records = this.excluded_records;
        var scopepopupobj;
        //自定义弹出层页面html，绑定事件
        getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
            var methodObj = {'popup_check_inactiveuser':'yes','popup_check_nogroupuser':'no'};
            scopepopupobj =  new ScopePopupObj(methodObj);
            scopepopupobj.popup_caption_value = arrJsPopLabel['SHARE'];//标题
            //若选择的单据数超过一条，则显示额外按钮  CANCEL SHARE  REPLACE TYPE
            if(rRowNum > 1){
                scopepopupobj.header = '<div style="text-align:left;">' + '<p>'+arrJsPopLabel['SHARETYPE']+'：&nbsp;'+
                    '<input type="radio" name="share_type" value="add" checked="checked"/><span style="font-size:12px">'+arrJsPopLabel['SUPERADDTION']+'</span>' +
                    '<input type="radio" name="share_type" value="cover"/><span style="font-size:12px">'+arrJsPopLabel['REPLACE']+'</span>' +
                    '<input type="radio" name="share_type" value="cancel_share"/><span style="font-size:12px">'+arrJsPopLabel['CANCELSHARE']+'</span>';
                //弹框右上角友情帮助Tips
                if(document.getElementById('oem_crm') != undefined){
                    var oem_crm = document.getElementById('oem_crm').value;
                    if(oem_crm == 'no'){
                        scopepopupobj.header += '<a class="rfloat" href="javascript:;" style="margin-right: 15px;margin-top: -4px;" onclick="getLinksUrl(\'\',\'Share\',\'module_list_share\');">'+arrJsPopLabel['ONLINEHELP']+'</a>';
                    }
                }
                scopepopupobj.header += '<div style="text-align:left;"><p style="margin-top:10px;" ><span>'+arrJsPopLabel['Operating_Instructions']+'：&nbsp;</span><span id="share_type_remind">'+arrJsPopLabel['SHARETYPEADD']+'</span></p></div>'
            }else{
                //选择单条记录时，默认共享类型为覆盖
                scopepopupobj.header = '<input type="radio" name="share_type" value="cover" checked="checked" hidden/>';
            }
            //搜索框
            scopepopupobj.popup_header += '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']+'\'>';
            //弹框右上角友情帮助Tips
            if(document.getElementById('oem_crm') != undefined && rRowNum <=1){
                var oem_crm = document.getElementById('oem_crm').value;
                if(oem_crm == 'no'){
                    scopepopupobj.popup_header += '<a class="rfloat" href="javascript:;" style="margin-right: 15px;margin-top: -4px;" onclick="getLinksUrl(\'\',\'Share\',\'module_list_share\');">'+arrJsPopLabel['ONLINEHELP']+'</a>';
                }
            }
            getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
                //获取选择用户信息
                cls_ScopePopup.prop.popup_module = rModule;//模块
                cls_ScopePopup.prop.popup_value = rUserid;
                cls_ScopePopup.prop.popup_url = "module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module="+rModule+"&popup_inputtype=checkbox&popup_selecttype=user";
                var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
                //共享类型给出友好提示
                ld('#'+cls_ScopePopup.popup_divid+' input[name="share_type"]').unbind('click').on('click',function(){
                    var share_type =ld(this).val();
                    var share_type_remind = '';
                    if(share_type=='add'){
                        share_type_remind = arrJsPopLabel['SHARETYPEADD'];
                    }else if(share_type=='cover'){
                        share_type_remind = arrJsPopLabel['SHARETYPEREPLACE'];
                    }else if(share_type=='cancel_share'){
                        share_type_remind = arrJsPopLabel['SHARETYPECANCEL'];
                    }
                    ld('#share_type_remind').html(share_type_remind);
                });
                //确认按钮事件
                scopepopupobj.setEventBtnOk=function(){
                    ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                        //选中的用户
                        var selected_user = cls_ScopePopup.return_obj.return_id;

                        if(rRowNum>1 && selected_user<=0){
                            RemindsMsg('',"LdPopWidth400px","","yes","yes",arrJsPopLabel['PLEASESELECTLESTONEUSER']);
                            return false;
                        }

                        //选中的共享类型
                        var share_type = ld("#"+cls_ScopePopup.popup_divid+' input[name="share_type"]:checked').val();
                        //处罚取消按钮事件，隐藏用户选择界面
                        ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
                        //保存共享信息
                        var urlstring = 'module=Users&action=UsersAjax&file=setModuleShare&frommodule='+rModule;
                        urlstring +='&recordall='+rIds+'&share_type='+share_type+'&excluded_records='+excluded_records;
                        urlstring +='&useridall='+selected_user+'&viewposition='+viewposition;

                        RequestAjax(urlstring,function(rest){
                            var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
                            //明细界面的共享操作
                            if(restobj.viewposition=='detailview'){
                                //共享成功
                                if(restobj.code==1){
                                    window.location.reload();
                                }else{
                                    RemindsMsg(restobj.title,"LdPopWidth400px","","yes","yes",restobj.log);
                                }
								DelProgressObjs();
                            }else{
                                //序时簿的共享操作
                                getJsScript('include/js/ldcrm.base.js',function(){
                                    //共享结果展示框
                                    var divobj = createElementDivs('mass_share');
                                    ld(divobj).find('.E_pop_tit .E_ptita').html(restobj.title);
                                    ld(divobj).find('.pop_remind_content').html(restobj.log);
                                    ld('#mass_share .D_pbtn .D_pbtncancel').css('display','none');
                                    fnvshobj(this,'mass_share');
                                    //绑定确认按钮
                                    ld('#mass_share .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                                        fninvshnew('mass_share');puyoungJS_DialogBox.unblock();
                                        //清楚选择数据的H5缓存
                                        $('basicsearchcolumns').innerHTML = '';
                                        $('allselectedboxes').value='';
                                        $('excludedRecords').value='';
                                        //AJAX重置序时簿内容栏
                                        getListViewEntries_js(module,'start='+restobj.start);//刷新页面
                                    });
									DelProgressObjs();
                                    return false;
                                });
                            }
                        });
                    });
                }
            });
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
