//ls 20221012 XUQIU1000284  增加“工作汇报（列表）”模块(切换页签)
function getWorkReportLogType(logtype,obj){
    if(obj!=null){
        var liobjs = ld('ul[class=ld-ui-tabs-nav]').children();
        ld.each(liobjs,function(){
            ld(this).removeClass();
        })

        ld(obj).addClass('ld-ui-tabs-active');
    }

    // var url = 'workreport_logtype='+logtype;
    // getListViewEntries_js('WorkReportList',url);


        var popupobj=CrmPopup.getPopupObj("last");
        ld('#rptContentLoading').show();
        /*if(ld(inputobj).prop("tagName") == 'SELECT'){
            var pool_id = ld(inputobj).val();
            var publicaccounttype = ld(inputobj).find("option:selected").attr("accounttype");
        }else{
            var pool_id = ld(inputobj).attr('pool_id');
            var publicaccounttype =  ld(inputobj).attr('accounttype');
        }*/
        // var viewname = encodeURIComponent(ld("#"+popupobj.divid+" [name=viewname]").val());
        var searchScope = '';
        if(ld("#"+popupobj.divid+" [name=SmOwnerSearchScope]")!=null)
            searchScope= encodeURIComponent(ld("#"+popupobj.divid+" [name=SmOwnerSearchScope]").val());
        ld("#workreport_logtype").val(logtype);

        var listview_page=new ListView_Page('WorkReportList',"module=WorkReportList&action=WorkReportListAjax&file=ListView&start=1&SearchScope="+searchScope+"&workreport_logtype="+logtype,"pagecontent1");
        listview_page.callback_fun=function()
        {
            popupobj.listresizeobj.setReiszeTable_Init(module,'ajax');
            setContentHeight(module);//计算内容高度
            IsFrameElement();
        }
        listview_page.page();
}


