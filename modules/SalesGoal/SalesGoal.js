function checkfrom()
{
    var viewrangeone_year= document.getElementById('viewrangeone_year').value;
    var viewrangeone_month= document.getElementById('viewrangeone_month').value;
    var viewrangetwo_year= document.getElementById('viewrangetwo_year').value;
    var viewrangetwo_month= document.getElementById('viewrangetwo_month').value;
    if(eval(viewrangeone_year) == eval(viewrangetwo_year))
    {
        if(eval(viewrangeone_month) > eval(viewrangetwo_month))
        {
            alert(arrJsPopLabel['TOBESURESTRARTNEQEND']);
            return false;
        }
    }
    else
    {
        if(viewrangeone_year > viewrangetwo_year)
        {
            alert(arrJsPopLabel['THESTARTTIME']);
            return false;
        }
    }
}
 