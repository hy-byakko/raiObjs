Ext.define('Vmoss.lib.CPanel', {
    requires: ['Vmoss.tool.Base'],
    extend:'Ext.panel.Panel',

    constructor:function (config) {
        Vmoss.tool.Base.log('CPanel running.');
        this.callParent(arguments);
    }

//    statics:{
//        method:function () {
//        }
//    }
});