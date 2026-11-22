function cls_AESencryptionbykey() {
  this.encryptykey = 'lingdang';
  var that = this;
  /*
   * 设置加密的key
   * */
  this.setencryptykey =function(secretkey)
  {
    this.encryptykey = secretkey;
  }
  /*
   * 获取数组加密结果
   * */
  this.getencryption_arr = function(encorypty_arr,keyarr)
  {
    if(keyarr&&keyarr.length>0){
      for(var i = 0 ; i<keyarr.length ; i++){
        var tmpkey = keyarr[i];
        var tmpitem = encorypty_arr[keyarr[i]];
        encorypty_arr[tmpkey] = that.getencryption(tmpitem);
      }
    }
    return encorypty_arr;
  }
  /*
   * 获取字符串加密结果
   * */
  this.getencryption = function(string)
  {
    var  secretkey = this.encryptykey;
    return this.getencryptionbykey(string,secretkey);
  }
  /*
   * 根据key获取字符串加密结果
   * */
  this.getencryptionbykey = function(string,secretkey)
  {
    return this.getLingdangencryptionbyoperation(string,secretkey,false);
  }

  /*
   * 获取数组解密结果
   * */
  this.getdecryption_arr = function(decorypty_arr,keyarr)
  {
    if(keyarr&&keyarr.length>0){
      for(var i = 0 ; i<keyarr.length ; i++){
        var tmpkey = keyarr[i];
        var tmpitem = decorypty_arr[keyarr[i]];
        decorypty_arr[tmpkey] = that.getencryption(tmpitem);
      }
    }
    return decorypty_arr;
  }
  /*
   * 获取字符串解密结果
   * */
  this.getdecryption = function(string)
  {
    var  secretkey = this.encryptykey;
    return this.getdecryptionbykey(string,secretkey);
  }
  /*
   * 根据key获取字符串解密结果
   * */
  this.getdecryptionbykey = function(string,secretkey)
  {
    return this.getLingdangencryptionbyoperation(string,secretkey,true);
  }

  /*
   * 加密/解密字符串
   * string:被加密/解密字符串; code:加密/解密的key; operation:操作类型 true解密,false加密
   * */
  this.getLingdangencryptionbyoperation = function(string,code,operation=false)
  {
    code = code.trim();
    code = CryptoJS.MD5(code).toString()
    var iv = CryptoJS.enc.Utf8.parse(code.substring(0, 16))
    var key = CryptoJS.enc.Utf8.parse(code.substring(16));
    var encryptstring = '';
    if (operation) {
      encryptstring =  CryptoJS.AES.decrypt(string, key, {
        iv: iv,
        padding: CryptoJS.pad.Pkcs7
      }).toString(CryptoJS.enc.Utf8)
    }
    else{
      encryptstring =  CryptoJS.AES.encrypt(string, key, {
        iv: iv,
        mode: CryptoJS.mode.CBC,
        padding: CryptoJS.pad.Pkcs7
      }).toString()
    }
    return encryptstring;
  }
}
/*
* zkt 20231109
* 根据传入操作,获取哦对应value加密/解密结果
* */
cls_AESencryptionbykey.Lingdang_Encryptyfieldvaluebyoperation = function(value,operation,fieldinfo){
  var cls_AESencryptionbykeyobj = new cls_AESencryptionbykey();
  var returnvalue = '';
  if(operation){
    //获取解密结果
    returnvalue = cls_AESencryptionbykeyobj.getdecryption(value);
  }
  else{
    //获取加密结果
    returnvalue = cls_AESencryptionbykeyobj.getencryption(value);
  }
  return returnvalue;
}



cls_AESencryptionbykey.Lingdang_Dncryptyvaluearrbyoperation = function(value_arr,operation,key_arr){
    var cls_AESencryptionbykeyobj = new cls_AESencryptionbykey();
    var returnvalue = '';
    var tmp_value_arr = JSON.parse(JSON.stringify(value_arr));
    if(operation){
        //获取解密结果
        tmp_value_arr = cls_AESencryptionbykeyobj.getdecryption_arr(tmp_value_arr,key_arr);
    }
    else{
        //获取加密结果
        tmp_value_arr = cls_AESencryptionbykeyobj.getencryption_arr(tmp_value_arr,key_arr);
    }
    return tmp_value_arr;
}
