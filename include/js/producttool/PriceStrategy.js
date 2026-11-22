//价格策略
function PriceStrategy()
{
    var that=this;

    that.popupobj=CrmPopup.getPopupObj('last');

    this.lengthDecimaldigits=ld("#"+that.popupobj.divid+" [name=lengthdecimaldigits]").val();//document.getElementById('lengthdecimaldigits').value;//数量小数位数
    this.lengthPrice=ld("#"+that.popupobj.divid+" [name=lengthprice]").val();//document.getElementById('lengthprice').value;//单价小数位数
    this.lengthDecimaldigits=parseInt(eval(this.lengthDecimaldigits),10);
    this.lengthPrice=parseInt(eval(this.lengthPrice),10);
    //所有行的计算
    this.startallrowcomputer=function()
    {

    }
    this.modulehaveprice=function(module)
    {
        if(module=='SalesOrder'||module=='Quotes'||module=='ServiceContracts')
        {
            return 'yes';
        }
        else
        {
            return 'no';

        }
    }
    /*
    获取数量在固定基数中的价税合计
    tax_amount:价税合计字段
    */
    this.getbasetax_amount=function(quantity,productid)
    {

        var productstrategyobj=that.popupobj.productstrategyobj;

        var strategyinfo=productstrategyobj.info[productid];


        var money=0;
        quantity=parseFloat(eval(quantity),10).toFixed(this.lengthDecimaldigits);
        var tmpindex=-1;
        var mimumquantity=9999999999;
        var isaddmoney='no';

        ld.each(strategyinfo,function(index,tmpstragtegyinfo){
            var count_to=tmpstragtegyinfo.count_to;
            if(parseInt(tmpstragtegyinfo.type)!=1)
            {
                return false;
            }
            if(Math.abs(count_to-quantity)<mimumquantity)
            {
                //考虑断数
                mimumquantity=Math.abs(count_to-quantity);
                tmpindex=index;
            }



            if(that.compare(quantity,tmpstragtegyinfo.count_from)=='yes'&&that.compare(tmpstragtegyinfo.count_to,quantity)=='yes')
            {

                isaddmoney='yes';
                money=tmpstragtegyinfo.money;

                return false;
            }
        });


        if(tmpindex>=0&&isaddmoney=='no')
        {
            return strategyinfo[tmpindex+1].money;
        }

        return money;

    }
    /*
    获取数量在固定基数+固定增量的价税合计
    tax_amount:价税合计字段
    */
    this.getfixedincrementtax_amount=function(quantity,productid)
    {
        var productstrategyobj=that.popupobj.productstrategyobj;
        //quantity=parseFloat(eval(quantity),10).toFixed(this.lengthDecimaldigits);
        var maxfixedbase=this.getmaxFixedBasebyProductid(productid);
        if(maxfixedbase==null||maxfixedbase==undefined)
        {
            //获取最大基数
            maxfixedbase=0;


        }
        var strategyinfo=productstrategyobj.info[productid];
        var arrlength=strategyinfo.length;

        var maxfixedbasemoney=strategyinfo[arrlength-2].money;
        maxfixedbasemoney = parseFloat(eval(maxfixedbasemoney),10).toFixed(this.lengthPrice+1);
        var incrementment=strategyinfo[arrlength-1].count_to;
        var minquantity=quantity-maxfixedbase;//和最大基数的差

        var incrementmentstep=minquantity/incrementment;//步长
        //    var incrementmentstepmod=minquantity/incrementment;// 步长余数
        //固定基数的总金额=固定基数最大总金额+（数量-最大固定基数数量）*固定增量总金额



        var money=parseFloat((minquantity)*strategyinfo[arrlength-1].money)+parseFloat(maxfixedbasemoney);


        return money;
    }
    /*
    阶梯增量
    */
    this.getstepincrementtax_amount=function(quantity,productid)
    {

        var productstrategyobj=this.popupobj.productstrategyobj;

        quantity=parseFloat(eval(quantity),10).toFixed(this.lengthDecimaldigits);

        var maxfixedbase=this.getmaxFixedBasebyProductid(productid);
        if(maxfixedbase==null||maxfixedbase==undefined)
        {
            //获取最大基数
            maxfixedbase=0;


        }
        var strategyinfo=productstrategyobj.info[productid];
        var arrlength=strategyinfo.length;
        var maxincrementquantity=strategyinfo[arrlength-1].count_to;


        if(this.compare(maxincrementquantity,quantity)!='yes')
        {

            quantity=maxincrementquantity;
        }

        // var minquantity=quantity-maxfixedbase;//和最大基数的差
        var tmpmoney=0;
        var startaddmoney='no';//阶梯增量金额累计
        var mimumquantity=9999999999;

        var startloopindex=0;


        //判断阶梯增量是否有断数
        for(var i=arrlength-1;i>=0;i--)
        {
            var count_to=strategyinfo[i].count_to;
            var count_from=strategyinfo[i].count_from;
            var type=strategyinfo[i].type;

            if(type<3)
            {
                break;
            }
            if(Math.abs(count_to-quantity)<mimumquantity)
            {
                //考虑断数
                mimumquantity=Math.abs(count_to-quantity+1);

                startloopindex=i;//阶梯增量的断数按照上一行
            }

            if(that.compare(quantity,count_from)=='yes'&&that.compare(count_to,quantity)=='yes')

            {

                startloopindex=i;
                startaddmoney='yes';
                break;
            }
        }


        for(var i=startloopindex;i>=0;i--)
        {
            var count_to=strategyinfo[i].count_to;
            var count_from=strategyinfo[i].count_from;
            var type=strategyinfo[i].type;

            if(type<3)
            {
                break;
            }

            if(i<startloopindex)
            {
                tmpmoney+=parseFloat((count_to-count_from+1)*strategyinfo[i].money);
            }
            else
            {

                tmpmoney+=parseFloat((quantity-count_from+1)*strategyinfo[i].money);
            }
        }


        //strategyinfo[i].money最大基数金额
        var money=parseFloat(strategyinfo[i].money)+parseFloat(tmpmoney);
        return money;
    }
    this.getmaxFixedBasebyProductid=function(productid)
    {
        var productstrategyobj=that.popupobj.productstrategyobj;
        for(var i=0;i<productstrategyobj.maxfixedbase.length;i++)
        {

            if(productstrategyobj.maxfixedbase[i].productid==productid)
            {

                return productstrategyobj.maxfixedbase[i].count_to;
            }
        }
    }
    /*
    one>=two,返回'yes'
    */
    this.compare=function(one,two)
    {

        if(parseInt(one)>parseInt(two))
        {
            return 'yes';
        }
        else if(parseInt(one)<parseInt(two))
        {
            return 'no';

        }
        if(one.indexOf(".")>0)
        {
            var one_b = one.split(".");
            var one_c=two.split('.');
            if(one_b>=one_c)
            {
                return 'yes';
            }
            else
            {
                return 'no';

            }

        }
        return 'yes';
    }
    //
    this.startcomputer=function(rowindex)
    {
        var tableobj=that.popupobj.getDetailTableObj();
        var rowobj=ld(tableobj).find("tr[rowindex="+rowindex+"]");

        var productstrategyobj=that.popupobj.productstrategyobj;
        /*var isdel=ld("#"+that.popupobj.divid+" [name=hidden_rowid_"+rowindex+"]").val();
        //目前的行删除，直接删除了
        if(isdel==1)
        {//改行被删除
            return ;
        }*/

        var productid= ld(rowobj).find(" [name=hdnProductId]").val(); //productstrategyobj[]
        if(productid==""||productid<=0)
        {
            return false;
        }


        //变量productstrategyobj:在inventoryEditView.tpl和inventoryCreateView.tpl
        var havepricestrategy='no';

        if(ld.inArray(productid,productstrategyobj.productids)>=0)
        {
            havepricestrategy='yes';

        }


        if(havepricestrategy=='no')
        {
            //没有价格策略
            return false;
        }


        var quantity=ld(rowobj).find(" [name=quantity]").val();
        var  quantity=parseFloat(quantity).toFixed(this.lengthDecimaldigits);

        var maxfixedbase=this.getmaxFixedBasebyProductid(productid);

        if(maxfixedbase==null||maxfixedbase==undefined)
        {
            //获取最大基数
            maxfixedbase=0;
        }
        maxfixedbase=parseFloat(maxfixedbase).toFixed(this.lengthDecimaldigits);
        var strategyinfo=productstrategyobj.info[productid];

        var minfixedbase=strategyinfo[0].count_from;

        if(this.compare(minfixedbase,quantity)=='yes'&&minfixedbase!=quantity)//小于最小固定的基数
        {
            //var money= strategyinfo[0].money;

            var money= 0;
        }
        else if(this.compare(maxfixedbase,quantity)=='yes')//大约
        {


            var money= this.getbasetax_amount(quantity,productid);


        }
        else
        {


            var arrlenth=productstrategyobj.info[productid].length;
            var lasttype=productstrategyobj.info[productid][arrlenth-1].type;


            if(lasttype==3)//阶梯增量
            {

                var money= that.getstepincrementtax_amount(quantity,productid);
            }
            else if(lasttype==2)//固定增量
            {

                var money= this.getfixedincrementtax_amount(quantity,productid);

            }
            else
            {
                var money=productstrategyobj.info[productid][arrlenth-1].money;
            }
        }

        ld(rowobj).find(" [name=tax_amount]").val(money);
        ld(rowobj).find(" [name=span_tax_amount]").text(money);

        that.popupobj.fieldformulaobj.changedatabyColumnname("tax_amount",rowindex);//调用字段公式


    }
}