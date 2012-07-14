Ext.define('Vmoss.tool.Request', {
    extend: 'Ext.data.Connection',
    alias: 'widget.request',
    initComponent: function(options) {
        options = options || {}
        this.callParent(arguments);
    }
})