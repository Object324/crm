function cls_StepApproverSet(stepid,flowstepid,approvestepflowobj)
{
    //审批步骤
    this.remindlabel=[];
    this.remindinfo=[];
    this.flowstepid=flowstepid;
    this.stepid=stepid;
    this.approvestepflowobj=approvestepflowobj;
    var that=this;
    this.label_arr=[];
    this.ajaxdata=[];
    this.value_arr=[];
    this.reminddata=[];
    this.editprofile='yes';
    this.curstepindex=that.approvestepflowobj.getFlowStepIndex(flowstepid);
    this.show=function(){
        that.divid=parseInt(Math.random()*10000)+"approvestep";
        that.popupobj=new Object();

        that.popupobj.divid=that.divid;
        CrmPopup.global_listPopupObj.push(that.popupobj);
        that.stepid=that.approvestepflowobj.stepflow_arr[that.curstepindex].id;
        
         if(that.approvestepflowobj.stepflow_arr[that.curstepindex].stepinfo.edit!=undefined)
        {
                var stepid=0;
        }
        else
        {
               var stepid=that.stepid;
        }
       ldAjaxNoProgress("index.php?module=Settings&action=SettingsAjax&file=newApproverStepSet&approveid="+newApproveSetObj.approveid
                ,{"tabid":newApproveSetObj.tabid,'flowstepid':that.flowstepid,'stepid':stepid},function(ajaxdata){
            DelProgressObjs();
            that.remindinfo=ajaxdata.result.remindinfo;
            that.remindlabel=ajaxdata.result.remindlabel;
            that.label_arr=ajaxdata.result.label;
            that.tipslabel_arr=ajaxdata.result.tipslabel;// 提示信息的label
            that.ajaxdata=ajaxdata;
            
            if(that.approvestepflowobj.stepflow_arr[that.curstepindex].stepinfo.edit!=undefined){
                that.value_arr=that.approvestepflowobj.stepflow_arr[that.curstepindex].stepinfo;
            }
            else
            {
                that.value_arr=ajaxdata.result.value;
                
            }
            if(!empty(that.value_arr.reminddata)){
                that.reminddata=that.value_arr.reminddata;
            }else{
                that.reminddata= [];
            }

            that.initApproveSetDrawer();
            that.initDrawerApproveSetpage();
            that.setValue();
            that.setEvent();
            that.setTabEvent();//页签切换
            //edit: xll BUG0062036 ”审批流程定制”选择审批人类型：指定部门成员的职位级别 ，“职位级别”下拉框没有搜索功能 
            var selectobj = ld("#" + that.popupobj.divid + " [fieldtype=selecttype]");
           var ldtmpobj = ld("#" + that.popupobj.divid + " [name=approvetype]");
           var ldtmpwidth = ldtmpobj.width()+28;
            ld.each(selectobj, function(){
                var tmpobj = ld("#" + that.popupobj.divid + " [name=" + this.getAttribute('name') + "]");
                if(tmpobj.length>0&&tmpobj!=undefined){
                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml(tmpobj.attr("name"));
                    cls_resetComboxHtmlobj.setPopupObj(that.popupobj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(tmpobj,ldtmpwidth);
                    cls_resetComboxHtmlobj.setOptionText = function (optiontext){
                        optiontext = optiontext.replaceAll('&nbsp;','');
                        return optiontext;
                    }
                }
            })
        })
       
        
    }

    this.initApproveSetDrawer=function (){
        ld('<div class="first-modal" autocomplete="off"></div>').appendTo("body");

        var htmlStr =   '<div id="'+that.divid+'" class="first-drawer-wrapper first-drawer-wrapper-approve">' + 
                            '<div class="first-drawer-container">' + 
                                '<div class="first-drawer-header" id="first-drawer-header">' + 
                                    '<span class="first-drawer-title"></span>' + 
                                    '<span class="first-drawer-titlenum"></span>' + 
                                    '<div class="first-drawer-headerbtn">' + 
                                        '<button type="button"><i class="ld-fonticon ld-fonticon-close"></i></button>' +
                                    '</div>' + 
                                '</div>' + 
                                '<div class="first-drawer-body" id="first-drawer-body">' + 
                                    '<div class="first-drawer-body-content"></div>' + 
                                    '<div class="first-drawer-body-footer"></div>' + 
                                '</div>' + 
                                '<div class="first-drawer-footer" id="first-drawer-footer"></div>' + 
                            '</div>' + 
                        '</div>';
        ld(htmlStr).appendTo("body");

         ld(" .first-modal").css("zIndex",CrmPopup.zIndex+1);
        ld(" .first-drawer-wrapper-approve").css("zIndex",CrmPopup.zIndex+2)
        CrmPopup.zIndex=CrmPopup.zIndex+2;

    }
        
    //抽屉-审批设置
   this.initDrawerApproveSetpage= function (){
        ld('.first-drawer-title').html(that.label_arr['approvestep']);//title
        var approveStr =    '<div class="demo-block demo-zh-CN demo-menu drawer-approve-page" style="position: sticky;top: 0;z-index: 1;">' +
                                '<div class="source">' + 
                                    '<div>' + 
                                        '<ul role="menubar" class="el-menu-demo el-menu--horizontal el-menu">' + 
                                            '<li role="menuitem" class="el-menu-item is-active" style="" tag="menubar_basic">'+that.label_arr['basicinfo']+'</li>' + 
                                            '<li role="menuitem" class="el-menu-item" style="'+(this.editprofile=='no'?'display:none':'')+'" tag="menubar_required">'+that.label_arr['approvalrequired']+'</li>' +
                                            '<li role="menuitem" class="el-menu-item" style="" tag="menubar_remind">'+that.label_arr['approvereminds']+'</li>' + 
                                            '<li role="menuitem" class="el-menu-item" style="'+(this.editprofile=='no'?'display:none':'')+'" tag="menubar_advance">'+that.label_arr['advfun']+'</li>' +
                                        '</ul>' + 
                                    '</div>' + 
                                '</div>' + 
                            '</div>';
        ld('.first-drawer-body-content').append(approveStr);
       /* ld(".drawer-approve-page li").click(function(){
            ld('.drawer-approve-page li').each(function(){
                ld(this).removeClass('is-active');
            });
            ld(this).addClass('is-active');
        });*/

       
        that.initDrawerApproveSetAppend("menubar_basic");//基本信息
        that.initDrawerRemind("menubar_remind");//提醒
        that.InitDrawerChangeFieldVale("menubar_advance");
        that.InitDrawerModuleField("menubar_required");//审批必填

        that.changeTab(ld("#"+that.divid+" [role=menuitem]:first").attr("tag"))

        // 动态赋予中间内容高度，去掉头部底部
        var content_height = ld("#"+that.divid).height() - ld('#first-drawer-header').outerHeight() - ld('#first-drawer-footer').outerHeight();    
        ld('#first-drawer-body').css('height',content_height+'px');
        
    }
     this.setTabEvent=function(){
        //页签切换事件 
        ld("#"+that.divid+" li[role=menuitem]").unbind("click").bind("click",function(){
                that.changeTab(ld(this).attr("tag"))
                
        })
    }
    this.changeTab=function(tag)
    {
        ld("#"+that.divid+" li[role=menuitem]").removeClass('is-active');
        ld("#"+that.divid+" .first-drawer-body-content").find(".first-drawer-content-items").css('display','none')        
        ld("#"+that.divid+" .first-drawer-body-content").find("[tag="+tag+"]").css("display",'');
        ld("#"+that.divid+" .first-drawer-body-content").find("[tag="+tag+"]").addClass('is-active')
    }      
   this.initDrawerRemind=function(tag){
       
        getJsScript('include/js/modules/Approve/cls_ApproveRemindSet.js',function(){
                 
             that.approveremindobj=new cls_ApproveRemindSet(that);
             that.approveremindobj.InitHtml(tag);
        })
        
   } 

   this.InitDrawerChangeFieldVale=function(tag){
         getJsScript('include/js/modules/Approve/cls_StepChangeFieldValue.js',function(){
                 
             that.StepChangeFieldValueobj=new cls_StepChangeFieldValue(that);
             that.StepChangeFieldValueobj.InitHtml(tag);
        })
   }
   this.InitDrawerModuleField=function(tag)
   {
        //审批必填
        getJsScript('include/js/modules/Approve/cls_StepModuleField.js',function(){
                 
             that.StepModuleFieldobj=new cls_StepModuleField(that);
             that.StepModuleFieldobj.InitHtmlSecond(tag);
        })
   }
    //抽屉-列表设置
    this.initDrawerApproveSetAppend=function(tag){
        ld('.first-drawer-body-content').append('<div class="first-drawer-content-items" tag="'+tag+'"></div>');
        ld('.first-drawer-body-content .first-drawer-content-items').append('<div class="first-drawer-content-title ld-from-headblock-title">'+ arrJsPopLabel['FormSet'] + '</div>');
        var itemStr =   '';
        //步骤名称
        itemStr =   '<div class="first-drawer-content-item ">' +
                        '<label class="drawer-content-item-title2"><font color="red" >*</font>'+that.label_arr['stepname']+'</label>' + 
                        '<input class="ld-input-inner" name="stepname" type="text">' +
                    '</div>';
        //备注
        itemStr +=  '<div class="first-drawer-content-item ">' +
                        '<label class="drawer-content-item-title2">'+that.label_arr['remark']+'</label>' + 
                        '<textarea class="ld-textarea-inner" name="description" style="resize:vertical;"></textarea>' +
                    '</div>';
        //审批人类型
        itemStr+=   '<div class="ld-from-headblock" style="height:12px;"></div>';
        itemStr+=   '<div class="first-drawer-content-title ld-from-headblock-title">'+that.label_arr['setapprover']+'</div>';
        itemStr+=   '<div class="first-drawer-content-item">' + 
                        '<label class="drawer-content-item-title2">'+that.label_arr['approvertype']+'</label>' + 
                        '<select class="ld-select-inner" name="approvetype" fieldtype="selecttype">'+
                            '<option value="0">'+that.label_arr['approveruser']+'</option>'+
                            '<option value="1">'+that.label_arr['approverrole']+'</option>'+
                            '<option value="5">'+that.label_arr['approvercreator']+'</option>'+
                            '<option value="6">'+that.label_arr['approversmowner']+'</option>'+
                            '<option value="2">'+that.label_arr['approverdeparmentposition']+'</option>'+
                            '<option value="3">'+that.label_arr['approvertopposition']+'</option>'+
                            '<option value="4">'+that.label_arr['approverdepartmentuser']+'</option>';
                            //模块的选择用户字段
                            ld.each(that.ajaxdata.result.approverfield,function(tmpindex,tmpinfo){
                                itemStr+='<option value="'+tmpinfo.fieldid+'" uitype="'+tmpinfo.uitype+'" >'+tmpinfo.label+"</option>";
                            });
        itemStr+=       '</select>';
        itemStr+='</div>';
        //指定成员
        itemStr+=   '<div id="username_tr" class="first-drawer-content-item " style="position: relative;">' +
                        '<label class="drawer-content-item-title2"><font color="red">*</font>'+that.label_arr['member']+'</label>' + 
                        '<div class="ld-input-inner-div ld-input-inner-add" name="userid_name" id="userid_name" style="text-align:left;overflow: hidden;text-overflow: ellipsis;vertical-align:middle;display:inline-block;margin:0"></div>'+
                        '<input class="txt" name="userid" id="userid" type="hidden">' +
                        '<a class="ld-text-select" style="right: 0;" href="javascript:;" name="select_step_approve_user">+</a>'+
                    '</div>';
        //指定角色
        itemStr+=   '<div id="role_name_tr" class="first-drawer-content-item " style="position: relative;">' +
                        '<label class="drawer-content-item-title2"><font color="red">*</font>'+that.label_arr['approverrole']+'</label>' + 
                        '<input class="ld-input-inner-div ld-input-inner-add" name="role_name" id="role_name" style="text-align:left;overflow: hidden;text-overflow: ellipsis;vertical-align:middle;display:inline-block;margin:0"></input>'+
                        '<input class="txt" name="user_role" id="user_role" type="hidden">' +
                        '<a class="ld-text-select" style="right: 0;" href="javascript:;" onclick="selectPopupProfile(\'user_role\',\'角色权限\');">+</a>'+
                    '</div>';
        //itemStr+='</select></div>';

         //审批人类型选择 单据负责人部门成员的职位级别-》职位级别 
        itemStr+=   '<div id="position_tr" class="first-drawer-content-item ">' +
                        '<label class="drawer-content-item-title2"><font color="red">*</font>'+that.ajaxdata.result.userlevellabel+'</label>' ;
        itemStr+='<select class="ld-select-inner" name="position" fieldtype="selecttype">';
        ld.each(that.ajaxdata.result.userlevel,function(tmpindex,tmpvalue){
                itemStr+='<option value="'+tmpvalue+'">'+tmpvalue+'</option>';
        }) 
        itemStr+="</select></div>";

        //审批人类型选择单据负责人直属上级部门成员的职位级别-》职位级别
        itemStr+=   '<div id="positionlevel_tr" class="first-drawer-content-item ">' +
                        '<label class="drawer-content-item-title2"><font color="red">*</font>'+that.ajaxdata.result.userlevellabel+'</label>' ;
        itemStr+='<select class="ld-select-inner" name="positionlevel" style="width: 100%;" fieldtype="selecttype">';
        ld.each(that.ajaxdata.result.userlevel,function(tmpindex,tmpvalue){
                itemStr+='<option value="'+tmpvalue+'">'+tmpvalue+'</option>';
        }) 
        itemStr+="</select></div>";
        //审批人类型选择 指定部门成员的职位级别

        //部门
        itemStr+='<div id="positiondepartment_tr1" class="first-drawer-content-item  ltextalign">' +
                        '<label class="drawer-content-item-title2"><font color="red">*</font>部门</label>' + 
                        '<select  class="ld-select-inner" name="positiondepartment1" fieldtype="selecttype">';
                ld.each(that.ajaxdata.result.group,function(groupname,groupid){
                        itemStr+='<option value="'+groupid+'">'+groupname+'</option>'
                })
        itemStr+="</select></div>";

        //职位级别
        itemStr+=   '<div id="positiondepartment_tr2" class="first-drawer-content-item ">' +
                        '<label class="drawer-content-item-title2"><font color="red">*</font>'+that.ajaxdata.result.userlevellabel+'</label>' ;
        itemStr+='<select class="ld-select-inner" name="positiondepartment2" fieldtype="selecttype">';
        ld.each(that.ajaxdata.result.userlevel,function(tmpindex,tmpvalue){
                itemStr+='<option value="'+tmpvalue+'">'+tmpvalue+'</option>';
        })               
        itemStr+='</select></div>';

        //审批人为空时
        itemStr+=   '<div name="when_approver_empty" class="first-drawer-content-item  flex-start">' +
                        '<label class="drawer-content-item-title2"><font color="red">*</font>'+that.label_arr['whenapproverempty']+'</label>' + 
                        '<input type="radio" name="autopass" id="autopass" tag="emptyapproverdeal"><label for="autopass" class="padL5 padR10">'+that.label_arr['autopass'] + '</label>' +
                        '<input type="radio" name="transfertomanager" id="transfertomanager" tag="emptyapproverdeal"><label for="transfertomanager" class="padL5 padR10">'+that.label_arr['autochangeadmin'] + '</label>' +
                        '<input type="radio" name="transfertouser" id="transfertouser" tag="emptyapproverdeal"><label for="transfertouser" class="padL5">'+that.label_arr['specifyapprover'] + '</label>' +
                    '</div>';

         //审批人为空时 指定审批成员
        itemStr+=   '<div name="transferusername_tr" class="first-drawer-content-item " style="position: relative;">' +
                    '<label class="drawer-content-item-title2"><font color="red">*</font>审批成员</label>' +
                    '<input class="ld-input-inner-div ld-input-inner-add" name="transfer_userid_name" id="transfer_userid_name"  style="text-align:left;overflow: hidden;text-overflow: ellipsis;vertical-align:middle;display:inline-block;margin:0">'+
                    '<input class="txt" name="transfer_userid" id="transfer_userid" type="hidden">'+
                    '<a class="ld-text-select" style="right: 0;" href="javascript:;" onclick="transfer_approve_selectuser();">+</a>'+
                    '</div>';

        //多人审批方式“或签”（一个审批人通过即可通过审批步骤）
        itemStr+=   '<div name="tr_countersigner" class="first-drawer-content-item  flex-start">' +
                        '<input type="radio" value="no" name="countersigner" id="countersigner_huoqian">'+
                        '<label for="countersigner_huoqian" class="drawer-content-item-title2 autoWidth padL5">'+that.label_arr['multipleapproversone']+'</label>' +
                    '</div>';

        //多人审批方式“会签”（所有审批人通过才能通过审批步骤） 
        itemStr+=   '<div name="tr_countersigner" class="first-drawer-content-item  flex-start">' +
                        '<input type="radio" value="yes" name="countersigner" id="countersigner_huiqian">'+
                        '<label for="countersigner_huiqian" class="drawer-content-item-title2 autoWidth padL5">'+that.label_arr['multiplecountersignature']+'</label>' +
                    '</div>';

        //审批控制
        itemStr+= '<div class="ld-from-headblock" style="height:12px;"></div>';
        itemStr+= '<div class="first-drawer-content-title ld-from-headblock-title">'+that.label_arr['approvecontrol']+'</div>';

        //允许审批人编辑单据
        itemStr +=  '<div class="first-drawer-content-item  flex-start" style="'+(this.editprofile=='no'?'display:none':'')+'">' +
                        '<label class="drawer-content-item-title3">'+that.label_arr['allowedit']+'</label>' + 
                        '<div><input name="alloweditbill" class="second_switch" type="checkbox" checked=""></div>' +  
                    '</div>';
        //允许直接结束流程
        itemStr +=  '<div class="first-drawer-content-item  flex-start">' +
                        '<label class="drawer-content-item-title3">'+that.label_arr['allowendapproveflow']+'</label>' + 
                        '<div><input name="ended" class="second_switch" type="checkbox" checked=""></div>' +  
                    '</div>';
        //允许更换本步骤审批人
        itemStr +=  '<div class="first-drawer-content-item  flex-start">' +
                        '<label class="drawer-content-item-title3">'+that.label_arr['allowchangeapprover']+'</label>' + 
                        '<div><input name="selectapproveuser" class="second_switch" type="checkbox"></div>' +  
                    '</div>';
        //允许加签             
        itemStr +=  '<div class="first-drawer-content-item  flex-start">' +
                        '<label class="drawer-content-item-title3">'+that.label_arr['allowaddapprover']+'</label>' + 
                        '<div><input name="is_augmentsinger" class="second_switch" type="checkbox" ></div>' +
                    '</div>';
        //加签 或签
         itemStr +=  '<div class="first-drawer-content-item  flex-start" name="tr_augmentsinger">' +
                        '<div style="margin-left: 24px;"><input name="augmentsinger"  value="no" type="radio" > <label class="padL5 padR10">'+that.label_arr['multipleapproversone'] + '</label></div>' +
                    '</div>';
        //加签 会签
        itemStr +=  '<div class="first-drawer-content-item  flex-start" name="tr_augmentsinger">' +
                        '<div style="margin-left: 24px;"><input name="augmentsinger"   value="yes"  type="radio" > <label class="padL5 padR10">'+that.label_arr['multiplecountersignature'] + '</label></div>' +
                    '</div>';         
        //e.允许指定下一步审批节点
        itemStr +=  '<div class="first-drawer-content-item  flex-start">' +
                        '<label class="drawer-content-item-title3">'+that.label_arr['allowchangestep']+'</label>' + 
                        '<div><input name="step" class="second_switch" type="checkbox"></div>' +  
                    '</div>';
        //审批意见必填
        itemStr +=  '<div class="first-drawer-content-item  flex-start">' +
                        '<label class="drawer-content-item-title3">'+that.label_arr['approveremarkrequired']+'</label>' + 
                        '<div><input name="approveremarkrequire" class="second_switch" type="checkbox" ></div>' +  
                    '</div>';
        //手写签名必填
        itemStr +=  '<div class="first-drawer-content-item  flex-start">' +
                        '<label class="drawer-content-item-title3">'+that.label_arr['signrequired']+'</label>' + 
                        '<div><input name="writesignrequired" class="second_switch" type="checkbox" ></div>' +  
                    '</div>';
        //使用上次签名
         itemStr +=  '<div class="first-drawer-content-item  flex-start" name="dv_writesignrequired">' +
                        '<label class="drawer-content-item-title3 textIndent24">'+that.label_arr['usedprevsign']+'</label>' + 
                        '<div><input name="writesignlogtype" value="useprevsign" class="second_switch" type="checkbox" ></div>' +  
                    '</div>';  
        //每次重新签名 
        itemStr +=  '<div class="first-drawer-content-item  flex-start" name="dv_writesignrequired">' +
                        '<label class="drawer-content-item-title3 textIndent24">'+that.label_arr['rewriteagain']+'</label>' + 
                        '<div><input name="writesignlogtype" value="rewrite" class="second_switch" type="checkbox" ></div>' +  
                    '</div>';  
        //审批人自动去重（自动通过）
        itemStr +=  '<div class="first-drawer-content-item  flex-start">' +
                        '<label class="drawer-content-item-title3">'+that.label_arr['removerepeatapprover']+'</label>' + 
                        '<div><input name="removesetting" class="second_switch" type="checkbox" ></div>' +  
                    '</div>';   
        //同一审批人多次出现时
        itemStr +=  '<div class="first-drawer-content-item  flex-start" name="dv_removeapprovemethod">' +
                        '<label class="drawer-content-item-title3 textIndent24">1.'+that.label_arr['sameapprovemany']+'</label>' + 
                        '<div><input name="removechoose" value="approvercounterremove" class="second_switch" type="checkbox"></div>' +  
                    '</div>';   
        //仅保留第一个
        itemStr +=  '<div class="first-drawer-content-item  flex-start" name="dv_removeapprovemethod">' +
                        '<label class="drawer-content-item-title3 textIndent24">&emsp;'+that.label_arr['onlyusefirst']+'</label>' +
                        '<div><input name="approverremovetype" value="usefirst" class="second_switch" type="checkbox" ></div>' +  
                    '</div>';              
        //仅在连续出现时去重
        itemStr +=  '<div class="first-drawer-content-item  flex-start" name="dv_removeapprovemethod">' +
                        '<label class="drawer-content-item-title3 textIndent24">&emsp;'+that.label_arr['continueapprover']+'</label>' +
                        '<div><input name="approverremovetype" value="continueremove" class="second_switch" type="checkbox" ></div>' +  
                    '</div>';
        //审批人和提交人相同时去重
        itemStr +=  '<div class="first-drawer-content-item  flex-start" name="dv_removeapprovemethod">' +
                        '<label class="drawer-content-item-title3 textIndent24">2.'+that.label_arr['approversamesubmitter']+'</label>' + 
                        '<div><input name="removechoose" value="approversamesubmitter" class="second_switch" type="checkbox" name="approversamesubmitter" ></div>' +  
                    '</div>';

        //审批权限
        itemStr+= '<div class="ld-from-headblock" style="height:12px;"></div>';
        itemStr+= '<div class="first-drawer-content-title ld-from-headblock-title">'+that.label_arr['approvalauthority']+'</div>';

        ld.each(that.value_arr['approvalauthority'],function(tmpkey,tmpvalue){
            itemStr +=  '<div class="first-drawer-content-item  flex-start" name="div_approvalauthority">' +
                            '<label class="drawer-content-item-title3">'+that.label_arr[tmpkey];
            // if(!empty(that.tipslabel_arr[tmpkey])){
            //     itemStr +=  '<b data-tip="'+that.tipslabel_arr[tmpkey]+'" class="icon-homeimg icon-askgrey-helptips" onmouseenter="tooltip.bind(this)"></b>';
            // }
            itemStr +=  '</label><div><input name="'+tmpkey+'" class="second_switch" type="checkbox"></div>'+
                    '</div>';
        });

        ld('.first-drawer-content-items[tag='+tag+']').append(itemStr);
        let heightStr = '<div style="height:50px;"></div>';
        ld('.first-drawer-content-items').append(heightStr);

        //底部按钮
        let btnStr =    '<div class="E_pbtn" id="'+that.divid+'_popupbottom">' + 
                            '<input name="button" id="'+that.divid+'_btnok" class="E_pbtnok ld-button ld-button-primary" value="'+that.ajaxdata.result.oktext+'" tagclick="save" type="button">' +
                            '<span>&nbsp;</span>' + 
                            '<input name="button" class="E_pbtncancel ld-button" value="'+that.ajaxdata.result.canceltext+'" id="'+that.divid+'_btncancel" type="button">' +
                        '</div>';
         ld('.first-drawer-footer').append(btnStr);
 
    }

    this.setValue=function()
    {
        //赋值
        ld("#"+that.divid+" [name=stepname]").val(that.value_arr['stepname']);
        ld("#"+that.divid+" [name=description]").text(that.value_arr['description']);
        //duan 20231206 审批人类型为空时，默认指定成员
        if(empty(that.value_arr['approvetype']))that.value_arr['approvetype'] = 0;
        ld("#"+that.divid+" [name=approvetype]").val(that.value_arr['approvetype']);
        //如果设置的用户字段关闭了，默认指定成员
        if(ld("#"+that.divid+" [name=approvetype]").find('option:selected').length <= 0){
            ld("#"+that.divid+" [name=approvetype]").val(0);
        }

        if(that.value_arr['alloweditbill']=='yes')
                ld("#"+that.divid+" [name=alloweditbill]").prop("checked",true);
        else
                ld("#"+that.divid+" [name=alloweditbill]").prop("checked",false);

        if(that.value_arr['ended']=='1')//结束流程
                ld("#"+that.divid+" [name=ended]").prop("checked",false);
        else
                ld("#"+that.divid+" [name=ended]").prop("checked",true);

        that.getChangeApproveType(ld("#"+that.divid+" [name=approvetype]").get(0));
       
        if(that.value_arr['countersigner']!='')//会签 或签
        ld("#"+that.divid+" [name=countersigner][value="+that.value_arr['countersigner']+"]").prop("checked",true);
      

        if(that.value_arr['specifyapproverid']=='1')//允许更换审批人
                ld("#"+that.divid+" [name=selectapproveuser]").prop("checked",false);
        else
                ld("#"+that.divid+" [name=selectapproveuser]").prop("checked",true);

         if(that.value_arr['augmentsinger']=='yes')//加签
                ld("#"+that.divid+" [name=augmentsinger]").prop("checked",true);
        else
                ld("#"+that.divid+" [name=augmentsinger]").prop("checked",false);
                   

        if(that.value_arr['step']=='1')//允许指定下一步审批节点
                ld("#"+that.divid+" [name=step]").prop("checked",false);
        else
                ld("#"+that.divid+" [name=step]").prop("checked",true);
        if(that.value_arr['approveremarkrequire']=='yes')//审批意见必填
            ld("#"+that.divid+" [name=approveremarkrequire]").prop("checked",true);
        else
            ld("#"+that.divid+" [name=approveremarkrequire]").prop("checked",false);
        that.setAugmentsingerfun();//加签
        that.emptyapproverdealfun();//审批人为空
        that.getChangeWriteSignRequired();//签名必填设置

        that.getapproverremovetype();//去重
        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
        {
          
            cls_wxOpenDataobj.bindAllOpenDataByPopupObj(that.popupobj);
        }
        // 审批权限
        var approvalauthority_obj = ld("#"+that.divid).find("[name=div_approvalauthority]");
        ld.each(that.value_arr['approvalauthority'],function(tmpkey,tmpvalue){
            approvalauthority_obj.find('[name="'+tmpkey+'"]').prop("checked",(tmpvalue=='yes'?true:false));
        });
    }
    this.setEvent=function()
    {

            //关闭抽屉
            ld(".first-modal").click(function(){
                 
                ld(".first-drawer-headerbtn").click();
            });
            ld(".first-drawer-headerbtn").click(function(){
                 
                ld(".first-modal").remove();
                ld(".first-drawer-wrapper").remove();
                ld(document).unbind();
                CrmPopup.global_listPopupObj.pop();
            });
            ld("#"+that.divid+'_btnok').unbind("click").bind('click',function(){

                //审批步骤保存
                that.save();

            })
            ld("#"+that.divid+'_btncancel').unbind("click").bind('click',function(){

                //审批步骤取消
                ld(".first-drawer-headerbtn").click();

            })
            //审批人类型改变
            ld("#"+that.divid+" [name=approvetype]").unbind("change").bind("change",function(){
                that.value_arr['approvevalue_name']='';

                that.getChangeApproveType(ld(this).get(0));

            })
            ld("#"+that.divid+" [tag=emptyapproverdeal]").unbind("click").bind("click",function(){
                   that.value_arr['emptyapproverdeal']=ld(this).attr("name");
                   that.emptyapproverdealfun();//审批人为空
            })
            ld("#"+that.divid+" [name=countersigner]").unbind("click").bind("click",function(){
                //会签 ，或签
               that.value_arr['countersigner']=ld(this).val();

            })
            ld("#"+that.divid+" [name=alloweditbill]").unbind("click").bind("click",function(){
                //允许编辑单据
                that.value_arr["alloweditbill"]='no';
                if(ld(this).prop("checked"))
                {
                    that.value_arr["alloweditbill"]='yes';
                }
            })
            ld("#"+that.divid+" [name=ended]").unbind("click").bind("click",function(){
                //允许结束流程
                that.value_arr["ended"]='1';
                if(ld(this).prop("checked"))
                {
                    that.value_arr["ended"]='0';
                }
            })
            ld("#"+that.divid+" [name=selectapproveuser]").unbind("click").bind("click",function(){
                //允许更换审批人
                that.value_arr["specifyapproverid"]='1';
                if(ld(this).prop("checked"))
                {
                    that.value_arr["specifyapproverid"]='0';
                }
            })
            ld("#"+that.divid+" [name=augmentsinger]").unbind("click").bind("click",function(){
                //允许加签方式
                that.value_arr["augmentsinger"]=ld(this).val();
                that.setAugmentsingerfun();
            })
            ld("#"+that.divid+" [name=is_augmentsinger]").unbind("click").bind("click",function(){
                //允许加签
                
                if(ld(this).prop("checked"))
                {
                    that.value_arr["augmentsinger"]='no';
                }
                else{
                    that.value_arr["augmentsinger"]='';
                }
                that.setAugmentsingerfun();
            })

            ld("#"+that.divid+" [name=step]").unbind("click").bind("click",function(){
                //允许指定下一步审批节点
                that.value_arr["step"]='1';
                 if(ld(this).prop("checked"))
                 {
                    that.value_arr["step"]='0';
                 }
            })

             ld("#"+that.divid+" [name=approveremarkrequire]").unbind("click").bind("click",function(){
                //审批意见必填
                that.value_arr["approveremarkrequire"]='no';
                 if(ld(this).prop("checked"))
                 {
                    that.value_arr["approveremarkrequire"]='yes';
                 }
            })

            ld("#"+that.divid+" [name=writesignrequired]").unbind("click").bind("click",function(){
                //签名是否必填
                if(ld(this).prop("checked"))
                {
                    that.value_arr['writesignrequired']='yes';
                    that.value_arr['writesignlogtype']='useprevsign';//使用上次签名
                }
                else
                {
                    that.value_arr['writesignrequired']='no';
                    that.value_arr['writesignlogtype']='';//签名方式
                }

                that.getChangeWriteSignRequired();
                 
            })
            ld("#"+that.divid+" [name=writesignlogtype]").unbind("click").bind("click",function(){
                that.value_arr['writesignlogtype']=ld(this).val();
                that.getChangeWriteSignRequired();

            })
            ld("#"+that.divid+" [name=removesetting]").unbind("click").bind('click',function(){
                //去重设置
                if(ld(this).prop("checked"))
                {
                    that.value_arr['approverremovetype']="usefirst";
                }
                else
                    that.value_arr['approverremovetype']='no';
                that.getapproverremovetype();
            })
            ld("#"+that.divid+" [name=removechoose]").unbind("click").bind("click",function(){
                //同一审批人多次出现时 
                if(ld(this).val()=='approversamesubmitter')//审批人和提交人相同时去重
                {
                    that.value_arr['approverremovetype']=ld(this).val()
                }
                else{
                    that.value_arr['approverremovetype']="usefirst";
                }
                that.getapproverremovetype();
                   

            })
            ld("#"+that.divid+" [name=approverremovetype]").unbind("click").bind("click",function(){
                //仅保留第一个 仅在连续出现时去重
                that.value_arr['approverremovetype']=ld(this).val();
                that.getapproverremovetype();
            })
            ld("#"+that.divid+" [name=select_step_approve_user]").unbind("click").bind("click",function(){

                that.approve_selectuser();
            })
        // 审批权限
        var approvalauthority_obj = ld("#"+that.divid).find("[name=div_approvalauthority]");
        ld.each(that.value_arr['approvalauthority'],function(tmpkey,tmpvalue){
            approvalauthority_obj.find('[name="'+tmpkey+'"]').unbind("click").bind("click",function(){
                if(ld(this).prop("checked")){
                    that.value_arr['approvalauthority'][tmpkey] = 'yes';
                }else{
                    that.value_arr['approvalauthority'][tmpkey] = 'no';
                }
            });
        });
    }
    this.setAugmentsingerfun=function(){
        if(that.value_arr['augmentsinger']=='')
        {
            ld("#"+that.divid+" [name=tr_augmentsinger]").css("display",'none');
            ld("#"+that.divid+" [name=is_augmentsinger]").prop("checked",false)

        }
        else{
            ld("#"+that.divid+" [name=is_augmentsinger]").prop("checked",true)
            ld("#"+that.divid+" [name=tr_augmentsinger]").css("display",'');
            ld("#"+that.divid+" [name=augmentsinger][value="+that.value_arr['augmentsinger']+"]").prop("checked",true)
        }
    }
    this.save=function(){

        that.value_arr['stepname']=ld("#"+that.divid+" [name=stepname]").val();
        if(ld.trim(that.value_arr['stepname'])=='')
        {

            var confirm_str = arrJsPopLabel['STEPNAMECANOTEMPTY'];
             RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
             ld("#"+that.divid+" [name=stepname]").focus();
             return false;
        }
        that.value_arr['description']=ld("#"+that.divid+" [name=description]").val();
        var approve_type=that.value_arr['approvetype'];//审批人类型
        that.value_arr['approvevalue']='';
        that.value_arr['approvevalue_label'] = '';
        if(approve_type==0){
            var userid=ld("#"+that.divid+" [name=userid]").val();
            that.value_arr['approvevalue']=userid;
            that.value_arr['approvevalue_name']=ld("#"+that.divid+" [name=userid_name]").html();
            that.value_arr['approvevalue_label'] =  that.value_arr['approvevalue_name'];
            if(userid.length>0);
            else{
                //用户不能为空！
                 
                var confirm_str = arrJsPopLabel['USERCANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                ld("#"+that.divid+" [name=userid_name]").focus();
                return false;
            }       
        }
        else if(approve_type==1){
            var user_roleid= ld("#"+that.divid+" [name=user_role]").val();
              that.value_arr['approvevalue']=user_roleid;
              that.value_arr['approvevalue_name']=ld("#"+that.divid+" [name=role_name]").val();
              that.value_arr['approvevalue_label'] =  that.value_arr['approvevalue_name'];
            if(user_roleid.length>0);
            else{
                //角色不能为空！
                var confirm_str = arrJsPopLabel['ROLECANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
              ld("#"+that.divid+" [name=role_name]").focus();
                return false;
            }  
          
        }
        else if(approve_type==2){//单据负责人部门成员的职位级别
                that.value_arr['approvevalue']= ld("#"+that.divid+" [name=position]").val();
                that.value_arr['approvevalue_label'] =  ld("#"+that.divid+" [name=position]").find(' option:selected').text();
                if( that.value_arr['approvevalue']=='')
                {
                    
                      RemindsMsg("","LdPopWidth400px","","yes","yes",that.ajaxdata.result.userlevellabel+arrJsPopLabel['CANOTEMPTY']);
                      return false;
                }
                

        }
        else if(approve_type==3)
        {
            //单据负责人直属上级部门成员的职位级别
            that.value_arr['approvevalue']= ld("#"+that.divid+" [name=positionlevel]").val();
            that.value_arr['approvevalue_label'] =  ld("#"+that.divid+" [name=positionlevel]").find(' option:selected').text();
            if( that.value_arr['approvevalue']=='')
            {
                
                  RemindsMsg("","LdPopWidth400px","","yes","yes",that.ajaxdata.result.userlevellabel+arrJsPopLabel['CANOTEMPTY']);
                  return false;
            }
            
        }
        else if(approve_type==4)
        {
            //指定部门成员的职位级别
            that.value_arr['approvevalue']=ld("#"+that.divid+" [name=positiondepartment1]").val()+"::"+ld("#"+that.divid+" [name=positiondepartment2]").val();
            that.value_arr['approvevalue_label'] =  ld("#"+that.divid+" [name=positiondepartment1]").find(' option:selected').text()+":"+ld("#"+that.divid+" [name=positiondepartment2]").find(' option:selected').text();
        }
        if(((parseInt(approve_type)>=1&&parseInt(approve_type)<=4) || parseInt(approve_type)>6)&&(( that.value_arr['emptyapproverdeal']!='transfertomanager'&&that.value_arr['emptyapproverdeal']!='autopass')))
        {
        
            that.value_arr['emptyapproverdeal']=ld("#"+that.divid+" [name=transfer_userid]").val();
            that.value_arr['emptyapproverdeal_username']=ld("#"+that.divid+" [name=transfer_userid_name]").val();
             
        }
        that.value_arr['edit']='yes';

        var tablemodulefieldobj=ld("#"+that.divid+" [name=tablemodulefield]");
        var module_field_arr=[];
        //审批必填
        ld.each(ld(tablemodulefieldobj).find(" [type=checkbox]"),function(){

                if(ld(this).prop("checked")){

                        module_field_arr.push(ld(this).val())
                }
        })
        that.value_arr.module_field=module_field_arr;
        //duan 20230714 审批必填字段格式修改
        that.value_arr.mandatoryfield = that.popupobj.mandatoryfieldobj.getMandatoryField();

        //保存提醒
        try {
            var reminddatainfo_arr={};
            ld.each(that.remindinfo['groups'],function(tmpindex,remindtype){
                var trobjs=ld("#"+that.divid+" table[remindtype="+remindtype+"]").find(" tr[deleted=no]");
                var remindrowindex=0;
                reminddatainfo_arr[remindtype]=[];
                ld.each(trobjs,function(){
                    var remindmethod=ld(this).find(" [name=remindmethod]").val();
                    var remindapprover=ld(this).find(" [name=remindapprover]").val();
                    var reminddtitle=ld(this).find(" [name=title]").val();
                    var remindcontent=ld(this).find(" [name=content]").val();
                    var  selectfield=ld(this).find(" [name=remindselectfield]").val();

                    var  stage_smstemplate_arr=ld(this).data("stage_smstemplate_arr") || '';
                    //其他消息类型为空可以保存，短信不行
                    if (remindmethod == 'sms' && that.approveremindobj.sms_platform == 'aliyun') {
                        // console.log(stage_smstemplate_arr);
                        if (empty(stage_smstemplate_arr) || (!empty(stage_smstemplate_arr) && empty(stage_smstemplate_arr['templateid']))) {
                            var confirm_str = arrJsPopLabel['REMINDERSCANOTEMPTY'] + '!';
                            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            throw 'ExitLoops';
                        }
                        var  smstemplateid=stage_smstemplate_arr['templateid'];
                        var  smstemplateparamconf=stage_smstemplate_arr['templateparamconf'];
                        var  templatecontent=stage_smstemplate_arr['templatecontent'];//关闭弹窗再打开时需要记住使用
                    }



                    if(reminddatainfo_arr[remindtype][remindrowindex]==undefined){
                        reminddatainfo_arr[remindtype][remindrowindex]={};
                    }

                    reminddatainfo_arr[remindtype][remindrowindex]={
                        'method':remindmethod,'users':remindapprover
                        ,'reminduserid':'','remindcolumnname':''
                        ,'content':remindcontent,'title':reminddtitle
                        ,'platform':that.approveremindobj.sms_platform,'templateid':smstemplateid,'templateparamconf':smstemplateparamconf,'templatecontent':templatecontent
                    }

                    if(['selectuser','selectrole','departmentposition','topposition','departmentuser'].includes(remindapprover)){
                        reminddatainfo_arr[remindtype][remindrowindex].reminduserid=selectfield
                    }
                    else{
                        reminddatainfo_arr[remindtype][remindrowindex].remindcolumnname=selectfield
                    }
                    remindrowindex++;


                })

            })
        }catch (e){
            if (e === 'ExitLoops') {
                console.log('退出循环');
                return false;
            }
        }



       that.value_arr.reminddata=reminddatainfo_arr

       //高级功能
       var tableobj=ld("#"+that.divid+" [name=changetable]");
        var changefieldvalue_arr=[];
       ld.each(ld(tableobj).find(" tr[deleted=no]"),function(){
                var passtype=ld(this).find(" [name=passtype]").val();
                var fieldvalue=ld(this).find(" [name=fieldvalue]").val();
                var passfield=ld(this).find(" [name=passfield]").val();
                changefieldvalue_arr.push({'passtype':passtype,'value':fieldvalue
                        ,'columnname':passfield})

       })
       that.value_arr.fieldvalue=changefieldvalue_arr;
       
       that.approvestepflowobj.stepflow_arr[that.curstepindex].stepname=that.value_arr['stepname'];
       that.approvestepflowobj.stepflow_arr[that.curstepindex].stepinfo=that.value_arr;
       
        ld(".first-drawer-headerbtn").click();
       that.approvestepflowobj.innerNodeHtml();
       
    }
    this.getapproverremovetype=function(){
        //去重

        if(that.value_arr["approverremovetype"]=='no')
        {
            ld("#"+that.divid+" [name=removechoose]").prop("checked",false);//同一审批人多次出现时 审批人和提交人相同时去重
            ld("#"+that.divid+" [name=approverremovetype]").prop("checked",false);//仅保留第一个 仅在连续出现时去重
            ld("#"+that.divid+" [name=dv_removeapprovemethod]").css("display",'none');
            return false;
        }
         ld("#"+that.divid+" [name=removechoose]").prop("checked",true);//同一审批人多次出现时 审批人和提交人相同时去重
         ld("#"+that.divid+" [name=approverremovetype]").prop("checked",false);//仅保留第一个 仅在连续出现时去重
        ld("#"+that.divid+" [name=dv_removeapprovemethod]").css("display",'');
        ld("#"+that.divid+" [name=removesetting]").prop("checked",true);
        if(that.value_arr["approverremovetype"]!='approversamesubmitter')
        {
            //审批人和提交人相同时去重
            ld("#"+that.divid+" [name=removechoose][value=approversamesubmitter]").prop("checked",false)
            ld("#"+that.divid+" [name=approverremovetype][value="+that.value_arr["approverremovetype"]+"]").prop("checked",true)

        }
        else{

             ld("#"+that.divid+" [name=removechoose][value=approvercounterremove]").prop("checked",false)
            
        }
    }
    this.getChangewritesignlogtype=function(){
       that.getChangeWriteSignRequired();
    }
    this.getChangeWriteSignRequired=function()
    {

        ld("#"+that.divid+" [name=writesignlogtype]").prop("checked",false);

        if(that.value_arr['writesignrequired']=='yes')
        {
            //显示
            //手写签名必填
            
            ld("#"+that.divid+" [name=dv_writesignrequired]").css("display",'')
            ld("#"+that.divid+" [name=writesignlogtype][value="+that.value_arr['writesignlogtype']+"]").prop("checked",true);
            ld("#"+that.divid+" [name=writesignrequired]").prop("checked",true);

        }
        else{
            //隐藏
            ld("#"+that.divid+" [name=dv_writesignrequired]").css("display",'none')
            ld("#"+that.divid+" [name=writesignrequired]").prop("checked",false);
        }

    }
    this.emptyapproverdealfun=function(){
        ////选中‘审批人为空时’类型,
      

        //控制其他选择项取消选中
         var user_trobj = ld("#"+that.divid+" [name=transferusername_tr]");
        if(that.value_arr['emptyapproverdeal']=='')
        {
                 user_trobj.hide();
                 return ;
        }

        var radio_objs = ld("#"+that.divid+" [tag=emptyapproverdeal]");
        radio_objs.prop('checked',false);
      

        if( that.value_arr['emptyapproverdeal']=='transfertomanager'||that.value_arr['emptyapproverdeal']=='autopass')
        {
             user_trobj.hide();
            ld("#"+that.divid+" [name="+that.value_arr['emptyapproverdeal']+"]").prop("checked",true)
        }
        else{
            ld("#"+that.divid+" [name=transfertouser]").prop("checked",true)
            if(that.value_arr['emptyapproverdeal']!='transfertouser')
            {
                ld("#"+that.divid+" [name=transfer_userid]").val(that.value_arr['emptyapproverdeal'])
                ld("#"+that.divid+" [name=transfer_userid_name]").val(that.value_arr['emptyapproverdeal_username'])
            }
              //选择'转交指定人审批'时，出现选择用户框
             user_trobj.show();
             
        }
       

      
  }
    this.getChangeApproveType=function (obj)
    {
       
        
        var index=parseInt(obj.options[obj.selectedIndex].value);
      
       ld("#"+that.divid+" [name=userid_name]").html('');
       ld("#"+that.divid+" [name=userid]").val();
       ld("#"+that.divid+" [name=role_name]").val();
       ld("#"+that.divid+" [name=user_role]").val();
       
        ld("#"+that.divid+" [name=tr_countersigner]").css('display','');//显示（多人审批/多人审批）
        that.value_arr['approvetype']=index;
        that.value_arr['approvetype_label']=obj.options[obj.selectedIndex].text;
        if(empty(that.value_arr['approvevalue']))that.value_arr['approvevalue'] = '';
        switch(index){
            case 0://指定成员
            ld('#role_name_tr').css("display",'none');
            ld('#username_tr').css("display",'');
            ld('#username_tr2').css("display",'');
            ld('#position_tr').css("display",'none');
            ld('#positionlevel_tr').css("display",'none');

            ld('#positiondepartment_tr1').css("display",'none');
            ld('#positiondepartment_tr2').css("display",'none');

            var approvevalue = that.value_arr['approvevalue'];
            ld("#"+that.divid+" [name=userid_name]").html(that.value_arr['approvevalue_name']);
            ld("#"+that.divid+" [name=userid]").val(approvevalue);
            ld("#"+that.divid+" [name=tr_countersigner]").css('display','none');
            //duan 20240109 修复审批步骤编辑编辑页面,指定成员时,或/会签选项不显示的问题
            if(!empty(approvevalue)){
                var approvevalue_arr = approvevalue.split(',');
                if(approvevalue_arr.length>1){
                    ld("#"+that.divid+" [name=tr_countersigner]").css('display','');
                }
            }

            that.value_arr['emptyapproverdeal']='';//不需要设置审批人为空的判断

            break;
            case 1://指定角色
            ld('#role_name_tr').css('display','');
            ld('#username_tr').css('display','none');
            ld('#username_tr2').css('display','');
            ld('#position_tr').css('display','none');
            ld('#positionlevel_tr').css('display','none');
            ld("#"+that.divid+" [name=role_name]").val(that.value_arr['approvevalue_name']);
            ld("#"+that.divid+" [name=user_role]").val(that.value_arr['approvevalue']);
            ld('#positiondepartment_tr1').css('display','none');
            ld('#positiondepartment_tr2').css('display','none');
            break;
            case 2://单据负责人部门成员的职位级别
            ld('#role_name_tr').css('display','none')
            ld('#username_tr').css('display','none')
            ld('#username_tr2').css("display",'');
            ld('#position_tr').css('display','')
            ld('#positionlevel_tr').css('display','none')

            ld('#positiondepartment_tr1').css('display','none')
            ld('#positiondepartment_tr2').css('display','none')
            ld("#"+that.divid+" [name=position]").val(that.value_arr['approvevalue']);//职位级别
            break;
            case 3://单据负责人直属上级部门成员的职位级别
            ld('#role_name_tr').css('display','none')
            ld('#username_tr').css('display','none')
            ld('#username_tr2').css('display','')
            ld('#position_tr').css('display','none')
            ld('#positionlevel_tr').css('display','')
            ld("#"+that.divid+" [name=positionlevel]").val(that.value_arr['approvevalue']);//职位级别
            ld('#positiondepartment_tr1').css('display','none')
            ld('#positiondepartment_tr2').css('display','none')
            break;
            case 4://指定部门成员的职位级别
            ld('#role_name_tr').css('display','none')
            ld('#username_tr').css('display','none')
            ld('#username_tr2').css('display','')
            ld('#position_tr').css('display','none')
            ld('#positionlevel_tr').css('display','none')

            ld('#positiondepartment_tr1').css('display','');
            ld('#positiondepartment_tr2').css('display','');
            var tmpvalue=that.value_arr['approvevalue'].split('::');
            if(tmpvalue.length==2)
            {
                ld("#"+that.divid+" [name=positiondepartment1]").val(tmpvalue[0]);
                ld("#"+that.divid+" [name=dv_cmb_positiondepartment1]").find(" [tag=txt_search]").html(
                ld("#"+that.divid+" [name=positiondepartment1]").find("option:selected").text());
                ld("#"+that.divid+" [name=positiondepartment2]").val(tmpvalue[1]);//职位级别
            }
            break;
            case 5://单据创建人
            case 6://单据负责人
            ld('#role_name_tr').css('display','none')
            ld('#username_tr').css('display','none')
            ld('#position_tr').css('display','none')
            ld('#positionlevel_tr').css('display','none')
            ld("#"+that.divid+" [name=tr_countersigner]").css('display','none');
            ld('#positiondepartment_tr1').css('display','none')
            ld('#positiondepartment_tr2').css('display','none')
           that.value_arr['emptyapproverdeal']='';//不需要设置审批人为空的判断
            break;
        }
        if(index > 6){
            ld('#role_name_tr').css('display','none')
            ld('#username_tr').css('display','none')
            ld('#position_tr').css('display','none')
            ld('#positionlevel_tr').css('display','none')
            ld('#positiondepartment_tr1').css('display','none')
            ld('#positiondepartment_tr2').css('display','none')
            
            //duan 20221123 多选用户字段允许选择或签和会签
            var uitype=parseInt(ld(obj).find('option:selected').attr('uitype'));
            if(uitype == 154){
                ld("#"+that.divid+" [name=tr_countersigner]").css('display','');
            }else{
                ld("#"+that.divid+" [name=tr_countersigner]").css('display','none');
            }
        }
        //根据审批人类型判断是否需要显示’审批人为空时‘的判断
        var appovertype_arr = new Array(1,2,3,4);
        if(index>6|| appovertype_arr.indexOf(index) != -1){
               ld("#"+that.divid+" [name=when_approver_empty]").show();
            //如果审批人为空未选中，则默认选择自动转交管理员
            var emptyapproverdealobj = ld("#"+that.divid+" [tag=emptyapproverdeal]:checked");
            if(emptyapproverdealobj.length<=0){
                ld("#"+that.divid+" [name=transfertomanager]").prop('checked',true);
            }
            
            //如果选择为'指定成员审批',则显示选择用户输入框
            if(ld("#"+that.divid+" [name=transfertouser]").length>0&&ld("#"+that.divid+" [name=transfertouser]").prop('checked')){
                ld("#"+that.divid+" [name=transferusername_tr]").show();
                //获取选中的成员个数，用于隐藏显示多人审批
                var strhtml=ld("#"+that.divid+" [name=transfer_userid_name]").html();
                if(!empty(strhtml)){
                    var tmps=strhtml.split(",");
                    if(tmps.length>1&&tmps[1]!=''&&tmps[1]!=',')
                    {
                        //选择多个，显示多人审批
                        ld("#"+that.divid+" [name=tr_countersigner]").css('display','');
                    }
                }

                    
            }
        }else{
            ld("#"+that.divid+" [name=when_approver_empty]").hide();
            ld("#"+that.divid+" [name=transferusername_tr]").hide();
        }
 
        /*
        var cls_resetComboxHtmlobj=new cls_resetComboxHtml('positiondepartment1');
        cls_resetComboxHtmlobj.setPopupObj(that.popupobj);
        cls_resetComboxHtmlobj.setPickListContent(that.ajaxdata.result.group);
        cls_resetComboxHtmlobj.searchhtmltype='div';
        cls_resetComboxHtmlobj.setComboxObjHtml();
        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
        {
          
            cls_wxOpenDataobj.bindAllOpenDataByPopupObj(that.popupobj);
        }
        ld('#positiondepartment_tr1 [name=dv_cmb_positiondepartment1]').css('width','calc(100% - 100px)');
        ld('#positiondepartment_tr1 [name=cmb_span_optiontext_positiondepartment1]').css('width','191px');
        */
    }
    /**
 * 选择审批步骤指定审批人
 * @author Tujt 2015-04-29
 */
this.approve_selectuser=function(){
        /* editor:gyq_14 */
   
        getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
            ScopePopup_Details.getInstance().wareHouseselectUser('userid','userid_name','approvestep');
        });


        ld("#"+that.divid+" [name=userid_name]").unbind("DOMNodeInserted").bind("DOMNodeInserted", function(){
            //edit:can 20200715 获取选中的成员个数，用于隐藏显示多人审批
            var strhtml=ld(this).html();
            if(strhtml==''){
                //没有选择，隐藏多人审批
                ld("#"+that.divid+" [name=tr_countersigner]").css('display','none');
                ld("#"+that.divid+" [name=countersigner]:first").prop("checked",true);
            }
            else
            {
                var tmps=strhtml.split(",");
                if(tmps.length>1&&tmps[1]!=''&&tmps[1]!=',')
                {
                    //选择多个，显示多人审批
                    ld("#"+that.divid+" [name=tr_countersigner]").css('display','');
                }
                else{
                     //选择一个，隐藏多人审批
                    ld("#"+that.divid+" [name=tr_countersigner]").css('display','none');
                   ld("#"+that.divid+" [name=countersigner]:first").prop("checked",true);
                }
            }
            
        });
    }
}