Ext.define('Vmoss.view.menu.Tree', {
    extend: 'Ext.tree.Panel',

    initComponent: function(options) {
        Ext.apply(this, {
            autoScroll:true,
            width:120,
            frame:false,
            border:false,
            containerScroll:true,
            rootVisible:false
        });

        this.callParent(arguments);
    }
});