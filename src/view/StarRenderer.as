 package view {
    import flash.events.MouseEvent;
    
    import mx.controls.CheckBox;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.controls.listClasses.IListItemRenderer;
    import mx.core.UIComponent;



    public class StarRenderer extends UIComponent implements IListItemRenderer{
		[Embed(source='../icons/star.png')] 
		protected var imgStar:Class 

        public var checkBox:CheckBox;
    
        private var columnData:Object;
        
        private var dataField:String;
    
        public function get data():Object{
            return columnData;
        }
        
        public function set data(value:Object):void{
            columnData = value;
        }
        
        protected override function createChildren():void {
            super.createChildren();
            
            if (checkBox == null){
            	
                checkBox = new CheckBox();
                
                addChild(checkBox);
                checkBox.addEventListener(MouseEvent.CLICK, clickCheckBox, false, 0, true);
            }
            var column:DataGridColumn = styleName as DataGridColumn;
            dataField = column.dataField;
        }
        
        protected override function commitProperties():void{
            super.commitProperties();
            trace("commitProperties:" + columnData[ dataField ]);
            if (columnData != null){
                checkBox.selected = columnData[ dataField ];
                if (checkBox.selected) {
                	checkBox.setStyle('icon', imgStar);
                } else {
                	checkBox.setStyle('icon', null);
                }
            }
        }

        protected override function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void{
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            checkBox.selected = columnData[ dataField ];
        }
        
        private function clickCheckBox(event:MouseEvent):void{
            columnData[ dataField ] = checkBox.selected; 
            if (checkBox.selected) {
            	checkBox.setStyle('icon', imgStar);
            } else {
            	checkBox.setStyle('icon', null);
            }
        }
    }
}

