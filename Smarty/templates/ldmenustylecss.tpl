<style>
    .ding,.logo{
        background:{$MENUSTYLEINFO.Menuback_color};
    }
    .nav-menu{
        background:{$MENUSTYLEINFO.Menuback_color};
    }
    .page-link.selected,.page-link:hover{
        background-color: {$MENUSTYLEINFO.Menuhover_color};
    }
    .el-menu-item.is-active.page-link{
        background-color: {$MENUSTYLEINFO.Menuhover_color};
    }
    .page-link a,.el-menu-item.page-link span {
        color:{$MENUSTYLEINFO.Menufont_color};
    }
    .page-link.selected a,.page-link:hover a {
        color: {if $MENUSTYLEINFO.Menufont_color == '#FFFFFF'}#FFFFFF{else}#3B7CFF{/if};
    }
    .ld-bg-color{
        background:{$MENUSTYLEINFO.Background_color};
    }
    /*.user-left-td{
        box-shadow: 10px 0px 0px 0px {$MENUSTYLEINFO.Background_color};
    }*/
    {if $popupbuttontype == 1}
        .E_pbtn{
            text-align: right !important;
        }
        .ld-E-pbtn-bg{
            text-align: right !important;
        }
    {/if}
</style>