function cls_fieldsensitiverule(blocklist,vuewobj)
{
  this.vueobj = vuewobj;//当前vue对象
  this.blocklist = blocklist;
  var that=this;

  this.senditivefieldname_arr = [];//敏感规则字段
  this.relatedfieldname_arr = this.vueobj.fieldSensitiverule;//会触发敏感规则

  this.init = function(){
    var vueobj = this.vueobj;
    this.blocklist = vueobj.listData.list;
    this.relatedfieldname_arr = vueobj.fieldSensitiverule;//会触发敏感规则
  }

  this.setEvent = function(){
    var relatedfieldname_arr = this.relatedfieldname_arr;
    if(this.blocklist.length > 0){
      $.each(blocklist,function(blockindex,blockinfo) {
        $.each(blockinfo.fieldinfo,function(tmpfieldindex,tmpfieldinfo){
          //被加密的字段
          if(tmpfieldinfo.sensitivepresence && tmpfieldinfo.sensitivepresence == 'yes' && tmpfieldinfo.havesensitivevalue == 'yes' && tmpfieldinfo.sensitiveencryptvalue != ''){
            var tmpobj=$("#"+tmpfieldinfo.fieldname);
            if(tmpobj.length > 0){
              tmpobj.bind('change',function() {
                that.fieldnamechangeFun(tmpfieldinfo.fieldname);
              });
            }
          }
          //触发敏感规则字段
          if(relatedfieldname_arr.length > 0 && relatedfieldname_arr.indexOf(tmpfieldinfo.fieldname) >= 0){
            var tmpobj=$("#"+tmpfieldinfo.fieldname);
            if(tmpobj.length > 0){
              tmpobj.bind('change',function() {
                that.getAllSensitiveData(tmpfieldinfo.fieldname);
              });
            }
          }
        })
      });
    }
  }

  //访问后台获取敏感规则
  this.fieldnamechangeFun = function (fieldname){
    var blocklist = this.vueobj.listData.list;
    for (let i = 0; i < blocklist.length; i++) {
      for (let j = 0; j < blocklist[i].fieldinfo.length; j++) {
        if(fieldname == blocklist[i].fieldinfo[j].fieldname){
          blocklist[i].fieldinfo[j].havesensitivevalue = 'no';
          blocklist[i].fieldinfo[j].sensitiveencryptvalue = '';
          break;
        }
      }
    }
  }

  this.getAllSensitiveData = function(fieldname){
    var listObj = that.vueobj.getviewlist();
    let sensitiverequestfield = [];//敏感规则 被加密字段
    var blocklist = that.vueobj.listData.list;
    for (var i = 0; i < blocklist.length; i++) {
      for (var j = 0; j < blocklist[i].fieldinfo.length; j++) {
        if(blocklist[i].fieldinfo[j].sensitivepresence && blocklist[i].fieldinfo[j].sensitivepresence == 'yes' && blocklist[i].fieldinfo[j].havesensitivevalue == 'yes' && blocklist[i].fieldinfo[j].sensitiveencryptvalue != ''){
          sensitiverequestfield.push('requestvalues-'+blocklist[i].fieldinfo[j].fieldname);
          listObj[blocklist[i].fieldinfo[j].fieldname] = blocklist[i].fieldinfo[j].sensitiveencryptvalue;
        }
      }
    }

    var params = {
      'module': 'Users',
      'action': 'getSensitiveFieldsDatabyRule',
      'fieldname':fieldname,
      'requestvalues':JSON.stringify(listObj),
      'record':that.vueobj.recordid,
      'modulename':that.vueobj.mainmodule
    }
    if(sensitiverequestfield.length > 0){
      params['sensitiverequestfield'] = JSON.stringify(sensitiverequestfield);
    }
    that.vueobj.mob_ajax(params, (rest) => {
      if(rest.code == 1){
        if(rest.result.sensitivedata && rest.result.sensitivedata.length > 0){
          var sensitivedata = rest.result.sensitivedata;
          for (var i = 0; i < blocklist.length; i++) {
            for (var j = 0; j < blocklist[i].fieldinfo.length; j++) {
              for(var k = 0;k<sensitivedata.length;k++){
                if(blocklist[i].fieldinfo[j].fieldname == sensitivedata[k].rawValue.input_name){
                  blocklist[i].fieldinfo[j].text = sensitivedata[k].rawValue.value;
                  blocklist[i].fieldinfo[j].sensitivepresence = 'yes';
                  blocklist[i].fieldinfo[j].havesensitivevalue = sensitivedata[k].rawValue.havesensitivevalue;
                  blocklist[i].fieldinfo[j].sensitiveencryptvalue = sensitivedata[k].rawValue.sensitiveencryptvalue;
                }
              }
            }
          }
        }
        //this.vueobj.$set('currencyInfo', currency);
      }
    });
  }

  //根据数组 获取敏感规则
  this.getAllSensitiveData_arr = function(fieldname_arr){
    var falg = 'no';
    for(let i = 0;i<fieldname_arr.length;i++){
      if(that.relatedfieldname_arr.indexOf(fieldname_arr[i]) >= 0){
        falg = 'yes';
        break ;
      }
    }

    if(falg == 'yes'){
      that.getAllSensitiveData('');
    }
  }


}
export default {
  cls_fieldsensitiverule
}
