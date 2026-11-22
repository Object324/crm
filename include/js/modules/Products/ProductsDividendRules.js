/*
* editor:gyq_09
* reason:新增文件-派息规则处理类
* date  : 2016 4 7
* */
var Products_dividendRules = (function () {


    //参数：传递给单例的一个参数集合
    function dividendRules() {
        this.is_recalculation_float_income="no";//是否立核算浮动收益
        //数据库中浮动收益相关参数
        this.old_float_switch='';
        this.old_float_start="";
        this.old_float_rate="";
        this.name = 'Products_dividendRules';

    }


    dividendRules.prototype.init = function(){
    }

    /* 本金计算方式 */
    dividendRules.prototype.formula_capital = function (obj) {

        //var optionVal = ld('#dividendRules_contain select[name="formulacapital"]').val();
        var optionVal = ld(obj).val();

        ld('#dividendRules_contain option[value="' + optionVal + '"]').attr("selected",true);

        /* 一次性派息联动 */
        var select = ld('#dividendRules_contain select[name="grantdateright"]');
        select.next().val(select.find('option:selected').text());;

        ld('#dividendRules_contain input[name="formulacapitalsons"]').each(function(){
            ld(this).val(ld(this).prev().find('option:selected').text());
        });

    }

    /* 利息计算方式 */

    dividendRules.prototype.formula_mode = function (obj,editinfo) {
        var ruleobj = this;

        var selVal = ld(obj).val();

        /* 按月派息方显示浮动派息框和截止日期框 */
        if(selVal == 'monthly'){
            ld('#dividend_floatincome_div').css({"display":""});
            ld('#dividend_deadline_div').css({"display":""});
        }else{
            ld('#dividend_floatincome_div').css({"display":"none"});
            ld('#dividend_deadline_div').css({"display":"none"});


        }
        ld.get("index.php",{formulamode_ajax : selVal ,module:"Products",file:"DividendRules",'action':"ProductsAjax"},function(response){

            var  responseArr =  response.split('$##$');
            ld('#dividendRules_contain select[name="formulas"]').html(responseArr[0]);
            ld('#dividendRules_contain td[class="grantdatecontent"]').html(responseArr[1]);

            if(selVal == 'oneoff'){
                var formula_capital=ld('#dividendRules_contain select[name="formulacapital"]').val();
                ld('#dividendRules_contain option[value="' + formula_capital + '"]').attr("selected",true);
                var select = ld('#dividendRules_contain select[name="grantdateright"]');
                select.next().val(select.find('option:selected').text());;
            }

            if(editinfo!=undefined&&editinfo.length > 0){//初始化调用

                if(editinfo[1] == 'monthly'){

                    ld('#dividendRules_contain #dividend_floatincome_div input').attr('disabled',false);

                    ld('#dividendRules_contain select[name="deadline"] option[value="'+ editinfo[2] +'"]').attr("selected",true);
                    ld('#dividendRules_contain select[name="grantdateleft"] option[value="'+ editinfo[4] +'"]').attr("selected",true);

                    /* 利息发放日 */
                    ruleobj.grant_rate(editinfo[3]);
                    /* 浮动收益 */
                    if(editinfo[7] == 'on'){
                        ld('#dividendRules_contain #dividend_floatincome_div').css({"color":"#555"});
                        ld('#dividendRules_contain #dividend_floatincome_div input[type="checkbox"]').attr("checked",true).val('on');
                        ld('#dividendRules_contain #dividend_floatincome_div input[name="floatstartdate"]').val(editinfo[8]);
                        ld('#dividendRules_contain #dividend_floatincome_div input[name="floatyield"]').val(editinfo[9]);
                    }
                    ruleobj.old_float_switch=editinfo[7];
                    ruleobj.old_float_start=editinfo[8];
                    ruleobj.old_float_rate=editinfo[9];
                    
                }else if(editinfo[1] == 'designated'){

                    var dateArr = editinfo[5].split('$##$');

                    /* 自动生成日期 */
                    for(var i=0;i<dateArr.length-1;i++){
                        var lastdiv = ld('div[class="dividend_active_date"]').last();
                        lastdiv.find('input').val(dateArr[i]);
                        var addimg = lastdiv.find('img').last();
                        ruleobj.add_div(addimg);
                    }
                    ruleobj.delete_div(ld('div[class="dividend_active_date"]').last().find('img').first());
                }else{

                    ld('#dividendRules_contain select[name="grantdateright"] option[value="'+ editinfo[3] +'"]').attr("selected",true);

                }

                /* 利息计算公式 */
                ld('#dividendRules_contain select[name="formulas"] option[value="'+ editinfo[6] +'"]').attr("selected",true);

            }

        });

    }

    /* 派息日期 */
    dividendRules.prototype.grant_rate = function (gratedate) {


        var deadline = ld('#dividendRules_contain select[name="deadline"]').val();
        var grantdate = ld('#dividendRules_contain select[name="grantdateleft"]').val();

        ld.get("index.php",{deadline_ajax : deadline ,grantdate_ajax:grantdate,module:"Products",file:"DividendRules",'action':"ProductsAjax"},function(response){
            ld('#dividendRules_contain select[name="grantdateright"]').html(response);

            if(gratedate.length > 0){
                ld('#dividendRules_contain select[name="grantdateright"] option[value="'+gratedate+'"]').attr("selected",true);
            }
        });
    }
    /* 浮动收益多选框 */
    dividendRules.prototype.float_switch = function(obj){

       // var checked = ld(obj).attr('checked');
		var checked = obj.checked;
        if(checked){
            ld(obj).val('on');
            ld('#dividend_floatincome_div').css({"color":"#555"});
        }else{
            ld(obj).val('off');
            ld('#dividend_floatincome_div').css({"color":"grey"});
        }

        var inputs = ld('#dividend_floatincome_div input[type="text"]');
        inputs.attr('disabled',checked?false:'disabled');
        if(!checked){
            inputs.val('').removeAttr("style");
            inputs.last().attr('style','width:300px')
        }
    }

    /* 自动检测收益率合法性 */
    dividendRules.prototype.auto_units = function (onblur) {


        var formulamode = ld('#dividendRules_contain  select[name="formulamode"]').val();
        var float_switch = ld('#dividend_floatincome_div input[name="float_switch"]').val();



        if(formulamode == 'monthly' && float_switch == 'on'){

            var obj = ld('#dividend_floatincome_div input[name="floatyield"]');

            var match = /^\d+(\.\d+)?$/;
            var check = 0;
            if(match.test(obj.val())){
                obj.attr("style","width: 300px;border:solid 1px #999;border-bottom :solid 1px green");
                check += 1;
            }else{
                obj.attr("style","width: 300px;border:solid 1px #999;border-bottom :solid 1px red");
                check += 0;
            }

            var startdate = ld('#dividendRules_contain #dividend_floatincome_div input[name="floatstartdate"]');

            if(startdate.val().length < 1){
                startdate.attr("style","border:solid 1px #999;border-bottom :solid 1px red");
                check += 0;
            }else{
                startdate.attr("style","border:solid 1px #999;border-bottom :solid 1px green");
                check += 1;
            }

            if(check < 2){
                if(onblur != 'onblur'){
                    alert(arrJsPopLabel['REMINDFORUNLEGALCON']);
                }
                return false;
            }else{
                var float_start_date= ld('form input[name="floatstartdate"]').val();
                var float_rate=ld('form input[name="floatyield"]').val();
                if(float_switch=='off')
                    float_switch='';
                if(this.old_float_switch=='off')
                    this.old_float_switch='';
                if(this.old_float_rate=='')
                    this.old_float_rate=0;
                if(float_rate=='')
                    float_rate=0;
                if(this.old_float_start<='1600-01-01');
                this.old_float_start='';

                if(float_start_date<='1600-01-01')
                    float_start_date='';
                if(float_switch!=this.old_float_switch||this.old_float_rate!=float_rate||this.old_float_start!=float_start_date)
                {
                    if(onblur != 'onblur'){
                        if(confirm(arrJsPopLabel['HASSETFLOATINCOMEWHETER']))
                        {
                            this.is_recalculation_float_income="yes";

                        }
                    }
                }

                if(this.is_recalculation_float_income=='yes')
                {
                    //浮动收益重新计算
                    ld('form input[name="recal_float_income"]').val('yes');
                }
                return true;
            }

        }else if(formulamode == 'designated'){
            var desidate = this.grantdate_designated();
            if(desidate == 'empty'){

                if(onblur != 'onblur'){
                    alert(arrJsPopLabel['REMINDFORUNLEGALCON']);
                }
                return false;
            }else{

                return true;
            }
        }else{
            return true;
        }

    }

    dividendRules.prototype.grantdate_designated = function () {
        if(ld('#dividendRules_contain select[name="formulamode"]').val() == 'designated') {

            var dateStr = '';
            ld('#dividendRules_contain input[name="grantdateright"]').each(function () {

                if(ld(this).val().length > 0){
                    dateStr += ld(this).val() + '$##$';
                }
            });
            if(dateStr.length == 0){
                return 'empty';
            }
            ld('form input[name="grantdate_designated"]').val(dateStr);
        }
    }

    /* 删除自定义派息日 */
    dividendRules.prototype.delete_div = function (obj) {

        var divnum = ld('div[class="dividend_active_date"]').length;
        if(divnum >1) {

            ld(obj).parent().remove();
            var lastdiv = ld('div[class="dividend_active_date"]').last();
            if (lastdiv.children().length < 3) {
                lastdiv.find('img').after('<a class="icon-homeimg icon-select" href="javascript:;" onclick="Products_dividendRules.getInstance().add_div(this);"></a></div>');
            }
        }

    }
    /* 新增自定义派息日 */
    dividendRules.prototype.add_div = function (obj) {

        var divnum = ld('div[class="dividend_active_date"]').length;
        var addimg = '<a class="icon-homeimg icon-select" href="javascript:;" onclick="Products_dividendRules.getInstance().add_div(this);"></a>';
        if(divnum < 12){
            if(divnum == 11){
                addimg = '';
            }
            ld(obj).parent().after('<div class="dividend_active_date" style="float:left;margin-right:2px;width: 190px;height:30px">'+
                '<input name="grantdateright"  class="Wdate"   type="text" style="border:1px solid #bababa;"'+
                'fieldonly="0" size="20" maxlength="10"  onclick="WdatePicker()">'+
                ' <a class="icon-homeimg icon-sdel" href="javascript:;"  title="删除" onclick="Products_dividendRules.getInstance().delete_div(this);"></a>'+
                addimg +'</div>');
        }
        ld(obj).remove();
        return obj;
    }




    /* 编辑界面初始化 */
    dividendRules.prototype.editInterface = function () {

       
        var editinfo = ld('form input[name="didvidendRules_info"]').val().split(',');

        if(editinfo.length > 0 ){
          
            /* 本金计算方式 */
            ld('#dividendRules_contain option[value="'+ editinfo[0] +'"]').attr("selected",true);

            /* 利息计算方式 */

            ld('#dividendRules_contain  select[name="formulamode"] option[value="'+ editinfo[1] +'"]').attr("selected",true);

            this.formula_mode(ld('#dividendRules_contain  select[name="formulamode"]'),editinfo);
        }
    }

    /* 派息规则按钮事件 */
    dividendRules.prototype.Buttons_dividendRules = function(obj,module,record){


        var returnmodule=module;
      
        var thisobj = this;
        var selectedval = ld('#allselectedboxes').val();
        var fromview = 'listview';

        if(record > 0){
            selectedval = record;
            fromview = 'detailview';
        }
       
        if(selectedval.toString().length > 0){
            
            var url='index.php?dividendrules_ids='+selectedval+"&module=Products&file=DividendRules&action=ProductsAjax&fromview="+fromview;
            
             ld.ajax({
                url: url,
                type: 'POST',
                data:{"namename": "uname", "namenameage": 18},
               dataType:'json',
                async: true,//
                timeout: 10000,
               
                success: function(data)
                {
                  
                   
                    if(data.code==1)
                    {
                         
                        var popupobj=CrmPopup.load(data.result.title,"","","LdPopWidth600px","Products","",data.result.oktext,'',data.result.canceltext);
                        popupobj.show(data.result.content);
                        thisobj.interfaceButtons(module);
                        thisobj.editInterface();
                        
                    }
                    else
                    {
                      
                      
                    }
                
                },
                error:function(data)
                {
                 
                }
                
            });
   
       
            

        }else{
            alert(arrJsPopLabel['PLEASESELECTONEENTITY']);
            return false;
        }
    }

    /* 合同订单创建派息单，派息规则按钮事件 */
    dividendRules.prototype.Rules_In_CreateDividendOrder = function(obj,module,record){
        /* 隐藏派息单 */
         var thisobj = this;
           
        var url='index.php?dividendrules_ids='+record+"&module=Products&file=DividendRules&action=ProductsAjax&fromview=detailview";
            
             ld.ajax({
                url: url,
                type: 'POST',
                data:{"namename": "uname", "namenameage": 18},
               dataType:'json',
                async: true,//
                timeout: 10000,
               
                success: function(data)
                {
                  
                   
                    if(data.code==1)
                    {
                         
                        var popupobj=CrmPopup.load(data.result.title,"","","LdPopWidth600px","Products","",data.result.oktext,'',data.result.canceltext);
                        
                        popupobj.show(data.result.content);
                    
                        thisobj.interfaceButtons(module);
                        
                        thisobj.editInterface();
                        
                    }
                    else
                    {
                      
                      
                    }
                
                },
                error:function(data)
                {
                 
                }
                
            });
   
   
   
       /* ld('#CreateDividendOrder').hide();
        var thisobj = this;

        ld.post("index.php",{dividendrules_ids : record ,module:"Products",file:"DividendRules",'action':"ProductsAjax"},function(response) {

            createElementDiv('Products_dividendRules');

            ld('#Products_dividendRules').html(response);

            ld('#Products_dividendRules').attr('class','D_pop_box LdPopWidth600px');

           
            var travelview = ld('#dividendRules_contain > input[name="travelview"]').val();
            if(travelview == 'travelview'){
                ld('#dividendRules_contain table:first').nextAll().remove();
                ld('#Products_dividendRules').find('input[class="D_pbtnok"]').remove();
            }else{
                thisobj.editInterface();
            }

            thisobj.interfaceButtons(module,obj);
            fnvshobj(obj,'Products_dividendRules');

        });*/
    }


    /* 派息单页面弹框保存取消关闭按钮事件 */
    /* 参数obj仅代表合同订单创建派息单按钮事件对象 */
   // dividendRules.prototype.interfaceButtons.funname='dividendRules.prototype.interfaceButtons';
    
    dividendRules.prototype.interfaceButtons = function(module,obj){
        var thisobj = this;
        if(module == 'Products'){
            
            var popupobj=CrmPopup.getPopupObj("last");
           
            ld('#'+popupobj.divid+"_btnok").on('click',function(){
                
                //chj 2021/3/12 44956: （http://51mis.com/ys/1018 [^]）客户问题（徐燕男），产品单据查看详情界面，点击派息规则->保存，界面返回到首页了
                if(thisobj.auto_units()){
					 var arr = {};
                    ld('#'+popupobj.divid).find('*[name]').each(function () {
                        arr[ld(this).attr('name')] = ld(this).val();
                    })
                    var forminfo = JSON.stringify(arr);
					 ld.post("index.php", {
                        serializeinfo: forminfo,
                        module: "Products",
                        file: "DividendRules",
                        'action': "ProductsAjax"
                    }, function (response) {
                        
                        popupobj.CancelEvent();
                       
                    });
                   //ld('#'+popupobj.divid+" [name=dividend_rules]").submit();
                }
               // thisobj.active_date_save(this.form);
            });
           

        }else if(module == 'SalesOrder'){
             var popupobj=CrmPopup.getPopupObj("last");
            ld('#'+popupobj.divid+"_btnok").on('click',function(){
                
                    
               

                if(thisobj.auto_units()) {

                   

                    var arr = {};
                    ld('#'+popupobj.divid).find('*[name]').each(function () {
                        arr[ld(this).attr('name')] = ld(this).val();
                    })
                    var forminfo = JSON.stringify(arr);

                    ld.post("index.php", {
                        serializeinfo: forminfo,
                        module: "Products",
                        file: "DividendRules",
                        'action': "ProductsAjax"
                    }, function (response) {
                        
                        popupobj.CancelEvent();
                        /*ld('#Products_dividendRules').hide();
                        ld('#DividendOrder_form_div').html('');

                       */
                        NewDividendOrder(ld(obj), 'CreateDividendOrder',
                            ld('form[name="DetailView"] > input[name="record"]').val());
                            
                    });
                }
            });


            ld('#Products_dividendRules').find('input[class="D_pbtncancel"],a[class="D_ptitc"]').on('click',function(){
                fninvshnew('Products_dividendRules');
                puyoungJS_DialogBox.unblock();
                ld('#CreateDividendOrder').show();
            });
        }
    }



    //实例容器
    var instance;

    var _static = {
        name: 'Products_dividendRules',

        //获取实例的方法
        getInstance: function () {
            
          
            if (instance === undefined) {
                instance = new dividendRules();
            }
            return instance;

        }
    };
    return _static;

})();
