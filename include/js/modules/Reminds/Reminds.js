
function getSelected(txtid){
    cbobj=document.getElementsByName('cb_select_user');
    txtidobj=document.getElementById(txtid);
    txtobj=document.getElementById('txt_select_user');
    if(cbobj!=undefined&&txtobj!=undefined&&txtidobj!=undefined){
        txtobj_str='';
        txtidobj_str='';
        for(i=0;i<cbobj.length;i++){
            if(cbobj[i].checked){
                sp_obj=document.getElementById('sp_user_'+i);
                txt_obj=document.getElementById('txt_user_'+i);
                txtobj_str=txtobj_str+sp_obj.innerHTML+',';
                txtidobj_str=txtidobj_str+txt_obj.value+',';
            }
        }
        txtobj_str=txtobj_str.substr(0,txtobj_str.lastIndexOf(','));
        txtidobj_str=txtidobj_str.substr(0,txtidobj_str.lastIndexOf(','));
        txtobj.value=txtobj_str;
        txtidobj.value=txtidobj_str;
    }
}
function fnDropDownUsers(obj,Lay,topY){
	var tagName = document.getElementById(Lay);
	var leftSide = findPopX(obj);
	var topSide = findPopY(obj);
	var maxW = tagName.style.width;
	var widthM = maxW.substring(0,maxW.length-2);
	var getVal = eval(leftSide) + eval(widthM);
	if(getVal  > document.body.clientWidth ){
		leftSide = eval(leftSide) - eval(widthM);
		tagName.style.left = leftSide + 34 + 'px';
	}
	else
		tagName.style.left= leftSide + 'px';
        if(topY!=undefined){
        tagName.style.top= topSide + topY+'px';
        tagName.style.width=obj.clientWidth+'px';
        }
        else
		tagName.style.top= topSide + 28 +'px';
		tagName.style.display = 'block';
}
function set_return(product_id, product_name) {
	if(document.getElementById('from_link').value != '') {
        window.opener.document.QcEditView.parent_name.value = product_name;
        window.opener.document.QcEditView.parent_id.value = product_id;
	} else {
        window.opener.document.EditView.parent_name.value = product_name;
        window.opener.document.EditView.parent_id.value = product_id;
	}
}
function set_return_specific(product_id, product_name) {
        
        //getOpenerObj used for DetailView 
	if(document.getElementById('from_link').value != '')
	{
		var fldName = window.opener.document.QcEditView.accounts_name;
		var fldId = window.opener.document.QcEditView.account_id;
	}else
	{	
		var fldName = window.opener.document.EditView.accounts_name;
		var fldId = window.opener.document.EditView.account_id;
	}
        fldName.value = product_name;
        fldId.value = product_id;
}
function add_data_to_relatedlist(entity_id,recordid) {

        opener.document.location.href="index.php?module=Emails&action=updateRelations&destination_module=Accounts&entityid="+entity_id+"&parentid="+recordid;
}
function set_return_formname_specific(formname,product_id, product_name) {
        window.opener.document.EditView1.accounts_name.value = product_name;
        window.opener.document.EditView1.account_id.value = product_id;
}


//added by rdhital/Raju for emails
function submitform(id){
		document.massdelete.entityid.value=id;
		document.massdelete.submit();
}	

function findPopX(obj)
{
  var curleft = 0;
        if (document.getElementById || document.all) {
                while (obj.offsetParent && obj.offsetParent.id!="qcform") { curleft += obj.offsetLeft; obj = obj.offsetParent;}
        }        
        else if (document.layers) { curleft += obj.x; }
        return curleft;
}

function findPopY(obj)
{
  var curtop = 0;
        if (document.getElementById || document.all) {
                while (obj.offsetParent && obj.offsetParent.id!="qcform") { curtop += obj.offsetTop; obj = obj.offsetParent;}
        }        
        else if (document.layers) { curtop += obj.Y; }
        return curtop;
}
/*function findPosX(obj) {
   
        var curleft = 0;
        if (document.getElementById || document.all) {
                while (obj.offsetParent) { curleft += obj.offsetLeft; obj = obj.offsetParent;}
        }
        
        else if (document.layers) { curleft += obj.x; }
        //alert(curleft);
        return curleft;
}


function findPosY(obj) {
        var curtop = 0;
        if (document.getElementById || document.all) {
                while (obj.offsetParent) { curtop += obj.offsetTop; obj = obj.offsetParent; }
        }
        else if (document.layers) {curtop += obj.y;}
        return curtop;
}
*/
ScrollEffect = function(){ };
ScrollEffect.lengthcount=202;
ScrollEffect.closelimit=0;
ScrollEffect.limit=0;


function just(){
        ig=getObj("company");
        if(ScrollEffect.lengthcount > ScrollEffect.closelimit ){closet();return;}
        ig.style.display="block";
        ig.style.height=ScrollEffect.lengthcount+'px';
        ScrollEffect.lengthcount=ScrollEffect.lengthcount+10;
        if(ScrollEffect.lengthcount < ScrollEffect.limit){setTimeout("just()",25);}
        else{ getObj("innerLayer").style.display="block";return;}
}

function closet(){
        ig=getObj("company");
        getObj("innerLayer").style.display="none";
        ScrollEffect.lengthcount=ScrollEffect.lengthcount-10;
        ig.style.height=ScrollEffect.lengthcount+'px';
        if(ScrollEffect.lengthcount<20){ig.style.display="none";return;}
        else{setTimeout("closet()", 25);}
}