//操作列  现在点评
function NowReview(obj,record){
    var url="index.php?module=WorkReportList&action=WorkReportListAjax&file=NowReview";
    url += '&method=createreaderpop&record='+record+'&workreportid='+record;

    var Popupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
    Popupobj.prevshow();
    //alert(url);
    ld.ajax({
        url: url,
        type: 'POST',
        dataType:'json',
        timeout:20000,
        success:function(data){
            Popupobj.setParams(data.result.title,saveReview,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
            Popupobj.createScrollDiv();
            Popupobj.show(data.result.content);
            // Popupobj.setScrollDivMaxHeight();
            Popupobj.center();

            //抄送范围事件
            ld('#dialogDiv .ui-popup-centent div[tag=dialog]').click(function(event){
                var e = event || window.event;
                var obj = e.srcElement||e.target;
                obj = ld('#dialogDiv .ui-popup-centent div[tag=dialog] .show-select-panel').get(0);
                //日志点评 - 选择抄送范围时，不隐藏其他弹出层
                pop_num = 1;
                if('remove-h' == ld(obj).attr('class')){
                    return false;
                }
                ld('#dialogDiv .ui-popup-centent div[tag=dialog] input.input-field').removeClass('ui-hide');
                ld('#dialogDiv .ui-popup-centent div[tag=dialog] input.input-field').addClass('ui-show');
                if('show-select-panel' != ld(obj).attr('class')){
                    //ld('#dialogDiv .ui-popup-centent div[tag=dialog] .input-tip').css('display','none');
                    //ld('#dialogDiv .ui-popup-centent div[tag=dialog] input.input-field').focus();
                    ld(obj).click();
                }else{
                    var selectUserid = [];//默认选中的用户id
                    var selectNum = 0;
                    ld('#dialogDiv .ui-popup-centent div[tag=dialog] ul.reader-bar-list li').each(function(){
                        selectUserid[selectUserid.length] = ld(this).attr('userid');
                        selectNum++;
                    });
                    var userids = '';
                    selectUserid+='';
                    //41884: （https://61mis.com/kfbtest/ [^]）工作汇报，点击现在点评弹出层中，抄送范围选择成员后，再点击选择抄送范围按钮点不动

                    if(ld.trim(selectUserid).length > 0){
                        userids = selectUserid.split(',');
                    }
                    //选择抄送范围事件
                    setEventSelectUserForReview('dialogDiv .ui-popup-centent div[tag=dialog]',selectNum,userids);
                }
            });

        }
    });
}
saveReview.funname = 'saveReview';

//选择抄送范围事件(复制的工作汇报Coordination.js的方法)
setEventSelectUserForReview = function(div_tag,selectNum,selectUserid){
    var module = 'CooperativeWork';
    var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_module='+module+'&popup_inputtype=checkbox';

    if(div_tag=='_select_sponsor_div')
    {
        //选择发起人
        popup_url+="&popup_scopetype=private";
    }
    //zkt 0046534: （81mis.com/kfbcrm）OA表单-工作汇报-新建，新建日志抄送时，没有“子部门默认收起”的控制按钮
    var popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['searchforcolleagues']+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
    getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
        var scopepopupobj =  new ScopePopupObj(module);
        scopepopupobj.popup_caption_value =arrJsPopLabel['LBL_SELECTUSER'];//标题
        scopepopupobj.popup_searchvalue = arrJsPopLabel['searchforcolleagues'];//查询框默认值
        scopepopupobj.popup_header = popup_header;
        scopepopupobj.popup_searchTextDiv = '<div id=\'popup_search_div\' style=\'padding-left:59px;display: block;position: absolute;top: 84px;\'><div class=\'view-search\' ></div></div>';
        scopepopupobj.popup_footer = '<div class="E_pbtn"><div>'+arrJsPopLabel['isselect']+'<span id="selectnum">0</span>/<span id="totalnum">77</span></div><div><input class="E_pbtnok" value="'+arrJsPopLabel['CONFIRME']+'" type="button"><span>&nbsp;</span>'+'<input class="E_pbtncancel" value="'+arrJsPopLabel['CANCEL']+'" type="button"></div></div>';
        getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
            cls_ScopePopup.prop.popup_url = popup_url;//popup_url
            cls_ScopePopup.prop.popup_module = module;//模块
            cls_ScopePopup.prop.popup_value = selectUserid;
            var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
            ld('#'+cls_ScopePopup.popup_divid).css('z-index',"9999");
            //加载用户总数和已选的用户数
            scopepopupobj.setEventLoad=function(){
                var selectUseridAll = [];//显示的全部用户数
                var viewuser_nogroupuser = ld('#viewuser_nogroupuser').prop('checked');
                //alert(cls_ScopePopup.popup_divid);
                ld('#'+cls_ScopePopup.popup_divid+' .filetree span').each(function(){
                    var record = ld(this).attr('record');
                    var recordarr = record.split('_');
                    //处理用户图标
                    if('user' == recordarr[0]){
                        //ld(this).attr('class','user');
                        var parentfilter = ld(this).attr('parent');
                        var parentarr = parentfilter.split('_');
                        if('Inactive' != parentarr[1] &&  'Inactive' != parentarr[2]){//因为停用用户不显示，所以在这不进行计算
                            if('nogroup' == parentarr[1]){
                                /*if(!viewuser_nogroupuser){//false
                                    if(ld('#viewuser_disableuser').prop("checked")==true){
                                        selectUseridAll[selectUseridAll.length] = recordarr[1];
                                    }
                                }else{*/
                                selectUseridAll[selectUseridAll.length] = recordarr[1];
                                //}
                            }else{
                                selectUseridAll[selectUseridAll.length] = recordarr[1];
                            }
                        }
                    }
                });
                var userAll = js_unique(selectUseridAll);
                ld('#selectnum').html(selectNum);//已选
                ld('#totalnum').html(userAll.length);//全部
                ld('#viewuser_nogroupuser').unbind('click').on('click',function(){
                    cls_ScopePopups.noGroupUser('viewuser_nogroupuser');
                    if(!empty(cls_ScopePopup.return_obj.return_id)){
                        var userid = cls_ScopePopup.return_obj.return_id.split(',');
                        selectNum = userid.length;//已选
                    }else{
                        selectNum = 0;
                    }
                    scopepopupobj.setEventLoad();
                });
            }
            //用户选择后的执行事件
            scopepopupobj.setEventSelGroupByUsers=function(){
                if(!empty(cls_ScopePopup.return_obj.return_id)){
                    var userid = cls_ScopePopup.return_obj.return_id.split(',');
                    ld('#selectnum').html(userid.length);//已选
                }else{
                    ld('#selectnum').html(0);
                }

            }
            //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){

                    //基本查询 - 发起人
                    if(div_tag == '_select_sponsor_div'){

                        ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();

                        var userid = cls_ScopePopup.return_obj.return_id.split(',');
                        var _name;
                        ld('#'+div_tag+' ul.reader-bar-list').empty();
                        //一个用户
                        if(userid.length == 1){
                            _name = cls_ScopePopup.return_obj.return_name;
                        }else{
                            _name = userid.length +'个同事';
                        }
                        ld('#'+div_tag+' ul.reader-bar-list').append('<li><span class="item-name">'+_name+'</span><span class="remove-h">×</span></li>');
                        ld('#'+div_tag+' ul.reader-bar-list li .remove-h').unbind('click').click(function(){
                            ld('#'+div_tag+' ul.reader-bar-list li').remove();
                            ld('#sponsor_value').val('');
                            fun_search();
                            return false;
                        });
                        ld('#sponsor_value').val(userid);
                        //edit:can 2020-11-25 043346: （https://61mis.com/kfbtest [^]）工作汇报的日志中如果先将页面下拉到底部加载出更多的工作汇报，这时候点击筛选，指定发起人。下方新加载出来的信息不会被隐藏。
                        ld('.pubDetialC').html('<div id="worklist_page_1"></div>');
                        fun_search();
                    }else{
                        //没有选择任何用户，则给出提示
                        if(empty(cls_ScopePopup.return_obj.return_id)){
                            var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                            return false;
                        }else{
                            ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                            var userid = cls_ScopePopup.return_obj.return_id.split(',');
                            var username = cls_ScopePopup.return_obj.return_name.split(',');
                            //每次确认之前，先情况之前记录
                            ld('#'+div_tag+' ul.reader-bar-list').empty();
                            for(var i = 0; i < userid.length; i++){
                                //添加新的li
                                ld('#'+div_tag+' ul.reader-bar-list').append('<li userid="'+userid[i]+'"><span class="item-name">'+username[i]+'</span><span class="remove-h">×</span></li>');
                                //绑定删除事件
                                ld('#'+div_tag+' ul.reader-bar-list li[userid='+userid[i]+'] .remove-h').unbind('click').click(function(){
                                    var liuserid = ld(this).parent().attr('userid');
                                    ld('#'+div_tag+' ul.reader-bar-list li[userid='+liuserid+']').remove();
                                    return false;
                                });
                            }
                        }
                    }
                    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                    {
                        //通讯录(pc端企业微信)
                        cls_wxOpenDataobj.bindAllOpenData();
                    }

                });
            }
        });
    });
}
//保存点评内容
function saveReview() {
    var popupobj=CrmPopup.getPopupObj("last");
    var record = ld("#"+popupobj.divid+" [name=record]").val();
    var reader_content = ld('#dialogDiv textarea.input-text').val();
    var reader_score = ld('#dialogDiv select.commenton-select').val();
    var ccuser = '';var ccgroup = '';//抄送范围 用户、部门
    if(ld('#dialogDiv div.ui-popup-centent div[tag=dialog] ul.reader-bar-list li').length > 0){
        ld('#dialogDiv div.ui-popup-centent div[tag=dialog] ul.reader-bar-list li').each(function(){
            if(ld(this).attr('userid') != undefined && ld(this).attr('userid') > 0){
                ccuser += ld(this).attr('userid')+',';
            }else if(ld(this).attr('groupid') != undefined && ld(this).attr('groupid') > 0){
                ccgroup += ld(this).attr('groupid')+',';
            }
        });
    }
    var urlstring = 'module=WorkReportList&action=WorkReportListAjax&file=NowReview';
    urlstring += '&method=savereader&savetype=savecomment';
    urlstring += '&reader_content='+encodeURIComponent(reader_content)+'&reader_score='+reader_score;
    urlstring += '&ccuser='+ccuser+'&ccgroup='+ccgroup+'';
    urlstring += '&record='+record+'&workreportid='+record;

    RequestAjax(urlstring,function(rest){
        CrmPopup.getPopupObj("last").CancelEvent();
        DelProgressObjs();

        var popupobj=CrmPopup.getPopupObj("last");
        var pagenum = ld("#"+popupobj.divid+" [name=pagenum]").val();
        getListViewEntries_js('WorkReportList','&start='+pagenum);//刷新页面

    });
}