Ext.define('Vmoss.view.main.ModelBench', {
    extend:'Vmoss.lib.CForm',

    layout:'column',
    frame:true,
    width:Ext.getDoc().dom.width * 0.9,
    bodyPadding:5,

    defaults:{
        labelAlign:'right',
        labelWidth:80,
        columnWidth: 1/3,
        padding: '2'
    },

    fieldDefaults:{
        xtype:'textfield',
        msgTarget:'side'
    }
});