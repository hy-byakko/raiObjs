Ext.define('Vmoss.view.main.button.GridView', {
    extend:'Ext.button.Button',

    text:'查看',
    iconCls:"icon-view",

    handler:function () {
        var selected = grid.getSelectionModel().getSelections();
        if (selected.length == 0) {
            Ext.MessageBox.show({
                title:'错误信息',
                msg:'请选择' + objName + '!',
                buttons:Ext.MessageBox.OK,
                icon:Ext.MessageBox.ERROR
            });
        } else if (selected.length > 1) {
            Ext.MessageBox.show({
                title:'错误信息',
                msg:'请选择一个' + objName + '进行查看!',
                buttons:Ext.MessageBox.OK,
                icon:Ext.MessageBox.ERROR
            });
        } else {
            grid.suspendEvents();
            window.location.href = '/bumons/' + selected[0].data.id;
        }
    },

// '查看'按钮构造
    initComponent:function () {
        this.tooltip = '查看选中的' + this.instanceLabel;
        this.callParent(arguments);
    }
});