function fnDown(obj){
        var tagName = document.getElementById(obj);
        document.EditView.description.value = document.getElementById('summary').innerHTML;
        document.EditView.employees.value = getObj('emp').value;
        document.EditView.website.value = getObj('site').value;
        document.EditView.phone.value = getObj('Phone').value;
        document.EditView.fax.value = getObj('Fax').value;
        document.EditView.bill_street.value = getObj('address').value;
        if(tagName.style.display == 'none')
                tagName.style.display = 'block';
        else
                tagName.style.display = 'none';
}

function set_return_todo(product_id, product_name) {
        window.opener.document.createTodo.task_parent_name.value = product_name;
        window.opener.document.createTodo.task_parent_id.value = product_id;
}

//Changing account address info - ENDS
/*
edit:limengxing
date:20140212
reason:温馨提醒改进(V5.3)
other:提醒状态修改为已读
*/
function setRemindReaden(remindid,isReminds_popupexist='',  current_page = 0, is_last = 0)
{
    //zkt 20231012 XUQIU1001341 SQL注入
    var url='module=Reminds&ReportHeader=DHeader&types=update_state&action=SetRemindReaden&remindsid='+remindid;
    ldAjaxHtmlNoProgress('index.php?',url,function(response) {
        ActivityReminderCallbackProcessg(response,isReminds_popupexist);
        /* var remindcount = ld('#headerremindscount').html();
         remindcount = remindcount.substring(remindcount.indexOf("(")+1,remindcount.indexOf(")"))
         remindcount = remindcount - 1;
         ld('#headerremindscount').html('('+remindcount+')');*/
        getRemindsCount();
        //wyt BUG0055462 220823 消息提醒点击上面的设为已读，消息提醒界面更新为下一条，但是下面的只有数字变了，点击下面的也一样
        getJsScript('include/js/ListViewButton.js', function () {
            setRemindReadenHeaderSecond(remindid,'',  current_page, is_last);
        });
    });
}
function getRemindsCount()
{
    if(ld('#noticebar').length > 0){
        //zkt 20231012 XUQIU1001341 SQL注入
        ldAjaxHtmlNoProgress('index.php?','module=Reminds&ReportHeader=DHeader&action=getRemindsCount',function(response) {
            //wym BUG0068415 kfbcrm-消息中心-将所有消息提醒设为已读，右上角消息后边应显示“（0）”
            if(response!=''&&parseInt(response)>=0){
                if(ld('#reminds_popup_expansion .remind_notread_count') != undefined){
                    ld('#reminds_popup_expansion .remind_notread_count').html('('+response+')');
                }
                ld('#headerremindscount').html('('+response+')');
                // ld('#remind_notread_count').html(response.responseText);
                // ld('#reminds_popup').find('.Stcbox .R .C').html('<strong>1</strong> / '+response.responseText);
                ld('#noticeHeader .noticeHeaderContent .noticeBox_T').find('span').find('b').html('（1/'+response+'）');
                // 消息为0条时，去掉红点
                if(parseInt(response) == 0){
                    ld('#noticebar').removeClass('notice');
                }
            }else{
                if(ld('#reminds_popup_expansion .remind_notread_count') != undefined){
                    ld('#reminds_popup_expansion .remind_notread_count').hide();
                }
                ld('#headerremindscount').html('');
                ld('#noticebar').removeClass('notice');
            }
        });
    }

}

/*
edit:limengxing
date:20140212
reason:温馨提醒改进(V5.3)
other:更新该提醒的“提醒时间”
*/
function updateRemindtime(remindtime)
{
         document.getElementById("selectviewremind").style.display="none";
        if(document.getElementById("popremindids")!=undefined&&document.getElementById("popremindids").value)
        {
            var ids=document.getElementById("popremindids").value;
            //zkt 20231012 XUQIU1001341 SQL注入
            ldAjaxHtmlNoProgress('index.php?','module=Reminds&ReportHeader=DHeader&action=SetRemindReaden&remindtime='+remindtime+'&remindsid='+ids,function(response) {
                ActivityReminderCallbackProcessg(response);
                var remindcount = ld('#headerremindscount').html();
                remindcount = remindcount.substring(remindcount.indexOf("(")+1,remindcount.indexOf(")"))
                remindcount = remindcount - 1;
                if(empty(remindcount)){
                    if(ld('#reminds_popup_expansion .remind-notread-count') != undefined){
                        ld('#reminds_popup_expansion .remind-notread-count').hide();
                    }
                }else{
                    if(ld('#reminds_popup_expansion .remind-notread-count') != undefined){
                        ld('#reminds_popup_expansion .remind-notread-count').html(remindcount);
                    }
                }
                ld('#headerremindscount').html('('+remindcount+')');
                //wyt 220825 BUG0055570 下方点击推迟的消息，上方没有自动消除，只是数字减少了
                setRemindReadenHeaderSecond(ids,remindcount+1);
                //wyt 220921 BUG0056582 首页-消息，消息选择推迟的时候，数量不同步
                getRemindsCount();
            });
        }
}

/*
edit:limengxing
date:20140212
reason:温馨提醒改进(V5.3)
other:更新该提醒的“上一篇下一篇”
*/
function Remindpages(pages,ids,pagenum)
{
    //zkt 20231012 XUQIU1001341 SQL注入
    ldAjaxHtmlNoProgress('index.php?','module=Reminds&ReportHeader=DHeader&action=SetRemindReaden&pages='+pages+'&remindsid='+ids+'&pagenum='+pagenum,function(response) {
        ActivityReminderCallbackProcessg(response);
    });
}
/*
edit:limengxing
date:20140213
reason:温馨提醒改进
other:推迟弹出框
*/
function RemindDelayDropDown(event,obj,Lay){

    var tagName = document.getElementById(Lay);
        if(typeof tagName == 'undefined') {
        return false;
    }


    tagName.style.display = 'block';
    return false;
}

