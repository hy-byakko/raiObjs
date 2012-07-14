Ext.define('Vmoss.view.header.View', {
    extend:'Vmoss.lib.CPanel',
    alias:'widget.headerview',

    region:"north",
    height:55,
    cls:'loginbgimage',
    baseCls:'my-panel-no-border',

    initComponent:function () {
        Vmoss.tool.Base.log('Header running.');

        Ext.applyIf(this, {
            html:"<img src='/images/New_toplogo.png'>",
            dockedItems:[
                Ext.create('Vmoss.view.header.User')
            ]
        });

        this.callParent(arguments);
    }
});