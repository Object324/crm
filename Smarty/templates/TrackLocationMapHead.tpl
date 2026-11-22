<style>
    .track_position_changemap{
        display: flex;
        margin-right: 20px;
    }
    .track_position_changemap_left{
        width: 30px;
        height: 30px;
        border: 1px solid #DCDEE0;
        border-radius: 4px 0px 0px 4px;
        cursor: pointer;
    }
    .track_position_changemap_left_icon{
        width: 100%;
        height: 100%;
        background-image: url(./themes/icon/track_trajectory.png);
        background-size: 60% 60%;
        background-repeat: no-repeat;
        background-position: center center;
    }
    .track_position_changemap_right{
        width: 29px;
        height: 30px;
        border: 1px solid #DCDEE0;
        border-left: none;
        border-radius: 0px 4px 4px 0px;
        cursor: pointer;
    }
    .track_position_changemap_right_icon{
        width: 100%;
        height: 100%;
        background-image: url(./themes/icon/track_position.png);
        background-size: 60% 60%;
        background-repeat: no-repeat;
        background-position: center center;
    }
    .track_position_changemap_left.track_select,.track_position_changemap_right.track_select{
        background: rgba(59,124,255,0.1);
    }
    .track_position_changemap_left.track_select .track_position_changemap_left_icon{
        background-image: url(./themes/icon/track_trajectory_select.png);
        background-size: 60% 60%;
        background-repeat: no-repeat;
        background-position: center center;
    }
    .track_position_changemap_right.track_select .track_position_changemap_right_icon{
        background-image: url(./themes/icon/track_position_select.png);
        background-size: 60% 60%;
        background-repeat: no-repeat;
        background-position: center center;
    }
</style>

<script>
    var SmOwner_option_arr = [];
    TrackLocationMap.userid=0;
    {if isset($Merge_SmOwner_arr)}
    if(ld('#tracksearchscope').length > 0){
        var Merge_SmOwner = {$Merge_SmOwner_arr};
        var displayinactiv = '{$displayinactiv}';


        ld.each(Merge_SmOwner,function (index,userscopeinfo) {

            if(displayinactiv == 'no' && inactiveuser.indexOf(userscopeinfo['value']) >=0 ){

            }else{
                SmOwner_option_arr.push(userscopeinfo);
            }
            if(userscopeinfo['selected']){
                TrackLocationMap.userid = userscopeinfo['value'];
            }
        });
        //TrackLocationMap.userid=Merge_SmOwner[0]['value']

    }
    {/if}
    AjaxJSPage('ld_Select','include/js/component/ld_Select.js');

    var tracksearchscope_selectobj = ld_Select.showSelect(ld('#tracksearchscope').get(0), {
        list: SmOwner_option_arr,
        width: '180px',
        optionwidth: '180px',
        selecticonurl: 'themes/icon2024/searchscope.png',
        selecticonhoverurl: 'themes/icon2024/searchscope1.png',
        optionobjattr: ['value'],
        filterable: true,
        change: function (evt){
            console.log(evt);
            TrackLocationMap.userid=evt.NavBarItem.value
            TrackLocationMap.search();

        }
    });
</script>