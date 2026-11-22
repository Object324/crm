function DataHtmlBind_Seq()
{
    var that=this;
    var SeqList = [];
    var SeqObj;
    var SeqListObj;

    this.SetSeqObj = function (JqueryObj) {
        that.SeqObj = ld(JqueryObj);
        that.SeqListObj = ld(JqueryObj).parent();
    }

    this.SetDataObj = function (DataObj) {
        that.DataObj = DataObj;
        DataObj[Symbol.iterator] = function () {
            return {
                this
            }
        }
    }

    this.GetSeqList = function () {
        var SeqListObj = that.SeqListObj;
    }

    /**
     * Edit: xll
     * Date: 2023/08/31
     * Description: 双向绑定时，自定义获取值和设置值的触发方法
     * Description: FunList为方法集合（Json Array）
     * Description: getVal_Fun 获取值触发的方法，仅一个参数JqueryObj
     * Description: setVal_Fun 设置值触发的方法，仅两个参数JqueryObj，NewValue
     */
    this.SetDataBindByJqObj_FunList = function (JqueryObj,DataObj,KeyName,FunList={}){
        DataObj[KeyName] = '';
        that.JqueryObjList[KeyName] = JqueryObj;
        var getValFun_Name = 'getVal_Fun';
        var setValFun_Name = 'setVal_Fun';
        if(!FunList[getValFun_Name] || !FunList[setValFun_Name]){
            console.log('bind error : Fun_List error');
            return false;
        }
        Object.defineProperty(DataObj,KeyName,{
            get:function () {
                return FunList[getValFun_Name](that.JqueryObjList[KeyName]);
            },
            set:function (NewValue) {
                FunList[setValFun_Name](that.JqueryObjList[KeyName],NewValue);
            }
        });
    }

    /**
     * Edit: xll
     * Date: 2023/09/08
     * Description: 设计自定义的set、get方法实现顺序的双向绑定
     */
    this.SetSeqBindByJqObj = function (JqueryObj,DataObj,KeyName) {
        that.setDataBindByJqObj_FunList(JqueryObj,DataObj,KeyName,that.SetSeqBind_FunList);
    }

    /**
     * Edit: xll
     * Date: 2023/09/08
     * Description: 设计自定义的set、get方法实现顺序的双向绑定
     */
    this.SetSeqBind_FunList = {
        getVal_Fun: function(JqueryObj) {
            return ld(JqueryObj).index();
        },
        setVal_Fun: function(JqueryObj, NewValue) {
            var newIndex = parseInt(NewValue) - 1;
            var parentObj = ld(JqueryObj).parent();
            ld(JqueryObj).remove();
            var dir_obj = parentObj.find('li:eq(' + newIndex + ')');
            dir_obj.before(JqueryObj);
        },
    }
}