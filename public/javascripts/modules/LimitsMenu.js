/*

BLACKLIGHT.LimitsMenu extends the Ext.Panel class using the pattern found at
http://extjs.com/learn/Manual:Component:Extending_Ext_Components

*/

BLACKLIGHT.LimitsMenu = Ext.extend(Ext.Panel, {
       
    // public properties
	panelClone:{},
	expanded:false,
	moreLoaded:false,
	moreLoading:false,
	// override initialConfig;
	initComponent:function() {
	    // override Ext.Panel defaults        
	    Ext.apply(this, {
		    renderTo: this.renderTo || BLACKLIGHT.app.limitsMenusContainer,
		    title: this.titleContents,
		    html: this.bodyContents,
		    collapsible: true,
		    /* collapsed: (typeof this.originator != 'undefined' ? false : true), */
		    titleCollapse: false,
		    overCls: 'hover',
		    frame: true
		});
	    // call parent
	    BLACKLIGHT.LimitsMenu.superclass.initComponent.apply(this);
	}

	,
	// extend onRender
	onRender:function() {

		// call parent
		BLACKLIGHT.LimitsMenu.superclass.onRender.apply(this, arguments);
		
		// condition to prevent recursion
		if(typeof this.originator == 'undefined') {
		
		    $(this.getEl().dom).wrap('<div class="limitsMenu"></div>');
						
			// capture a reference to the original panel object for use in closures
			var that = this; 
			
			// only clone after expanding
			this.on('expand',function(e){
						
				that.panelClone = that.cloneConfig({
					originator: that, // originator is a reference to the original Ext.Panel object
					floating: true, // makes it absolutely positioned with a shadow
					renderTo: that.getEl().dom.parentNode // the div.box position:relative
				});

				that.panelClone.on('beforeCollapse',function(e){
					if(that.expanded) {
						that.shrinkAndCollapse();
					} else {
						that.panelClone.hide();
						that.collapse();
					}
					return false; // cancel the event
				});
				
				
				//$('a.moreLink',that.panelClone.getEl().dom).click(function(e){
				//	if(that.expanded) {
				//		that.shrink();
				//	} else {
				//		that.grow();
				//	}
				//	e.preventDefault();			
				//});
				
				
				// Ext.select('.x-panel-mc',false,that.panelClone.getEl().dom).first().setHeight(
				// 					Ext.select('.x-panel-mc',false,that.panelClone.getEl().dom).first().dom.scrollHeight	
				// 				);

				// branch and don't execute the above code after the self executing function runs it once
				return function(){

					//var contentElForHeightJQ = $('.x-panel-mc',that.panelClone.getEl().dom);
					that.clonePanelMcElX = Ext.select('.x-panel-mc',false,that.panelClone.getEl().dom).first();
					that.clonePanelMcElJQ = $(that.clonePanelMcElX.dom);
					that.panelMcElX = Ext.select('.x-panel-mc',false,that.getEl().dom).first();
					that.panelMcElJQ = $(that.panelMcElX.dom);
			
					
					that.shrunkBodyH = that.panelMcElX.getHeight(true);
					that.shrunkBodyW = that.panelMcElX.getWidth(true);
					
					that.menuColW = that.shrunkBodyW;
					Ext.util.CSS.createStyleSheet('#availableFilters .ajaxLimitsList ul.limitsList { width: '+that.menuColW+'px;}')
					
					that.panelClone.setWidth('100%');
					that.clonePanelMcElJQ.height(that.shrunkBodyH);
					//that.panelClone.getEl().shadow.setZIndex(that.baseZIndex+999);
					//that.panelClone.getEl().setStyle('z-index',that.baseZIndex+1000);
					that.panelClone.setPosition(0,0);
					that.panelClone.show();
					

					$('body').click(function(e){
						var isInPanel = false;
						$(e.target).parents().each(function(){
							if(this.id == that.panelClone.id){
								isInPanel = true;
							}
						});
						if(!isInPanel && that.expanded) that.shrink();
					});
				} // end return
			}()); // end self-executing function and .on() method
		} // end if
	},

    // other added/overrided methods

	animateGrow : function() {
		var that = this;
		var el = this.panelClone.getEl();
		
		
		el.setWidth(that.grownWidth,{ // width:500 and height:230 just placeholders for now
			duration:.5,
			easing: 'linear'
		});
		$('.x-panel-mc',el.dom).animate(
			{ 'height': that.grownHeight},
			500,
			'swing',
			function(){
				el.shadow.show(el);
				that.expanded = true;
				$('a.moreLink',el.dom).html('<< less');
			}
		);
	},
	grow : function() {		
		var that = this;
		var el = this.panelClone.getEl();
		// el.shadow.setZIndex(that.baseZIndex+2);
		// el.setStyle('z-index',that.baseZIndex+3);
		if(!that.moreLoading) {
			if(that.moreLoaded) {
				that.limitsListExtraElsJQ.show();
				that.animateGrow();
			} else {
				that.loadMoreContent();
			}			
		}
	},
	shrink : function() {
		var that = this;
		var callback = typeof arguments[0] == 'function' ? arguments[0] : false;
		var el = this.panelClone.getEl();
		/*
		TODO :
		hide and set to display:none all limits list items except for the first 5
		*/
		// el.shadow.setZIndex(that.baseZIndex);
		// el.setStyle('z-index',that.baseZIndex+1);
		//$('div[class!=col1],div[class=col1] li:gt('+(itemsBeforeGrow-1)+')]',el.dom).hide();
		that.limitsListExtraElsJQ = $('ul:not(ul.col1),ul.col1 li:gt('+(that.itemsBeforeGrow-1)+')',el.dom);
		
		
		el.setWidth(this.getSize()['width'],{
			duration:.5,
			easing: 'linear'
		});
		$('.x-panel-mc',el.dom).animate(
			{ height: Ext.select('.x-panel-mc',false,this.getEl().dom).first().getHeight(true)
			},500,
			'swing',
			function(){
				el.shadow.show(el);
				that.expanded = false;
				that.limitsListExtraElsJQ.hide();
				$('a.moreLink',el.dom).html('more >>');
				
				if(callback) callback();
			});
		
	},
	shrinkAndCollapse : function() {
		var that = this;
		this.shrink(function(){
			that.panelClone.hide();
			that.collapse();
		});
	},
	loadMoreContent : function() {
		var that = this;
		var el = this.panelClone.getEl();

		that.moreLoading = true;
		var listElJQ = $('ul.limitsList',el.dom);
		
		var ajaxLoadEl = that.panelClone.body.createChild({
			tag: 'div',
			cls: 'ajaxLimitsList'
		});
		
		listElJQ.css({position: 'absolute',left:'-1000em'});
		var listEl = listElJQ.get(0);

		Ext.get(ajaxLoadEl).load({
			url: that.moreLink,
			text: 'Getting more limits...',
			callback: function(el,success,response) {				
				/*
				width = number of columns * width of columns
				*/
				if(success) {
					that.moreLoading = false;
					that.moreLoaded = true;
					var numCols = $('ul.limitsList',ajaxLoadEl.dom).length;
					that.grownWidth = (that.menuColW * numCols)+that.panelClone.getFrameWidth()+24;

					ajaxLoadEl.setWidth(that.grownWidth-that.panelClone.getFrameWidth());
					that.grownHeight = ajaxLoadEl.getHeight(true);
					that.animateGrow();
				} else {
					/* failure!!! */
					/*
						TODO handle failure to load limits menus 
					*/
				}

			}
		});
 
	}

});

// register xtype
Ext.reg('limitsMenu', BLACKLIGHT);