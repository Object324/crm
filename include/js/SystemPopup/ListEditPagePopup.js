//小编辑弹出框
function ListEditPagePopup(listpopupobj) {
  
  this.pagevaliddatasavetip='yes';
  
  this.listpopupobj=listpopupobj;
  this.listpopupobj.listpageditobj=this;
  var that=this;
  this.tdobj = '';
  this.fieldsarr = [];
  
  
  

  this.setListPopupObj=function(listpopupobj){
     this.listpopupobj=listpopupobj;
     this.listpopupobj.listpageditobj=this;
     
  }
  
  
  this.init=function(){
    this.listtableobj=ld("#resize_content_tableid");
    this.tabletrobjs=ld(this.listtableobj).find("tr[module="+this.listpopupobj.module+"]");
    this.tr_headerobj=ld(this.listtableobj).find("tr[name=tr_header]");
    this.popupdivobj=ld('#listeditpagepopup');
    this.editbuttonobj = ld("div[name=listedit]");
    ld(this.popupdivobj).css('display','none');
    if(ld(this.editbuttonobj).length>0)
    {
        ld(this.editbuttonobj).css('display','none');
    }
    
  }
  this.init();
  
  
  /**
   *小编辑按钮不显示 
   *
   */
  this.Noshoweidtbutton=function()
  {
        this.init();
        ld(this.tabletrobjs).find("td").unbind("mouseover")
        if(ld(this.editbuttonobj).length>=0)
        {
            ld(this.editbuttonobj).css("display",'none');
        }
  }
  
  this.setListEditEvent=function()
  {
        //return false;
        //zkt 20220505 51438(https://61mis.com/order/index.php)  租赁客户注册信息》单据编号，在列表界面点击编辑提示“【单据编号】字段在列表界面不能编辑”
        //增加有关字段信息
       that.fieldsarr = [];
       if(!empty(that.listpopupobj.fields)){
        ld.each(that.listpopupobj.fields,function(){
            var tmpfieldname = this.fieldname;
            that.fieldsarr[tmpfieldname] = this;
        })
       }
       //duan 20240220 增加分录字段信息获取
      that.detailfieldsarr = {};
      if(!empty(that.listpopupobj.detailfields)){
          ld.each(that.listpopupobj.detailfields,function(){
              that.detailfieldsarr[this.fieldname] = this;
          })
      }

      // XUQIU20240709-03 后台设置-系统参数设置，系统参数增加“列表和详情页是否启用小编辑功能”
      if (that.listpopupobj.alloweditpage != undefined && that.listpopupobj.alloweditpage == 'yes'){
          // 鼠标移动显示 ，隐藏等事件
          //this.tabletrobjs=ld("#resize_content_tableid").find("tr[module="+this.listpopupobj.module+"]");
          //添加mouseover事件
          ld(this.tabletrobjs).find("td").unbind("mouseover").bind("mouseover",function(event){
              ld("#pageleft .menu-thumbnail-box").hide();//隐藏子菜单
              //zkt 20220929 BUG0057279鼠标移到单据上没有对应的显示效果（整行显示蓝色）
              var parenttrobj = Tools.getParentobjByChild(ld(this),'tr');
              ld(parenttrobj).mouseover();
              //return false;
              //加载小编辑div
              that.listTdmouseover(ld(this));
              //zkt 20230516 BUG0066434 61order bug管理---列表小编辑---点不到
              var tdobj = ld(this);
              ld(that.editbuttonobj).unbind("mouseover").bind("mouseover",function(event){
                  that.listTdmouseover(ld(tdobj));
                  StopEvent(event.originalEvent);
              })
              StopEvent(event.originalEvent);
          })

          ld(this.listtableobj).parent().bind("mouseover",function(event){

          })
          ld(this.tabletrobjs).find("td").unbind("mouseout").bind("mouseout",function(e){
              var parenttrobj = Tools.getParentobjByChild(ld(this),'tr');
              ld(parenttrobj).mouseout();
              var tdwidth = ld(this).width();
              var tdheight = ld(this).height();
              var tdtop = ld(this).offset().top;
              var awidth = ld(this).find('a').width();
              var aheight = ld(this).find('a').height();
              var hearddivobj = ld("#resize_header_table_divid");
              var hearddivtop = ld(hearddivobj).offset().top;
              var hearddivheight = ld(hearddivobj).height();
              var e = e||window.event;
              var x = (e && e.layerX) || window.event.offsetX;//获取鼠标相对于当前元素的位置X
              var y = (e && e.layerY) || window.event.offsetY;//获取鼠标相对于当前元素的位置Y
              //BUG0060873 序时簿列表进入单据明细，进度追踪点击推进，返回序时簿列表显示编辑图标不消失 -------直接使用mousout方法
              that.listTdmouseleave(ld(this));
              StopEvent(e.originalEvent);
          })
      }
    
  }
  this.listTdmouseover=function(tdobj){


            if(ld(this.editbuttonobj).length<=0)
            {
                ld("body").append('<div class="first-listlittle-edit" name="listedit" style="display:none;"><i class="ld-fonticon ld-fonticon-edit" name="hreflistedit" id="hreflistedit"></i></div>');
                this.editbuttonobj = ld("div[name=listedit]");
            }
            
            var tdobj=ld(tdobj);
            var tdindex=ld(tdobj).attr("tdindex");
            var isdetail = 'no';

            if(tdindex != undefined && tdindex != '')
            {
                if(ld(this.tr_headerobj).find("th[tag="+tdindex+"]").length>0){
                    var headerthobj = ld(this.tr_headerobj).find("th[tag="+tdindex+"]");
                    var headermodule = ld(headerthobj).attr("headermodule");
                    //zkt 20220525 52195客户问题（普阳会计），服务收费管理列表界面，字段没有小编辑功能（通用问题）
                    if(headermodule == 'Accounts'&&that.listpopupobj.module == 'ServiceCharge')
                    {
                        headermodule = 'ServiceCharge';
                    }
                    var headername = ld(headerthobj).attr("headername");

                    //duan 20240219小编辑支持单据分录字段
                    if(headermodule == that.listpopupobj.module){
                        if(empty(that.fieldsarr[headername])||empty(that.fieldsarr[headername].editpage)||that.fieldsarr[headername].editpage.indexOf("listview") == -1){
                            return ;
                        }
                    }else if(headermodule == 'Products' || headermodule == (that.listpopupobj.module+'Details')){
                        if(empty(that.detailfieldsarr[headername])||empty(that.detailfieldsarr[headername].editpage)||that.detailfieldsarr[headername].editpage.indexOf("listview") == -1){
                            return ;
                        }
                        //如果分录id为0,例如预收单和销售机会可能存在没有分录的情况,则不显示编辑
                        var trobj = Tools.getParentobjByChild(ld(tdobj),'tr');
                        var trid = ld(trobj).attr('id');
                        var tridarr = trid.split('_');
                        var recordarr = tridarr[1].split(',');
                        var detailid = recordarr[1];
                        if(detailid <= 0){
                            return;
                        }
                        isdetail = 'yes';
                    }else{
                        return ;
                    }
                }
                else{
                    return ;
                }

                /*wym BUG0067278 kfbcrm 客户----序时簿列表可以编辑客户编号---单据查看界面 客户编号字段没有小编辑*/
                if(tdobj.find("span[fieldname=\"account_no\"]").length>0){
                    return ;
                }

                var width=parseInt(ld(tdobj).get(0).offsetWidth);//列头的宽度
                var height = parseInt(ld(tdobj).get(0).offsetHeight);
                ld(this.editbuttonobj).css("left",(ld(tdobj).offset().left+width-parseInt(ld(this.editbuttonobj).css("width"))-5)+"px");
                ld(this.editbuttonobj).css("top",(ld(tdobj).parent().offset().top+height/2-parseInt( ld(this.editbuttonobj).css("height"))/2)+"px");
                
                ld(this.editbuttonobj).find(" [name=hreflistedit]").unbind('click').on('click',function(){
                    if(isdetail == 'yes'){
                        that.DetailEditPopupobjShow(ld(this),tdobj);
                    }else{
                        that.EditPopupobjShow(ld(this),tdobj);
                    }
                });
                ld(this.editbuttonobj).css("display",'');
            }
            else{
                ld(this.editbuttonobj).find(" [name=hreflistedit]").unbind('click');
                ld(this.editbuttonobj).css("display",'none');
                
            }
  }
  this.listTdmouseleave=function(tdobj){
        ld(this.editbuttonobj).css("display",'none');
  }
  this.EditPopupobjShow=function(editbuttonobj,tdobj){
        //显示编辑弹出层
        that.tdobj = tdobj;
        var thisobj = editbuttonobj;
        var tdindex=ld(tdobj).attr("tdindex");
        var headerthobj = ld(this.tr_headerobj).find("th[tag="+tdindex+"]");
        var fieldname = ld(headerthobj).attr("headername");
        var value = ld(tdobj).find(" [fieldname="+fieldname+"]").html();
        var trobj = Tools.getParentobjByChild(ld(tdobj),'tr');
        var trid = ld(trobj).attr('id');
        var tridarr = trid.split('_');
        var recordarr = tridarr[1].split(',');
        var record = recordarr[0];
        var module = ld(trobj).attr('module');
        
        //产生编辑弹窗
        var surl = "index.php?module=Users&action=UsersAjax&file=ListEdit";
        surl += "&frommodule="+module+"&fieldname="+fieldname+"&record="+record;
        surl += "&editmode=listview";
        
        //zkt 添加判断，链接模块的列表界面小编辑操作,防止编辑出错
        var popupobj = that.listpopupobj;
        if(popupobj.type=="listpage"){
            if (typeof linkmodulecustom != "undefined"&& popupobj.type !='relatelistpage') {
                var page_title = ld(" .detail_path li").html();
                surl += '&is_linkmodulecustom='+linkmodulecustom;
                //@edit:zkt,reason:链接模块，单据新建/编辑/复制界面，“数据分类设置的条件”字段显示为只读的，不可编辑修改
                //获取链接模块viewname
                var page_addurl = getSearchString('page_addurl',location.href);
                if(page_addurl != undefined){
                    var linkmodule_viewname = getSearchString('viewname',page_addurl);
                    if(linkmodule_viewname != undefined){
                        surl +='&linkmodule_viewname='+linkmodule_viewname;
                    }
                }
            }
        }
        //edit: xll 2023/09/02  BUG0071761 video标签导致小编辑界面一闪而过消失
        var params = "&pagetype=ListEditPagePopup";
        ldAjax(surl,params,function(data){
            if(data.code ==1)
            {
                var Popupobj = CrmPopup.load(arrJsPopLabel['EDIT'],that.EditPopupobjSave,'','LdPopWidth350px',module,'',arrJsPopLabel['CONFIRMED'],'',arrJsPopLabel['CANCEL'])
                var html = '<div id="listeditpagepopupcontent" class="first-listlittle-edit-pop-content ld-pop-container">';
                html += '<div class="first-listlittle-edit-pop-lable" name="listeidtpagecontentlabel" style="padding: 0 20px 10px 20px"></div>';
                html += '<div class="first-listlittle-edit-pop-input ld-form-item-content" name="listeidtpagecontentinput"></div>';
                html += '</div>';
                Popupobj.show(html)
                Popupobj.isclicklayerclose = 'yes';
                var divobj = ld('#'+Popupobj.divid);

                var tablehtml = data.result.content;
                var fields = data.result.fields;
                var fieldinfo = fields[0];
                
                Popupobj.record = record;
                Popupobj.module = module;
                Popupobj.fields = fields;
                Popupobj.fieldinfo = fieldinfo;
                Popupobj.fieldname = fieldinfo.fieldname;
                Popupobj.fieldname_fields = [];
                Popupobj.fieldname_fields[fieldinfo.fieldname] = fieldinfo;
                Popupobj.filejsondata = data.result.filejsondata;
                Popupobj.sensitiverelatedfield = data.result.sensitiverelatedfield;
                Popupobj.isadmin = data.result.isadmin;
                //edit:duan date:2024/10/25 reason:职位级别字段需要获取部门信息
                if (data.result.cur_groupinfo != undefined) {
                    Popupobj.cur_groupinfo = data.result.cur_groupinfo;
                }
                //edit: xll 2023/10/06 BUG0072908 客户管理（包括但不限于，比如报价单、销售订单等等）数据列表，无法通过快速编辑添加视频附件。
                Popupobj.pagetype = 'ListEditPagePopup';//小编辑页

                Popupobj.oCKeditors = [];
                //zkt 20220525 52183（https://81mis.com/kfbtest/index.php）（列表小编辑）编辑下拉框字段（所属行业），选项更新后，下拉选项没有立即更新
                Popupobj.getDetailTableObj=function(){
                    return [];
                }


                var contentdivobj = divobj.find("#listeditpagepopupcontent");
                var noshowconttentobj=ld(that.popupdivobj).find(" [id='listeditpagetablecontent']");
                ld(noshowconttentobj).html(data.result.content);
                var editfieldtabobj = ld(that.popupdivobj).find(" [name=listedittab]");
                var editfieldtabtrobjs = ld(editfieldtabobj).find("tr");
                ld.each(editfieldtabtrobjs,function(tmpindex){
                    if((SaveDataRecord.isfileattachUitype(fieldinfo.uitype) || fieldinfo.uitype == 19 || fieldinfo.uitype == 20)&&tmpindex==0){
                        //附件字段返回两个tr，编辑界面内容在第二个tr中
                        return true;
                    }
                    var tmptrobj=ld(this);
                    var lablehtml = ld(tmptrobj).children().eq(0).html();
                    var inputhtml = ld(tmptrobj).children().eq(1).html();
                    //zkt 20230110 BUG0060676服务合同，服务收费管理在目录页面上进行编辑保存之后还是原本的值 
                    if(fieldinfo.uitype == 56){
                        if(ld(tmptrobj).children().eq(2).length>0){
                            inputhtml += ld(tmptrobj).children().eq(2).prop("outerHTML");
                        }
                    }
                    ld(contentdivobj).find(" [name=listeidtpagecontentlabel]").html(lablehtml);
                    ld(contentdivobj).find(" [name=listeidtpagecontentinput]").html(inputhtml);
                    if(fieldinfo.isenablebusinessfuzzyquery != undefined && fieldinfo.isenablebusinessfuzzyquery == "yes")
                    {
                        ld(contentdivobj).height(200);
                        // divobj.css("max-height","258px");
                    }
                    else{
                        ld(contentdivobj).height("");
                        // divobj.css("max-height","200px");
                    }
                    var tmpinputbj = ld(contentdivobj).find(" [name=listeidtpagecontentinput]");
                    var inputvalue = ld(tmpinputbj).find(" [name="+Popupobj.fieldname+"]").val();
                    ld(tmpinputbj).find(" [name="+Popupobj.fieldname+"]").val('').focus().val(inputvalue);//hjz 打开小编辑光标直接显示
                    //获取b标签个数并控制input框宽度，工商查询图标和查重图标
                    /*var bcount = 0;
                    ld.each(ld(tmpinputbj).children('b'),function(){
                        var tmpdisplay = ld(this).css('display');
                        var tmpclass = ld(this).attr('class');
                        if(tmpdisplay!='none'&&(tmpclass.indexOf('icon-gongshang')>=0||tmpclass.indexOf('icon-searchgrey')>=0)){
                            bcount++;
                        }
                    });
                    if(bcount>0)
                    {
                        ld(tmpinputbj).find(' [name='+fieldinfo.fieldname+']').get(0).style.removeProperty("width");
                        ld(tmpinputbj).find(' [name='+fieldinfo.fieldname+']').get(0).style.setProperty('width',(95-bcount*5)+'%','important');
                    }*/
                    //zkt 20220411  50880（81mis.com/kfbcrm）（列表编辑）客户》客户列表，编辑多选框字段，弹窗中2个输入
                    if(fieldinfo.uitype == 33)
                    {
                        //多选框td的select框生成的span移除，后面还会生成
                        var tmpspanobj = ld(contentdivobj).find(" [name=listeidtpagecontentinput]").find('select[id='+fieldinfo.fieldname+']').next();
                        ld(tmpspanobj).remove();
                    }
                    return false;
                });

                //弹窗位置计算
                var windowWidth =CrmPopup.getClientWidth();// document.documentElement.clientWidth;
                var windowHeight =CrmPopup.getClientHeight();// ld(window).height();
                var divwidth = divobj.width();
                var divheight = divobj.height();
                var tdwidth = ld(tdobj).width();
                var tdtop = ld(tdobj).offset().top;
                var tdleft = ld(tdobj).offset().left;
                var height = parseInt(ld(tdobj).height());
                var edittop = (tdtop+height/2)+10;
                var editleft = (tdleft+(tdwidth-divwidth)/2)+10;
                var newleft = (editleft+divwidth)>windowWidth?windowWidth-(divwidth+10):editleft;
                var newtop = (edittop+divheight)>windowHeight?windowHeight-(divheight):edittop;
                divobj.css("left",newleft);
                divobj.css("top",newtop);

                // Popupobj.center();
                ld(noshowconttentobj).html('');//清空html
                that.EditPopupEvent(Popupobj);

               // cls_resetComboxHtmlobj.setPickListContent(picklistcontent);
                Popupobj.detailpicklist=data.result.detailpicklist;
                Popupobj.detailpicklistseq=data.result.detailpicklistseq;
                Popupobj.picklistcontent = data.result.picklistcontent;
                Popupobj.tmppicklist_color = data.result.tmppicklist_color;
                Popupobj.picklistdepencyfields = data.result.picklistdepencyfields;
                Popupobj.picklistobjarray = [];
                
                if (Popupobj.picklistcontent != null && Popupobj.picklistcontent != undefined){
                    for (var k = 0; k < Popupobj.picklistcontent.length; k++) {
                        //下拉框
                        var fieldname = Popupobj.picklistcontent[k].fieldname;
                        Popupobj.picklistobjarray[Popupobj.picklistcontent[k].fieldname] = new cls_picklist(Popupobj.picklistcontent[k].fieldname, Popupobj.picklistcontent[k].optionvalue);

                        var tmpinputobj = CrmPopup.findHtmlobj(Popupobj.divid,"cmb_span_optiontext_"+fieldname);
                        //zxm 20230403  kfbcrm 客户--序时簿列表 客户来源字段，点编辑不显示颜色---需要手动重新选择一下才显示
                        tmpinputobj.css('color',Popupobj.tmppicklist_color);
                        ld(tmpinputobj).off("keyup").on("keyup",function(){
                            var keyuppopupobj =  CrmPopup.getPopupObj('last');
                            keyuppopupobj.picklistobjarray[fieldname].com_chosen(event);
                            
                            //下拉框内容重新定位
                            var fromobj=CrmPopup.findHtmlobj(keyuppopupobj.divid,"cmb_a_"+fieldname);//获取点击按钮元素
                            var dvdrop= CrmPopup.findHtmlobj(keyuppopupobj.divid,"dv_drop_"+fieldname);//获取下拉框内内容
                            if(fromobj.hasClass('chzn-single-with-drop'))
                            {
                                var dvfluobj= CrmPopup.findHtmlobj(keyuppopupobj.divid,"dv_cmb_"+fieldname);//
                                var newpicklistleft = ld(dvfluobj).offset().left;//left
                                var dvfluobjtop = ld(dvfluobj).offset().top;
                                var dvfluobjheight = ld(dvfluobj).height();
                                var dvchzncontentobj= CrmPopup.findHtmlobj(keyuppopupobj.divid,"dv_chzn_"+fieldname);//
                                var dvchzncontentheight = ld(dvchzncontentobj).height();
                                dvfluobjheight = dvfluobjheight>0?dvfluobjheight:dvchzncontentheight;
                                var picklisttop = ld(dvdrop).offset().top;
                                var picklistheight = ld(dvdrop).height();
                                picklistheight = parseInt(picklistheight) > 280 ? 280 : picklistheight;
                                var newpicklisttop = dvfluobjtop+dvfluobjheight;
                                var windowHeight =CrmPopup.getClientHeight();
                                newpicklisttop = (newpicklisttop+picklistheight)>windowHeight?(dvfluobjtop-picklistheight-2):newpicklisttop;
                                dvdrop.css("left",newpicklistleft);
                                dvdrop.css("top",newpicklisttop+'px');
                            }
                        })
                        if (Popupobj.picklistdepencyfields != null && Popupobj.picklistdepencyfields != "" && Popupobj.picklistdepencyfields[fieldname] != undefined) {
                            Popupobj.picklistobjarray[Popupobj.picklistcontent[k].fieldname].setparentDependField(Popupobj.picklistdepencyfields[fieldname]);
        
                        }
                    }
                    
                }
                Popupobj.picklist_end_foucs=function(event,fieldname)
                {
            		ld("#"+this.divid+" [name=cmb_span_optiontext_"+fieldname+"]").select();
                }
                Popupobj.picklist_arrow_click = function (event, fieldname) {
                    cmb_fldname = fieldname;//用于picklist.js中document.onclick调用
                    cmb_parentdivid = this.divid;//用于picklist.js中document.onclick调用
                    Popupobj.picklistobjarray[fieldname].arrow_click(fieldname);
                    
                    //下拉框内容重新定位
                    var fromobj=CrmPopup.findHtmlobj(cmb_parentdivid,"cmb_a_"+fieldname);//获取点击按钮元素
                    var dvdrop= CrmPopup.findHtmlobj(cmb_parentdivid,"dv_drop_"+fieldname);//获取下拉框内内容
                    if(fromobj.hasClass('chzn-single-with-drop'))
                    {
                        var dvfluobj= CrmPopup.findHtmlobj(cmb_parentdivid,"dv_cmb_"+fieldname);//
                        var newpicklistleft = ld(dvfluobj).offset().left;//left
                        var dvfluobjtop = ld(dvfluobj).offset().top;
                        var dvfluobjheight = ld(dvfluobj).height();
                        var dvchzncontentobj= CrmPopup.findHtmlobj(cmb_parentdivid,"dv_chzn_"+fieldname);//
                        var dvchzncontentheight = ld(dvchzncontentobj).height();
                        dvfluobjheight = dvfluobjheight>0?dvfluobjheight:dvchzncontentheight;
                        var picklisttop = ld(dvdrop).offset().top;
                        var picklistheight = ld(dvdrop).height();
                        picklistheight = parseInt(picklistheight) > 280 ? 280 : picklistheight;
                        var newpicklisttop = dvfluobjtop+dvfluobjheight;
                        var windowHeight =CrmPopup.getClientHeight();
                        newpicklisttop = (newpicklisttop+picklistheight)>windowHeight?(dvfluobjtop-picklistheight-2):newpicklisttop;
                        dvdrop.css("left",newpicklistleft);
                        dvdrop.css("top",newpicklisttop).css('bottom','unset');
                    }
                }
                var fieldSensitiveruleobj=new cls_fieldSensitiverule(Popupobj,Popupobj.sensitiverelatedfield);
                Popupobj.fieldSensitiveruleobj=fieldSensitiveruleobj;
                fieldSensitiveruleobj.setEvent();

                DelProgressObjs();
            }
            else if(data.code == -1){
                var confirm_str = data.result.errormsg;
                DelProgressObjs();
    			// audioRemindsMsg("", "", "", "", "", confirm_str);
                MessagePopup.TipZero_warning(confirm_str);
            }
            
            
        })
  }
  
  this.EditPopupEvent=function(popupobj)
  {
        var savebuttonobj = ld("#"+popupobj.divid+'_btnok');
        popupobj.savebuttonobj = savebuttonobj;

        var fields = popupobj.fields;
        var uitype = popupobj.fieldinfo.uitype;
        var i = 0;
        if (SaveDataRecord.isfileattachUitype(popupobj.fields[i].uitype)) {
            var fileuploader = CrmPopup.findHtmlobj(popupobj.divid, popupobj.fields[i].fieldname);
            //editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/26 0:21
            //此处要做单例缓存，避免重复请求；若后台判断出是cos，应即可返回临时授权码
            var uploadFile = new WebUploadFile();
           
            globalWebUploadType = uploadFile.getScript(globalWebUploadType);
            uploadFile.setEvent(globalWebUploadType,fileuploader,popupobj,i);
         
            if (popupobj.fields[i].uitype == 28) {
                popupobj.docfilename = popupobj.fields[i].fieldname;
                showType();
            }
           window.setTimeout(function (i) {
                
                if(popupobj.fields[i].allowedit=='no')
                     ld("#"+that.divid+" [name="+that.fields[i].fieldname+"]").find(" [tag=deletefile]").css("display",'none');
             },200,i);
            
            
        }

        else if (popupobj.fields[i].uitype == 230 || popupobj.fields[i].uitype == 231) {
            
            //zkt 20220408 50884: （81mis.com/kfbcrm）（列表编辑）客户》客户列表，编辑富文本框字段，调用文档模板，点击模板没有反应，模板没填充到编辑栏内
            var tmpokeditor = UE.getEditor(popupobj.fields[i].fieldname);//实例化编辑器
            popupobj.oCKeditor = tmpokeditor;
            popupobj.oCKeditors[popupobj.fields[i].fieldname] = tmpokeditor;
            var tmpfieldname = popupobj.fields[i].fieldname;
            window.setTimeout(function (j) {
                //33793: 知识管理序时簿界面：点击操作列下面的“编辑”按钮，“知识管理”弹出层位置太靠下，“保存”按钮被遮挡
                var id = ld('#' + j).children("div:first-child").attr("id");
                ld('#' + id).css('z-index', '99999');
            }, 500, tmpfieldname);//防止变量污染，故需传递到闭包里面，可拿联系人模块的负责项目uitype为33测试。
        }
        else if(popupobj.fields[i].uitype==251)
        {
            //40471: （http://51mis.com/demo/panlulu004演示账套 [^]）财务核算->收款单，收款单新建界面，选择客户有预收单的源单后，更改账户下拉选项，可使用的预收单信息也应该随之更新
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(popupobj.fields[i].fieldname);
          
            cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(280);
        }
        else if (popupobj.fields[i].uitype == 33) {
            var tmpfieldname = popupobj.fields[i].fieldname;
            //ld('#' + tmpfieldname).select2({closeOnSelect: false});//详情编辑页面的多选框支持连续多选不收起
            //设置select2的zIndex
            ld('#' + popupobj.divid + " [name='" + tmpfieldname + "[]']").select2({
                closeOnSelect: false,//详情编辑页面的多选框连续多选不收起
                dropdownParent: ld("#" + popupobj.divid)
            });
        }
        
  }
  
  this.EditPopupobjSave=function(){
    var popupobj = CrmPopup.getPopupObj('last');
    popupobj.savebuttonobj.prop('disabled',true);
    var fieldname = popupobj.fieldname;
    var record = popupobj.record;
    var module = popupobj.module;
    var fieldinfo = popupobj.fieldinfo;
    var typeofdata = fieldinfo.typeofdata;
    var typeofdataarr = typeofdata.split("~");

    //BUG0059748 列表小编辑保存需要字段验证
    if(!formValidate()){
        return ;
    }
    //产生编辑弹窗
    var surl = "index.php?module=Users&action=UsersAjax&file=ListEditSave";
    surl += "&frommodule="+module+"&fieldname="+fieldname+"&record="+record;
    var divid = popupobj.divid;
    var tmpurl = '';
    var fieldvalue = '';
    var i = 0;
    var sensitiverequestfield_arr = [];
    if (SaveDataRecord.isfileattachUitype(popupobj.fields[i].uitype))//附件，图片
    {
        tmpurl += SaveDataRecord.getFileAttachmenturl(popupobj.fields[i], popupobj.divid);
    }
    else if(fieldinfo.uitype == 112){
        tmpurl += '&reltab=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, 'related_to_type'));
        fieldvalue = CrmPopup.getHtmlobjval(divid, fieldname);
        if(fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
            fieldvalue = fieldinfo.sensitiveencryptvalue;
            sensitiverequestfield_arr.push(fieldname);
        }
        tmpurl += '&' + fieldname + '=' + encodeURIComponent(fieldvalue);
    }
    else if(fieldinfo.uitype == 117){
        //币种
        var elementobj = CrmPopup.findHtmlobj(divid, fieldname);
        fieldvalue = CrmPopup.getHtmlobjval(divid, fieldname);
        if(fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
            fieldvalue = fieldinfo.sensitiveencryptvalue;
            sensitiverequestfield_arr.push(fieldname);
        }
        tmpurl += '&' + fieldname + '=' + encodeURIComponent(fieldvalue);
        tmpurl += '&hidden_currency_id=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, 'hidden_currency_id'));
    }
    //zkt 20220513 树结构多选框编辑无法保存
    else if(fieldinfo.uitype == 33){
        var fieldvalue = getMultiPickListSelectValue(popupobj.fields[i].fieldname+"[]");
        tmpurl += "&" + fieldname + "=" + encodeURIComponent(fieldvalue);
    }
    else if (fieldinfo.uitype == 34) {
          //edit:duan date:2024/10/24 reason:用户模块的职位级别字段特殊处理
          fieldvalue = CrmPopup.getHtmlobjval(divid, fieldname);
          tmpurl += "&" + fieldname + "=" + encodeURIComponent(fieldvalue);

          var json_value  = CrmPopup.getHtmlobjval(divid, 'jsonvalue_'+fieldname);
          tmpurl += "&jsonvalue_" + fieldname + "=" + encodeURIComponent(json_value);
      }
    else {
        fieldvalue = CrmPopup.getHtmlobjval(divid, fieldname);
        if(fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
            fieldvalue = fieldinfo.sensitiveencryptvalue;
            sensitiverequestfield_arr.push(fieldname);
        }
        tmpurl += '&' + fieldname + '=' + encodeURIComponent(fieldvalue);
    }
    var juedefieldvalue = fieldvalue;
    if(fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
        juedefieldvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(juedefieldvalue,true,fieldinfo);
    }
    if(typeofdataarr[1]=='M' && (juedefieldvalue==""|| juedefieldvalue==undefined))
    {//必填字段不能为空
        if(SaveDataRecord.isfileattachUitype(popupobj.fields[i].uitype)){
            var filenoempty = false;
            for(var i=0;i<=220;i++)
            {
                if(CrmPopup.findHtmlobj(popupobj.divid,fieldname+'-file_name_'+i)!=undefined&&CrmPopup.findHtmlobj(popupobj.divid,fieldname+'-file_name_'+i).length>0&&
                    CrmPopup.findHtmlobj(popupobj.divid,fieldname+'-file_name_'+i).val()!='')
                {
                    filenoempty =  true;
                }
    
            }
            if(CrmPopup.findHtmlobj(popupobj.divid,'filelocationtype') != undefined && CrmPopup.findHtmlobj(popupobj.divid,'filelocationtype').val() == 'E' && CrmPopup.findHtmlobj(popupobj.divid,'name_E__').val() != ''){
                filenoempty = true;
            }
            if(filenoempty == false){
                var confirm_str = fieldinfo.fieldlabel+arrJsPopLabel['CANOTEMPTY'];
                // audioRemindsMsg("","","","","",confirm_str);
                MessagePopup.TipZero_warning(confirm_str);
                return false;
            }
        }
        else{
            var confirm_str = fieldinfo.fieldlabel+arrJsPopLabel['CANOTEMPTY'];
		//  audioRemindsMsg("", "", "", "", "", confirm_str);
            MessagePopup.TipZero_warning(confirm_str);
            return false;
        }
    }
      tmpurl += "&sensitiverequestfield="+JSON.stringify(sensitiverequestfield_arr);
      surl+="&pagevaliddatasavetip="+this.pagevaliddatasavetip;
    surl += tmpurl;
  
    var con = true;
    //duan 20240611 修改后需要判断是否重置审批状态,调整提示框
    con = validatasave.checkResetApprove(popupobj,record,module,that.EditPopupobjSave);
    if (!con) {
        return '';
    }


    
    ldAjax(surl,'',function(data){
        
        if(data.code ==1)
        {
            var popupobj = CrmPopup.getPopupObj('last');
            
            that.CancelEditpopup(popupobj);

            workflowCallApiPop(data.result);//工作流API弹窗

            var fieldinfo = data.result.fieldinfo;
            var fieldshowinfo = data.result.fieldshowinfo;
            updateListtdFieldHtml(that.tdobj,module,fieldshowinfo);
            IsFrameElement();
            var confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
            ld('#rptContentLoading').hide();
            //zkt 20220525 52115(https://81mis.com/kfbcrm/index.php)(序时簿小编辑)（客户管理》客户》客户编号》2022-05-23-201修改为2022-05-23-200，与其他客户重复，但是保存时没有提醒而且还很卡，必须要刷新页面才可以显示）
            //单据编号重复时自动生成新编号提醒
            if(!empty(fieldshowinfo.modulebillnotip)&&fieldshowinfo.modulebillnotip == 'yes')
            {
                setdupBillNoTip(fieldshowinfo.modulebillnotip,that.listpopupobj.fields);
                return ;
            }
			// successaudioRemindsMsg("", "", "", "", "", confirm_str);
            MessagePopup.TipZero_success(confirm_str);
            // ljj 20230913 BUG0072489 kfbcrm-自定义表单59，列表界面小编辑设为树结构的下拉框字段，左侧树结构后的数量没有更新，需要手动刷新
            var treepopupobj=CrmPopup.getPopupObj("last");
            var isstructuretree=ld("#structuretree");
            if (isstructuretree.length>0){
                structureTreeobj.getModuleTreeCount(treepopupobj);
            }
        }
        else if(data.code=='-10')//验证规则 
        {
             con= confirm(data.msg);
             if(!con){
                    return false;
                }
             that.pagevaliddatasavetip='no';
             that.EditPopupobjSave();
             
        }
        else if(data.code == -1){
            that.pagevaliddatasavetip='no';
            var confirm_str = data.msg;
            ld('#rptContentLoading').hide();
            var popupobj = CrmPopup.getPopupObj('last');
            popupobj.savebuttonobj.prop('disabled',false);
            if(data.result.operation == 'editpage')
            {
                //打开编辑界面
                var popupobj = CrmPopup.getPopupObj('last');
                that.CancelEditpopup(popupobj);//关闭小编辑弹窗
                var urlstring= '';
                var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",module,"","","","",record);
                Popupobj.prevshow();
                var url = 'module='+module+'&action=EditView&record='+record;
                url += '&return_module='+module+'&return_action=LIstView';
                if(module == 'Attachment'){
                    var userid = ld('#userid').val();
                    if(ld('#userid') != undefined){
                        url += '&swid='+userid;
                        url += '&return_id='+record;
                    }
                }
                //列表和相关信息编辑
                if(CrmPopup.getPopupObj("last").type=='listpage'
                    ||CrmPopup.getPopupObj("last").type=='relatedpagelist'
                    ||CrmPopup.getPopupObj("lastprev").type=='listpage'
                    ||CrmPopup.getPopupObj("lastprev").type=='relatedpagelist')
                {
                    PageRecordPopup.params['refreshpage']='no';
                }
                PageRecordPopup.showpage(module,record,"",PageRecordPopup.params);
                
            }
            //zkt 20230328 BUG0062778  新建、编辑，序时簿列表小编辑界面，输入错误手机号码的提示信息缺少“！” 
            if(confirm_str.indexOf("!") == -1 &&confirm_str.indexOf("！") == -1){
                confirm_str+='！';
            }
            // audioRemindsMsg("", "", "", "", "", confirm_str);
            MessagePopup.TipZero_warning(confirm_str);
        }
        
        
    })
    
  }
  
  //关闭小编辑弹窗事件
  this.CancelEditpopup = function(popupobj){
        if(popupobj == undefined){
            popupobj = CrmPopup.getPopupObj('last');
        }
        if(popupobj.divid == 'listeditpagepopup')
        {
            
            if(popupobj.crmpopuplayerobj != undefined)
            {
                popupobj.crmpopuplayerobj.unblock();
            }
            ld('#listeditpagepopup').css('display','none');
            CrmPopup.global_listPopupObj.pop();
        }else{
            popupobj.CancelEvent();
        }
  }

    //分录字段编辑弹出层
    this.DetailEditPopupobjShow=function(editbuttonobj,tdobj){
        //显示编辑弹出层
        that.tdobj = tdobj;
        var thisobj = editbuttonobj;
        var tdindex=ld(tdobj).attr("tdindex");
        var headerthobj = ld(this.tr_headerobj).find("th[tag="+tdindex+"]");
        var fieldname = ld(headerthobj).attr("headername");
        var value = ld(tdobj).find(" [fieldname="+fieldname+"]").html();
        var trobj = Tools.getParentobjByChild(ld(tdobj),'tr');
        var trid = ld(trobj).attr('id');
        var tridarr = trid.split('_');
        var recordarr = tridarr[1].split(',');
        var record = recordarr[0];
        var detailid = recordarr[1];
        var module = ld(trobj).attr('module');

        //产生编辑弹窗
        var surl = "index.php?module=Users&action=UsersAjax&file=ListDetailEdit";
        surl += "&frommodule="+module+"&fieldname="+fieldname+"&record="+record;
        surl += '&detailid='+detailid+'&editmode=detail';
        //zkt 添加判断，链接模块的列表界面小编辑操作,防止编辑出错
        var popupobj = that.listpopupobj;
        if(popupobj.type=="listpage"){
            if (typeof linkmodulecustom != "undefined"&& popupobj.type !='relatelistpage') {
                var page_title = ld(" .detail_path li").html();
                surl += '&is_linkmodulecustom='+linkmodulecustom;
                //@edit:zkt,reason:链接模块，单据新建/编辑/复制界面，“数据分类设置的条件”字段显示为只读的，不可编辑修改
                //获取链接模块viewname
                var page_addurl = getSearchString('page_addurl',location.href);
                if(page_addurl != undefined){
                    var linkmodule_viewname = getSearchString('viewname',page_addurl);
                    if(linkmodule_viewname != undefined){
                        surl +='&linkmodule_viewname='+linkmodule_viewname;
                    }
                }
            }
        }
        //edit: xll 2023/09/02  BUG0071761 video标签导致小编辑界面一闪而过消失
        var params = "&pagetype=ListEditPagePopup";
        ldAjax(surl,params,function(data){
            if(data.code ==1)
            {
                ld('#rptContentLoading').hide();
                var tablehtml = data.result.content;
                var fields = data.result.fields;
                var fieldinfo = fields[0];

                ld(that.popupdivobj).css('display','block');
                ld(that.popupdivobj).css('zIndex',999);
                ld('#layer').css('zIndex',998);
                var Popupobj=new Object();
                Popupobj.divid='listeditpagepopup';

                Popupobj.record = record;
                Popupobj.module = module;
                Popupobj.fields = fields;
                Popupobj.fieldinfo = fieldinfo;
                Popupobj.fieldname = fieldinfo.fieldname;
                Popupobj.fieldname_fields = [];
                Popupobj.fieldname_fields[fieldinfo.fieldname] = fieldinfo;
                Popupobj.filejsondata = data.result.filejsondata;
                Popupobj.sensitiverelatedfield = data.result.sensitiverelatedfield;
                Popupobj.isadmin = data.result.isadmin;
                Popupobj.detailfieldmodule = data.result.detailfieldmodule;
                Popupobj.detailid = detailid;
                //edit: xll 2023/10/06 BUG0072908 客户管理（包括但不限于，比如报价单、销售订单等等）数据列表，无法通过快速编辑添加视频附件。
                Popupobj.pagetype = 'ListEditPagePopup';//小编辑页

                //添加遮罩层
                Popupobj.crmpopuplayerobj = new CrmPopupLayer(Popupobj);
                Popupobj.crmpopuplayerobj.block();
                ld('#'+Popupobj.crmpopuplayerobj.opopupblocknodeid).removeClass('opacity');//设置遮罩层透明

                ld(that.popupdivobj).css('zIndex',CrmPopup.zIndex);//设置小编辑弹窗显示与遮罩层之上
                CrmPopup.global_listPopupObj.push(Popupobj);
                Popupobj.oCKeditors = [];
                //zkt 20220525 52183（https://81mis.com/kfbtest/index.php）（列表小编辑）编辑下拉框字段（所属行业），选项更新后，下拉选项没有立即更新
                Popupobj.getDetailTableObj=function(){
                    return [];
                }

                ld('#'+Popupobj.crmpopuplayerobj.opopupblocknodeid).click(function(){//点击遮罩层关闭小编辑弹窗
                    that.CancelEditpopup(Popupobj);
                });
                var contentdivobj = ld("#listeditpagepopupcontent");
                var windowWidth =CrmPopup.getClientWidth();// document.documentElement.clientWidth;
                var windowHeight =CrmPopup.getClientHeight();// ld(window).height();
                var divwidth = ld(that.popupdivobj).width();
                var tdheight = ld(tdobj).height();
                var tdleft = ld(tdobj).offset().left;
                var height = parseInt(ld(tdobj).height());
                var edittop = (ld(tdobj).parent().offset().top+height/2)+10;
                var newleft = (tdleft+divwidth)>windowWidth?windowWidth-(divwidth+10):tdleft;
                //zkt 20220524 52153（https://81mis.com/kfbtest）客户管理》客户页面，编辑靠下的记录，弹窗不能显示保存与取消按钮（列表小编辑）
                var newtop = edittop+150>windowHeight?windowHeight-150:edittop;
                ld(that.popupdivobj).css("left",newleft);
                ld(that.popupdivobj).css("top",newtop);

                var noshowconttentobj=ld(that.popupdivobj).find(" [id='listeditpagetablecontent']");
                ld(noshowconttentobj).html(data.result.content);



                var editfieldtabobj = ld(that.popupdivobj).find(" [name=listedittab]");
                var editfieldtabtrobjs = ld(editfieldtabobj).find("tr");
                ld.each(editfieldtabtrobjs,function(tmpindex){
                    if((SaveDataRecord.isfileattachUitype(fieldinfo.uitype) || fieldinfo.uitype == 19)&&tmpindex==0){
                        //附件字段返回两个tr，编辑界面内容在第二个tr中
                        return true;
                    }
                    var tmptrobj=ld(this);
                    var lablehtml = ld(tmptrobj).children().eq(0).html();
                    var inputhtml = ld(tmptrobj).children().eq(1).html();
                    //zkt 20230110 BUG0060676服务合同，服务收费管理在目录页面上进行编辑保存之后还是原本的值
                    if(fieldinfo.uitype == 56){
                        if(ld(tmptrobj).children().eq(2).length>0){
                            inputhtml += ld(tmptrobj).children().eq(2).prop("outerHTML");
                        }
                    }
                    ld(contentdivobj).find(" [name=listeidtpagecontentlabel]").html(lablehtml);
                    ld(contentdivobj).find(" [name=listeidtpagecontentinput]").html(inputhtml);
                    var tmpinputbj = ld(contentdivobj).find(" [name=listeidtpagecontentinput]");
                    var inputvalue = ld(tmpinputbj).find(" [name="+Popupobj.fieldname+"]").val();
                    ld(tmpinputbj).find(" [name="+Popupobj.fieldname+"]").val('').focus().val(inputvalue);//hjz 打开小编辑光标直接显示
                    //获取b标签个数并控制input框宽度，工商查询图标和查重图标
                    var bcount = 0;
                    ld.each(ld(tmpinputbj).children('b'),function(){
                        var tmpdisplay = ld(this).css('display');
                        var tmpclass = ld(this).attr('class');
                        if(tmpdisplay!='none'&&(tmpclass.indexOf('icon-gongshang')>=0||tmpclass.indexOf('icon-searchgrey')>=0)){
                            bcount++;
                        }
                    });
                    if(bcount>0)
                    {
                        ld(tmpinputbj).find(' [name='+fieldinfo.fieldname+']').get(0).style.removeProperty("width");
                        ld(tmpinputbj).find(' [name='+fieldinfo.fieldname+']').get(0).style.setProperty('width',(95-bcount*5)+'%','important');
                    }
                    //zkt 20220411  50880（81mis.com/kfbcrm）（列表编辑）客户》客户列表，编辑多选框字段，弹窗中2个输入
                    if(fieldinfo.uitype == 33)
                    {
                        //多选框td的select框生成的span移除，后面还会生成
                        var tmpspanobj = ld(contentdivobj).find(" [name=listeidtpagecontentinput]").find('select[id='+fieldinfo.fieldname+']').next();
                        ld(tmpspanobj).remove();
                    }
                    return false;
                });
                ld(noshowconttentobj).html('');//清空html
                that.DetailEditPopupEvent(Popupobj);

                Popupobj.detailpicklist=data.result.detailpicklist;
                Popupobj.detailpicklistseq=data.result.detailpicklistseq;
                Popupobj.picklistcontent = data.result.picklistcontent;
                Popupobj.tmppicklist_color = data.result.tmppicklist_color;
                Popupobj.picklistdepencyfields = data.result.picklistdepencyfields;
                Popupobj.detailpicklistColors = data.result.global_picklist_colors_values;
                Popupobj.picklistobjarray = [];
                if (Popupobj.detailpicklist != null && Popupobj.detailpicklist != undefined){
                    //下拉框
                    var fieldname = fieldinfo.fieldname;
                    var columnname = fieldname;

                    var comboxobj = ld(that.popupdivobj).find("[fieldtype=select]");
                    var cls_resetComboxHtmlobj = new cls_resetComboxHtml(columnname);
                    var picklistcontent = Popupobj.detailpicklist[columnname];
                    var picklistcontentseq = Popupobj.detailpicklistseq[columnname];
                    cls_resetComboxHtmlobj.setPopupObj(Popupobj);//edit:can 产品多选//产品套餐选择
                    cls_resetComboxHtmlobj.setPickListContent(picklistcontent);
                    cls_resetComboxHtmlobj.setPickListContentseq(picklistcontentseq);
                    var tmpwidth = that.popupdivobj.width();
                    var picklist_colors_values = Popupobj.detailpicklistColors[columnname];
                    cls_resetComboxHtmlobj.setPickListColors(picklist_colors_values);
                    if (Popupobj.detailfieldmodule == 'Products')
                        cls_resetComboxHtmlobj.setEvent();
                    else
                        cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(comboxobj, tmpwidth - 40);
                }
            }
            else if(data.code == -1){
                var confirm_str = data.result.errormsg;
                ld('#rptContentLoading').hide();
                // audioRemindsMsg("", "", "", "", "", confirm_str);
                MessagePopup.TipZero_warning(confirm_str);

                if(data.result.refresh == 'yes'){
                    //刷新列表界面
                    that.refreshlist(popupobj,data);
                }
            }


        })
    }

    this.DetailEditPopupEvent=function(popupobj)
    {
        var savebuttonobj = ld("#"+popupobj.divid).find(' [name=listeditpagepopupsave]');
        var cancelbuttonobj = ld("#"+popupobj.divid).find(' [name=listeditpagepopupcancel]');
        ld(savebuttonobj).attr('id',popupobj.divid+'_btnok');
        ld(savebuttonobj).unbind('click').on('click',function(){
            that.DetailEditPopupobjSave();
        });
        popupobj.savebuttonobj = savebuttonobj;
        popupobj.savebuttonobj.disabled = true;//防止保存按钮重复点击

        ld(cancelbuttonobj).unbind('click').on('click',function(){
            that.CancelEditpopup(popupobj);
        });
    }

    this.DetailEditPopupobjSave=function(){
        var popupobj = CrmPopup.getPopupObj('last');
        popupobj.savebuttonobj.disabled = false;
        var fieldname = popupobj.fieldname;
        var record = popupobj.record;
        var module = popupobj.module;
        var fieldinfo = popupobj.fieldinfo;
        var typeofdata = fieldinfo.typeofdata;
        var typeofdataarr = typeofdata.split("~");
        var detailid = popupobj.detailid;

        //产生编辑弹窗
        var surl = "index.php?module=Users&action=UsersAjax&file=ListDetailEditSave";
        surl += "&frommodule="+module+"&fieldname="+fieldname+"&record="+record+"&detailid="+detailid;
        var divid = popupobj.divid;
        var tmpurl = '';
        var fieldvalue = CrmPopup.getHtmlobjval(divid, fieldname);
        tmpurl += '&'+fieldname+'='+fieldvalue;
        tmpurl+="&pagevaliddatasavetip="+this.pagevaliddatasavetip;
        var i = 0;
        if(typeofdataarr[1]=='M' && empty(fieldvalue))
        {//必填字段不能为空
            var confirm_str = fieldinfo.fieldlabel+arrJsPopLabel['CANOTEMPTY'];
            //  audioRemindsMsg("", "", "", "", "", confirm_str);
            MessagePopup.TipZero_warning(confirm_str);
            return false;
        }
        surl += tmpurl;
        var con = true;


        ldAjax(surl,'',function(data){

            if(data.code ==1)
            {
                var popupobj = CrmPopup.getPopupObj('last');

                that.CancelEditpopup(popupobj);

                workflowCallApiPop(data.result);//工作流API弹窗

                //刷新列表界面
                that.refreshlist(popupobj,data);

                //this.listpopupobj.call
                IsFrameElement();
                DelProgressObjs();
                var confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
                MessagePopup.TipZero_success(confirm_str);
                that.pagevaliddatasavetip='yes';
            }
            else if(data.code=='-10')//验证规则
            {
                con= confirm(data.msg);
                if(!con){
                    return false;
                }
                that.pagevaliddatasavetip='no';
                that.DetailEditPopupobjSave();

            }
            else if(data.code == -1){
                var confirm_str = data.msg;
                ld('#rptContentLoading').hide();
                var popupobj = CrmPopup.getPopupObj('last');
                popupobj.savebuttonobj.disabled = true;
                if(data.result.operation == 'editpage')
                {
                    //打开编辑界面
                    var popupobj = CrmPopup.getPopupObj('last');
                    that.CancelEditpopup(popupobj);//关闭小编辑弹窗
                    var urlstring= '';
                    var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",module,"","","","",record);
                    Popupobj.prevshow();
                    var url = 'module='+module+'&action=EditView&record='+record;
                    url += '&return_module='+module+'&return_action=LIstView';
                    if(module == 'Attachment'){
                        var userid = ld('#userid').val();
                        if(ld('#userid') != undefined){
                            url += '&swid='+userid;
                            url += '&return_id='+record;
                        }
                    }
                    //列表和相关信息编辑
                    if(CrmPopup.getPopupObj("last").type=='listpage'
                        ||CrmPopup.getPopupObj("last").type=='relatedpagelist'
                        ||CrmPopup.getPopupObj("lastprev").type=='listpage'
                        ||CrmPopup.getPopupObj("lastprev").type=='relatedpagelist')
                    {
                        PageRecordPopup.params['refreshpage']='no';
                    }
                    PageRecordPopup.showpage(module,record,"",PageRecordPopup.params);

                }
                //zkt 20230328 BUG0062778  新建、编辑，序时簿列表小编辑界面，输入错误手机号码的提示信息缺少“！”
                if(confirm_str.indexOf("!") == -1 &&confirm_str.indexOf("！") == -1){
                    confirm_str+='！';
                }
                // audioRemindsMsg("", "", "", "", "", confirm_str);
                MessagePopup.TipZero_warning(confirm_str);

                if(data.result.refresh == 'yes'){
                    that.CancelEditpopup(popupobj);
                    //刷新列表界面
                    that.refreshlist(popupobj,data);
                }
            }


        })

    }

    this.refreshlist = function (popupobj,data){
        //刷新列表界面
        var tmparr=data.result.refreshlistmodules;
        var tmpobj= new AfterUpdatePrevPopupObjContent(that.module,data.result,tmparr);
        var divobj = ld('#resize_content_table_divid').get(0);
        var scroll_top = divobj.scrollTop;
        var scrollLeft = divobj.scrollLeft;
        tmpobj.eachrefreshlistbyModules(tmparr);
        console.log(tmparr);
        if(empty(that.listpopupobj.listresizeobj)){
            var listresizeobj=new List_ResizeTable(that.listpopupobj);
            that.listpopupobj.listresizeobj=listresizeobj;
        }else{
            var listresizeobj = that.listpopupobj.listresizeobj;
        }
        listresizeobj.list_scroll_top = scroll_top;
        listresizeobj.list_scroll_Left = scrollLeft;

        //重新刷新界面方法,增加移动滚动条
        if(empty(listresizeobj.setReiszeTable_Init_new)){
            var tmp_fun = listresizeobj.setReiszeTable_Init;
            listresizeobj.setReiszeTable_Init_new = tmp_fun;
            listresizeobj.setReiszeTable_Init = function (module,pagetype){
                this.setReiszeTable_Init_new(module,pagetype);
                if(this.list_scroll_top > 0){
                    ld('#resize_content_table_divid').get(0).scrollTop = this.list_scroll_top;
                    this.list_scroll_top = 0;
                }
                if(this.list_scroll_Left > 0){
                    ld('#resize_content_table_divid').get(0).scrollLeft = this.list_scroll_Left;
                    this.list_scroll_Left = 0;
                }
            }
        }
    }


}

ListEditPagePopup.pagetype = "ListEditPagePopup";
