function DataHtmlBind()
{
    var that=this;
    this.type='';
    this.istype='';
    this.setPopupobj=function(popupobj)
    {
        this.popupobj=popupobj;
    }
    this.setJqueryObj=function(jqueryobj)
    {
         this.jqueryobj=jqueryobj;
    }
    
    this.setJsObj=function(jsObj)
    {
        this.jsOjb=jsObj;
    }
    //dataObj={} keyname 是dataObj一个属性
    this.setDataBindByJsObj=function(dataObj,keyname){
        Object.defineProperty(dataObj,keyname,{
            get:function(){
                if(that.jsObj.nodeName!=undefined)
                {
                    var nodename=that.jsObj.nodeName.toLocaleLowerCase();
                    if(nodename=='input')
                    {
                        if(that.jsObj.getAttribute("type")=='text'||that.jsObj.getAttribute("type")=='hidden')
                            return that.jsObj.value;
                        else if(that.jsObj.getAttribute("type")=='checkbox'|| that.jsObj.getAttribute("type")=='radio')
                            return that.jsObj.checked;

                    }
                    else if(nodename=='textarea')
                    {
                        return that.jsObj.value;
                    }
                    else{
                        return that.jsObj.innerHTML;
                    }
                        
                }
                else{
                    return '';
                }
                
            },
            set:function(newValue){
                // 给div的内容做一个赋值
                if(that.jsObj.nodeName!=undefined)
                {
                    var nodename=that.jsObj.nodeName.toLocaleLowerCase();
                    if(nodename=='input')
                    {
                        if(that.jsObj.getAttribute("type")=='text'||that.jsObj.getAttribute("type")=='hidden')
                            that.jsObj.value=newValue;
                        else if(that.jsObj.getAttribute("type")=='checkbox'|| that.jsObj.getAttribute("type")=='radio')
                            that.jsObj.checked=newValue;

                    }
                    else if(nodename=='textarea')
                    {
                        that.jsObj.value=newValue;
                    }
                    else{
                        that.jsObj.innerHTML=newValue;
                    }
                }
                else{
                    
                }
            }
        })
    }
    
    
    //通过jquery 对象绑定
    //dataObj={} keyname 是dataObj一个属性
    this.setDataBindByJqueryObj=function(dataObj,keyname){
        // 若 keyname 属性在 dataObj对象中不存在，则 Object.defineProperty 会创建一个 keyname 属性（该属性默认不可配置、不可枚举、不可写）
        // 故使用 dataObj[keyname]='' 进行属性创建，该属性可配置、可枚举、可写
        // 通过 typeof dataObj[keyname] === "undefined" 判断，避免二次绑定导致界面值被置空
        if(typeof dataObj[keyname] === "undefined")
            dataObj[keyname]=''

        if(that.istype=='')
        {
          
              
                if(that.jqueryobj.is("input"))
                {
                     that.istype='input'
                     that.type=that.jqueryobj.attr("type");
                }
                else if(that.jqueryobj.is("textarea"))
                {
                   that.istype='textarea'
                }
                else if(that.jqueryobj.is("select"))
                {
                   that.istype='select'
                }
                else{
                     that.istype='html'
                } 
                
        }
        Object.defineProperty(dataObj,keyname,{
            get:function(){

                if(that.istype=='input')
                {
                    if(that.type=='text'||that.type=='hidden'||that.type=='number')
                    {
                        return that.jqueryobj.val();
                    }
                    else if(that.type =='checkbox'|| that.type =='radio'){
                        return that.jqueryobj.prop("checked");
                    }

                }
                else if(that.istype=='textarea')
                {
                    return that.jqueryobj.val();
                }
                else if(that.istype=='select')
                {
                    //多选框
                    if(ld(that.jqueryobj).attr("multiple")!=undefined) {
                        return getMultiPickListSelectValueByObj(that.jqueryobj);
                    }else{
                        //单选框  zxm 20230613 单选之前没处理
                        return that.jqueryobj.val();
                    }
                }
                else{
                    return that.jqueryobj.html();
                }
            },
            set:function(newValue){


                  if(that.istype=='input')
               
                {
                    if(that.type=='text'||that.type=='hidden'||that.type=='number')
                        that.jqueryobj.val(newValue);
                    else if(that.type =='checkbox'|| that.type =='radio')
                        that.jqueryobj.prop("checked",newValue);
                   // console.log( that.jqueryobj)
                }
                else if(that.istype=='textarea')
                {
                    that.jqueryobj.val(newValue);
                }
                else if(that.istype=='select')
                {
                        
                       if(ld(that.jqueryobj).attr("multiple")!=undefined)
                       {
                        
                            var tmpvalue_arr=newValue.split(" |##| ");
                            //edit:can 63130 【合同订单】模块选择源单项目需求单，带不出来多选框字段，下推可以带出来（kfbcrm 也有问题 合同订单选择源单 报价单QUO2100） 
                            
                            that.jqueryobj.val(tmpvalue_arr);
                       }
                       else{
                            that.jqueryobj.val(newValue);
                       }
                }
                else{
                  
                    that.jqueryobj.html(newValue);
                }
            },
           // enumerable:true,
             //configurable:true
        })
    }

    /**
     * Jquery对象
     * @typedef JqueryObj
     */
    /**
     * @author      xll
     * @date        2023/09/21
     * @description 新的双向绑定方法，动态调用避免过多的if判断
     * @param {jQuery} JqueryObj 待绑定的 jQuery 对象
     * @param {Object} DataObj 数据对象
     * @param {string} KeyName 键值
     * @example
     * - ( new DataHtmlBind() ).setDataBindByJqObj(JqueryObj,DataObj,KeyName)
     */
    this.setDataBindByJqObj = function (JqueryObj,DataObj,KeyName){
        if(JqueryObj.length === 0){
            console.error(new Error('Binding failure \n the keyName is '+KeyName));
            return false;
        }
        // 若 KeyName 属性在 DataObj中不存在，则 Object.defineProperty 会创建一个 KeyName 属性（该属性默认不可配置、不可枚举、不可写）
        // 故使用 DataObj[KeyName]='' 进行属性创建，该属性可配置、可枚举、可写，即可使该属性既可以用赋值运算符赋值，也拥有 访问器描述符
        // 通过 DataObj dataObj[KeyName] === "undefined" 判断，避免二次绑定导致界面值被置空
        if(typeof DataObj[KeyName] === "undefined")
            DataObj[KeyName]=''
        var FunList = that.getBindFunList(JqueryObj);
        //根据对象中的值将界面初始化
        FunList.set(JqueryObj,DataObj[KeyName]);
        Object.defineProperty(DataObj,KeyName,{
            get:function () {
                return FunList.get(JqueryObj);
            },
            set:function (NewValue) {
                FunList.set(JqueryObj,NewValue);
            },
            //Object.defineProperty 创建的属性默认不可配置、不可枚举、不可写
            //此处设为可配置属性，否则无法重复使用 Object.defineProperty 进行配置
            // configurable: true,
            //此处设为可枚举属性，否则无法重复使用 JSON.stringfy 进行序列化
            // enumerable: true,
        });
    }
    
    this.getBindFunList = function (JqueryObj) {
        var JsObj = JqueryObj.get(0);
        var NodeName = JsObj.localName;
        var NodeType = '';
        if(that.getNodeTypeFunList['getNodeType_'+NodeName])
            NodeType = that.getNodeTypeFunList['getNodeType_'+NodeName](JsObj);
        var getValFun_Name = 'getVal_Default';
        var setValFun_Name = 'setVal_Default';
        if(that.getValFunList['getVal_'+NodeName+NodeType])
            getValFun_Name = 'getVal_'+NodeName+NodeType;
        if(that.setValFunList['setVal_'+NodeName+NodeType])
            setValFun_Name = 'setVal_'+NodeName+NodeType;
        return {
            get: that.getValFunList[getValFun_Name],
            set: that.setValFunList[setValFun_Name],
        };
    }

    /**
     * @type {object}
     * @description 获取节点类型方法的集合，用于区分不同类型的同类标签
     *
     * - input的类型: text，hidden，number，checkbox，radio
     * - select的类型: select-one，select-multiple
     */
    this.getNodeTypeFunList = {
        getNodeType_input : function (JsObj) {
            var ObjType = JsObj.type;
            return '_'+ObjType;
        },
        getNodeType_textarea : function (JsObj) {
            return '';
        },
        getNodeType_select : function (JsObj) {
            var ObjType = JsObj.type.split("-")[1];
            return '_'+ObjType;
        },
    }

    /**
     * @type {object}
     * @description 获取不同Dom元素值的方法集合，用于get()方法动态调用
     */
    this.getValFunList = {
        getVal_input_text : function (JqueryObj){
            return ld(JqueryObj).val();
        },
        getVal_input_hidden : function (JqueryObj){
            return ld(JqueryObj).val();
        },
        getVal_input_number : function (JqueryObj){
            return ld(JqueryObj).val();
        },
        getVal_input_checkbox : function (JqueryObj){
            return ld(JqueryObj).prop('checked');
        },
        getVal_input_radio : function (JqueryObj){
            return ld(JqueryObj).prop('checked');
        },
        getVal_textarea : function (JqueryObj){
            return ld(JqueryObj).val();
        },
        getVal_select_one : function (JqueryObj) {
            return ld(JqueryObj).val();
        },
        getVal_select_multiple : function (JqueryObj) {
            return getMultiPickListSelectValueByObj(JqueryObj);
        },
        getVal_Default : function (JqueryObj) {
            return ld(JqueryObj).html();
        },
    }

    /**
     * Edit: xll
     * Date: 2023/09/21
     * Description: 设置不同Dom元素值的方法集合，用于set()方法动态调用
     */
    this.setValFunList = {
        setVal_input_text : function (JqueryObj,Data){
            ld(JqueryObj).val(Data);
        },
        setVal_input_hidden : function (JqueryObj,Data){
            ld(JqueryObj).val(Data);
        },
        setVal_input_number : function (JqueryObj,Data){
            ld(JqueryObj).val(Data);
        },
        setVal_input_checkbox : function (JqueryObj,Data){
            if(Data === "0" || Data === "no")
                Data = false;
            ld(JqueryObj).prop('checked',Data);
        },
        setVal_input_radio : function (JqueryObj,Data){
            ld(JqueryObj).prop('checked',Data);
        },
        setVal_textarea : function (JqueryObj,Data){
            ld(JqueryObj).val(Data);
        },
        setVal_select_one : function (JqueryObj,Data) {
            if(Data === undefined || Data === '' || Data === null)
                ld(JqueryObj).prop('selectedIndex',0);
            else
                ld(JqueryObj).val(Data);
        },
        setVal_select_multiple : function (JqueryObj,Data) {
            var tmpvalue_arr = Data.split(" |##| ");
            ld(JqueryObj).val(tmpvalue_arr);
        },
        setVal_Default : function (JqueryObj,Data) {
            ld(JqueryObj).html(Data);
        },
    }

    /**
     * Edit: xll
     * Date: 2023/09/21
     * Description: 双向绑定时，自定义获取值和设置值的触发方法
     * Description: FunList为方法集合（Json Array）
     * Description: getVal_Fun 获取值触发的方法，仅一个参数JqueryObj
     * Description: setVal_Fun 设置值触发的方法，仅两个参数JqueryObj，NewValue
     */
    this.setDataBindByJqObj_FunList = function (JqueryObj,DataObj,KeyName,FunList={}){
        if(typeof DataObj[KeyName] === "undefined")
            DataObj[KeyName]=''
        var getValFun_Name = 'getVal_Fun';
        var setValFun_Name = 'setVal_Fun';
        if(!FunList[getValFun_Name] || !FunList[setValFun_Name]){
            console.log('bind error : Fun_List error');
            return false;
        }
        Object.defineProperty(DataObj,KeyName,{
            get:function () {
                return FunList[getValFun_Name](JqueryObj);
            },
            set:function (NewValue) {
                FunList[setValFun_Name](JqueryObj,NewValue);
            },
        });
    }

    /**
     * @author      xll
     * @date        2024/09/04
     * @description 使用 ES6 标准的 Proxy 对象实现双向绑定
     * @param {jQuery} JqueryObj 放置页签的DOM对象
     * @param {Object} DataObj 页签数组，含每个页签数据对象
     * @param {string} KeyName 配置项，非必须
     * @example
     * - ( new DataHtmlBind() ).setDataBindByJqObj(JqueryObj,DataObj,KeyName)
     */
    this.setDataBindByProxy = function () {
        
    }
}