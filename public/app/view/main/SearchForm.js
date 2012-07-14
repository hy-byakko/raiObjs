Ext.define('Vmoss.view.main.SearchForm', {
    extend:'Vmoss.lib.CForm',

    layout:'column',
    frame:true,

    defaults:{
        labelAlign:'right',
        labelWidth:80,
        columnWidth: .33
    },

    feature: 'search'
});