Ext.define('Vmoss.view.header.AlterpwView', {
    extend:'Ext.window.Window',
    alias:'widget.alterpwwidget',

    closeAction: 'hide',
    title:"修改密码",
    resizable:false,
    modal:true,
    layout: 'fit',

    items:[
        Ext.create('Vmoss.view.header.AlterpwForm')
	]
});