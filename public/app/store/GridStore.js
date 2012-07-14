Ext.define('Vmoss.store.GridStore', {
    extend: 'Ext.data.Store',
    model: 'Vmoss.model.GridModel',
    
    //autoLoad: true,
    proxy: {
        type: 'ajax',
        url : '/bumons.ext_json'
	}
});