function cls_Reminds(){
    var that = this;
    this.module = 'Reminds';
    this.popupobj = {};
    this.firstpopupobj = {};
    this.secondpopupobj = {};
    this.ld_navbarobj = {};// 页签对象

    this.surl = 'index.php?module=Reminds&action=RemindsAjax&file=RemindsCenter';
    this.firstpopup_zindex = 0;// 一级弹出层z-index\
    this.firstpopcontent_height = 0;// 一级弹出层内容高度

    this.selected_categoryobj;// 所选分类的对象
    this.selected_cvid;// 所选页签id
    this.NavBarSelKey = 1;// 所选页签index
    this.pagenum = 1;// 当前页数
    this.searchparams = {};// 查找的参数

    this.is_admin = 'no';
    
    // 初始化第一个弹出层
    this.initFirstPopup = function (){
        var crmpopupobj=CrmPopup.load("","","",'LdPopWidth350px ld-remindscenter-popbox','Reminds',"","","","");
        crmpopupobj.position=CrmPopup.Positions.right;
        crmpopupobj.type = 'Reminds';
        crmpopupobj.setHeight(CrmPopup.getClientHeight());
        crmpopupobj.popupMaxHeight=(CrmPopup.getClientHeight())
        crmpopupobj.isclicklayerclose='yes';//点击遮罩层关闭弹出层
        crmpopupobj.proportion = 1;
        crmpopupobj.prevshow();
        var beforeajax_timestamp = new Date().getTime();// 请求开始前时间戳
        var surl = this.surl;
        var param = {'mode':'getcategory'};
        ldAjaxNoProgress(surl,param,function (data){
            if(data.code == 1){
                crmpopupobj.setParams(data.result.title, "", that.closeFirstPopup, "LdPopWidth350px ld-remindscenter-popbox", 'Reminds', "", "", "", "");
                crmpopupobj.createHeadHtml = function () {
                    this.popupheadhtml = '<div class="E_pop_tit" id="' + this.divid + '_head" style="cursor:move">';
                    this.popupheadhtml += '<strong class="E_ptita">' + this.headtitle + '</strong>';
                    
                    this.popupheadhtml+='<div class="E_pop_tit_Second_Right">';
                    if(data.result.is_admin == 'yes'){
                        this.popupheadhtml += '<b class="icon-categorybtn categorysear-search tip-items-list marR8" id="setCategoryBtn" data-tip="'+arrJsPopLabel['ClassificationSettings']+'" data-direction="bottom" data-type="position"></b>';
                    }
                    this.popupheadhtml += '<div class="listviewsecond list-item" id="RemindsListBtn" style="margin-top: -8px;"><span>'
                                            +'<i class="list-item-btn list-btn tip-items-list" data-tip="'+arrJsPopLabel['RemindsList']+'" data-direction="bottom" data-type="position"></i>'
                                            +'</span></div>';
                    this.popupheadhtml += '<div class="ld-fonticon ld-fonticon-close tip-items-pop" value="' + arrJsPopLabel['LBL_CLOSE'] + '" data-tip="' + arrJsPopLabel['LBL_CLOSE'] + '" data-direction="bottom" data-type="position"  id="' + this.divid + '_imgclose"></div>';
                    this.popupheadhtml += '</div>';
                    this.popupheadhtml += '</div>';
            
                }
                that.is_admin = data.result.is_admin;
                that.firstpopupobj = crmpopupobj;
                that.firstpopupobj.pagetytpe = 'remindscenterview';
                var contenthtml = that.setFirstPopupContent(data.result.category_arr);
                CrmPopup.setPopupobjHtmlscrolljquery_noposition(crmpopupobj,contenthtml);

                // 调整一级弹出层z-index，使其能至于二级弹出层上方
                that.firstpopup_zindex = CrmPopup.zIndex+4;
                ld("#"+that.firstpopupobj.divid).css('z-index',(that.firstpopup_zindex));
                var Popup_Drag = new PopupDrag(crmpopupobj,crmpopupobj.divid);
                document.removeEventListener('mousemove', Popup_Drag.handleMousemove);//清除监听
                CrmPopup.zIndex = that.firstpopup_zindex+1;
                // 绑定事件
                that.setFirstEvent();
                // 将类对象放在弹出层中
                that.firstpopupobj.clsremindsobj = that;
                // 计算出请求前后时间差
                var time_difference = new Date().getTime() - beforeajax_timestamp;
                // 时间差过小，需要延缓点击事件，因为页面动画效果还没结束
                if(time_difference < 400){
                    setTimeout(() => {
                        ld("#"+that.firstpopupobj.divid).find("[name=categoryblock]:first").click();
                    }, (400 - time_difference));
                }else{
                    ld("#"+that.firstpopupobj.divid).find("[name=categoryblock]:first").click();
                }
                    
            }else{

            }

        })
    }
    // 第一个弹出层html内容
    this.setFirstPopupContent = function (categoryinfos){
        // that.firstpopupobj.proportion = 1;
        var popcontent_height = 0;
        if(that.firstpopcontent_height && !empty(that.firstpopcontent_height)){
            popcontent_height = that.firstpopcontent_height;
        }else{
            if(ld('#'+that.firstpopupobj.divid + " #" + that.firstpopupobj.divid + '_popupbottom').length > 0){
                popcontent_height = that.firstpopcontent_height = that.firstpopupobj.getPopContentHeight() + parseInt(ld('#'+that.firstpopupobj.divid + " #" + that.firstpopupobj.divid + '_popupbottom').outerHeight());
            }else{
                popcontent_height = that.firstpopcontent_height = that.firstpopupobj.getPopContentHeight() + 65;
            }
        }
        // 非管理员没有新增分类权限，需要加回底部高度
        // if(that.is_admin == 'no'){
            // popcontent_height += parseInt(ld('#'+that.firstpopupobj.divid + " #" + that.firstpopupobj.divid + '_popupbottom').outerHeight());
        // }
        var contenthtml = '';
        contenthtml += '<div>';
        contenthtml += '<div class="ld-remindscenter-categorylist padTB10" id="ld-remindscenter-categorylist" style="max-height: '+popcontent_height+'px;">';
        ld.each(categoryinfos, function(index, infos) {
            contenthtml += that.setCategoryBlockContent(infos)
        });
        if(that.is_admin == 'yes'){
            contenthtml += '<div class="" style="width: 300px;line-height: 50px;">'
                            + '<div class="ld-button ld-button-primary" id="addremindscategory" >+ ' + arrJsPopLabel['CREATECATEGORIES'] + '</div>'
                        + '</div>';
        }
        contenthtml += '</div>';
        contenthtml += '</div>';
        return contenthtml;
    }
    // 第一个弹出层绑定事件
    this.setFirstEvent = function(){
        var Popupobj = ld("#"+that.firstpopupobj.divid);
        // 分类设置
        Popupobj.find("#setCategoryBtn").off('click').on('click', function (event) {
            that.initRemindsDataCategoryPopup();
        });
        // 点击分类事件
        Popupobj.find("[name=categoryblock]").off('click').on('click', function (event) {
            Popupobj.find("[name=categoryblock]").removeClass('ld-remindscenter-categorylist-block-active');
            ld(this).addClass('ld-remindscenter-categorylist-block-active');
 
            that.initSecondPopup(this);
        });
        // 新增分类事件
        Popupobj.find("#addremindscategory").off('click').on('click', function (event) {
            that.addDataCategory();
        });
        // 切换至消息列表
        Popupobj.find("#RemindsListBtn").off('click').on('click', function (event) {
            var news_title = that.firstpopupobj.headtitle;
            ldAjaxHtml("index.php?module=Reminds&action=RemindsAjax&file=index",{},function(ajaxdata){
                if(that.firstpopupobj && !empty(that.firstpopupobj)){
                    that.firstpopupobj.CancelEvent();
                }
                that.closeFirstPopup();
                ld(" .detail_path li").html(news_title);
                ld("title").text(news_title);//修改title值
                ChangeWebUrl("index.php?pageto_module=Reminds&pageto_action=index");
                ld("#pagecontent .wrapper-panel-inner").html(ajaxdata);
                if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined"){
                    //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenData();
                }
                DelProgressObjs();
            })
        });

        tooltip(ld("#"+that.firstpopupobj.divid).find('.tip-items-list'), {transition: true, time: 200});
    }
    // 第一个弹出层绑定事件
    this.setCategoryBlockContent = function(infos){
        var num_html = '';
        if(infos.newreminds_num > 0){
            num_html = '<span style="color:red;">'+infos.newreminds_num+'</span>';
        }else{
            num_html = '<span>'+infos.newreminds_num+'</span>';
        }
        var blockhtml = '<div class="ld-remindscenter-categorylist-block" name="categoryblock" data-remindscategoryid="'+infos.remindscategoryid+'">'
                        + '<div class="ld-remindscenter-categorylist-block-icon" style="background: url('+infos.icon_path+') 0px 0 no-repeat;"></div>'
                        + '<div class="ld-remindscenter-categorylist-block-text tip-items-list" data-tip="'+infos.viewname+'">'
                            + '<span class="categoryname">'+infos.viewname+'</span>'
                            + '<span class="categorytips" name="categorytips">'+arrJsPopLabel['YouHaveVarUnreadMessages'].replace('{Var}', num_html)+'</span>'
                        + '</div>'
                    + '</div>';
        return blockhtml;
    }
    // 初始化二级弹出层
    this.initSecondPopup = function (obj){
        var remindscategoryid = ld(obj).data('remindscategoryid');
        this.selected_categoryobj = obj;
        this.pagenum = 1;// 重置当前页数
        var isfirstloadpopup = 'no';

        // 若已存在二级弹出层，不重新弹出弹出层
        if(empty(that.secondpopupobj)){
            isfirstloadpopup = 'yes';
            var crmpopupobj=CrmPopup.load("","","",'440','Reminds',"","","","");
            crmpopupobj.position=CrmPopup.Positions.right;
            crmpopupobj.setHeight(CrmPopup.getClientHeight());
            crmpopupobj.popupMaxHeight=(CrmPopup.getClientHeight())
            crmpopupobj.isclicklayerclose='yes';//点击遮罩层关闭弹出层
            crmpopupobj.proportion = 1;
            crmpopupobj.setParams("", "", that.closeSecondPopup, "440", 'Reminds', "", "", "", "");

            that.secondpopupobj = crmpopupobj;
            // 页面全部加载完成 包括动画
            that.secondpopupobj.PopupAllReadFun = function(){
                that.getList('entires');
            };
            // 重写二级弹出层滚动div的最大高度，因为没有头部底部所以就是弹出层最大高度
            that.secondpopupobj.setScrollDivMaxHeight = function () {
                var maxheight = this.getpopupMaxHeight();
                ld("#"+that.secondpopupobj.divid+'_scroll').css('max-height',maxheight);
            };
            that.secondpopupobj.positions_right_px = 350;// 增加参数控制在右侧出现的位置，二级弹出层需要离右侧350px
            var contenthtml = this.setSecondPopupContent();
            CrmPopup.setPopupobjHtmlscrolljquery_noposition(crmpopupobj,contenthtml);

            ld("#"+that.secondpopupobj.divid).css('z-index',(that.firstpopup_zindex-1));
            ld("#"+that.secondpopupobj.divid+'_olayernodeid').css('z-index',(that.firstpopup_zindex-2));
            ld("#"+that.secondpopupobj.divid+'_head').css('display','none');
            // ld("#"+that.secondpopupobj.divid).find('#RemindsCenterListContainer').css('height',ld(window).height());
            
            // 先解绑遮罩层关闭事件，防止内容没加载完时关闭弹窗导致页签报错
            ld("#"+that.secondpopupobj.divid+'_olayernodeid').off('click');
            var Popup_Drag = new PopupDrag(crmpopupobj,crmpopupobj.divid);
            document.removeEventListener('mousemove', Popup_Drag.handleMousemove);//清除监听
        }
        that.secondpopupobj.selected_cvid = 108;// 默认选中"未读"页签
        that.NavBarSelKey = 1;
        that.secondpopupobj.remindscategoryid = remindscategoryid;
        // 重置高级查找条件
        that.secondpopupobj.advft_criteria = {};
        that.secondpopupobj.advft_criteria_groups = {};
        if(isfirstloadpopup == 'no'){
            that.getList('entires');
        }
    }
    // 第二个弹出层html内容
    this.setSecondPopupContent = function (){
        var contenthtml = '';
        contenthtml += '<div id="RemindsCenterListContainer">';
        contenthtml += '<div class="ld-remindscenter-listcontainer-head">'
                            +'<div id="RemindsCenterNavBar" class="ld-remindscenter-navbar"></div>'
                            +'<div id="RemindsCenterSetReaden" class="ld-remindscenter-setreaden">'
                            +'</div>'
                        +'</div>';
        contenthtml += '<div id="RemindsCenterListEntries"></div>';
        contenthtml += '</div>';

        return contenthtml;
    }
    /**
     * 获取消息小列表内容
     * type="list"时只刷新分页和列表，type="entires"时刷新整个弹出层内容
     */
    this.getList = function (type='list'){
        // 增加加载效果
        if(that.pagenum == 1){
            var prevshowcontent = that.secondpopupobj.getPrevShowContent();
            CrmPopup.start_progressObjs = [];
            ld("#"+that.secondpopupobj.divid).append(prevshowcontent);
        }
        // 先解绑遮罩层关闭事件，防止内容没加载完时关闭弹窗导致页签报错
        ld("#"+that.secondpopupobj.divid+'_olayernodeid').off('click');

        var secondPopupobj = ld("#"+that.secondpopupobj.divid);
        if(empty(that.pagenum))
            that.pagenum = 1;

        var surl = that.surl;
        var params = {
            'mode': 'getlist',
            'remindscategoryid': that.secondpopupobj.remindscategoryid,
            'cvid': that.secondpopupobj.selected_cvid,
            'type': type,
            'pagenum': that.pagenum,
        };
        // 仅加载列表时增加查找的条件, 若是加载整个弹出层则清空查找条件
        if(type == 'list'){
            params = Object.assign({}, params, that.searchparams);
        }else{
            that.clearSearchparams();
        }

        ldAjaxNoProgress(surl,params,function (data){
            if(data.code == 1){
                var label_arr = data.result.label_arr;
                if(type == 'list'){
                    secondPopupobj.find("#RemindsCenterListSection").html(data.result.content);
                }else{
                    secondPopupobj.find("#RemindsCenterListEntries").html(data.result.content);
                }
                
                var max_listheight = ld(window).height()-secondPopupobj.find("#RemindsCenterNavBar").outerHeight()
                                    -secondPopupobj.find("#RemindsCenterSearcharea").outerHeight()
                                    -secondPopupobj.find("#RemindsCenterPagination").outerHeight(true)
                                    -secondPopupobj.find("#RemindsCenterLine").outerHeight(true)+4;
                secondPopupobj.find("#RemindsCenterList").css('height',max_listheight);

                if(type == 'entires'){
                    // 页签
                    that.secondpopupobj.NavBarList = data.result.NavBarList;
                    // setTimeout(() => {
                        that.setNavBarEvent();
                        
                    // }, 100);
                    // 高级查找字段
                    that.secondpopupobj.advancefieldnames = data.result.advancefieldnames;
                }
                // "全部已读"按钮
                var current_navbar = that.ld_navbarobj.getCurNavBarItem();// 获取当前选中页签
                var setreaden_btnhtml = '';
                if(current_navbar.NavBarItem.id != 114 && current_navbar.NavBarItem.id != 115){
                    setreaden_btnhtml = '<a class="Anu3_a" id="setreaden" href="javascript:void(0);">'+label_arr.setreaden+'</a>';
                }
                // "全部未读"按钮
                else if(current_navbar.NavBarItem.id == 114){
                    setreaden_btnhtml = '<a class="Anu3_a" id="setunread" href="javascript:void(0);">'+label_arr.setunread+'</a>';
                }
                secondPopupobj.find("#RemindsCenterSetReaden").html(setreaden_btnhtml);
                
                that.setSecondEvent();
            }
            else if(data.code == -2){
                // 分类已被删除,关闭二级弹窗
                if(that.secondpopupobj && !empty(that.secondpopupobj)){
                    that.secondpopupobj.CancelEvent();
                    that.closeSecondPopup();
                }
            }

            ld("#"+that.secondpopupobj.divid+'_olayernodeid').on('click', function (event) {
                ld("#" + that.secondpopupobj.divid + "_imgclose").get(0).click();
            });
            // 去除加载效果
            ld("#"+that.secondpopupobj.divid).find('[name=prevshowdv]').remove();
        })
    }
    // 绑定页签
    this.setNavBarEvent = function (){
        var headerobj = ld("#"+that.secondpopupobj.divid).find('#RemindsCenterNavBar');
        headerobj.html('');
        headerobj.removeAttr('_navbar_instance_');
        var StuffNavBarList = [];
        if(that.secondpopupobj.NavBarList && !empty(that.secondpopupobj.NavBarList)){
            var StuffNavBarList = that.secondpopupobj.NavBarList;
        }
        var NavBarSelKey = that.NavBarSelKey;// 默认选中"未读"页签
        that.ld_navbarobj = ld_NavBar.ShowNavBar(headerobj.get(0),StuffNavBarList,{
            NavBarSelKey : NavBarSelKey,
            ShowAllItemInfo : true,
            MaxSimpleNum: 4,
            OnClick : function(evt){
                var selectNavBarItem = evt.NavBarItem;
                that.secondpopupobj.selected_cvid = selectNavBarItem.id;
                that.NavBarSelKey = selectNavBarItem.NavBarIndex;
                that.pagenum = 1;// 重置当前页数
                that.clearSearchparams();// 清空查找条件
                that.getList();
            },
        });

    }
    // 二级弹出层绑定事件
    this.setSecondEvent = function(){
        var Popupobj = ld("#"+that.secondpopupobj.divid);
        // 进入消息单据详情
        Popupobj.find("#RemindsCenterList").find('[name=remindslistclick]').off('click').on('click', function (event) {
            that.remindsListClick(this,event);
        });
        // 上一页
        Popupobj.find("#RemindsCenterPagination").find('.icon-left-active').off('click').removeAttr('onclick').on('click', function (event) {
            that.pagenum--;
            that.getList();
        });
        // 下一页
        Popupobj.find("#RemindsCenterPagination").find('.icon-right-active').off('click').removeAttr('onclick').on('click', function (event) {
            that.pagenum++;
            that.getList();
        });
        // 指定页码
        Popupobj.find("#RemindsCenterPagination").find('.ld-pagenum-list').find('li').off('click').removeAttr('onclick').on('click', function (event) {
            that.pagenum = ld(this).attr('pagenum');
            that.getList();
        });
        // 全部已读
        Popupobj.find("#setreaden").off('click').on('click', function (event) {
            that.setAllReadStatus('setreaden');
        });
        // 全部未读
        Popupobj.find("#setunread").off('click').on('click', function (event) {
            that.setAllReadStatus('setunread');
        });
        var Searcharea_obj = Popupobj.find("#RemindsCenterSearcharea");
        // 基本查找
        Searcharea_obj.find('[name="search_text"]').off().removeAttr('onclick').removeAttr('onkeyup').on('keyup', function (event) {
            var e = event || window.event;
            if(e.keyCode == 13){
                that.basicSearch();    
            }
            setShowOrHideClearIcon(that.secondpopupobj);
        });
        Searcharea_obj.find('.ld-listview-search').off('click').removeAttr('onclick').on('click', function (event) {
            that.basicSearch();
        });
        Searcharea_obj.find('.ld-icon-clearsearch').off('click').removeAttr('onclick').on('click', function (event) {
            that.clearBasicSearch();
        });
        // 高级查找
        Searcharea_obj.find('#categoryAdvsear').find('a:first').off('click').removeAttr('onclick').on('click', function (event) {
            that.higherSearchPopup();
        });
        setShowOrHideClearIcon(that.secondpopupobj);
    }
    // 查看消息详情
    this.remindsListClick = function (obj,event){
        ListLinkClick(ld(obj),event);// 公共点开详情方法
        // 如果消息的状态是未读, 则执行
        if(ld(obj).data('status') == 'unread'){
            // var isReminds_popupexist= ld('#reminds_popup').css('display');
            // setRemindReaden(ld(obj).attr('record'),isReminds_popupexist);// 将消息设为已读
            var surl = that.surl;
            var param = { 'mode': 'listlinkclick', 'types': 'update_state', 'remindsid': ld(obj).attr('record') };
            ldAjaxHtmlNoProgress(surl,param,function (data){
                // 刷新列表，分页
                that.getList();
                // 刷新页签，更新未读条数
                // var headerobj = ld("#"+this.secondpopupobj.divid).find('#RemindsCenterNavBar');
                // var unreadobj = this.secondpopupobj.NavBarList.find(obj => obj.id == 108);// 未读
                // if(unreadobj){
                //     unreadobj.num = parseInt(unreadobj.num) - 1;
                //     if(unreadobj.num >= 0){
                //         unreadobj.label = unreadobj.rawlabel+'（'+unreadobj.num+'）';
                //         ld_NavBar.ShowNavBar(headerobj.get(0),this.secondpopupobj.NavBarList,this.ld_navbarobj.Options);
                //         // 更新一级弹出层中，"您有n条未读消息"
                //         // ld(this.selected_categoryobj).find('[name=categorytips]').text(arrJsPopLabel['YouHaveVarUnreadMessages'].replace('{Var}', unreadobj.num));
                //     }
                // }
                that.reloadFirstPopupNoProgress();// 刷新一级弹出层

                // // 如果处于消息的列表界面，还需要更新列表界面
                // var listpagepopupobj = CrmPopup.getlastPopupObjByPageType(ListPagePopup.type);
                // if(listpagepopupobj && listpagepopupobj.module == 'Reminds' && listpagepopupobj.type == 'listpage'){
                //     getListViewEntries_js('Reminds', 'start=1');//刷新消息模块的大列表
                // }
            
            })
        }
    }
    // 消息类型设置弹出层
    this.initRemindsDataCategoryPopup = function(){
        var surl = that.surl;
        var param = {'mode':'setcategory'};
        ldAjaxNoProgress(surl,param,function (data){
            if(data.code == 1){
                var groupListObj = data.result.cv_grouplist;
                // 使用 reduce 方法将数组转换为对象，属性名从 0 开始递增
                groupListObj = groupListObj.reduce((acc, curr, index) => {
                    acc[index] = curr;
                    return acc;
                }, {});
                getJsScript('include/js/CustomViewCategoryRightSetting.js', function () {
                    AjaxJSPage('DataCategoryListPopup','include/js/SystemPopup/DataCategoryPopup.js');// 非列表界面需要加载
                    var CustomViewCategoryRightSettingobj = new CustomViewCategoryRightSetting();
                    CustomViewCategoryRightSettingobj.allowcopy = true;
                    if(!empty(groupListObj)) {
                        CustomViewCategoryRightSettingobj.groupList = groupListObj;
                    }
                    CustomViewCategoryRightSettingobj.custom_info=that.module;
                    CustomViewCategoryRightSettingobj.prevpopup_zindex = that.firstpopup_zindex;// 将一级弹出层的z-index传到类中
                    CustomViewCategoryRightSettingobj.afterClosePopup = function(){
                        // 重载一级弹窗
                        that.reloadFirstPopup();
                        // 重载二级弹窗
                        if(that.selected_categoryobj && !empty(that.selected_categoryobj)){
                            that.pagenum = 1;// 重置当前页数
                            that.getList('entires');
                        }else{
                            if(that.secondpopupobj && !empty(that.secondpopupobj)){
                                that.secondpopupobj.CancelEvent();
                                that.closeSecondPopup();
                            }
                        }
                    };
                    CustomViewCategoryRightSettingobj.showCustomViewGroupRightSetting();
                    // 对象放在popupobj中
                    var popupobj=CrmPopup.getPopupObj('last');
                    popupobj.CustomViewCategoryRightSettingobj = CustomViewCategoryRightSettingobj;
                    // that.firstpopupobj.CustomViewCategoryRightSettingobj = CustomViewCategoryRightSettingobj;
                })
                // event.stopPropagation();
                
            }else{

            }

        })
    }
    // 重载一级弹窗内容
    this.reloadFirstPopup = function(){
        var prevshowcontent = that.firstpopupobj.getPrevShowContent();
        that.firstpopupobj.show(prevshowcontent);
        var surl = this.surl;
        var param = {'mode':'getcategory'};
        ldAjax(surl,param,function (data){
            if(data.code == 1){
                var contenthtml = that.setFirstPopupContent(data.result.category_arr);
                CrmPopup.setPopupobjHtmlscrolljquery_noposition(that.firstpopupobj,contenthtml);
                // 绑定事件
                that.setFirstEvent();
                if(that.selected_categoryobj && !empty(that.selected_categoryobj)){
                    ld("#"+that.firstpopupobj.divid).find("[name=categoryblock][data-remindscategoryid="+that.secondpopupobj.remindscategoryid+"]").addClass('ld-remindscenter-categorylist-block-active');
                }
            }
            DelProgressObjs();
        });
    }
    // 重载一级弹窗内容
    this.reloadFirstPopupNoProgress = function(){
        var surl = this.surl;
        var param = {'mode':'getcategory'};
        ldAjaxNoProgress(surl,param,function (data){
            if(data.code == 1){
                var contenthtml = that.setFirstPopupContent(data.result.category_arr);
                CrmPopup.setPopupobjHtmlscrolljquery_noposition(that.firstpopupobj,contenthtml);
                // 绑定事件
                that.setFirstEvent();
                if(that.selected_categoryobj && !empty(that.selected_categoryobj)){
                    ld("#"+that.firstpopupobj.divid).find("[name=categoryblock][data-remindscategoryid="+that.secondpopupobj.remindscategoryid+"]").addClass('ld-remindscenter-categorylist-block-active');
                }
            }
        });
    }
    // 关闭一级弹窗同时关闭二级弹窗
    this.closeFirstPopup = function(){
        if(that.secondpopupobj && !empty(that.secondpopupobj)){
            that.secondpopupobj.CancelEvent();
            that.closeSecondPopup();
        }
        // 刷新右上角消息条数
        getJsScript('include/js/ListViewButton.js', function () {
            setRemindReadenHeaderSecond();
        });
        // 如果处于消息的列表界面，还需要更新列表界面
        var listpagepopupobj = CrmPopup.getlastPopupObjByPageType(ListPagePopup.type);
        if(listpagepopupobj && listpagepopupobj.module == 'Reminds' && listpagepopupobj.type == 'listpage'){
            that.changeListCategory();
        }
    }
    // 关闭二级弹窗
    this.closeSecondPopup = function(){
        ld("#"+that.firstpopupobj.divid).find("[name=categoryblock]").removeClass('ld-remindscenter-categorylist-block-active');
        that.secondpopupobj = {};
        that.selected_categoryobj = {};
    }
    // 新增分类
    this.addDataCategory = function(){

        DataCategoryListPopup.add();
        var popupobj = CrmPopup.getPopupObj("last");
        popupobj.setOkfun(this.saveDataCategory);
    }
    // 保存分类
    this.saveDataCategory = function(){
        // 重写保存后事件
        DataCategoryListPopup.afterSaveEvent = function(data){
            var surl = that.surl;
            var param = {'mode':'gettargetcategory','remindscategoryid': data.result.cvid};
            ldAjaxNoProgress(surl,param,function (ajaxdata){
                if(ajaxdata.code == 1){
                    var infos = {
                        'remindscategoryid': data.result.cvid,
                        'viewname': data.result.viewname,
                        'icon_path': ajaxdata.result.icon_path,
                        'newreminds_num': ajaxdata.result.newreminds_num,
                    };
                    var blockhtml = that.setCategoryBlockContent(infos);
                    ld("#"+that.firstpopupobj.divid).find('#ld-remindscenter-categorylist').find('[name=categoryblock]:last').after(blockhtml);
                    that.setFirstEvent();
                    // 滚动到底部
                    ld("#"+that.firstpopupobj.divid).find('#ld-remindscenter-categorylist').scrollTop(ld("#"+that.firstpopupobj.divid).find('#ld-remindscenter-categorylist').prop('scrollHeight'));
                }else{
                    var confirm_str = popupobj.viewnamelabel+arrJsPopLabel['CANOTREPEATED'];
                    MessagePopup.TipOne_warning(confirm_str);
                }
            })
        }
        DataCategoryListPopup.pagesave();
    }
    // 全部已读
    this.setAllReadStatus = function(status){
        if(empty(status)){
            status = 'setreaden';
        }
        var surl = that.surl;
        var param = {'mode': status,'remindscategoryid': that.secondpopupobj.remindscategoryid};
        if(!empty(that.searchparams)){
            param = Object.assign({}, param, that.searchparams);
        }
        ldAjaxNoProgress(surl,param,function (data){
            if(data.code == 1){
                that.pagenum = 1;
                that.getList("entires");
                MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULOPERATION']);
                that.reloadFirstPopupNoProgress();// 刷新一级弹出层
            }
        })
    }
    // 基础查找
    this.basicSearch = function(){
        var searchparams = {};
        var Searcharea_obj = ld("#"+this.secondpopupobj.divid).find("#RemindsCenterSearcharea");
        var search_fld_obj = Searcharea_obj.find("select[name=search_field]")
        var search_fld_val = search_fld_obj.val();
        //zkt 20220614 BUG0052740（示图）单据编号值，直接从微信复制出来的，从表面看是空格，实际是转义字符，导致搜索不到
        var search_text_value = trim(Searcharea_obj.find("input[name=search_text]").val());
        // search_text_value = encodeURIComponent(search_text_value);
        searchparams = {
            'query' : 'true',
            'searchfrom' : 'listpage',
            'search_field' : search_fld_val,
            'searchtype' : 'BasicSearch',
            'search_text' : search_text_value,
        };
        //wym XUQIU1001090 单据序时簿列表界面，基本查找增加“全部字段”功能
        if(search_fld_val=='all'){
            var optionvalues = search_fld_obj.eq(0).find('option').map(function() {
                if(ld(this).val()!='all'){
                    return ld(this).val();
                }
            }).get();
            var search_fld_val_arr = JSON.stringify(optionvalues);
            searchparams['search_field_arr'] =  search_fld_val_arr;
        }
        this.searchparams = searchparams;
        this.pagenum = 1;
        this.getList('list');
    }
    // 清除基础查找
    this.clearBasicSearch = function(){
        ld("#"+this.secondpopupobj.divid).find("#RemindsCenterSearcharea").find("input[name=search_text]").val('');
        ld("#"+this.secondpopupobj.divid).find("#RemindsCenterSearcharea").find('[name=search_text]').focus();
        this.searchparams = {};
        setShowOrHideClearIcon(that.secondpopupobj);
    }
    // 高级查找弹出层
    this.higherSearchPopup = function(){
        global_showPopupHighSearch(this.higherSearch);
    }
    // 高级查找
    this.higherSearch = function(){
        var popupobj=CrmPopup.getPopupObj('last');
        if(!popupobj.advanceFilterObj.checkAdvancedFilter()) return false;
        var advft_criteria = popupobj.advft_criteria;
        var advft_criteria_groups = popupobj.advft_criteria_groups;
        var searchparams = {};
        searchparams = {
            'query' : 'true',
            'searchfrom' : 'listpage',
            'searchtype' : 'advance',
            'advft_criteria' : advft_criteria,
            'advft_criteria_groups' : advft_criteria_groups,
        };
        that.searchparams = searchparams;
        that.pagenum = 1;
        that.getList('list');
        popupobj.CancelEvent();
        // 高级查找条件存在一级弹出层中
        that.secondpopupobj.advft_criteria = advft_criteria;
        that.secondpopupobj.advft_criteria_groups = advft_criteria_groups;
        // 保存高级查找历史
        var search_history_url = '&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+'&searchfrom='+popupobj.type+'&searchtype=advance';
        getJsScript('include/js/search.js', function () {
            save_search_history(search_history_url,that.module)
        });
    }
    // 清空查找条件
    this.clearSearchparams = function(){
        that.searchparams = {};
        var searchareaobj = ld("#"+this.secondpopupobj.divid).find("#RemindsCenterSearcharea");
        if(searchareaobj.find("input[name=search_text]")){
            searchareaobj.find("input[name=search_text]").val('');
        }
        // 重置高级查找条件
        that.secondpopupobj.advft_criteria = {};
        that.secondpopupobj.advft_criteria_groups = {};
    }
    // 列表界面-切换消息类型
    this.changeListCategory = function(obj={}){
        ld('#rptContentLoading').show();
        var popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
        if(empty(obj)){
            var remindscategoryid = popupobj.remindscategoryid;
        }else{
            var remindscategoryid = ld(obj).data('remindscategoryid');
        }
        // 获取当前页签
        var cur_navbaritem = popupobj.ListViewNavBarObj.getCurNavBarItem().NavBarItem;
        var otherurl = '&remindscategoryid='+remindscategoryid;
        showDefaultCustomViews('',this.module,'',cur_navbaritem.value,otherurl);
    }
    // 列表界面-刷新消息类型
    this.reloadListCategory = function(popupobj,targetobj){
        var surl = this.surl;
        var param = {'mode':'reloadlistcategory','selected_remindscategoryid':popupobj.remindscategoryid};
        ldAjaxNoProgress(surl,param,function (data){
            if(data.code == 1){
                targetobj.html(data.result.content);
            }
        })
    }
}