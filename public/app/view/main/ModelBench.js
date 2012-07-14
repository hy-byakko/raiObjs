Ext.define('Vmoss.view.main.ModelBench', {
    extend:'Vmoss.lib.CForm',

    frame:true,
    layout:"form",
    width:300,
    bodyPadding:5,

    fieldDefaults:{
        xtype:'textfield',
        msgTarget:'side',
        autoFitErrors:false
    }
});